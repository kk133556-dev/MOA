package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.InventoryItem;

public class InventoryDAO {

    public void insert(int storeId, String itemName, double qty, double safetyQty, String unit) throws SQLException {
        String sql = "INSERT INTO inventory_items (store_id, item_name, qty, safety_qty, unit) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, itemName);
            ps.setDouble(3, qty);
            ps.setDouble(4, safetyQty);
            ps.setString(5, unit);
            ps.executeUpdate();
        }
    }

    public List<InventoryItem> listByStore(int storeId) throws SQLException {
        List<InventoryItem> list = new ArrayList<>();
        String sql = "SELECT * FROM inventory_items WHERE store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryItem it = new InventoryItem();
                    it.setItemId(rs.getInt("item_id"));
                    it.setStoreId(rs.getInt("store_id"));
                    it.setItemName(rs.getString("item_name"));
                    it.setQty(rs.getDouble("qty"));
                    it.setSafetyQty(rs.getDouble("safety_qty"));
                    it.setUnit(rs.getString("unit"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    public void delete(int itemId) throws SQLException {
        String sql = "DELETE FROM inventory_items WHERE item_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.executeUpdate();
        }
    }

    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM inventory_items WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }
}
