package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.QuickTodo;

public class QuickTodoDAO {

    public List<QuickTodo> listByStore(int storeId) throws SQLException {
        List<QuickTodo> list = new ArrayList<>();
        String sql = "SELECT * FROM quick_todos WHERE store_id = ? ORDER BY quick_id ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuickTodo q = new QuickTodo();
                    q.setQuickId(rs.getInt("quick_id"));
                    q.setStoreId(rs.getInt("store_id"));
                    q.setLabel(rs.getString("label"));
                    list.add(q);
                }
            }
        }
        return list;
    }

    public int insert(int storeId, String label) throws SQLException {
        String sql = "INSERT INTO quick_todos (store_id, label) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, storeId);
            ps.setString(2, label);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    public void delete(int quickId) throws SQLException {
        String sql = "DELETE FROM quick_todos WHERE quick_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quickId);
            ps.executeUpdate();
        }
    }
}
