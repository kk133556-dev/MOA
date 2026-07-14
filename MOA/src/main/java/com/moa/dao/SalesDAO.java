package com.moa.dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.SalesRecord;

public class SalesDAO {

    public void insert(int storeId, int totalAmount, int cardAmount, int cashAmount) throws SQLException {
        insert(storeId, totalAmount, cardAmount, cashAmount, null);
    }

    // 영수증 AI 스캔에서 넘어온 이미지 경로를 같이 저장할 때 써요. receiptImage는 없으면 null로 둬도 돼요.
    // 혹시 add_receipt_image_column.sql을 아직 안 돌리셨어도 매출 저장 자체는 깨지지 않도록,
    // receipt_image 컬럼이 없으면 그 컬럼 없이 다시 저장을 시도해요.
    public void insert(int storeId, int totalAmount, int cardAmount, int cashAmount, String receiptImage) throws SQLException {
        String sql = "INSERT INTO sales_records (store_id, sales_date, total_amount, card_amount, cash_amount, receipt_image) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setDate(2, java.sql.Date.valueOf(LocalDate.now()));
            ps.setInt(3, totalAmount);
            ps.setInt(4, cardAmount);
            ps.setInt(5, cashAmount);
            if (receiptImage != null) ps.setString(6, receiptImage); else ps.setNull(6, Types.VARCHAR);
            ps.executeUpdate();
        } catch (SQLSyntaxErrorException e) {
            // receipt_image 컬럼이 아직 없는 DB - 컬럼 없이 재시도
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

    // 월별 매출 집계. 결과: [ "2026-01", 총액 ] 형태로 최근 것부터.
    public List<Object[]> monthlyByStore(int storeId, int months) throws SQLException {
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
                    list.add(new Object[]{ rs.getString("ym"), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash") });
                }
            }
        }
        return list;
    }

    // 연도별 매출 집계. 결과: [ "2026", 총액 ] 형태로 오래된 연도부터.
    public List<Object[]> yearlyByStore(int storeId) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT YEAR(sales_date) AS yy, SUM(total_amount) AS total, " +
                     "SUM(card_amount) AS card, SUM(cash_amount) AS cash " +
                     "FROM sales_records WHERE store_id = ? GROUP BY yy ORDER BY yy ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{ String.valueOf(rs.getInt("yy")), rs.getInt("total"), rs.getInt("card"), rs.getInt("cash") });
                }
            }
        }
        return list;
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
        return r;
    }
}
