package com.moa.dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.SalesRecord;

public class SalesDAO {

    public void insert(int storeId, int totalAmount, int cardAmount, int cashAmount) throws SQLException {
        insert(storeId, totalAmount, cardAmount, cashAmount, null, 0, 0, 0);
    }

    public void insert(int storeId, int totalAmount, int cardAmount, int cashAmount, String receiptImage) throws SQLException {
        insert(storeId, totalAmount, cardAmount, cashAmount, receiptImage, 0, 0, 0);
    }

    // 카드/현금 말고 주류매출/수수료/기타지출까지 세분화해서 저장해요.
    // 혹시 add_sales_categories.sql / add_receipt_image_column.sql을 아직 안 돌리셨어도 저장 자체는
    // 깨지지 않도록, 새 컬럼이 없으면 옛날 방식(5개 컬럼)으로 재시도해요.
    public void insert(int storeId, int totalAmount, int cardAmount, int cashAmount, String receiptImage,
                        int liquorAmount, int feeAmount, int otherExpense) throws SQLException {
        String sql = "INSERT INTO sales_records (store_id, sales_date, total_amount, card_amount, cash_amount, " +
                     "receipt_image, liquor_amount, fee_amount, other_expense) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setDate(2, java.sql.Date.valueOf(LocalDate.now()));
            ps.setInt(3, totalAmount);
            ps.setInt(4, cardAmount);
            ps.setInt(5, cashAmount);
            if (receiptImage != null) ps.setString(6, receiptImage); else ps.setNull(6, Types.VARCHAR);
            ps.setInt(7, liquorAmount);
            ps.setInt(8, feeAmount);
            ps.setInt(9, otherExpense);
            ps.executeUpdate();
        } catch (SQLSyntaxErrorException e) {
            // 새 컬럼(주류/수수료/기타 또는 영수증이미지)이 아직 없는 DB - 예전 방식으로 재시도
            String fallbackSql = "INSERT INTO sales_records (store_id, sales_date, total_amount, card_amount, cash_amount) VALUES (?, ?, ?, ?, ?)";
            try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setInt(1, storeId);
                ps.setDate(2, java.sql.Date.valueOf(LocalDate.now()));
                ps.setInt(3, totalAmount);
                ps.setInt(4, cardAmount);
                ps.setInt(5, cashAmount);
                ps.executeUpdate();
            }
        }
    }

    public List<SalesRecord> listByStore(int storeId) throws SQLException {
        List<SalesRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM sales_records WHERE store_id = ? ORDER BY sales_date DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int sumByStore(int storeId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount),0) FROM sales_records WHERE store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // 전체 매장 매출 순위 (매출 등록한 매장만 나와요)
    public List<Object[]> rankStores() throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT s.store_name, SUM(r.total_amount) AS total FROM sales_records r " +
                     "JOIN stores s ON r.store_id = s.store_id " +
                     "GROUP BY s.store_id, s.store_name ORDER BY total DESC LIMIT 20";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Object[]{ rs.getString("store_name"), rs.getInt("total") });
            }
        }
        return list;
    }

    // 월별 매출 집계. 결과: [ 월, 총액, 카드, 현금, 주류, 수수료, 기타지출 ]
    public List<Object[]> monthlyByStore(int storeId, int months) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(sales_date, '%Y-%m') AS ym, SUM(total_amount) AS total, " +
                     "SUM(card_amount) AS card, SUM(cash_amount) AS cash, " +
                     "SUM(liquor_amount) AS liquor, SUM(fee_amount) AS fee, SUM(other_expense) AS other " +
                     "FROM sales_records WHERE store_id = ? " +
                     "AND sales_date >= DATE_SUB(CURDATE(), INTERVAL ? MONTH) " +
                     "GROUP BY ym ORDER BY ym ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setInt(2, months);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{ rs.getString("ym"), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash"),
                            rs.getInt("liquor"), rs.getInt("fee"), rs.getInt("other") });
                }
            }
            return list;
        } catch (SQLSyntaxErrorException e) {
            return monthlyByStoreFallback(storeId, months);
        }
    }

    // 주류/수수료/기타 컬럼이 아직 없는 DB용 - 나머지 3개는 0으로 채워서 형태를 맞춰줘요.
    private List<Object[]> monthlyByStoreFallback(int storeId, int months) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(sales_date, '%Y-%m') AS ym, SUM(total_amount) AS total, " +
                     "SUM(card_amount) AS card, SUM(cash_amount) AS cash " +
                     "FROM sales_records WHERE store_id = ? " +
                     "AND sales_date >= DATE_SUB(CURDATE(), INTERVAL ? MONTH) " +
                     "GROUP BY ym ORDER BY ym ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setInt(2, months);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{ rs.getString("ym"), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash"), 0, 0, 0 });
                }
            }
        }
        return list;
    }

    // 연도별 매출 집계. 결과: [ 연도, 총액, 카드, 현금, 주류, 수수료, 기타지출 ]
    public List<Object[]> yearlyByStore(int storeId) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT YEAR(sales_date) AS yy, SUM(total_amount) AS total, " +
                     "SUM(card_amount) AS card, SUM(cash_amount) AS cash, " +
                     "SUM(liquor_amount) AS liquor, SUM(fee_amount) AS fee, SUM(other_expense) AS other " +
                     "FROM sales_records WHERE store_id = ? GROUP BY yy ORDER BY yy ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{ String.valueOf(rs.getInt("yy")), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash"),
                            rs.getInt("liquor"), rs.getInt("fee"), rs.getInt("other") });
                }
            }
            return list;
        } catch (SQLSyntaxErrorException e) {
            List<Object[]> fallback = new ArrayList<>();
            String fsql = "SELECT YEAR(sales_date) AS yy, SUM(total_amount) AS total, SUM(card_amount) AS card, SUM(cash_amount) AS cash " +
                          "FROM sales_records WHERE store_id = ? GROUP BY yy ORDER BY yy ASC";
            try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(fsql)) {
                ps.setInt(1, storeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        fallback.add(new Object[]{ String.valueOf(rs.getInt("yy")), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash"), 0, 0, 0 });
                    }
                }
            }
            return fallback;
        }
    }

    // 전월 대비 이번달 증감률 계산용
    public int sumByMonth(int storeId, String yearMonth) throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount),0) FROM sales_records " +
                     "WHERE store_id = ? AND DATE_FORMAT(sales_date, '%Y-%m') = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, yearMonth);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // 회원 삭제 시 트랜잭션으로 같이 지우기 위한 메소드 - 외부에서 만든 Connection을 그대로 써요.
    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM sales_records WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }

    // 관리자 파일 관리 화면용 - 영수증 이미지가 첨부된 전체 매출기록을 매장명과 함께 최신순으로.
    public List<Object[]> listAllWithReceiptImages() throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT r.sales_id, r.sales_date, r.total_amount, r.receipt_image, s.store_name " +
                     "FROM sales_records r JOIN stores s ON r.store_id = s.store_id " +
                     "WHERE r.receipt_image IS NOT NULL ORDER BY r.sales_date DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Object[]{ rs.getInt("sales_id"), rs.getDate("sales_date"), rs.getInt("total_amount"), rs.getString("receipt_image"), rs.getString("store_name") });
            }
        }
        return list;
    }

    // 매출 기록 자체는 남기고, 첨부된 영수증 이미지 참조만 지워요 (실제 파일 삭제는 별도).
    public void clearReceiptImage(int salesId) throws SQLException {
        String sql = "UPDATE sales_records SET receipt_image = NULL WHERE sales_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, salesId);
            ps.executeUpdate();
        }
    }

    private SalesRecord map(ResultSet rs) throws SQLException {
        SalesRecord r = new SalesRecord();
        r.setSalesId(rs.getInt("sales_id"));
        r.setStoreId(rs.getInt("store_id"));
        r.setSalesDate(rs.getDate("sales_date"));
        r.setTotalAmount(rs.getInt("total_amount"));
        r.setCardAmount(rs.getInt("card_amount"));
        r.setCashAmount(rs.getInt("cash_amount"));
        try { r.setReceiptImage(rs.getString("receipt_image")); } catch (SQLException ignore) { r.setReceiptImage(null); }
        try { r.setLiquorAmount(rs.getInt("liquor_amount")); } catch (SQLException ignore) { r.setLiquorAmount(0); }
        try { r.setFeeAmount(rs.getInt("fee_amount")); } catch (SQLException ignore) { r.setFeeAmount(0); }
        try { r.setOtherExpense(rs.getInt("other_expense")); } catch (SQLException ignore) { r.setOtherExpense(0); }
        return r;
    }
}
