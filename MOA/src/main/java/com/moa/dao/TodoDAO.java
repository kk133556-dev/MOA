package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Todo;

public class TodoDAO {

    public int insert(int storeId, String content) throws SQLException {
        String sql = "INSERT INTO todos (store_id, content) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, storeId);
            ps.setString(2, content);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    public List<Todo> listByStore(int storeId) throws SQLException {
        List<Todo> list = new ArrayList<>();
        String sql = "SELECT * FROM todos WHERE store_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Todo t = new Todo();
                    t.setTodoId(rs.getInt("todo_id"));
                    t.setStoreId(rs.getInt("store_id"));
                    t.setContent(rs.getString("content"));
                    t.setDone(rs.getBoolean("is_done"));
                    list.add(t);
                }
            }
        }
        return list;
    }

    public void toggleDone(int todoId) throws SQLException {
        String sql = "UPDATE todos SET is_done = NOT is_done WHERE todo_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, todoId);
            ps.executeUpdate();
        }
    }

    public void delete(int todoId) throws SQLException {
        String sql = "DELETE FROM todos WHERE todo_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, todoId);
            ps.executeUpdate();
        }
    }

    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM todos WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }
}
