package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.StoreProfile;

public class StoreDAO {

    public void insert(StoreProfile s) throws SQLException {
        String sql = "INSERT INTO stores (member_id, store_name, address, business_reg_no) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, s.getMemberId());
            ps.setString(2, s.getStoreName());
            ps.setString(3, s.getAddress());
            ps.setString(4, s.getBusinessRegNo());
            ps.executeUpdate();
        }
    }

    public StoreProfile findByMemberId(int memberId) throws SQLException {
        String sql = "SELECT * FROM stores WHERE member_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public StoreProfile findByMemberId(int memberId, Connection conn) throws SQLException {
        String sql = "SELECT * FROM stores WHERE member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public void deleteByMemberId(int memberId, Connection conn) throws SQLException {
        String sql = "DELETE FROM stores WHERE member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.executeUpdate();
        }
    }

    public List<StoreProfile> searchByName(String keyword) throws SQLException {
        List<StoreProfile> list = new ArrayList<>();
        String sql = "SELECT * FROM stores WHERE store_name LIKE ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private StoreProfile map(ResultSet rs) throws SQLException {
        StoreProfile s = new StoreProfile();
        s.setStoreId(rs.getInt("store_id"));
        s.setMemberId(rs.getInt("member_id"));
        s.setStoreName(rs.getString("store_name"));
        s.setAddress(rs.getString("address"));
        s.setBusinessRegNo(rs.getString("business_reg_no"));
        return s;
    }
}
