package com.moa.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;

public class PaymentDAO {
    public void insert(int storeId, String plan, int amount) throws SQLException {
        String sql = "INSERT INTO payments (store_id, plan, amount) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, plan);
            ps.setInt(3, amount);
            ps.executeUpdate();
        }
    }

    // 관리자 콘솔에서 "현재 수익"을 보여주기 위한 전체 합계예요.
    public int sumAll() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM payments";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // 이번 달 수익만 따로 (월별 매출 흐름을 보고 싶을 때)
    public int sumThisMonth() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM payments WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // 관리자 콘솔 "결제 내역" 목록 - 어느 매장이 결제했는지 매장명까지 같이 가져와요.
    public List<java.util.Map<String, Object>> listAllWithStoreName() throws SQLException {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.payment_id, p.plan, p.amount, p.created_at, " +
                     "COALESCE(s.store_name, '(매장정보없음)') AS store_name " +
                     "FROM payments p LEFT JOIN stores s ON p.store_id = s.store_id " +
                     "ORDER BY p.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.HashMap<>();
                row.put("paymentId", rs.getInt("payment_id"));
                row.put("plan", rs.getString("plan"));
                row.put("amount", rs.getInt("amount"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                row.put("storeName", rs.getString("store_name"));
                list.add(row);
            }
        }
        return list;
    }

    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM payments WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }
}
