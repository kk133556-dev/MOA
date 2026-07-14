package com.moa.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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

    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM payments WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }
}
