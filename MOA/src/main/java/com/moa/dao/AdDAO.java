package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Ad;

public class AdDAO {

    public void insert(int storeId, String bannerText) throws SQLException {
        String sql = "INSERT INTO ads (store_id, banner_text) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, bannerText);
            ps.executeUpdate();
        }
    }

    // 홈페이지/로그인 화면에 실제로 노출할 광고만 골라요: 승인됐고, 오늘이 노출 기간 안에 있는 것.
    // start_date/end_date가 null이면 "기간 제한 없음"으로 봐요.
    public List<Ad> listApproved() throws SQLException {
        List<Ad> list = new ArrayList<>();
        String sql = "SELECT a.*, s.store_name FROM ads a JOIN stores s ON a.store_id = s.store_id " +
                     "WHERE a.status = 'APPROVED' " +
                     "AND (a.start_date IS NULL OR a.start_date <= CURDATE()) " +
                     "AND (a.end_date IS NULL OR a.end_date >= CURDATE()) " +
                     "ORDER BY a.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Ad> listPending() throws SQLException {
        List<Ad> list = new ArrayList<>();
        String sql = "SELECT a.*, s.store_name FROM ads a JOIN stores s ON a.store_id = s.store_id WHERE a.status = 'PENDING' ORDER BY a.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    // 현재 승인 상태와 관계없이, 관리자가 관리 화면에서 볼 전체 노출 광고 목록(기간 상관없이)
    public List<Ad> listAllApprovedIncludingExpired() throws SQLException {
        List<Ad> list = new ArrayList<>();
        String sql = "SELECT a.*, s.store_name FROM ads a JOIN stores s ON a.store_id = s.store_id " +
                     "WHERE a.status = 'APPROVED' ORDER BY a.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public void updateStatus(int adId, String status) throws SQLException {
        String sql = "UPDATE ads SET status = ? WHERE ad_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, adId);
            ps.executeUpdate();
        }
    }

    // 승인하면서 노출 기간까지 같이 지정해요. startDate/endDate가 빈 문자열이면 "기간 제한 없음"으로 null 저장.
    public void approveWithDateRange(int adId, String startDate, String endDate) throws SQLException {
        String sql = "UPDATE ads SET status = 'APPROVED', start_date = ?, end_date = ? WHERE ad_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (startDate != null && !startDate.isEmpty()) ps.setDate(1, Date.valueOf(startDate)); else ps.setNull(1, Types.DATE);
            if (endDate != null && !endDate.isEmpty()) ps.setDate(2, Date.valueOf(endDate)); else ps.setNull(2, Types.DATE);
            ps.setInt(3, adId);
            ps.executeUpdate();
        }
    }

    public void delete(int adId) throws SQLException {
        String sql = "DELETE FROM ads WHERE ad_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adId);
            ps.executeUpdate();
        }
    }

    public void deleteByStore(int storeId, Connection conn) throws SQLException {
        String sql = "DELETE FROM ads WHERE store_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.executeUpdate();
        }
    }

    // 내가 신청한 광고 내역 전체(상태 무관)를 최신순으로 보여줘요.
    public List<Ad> listByStore(int storeId) throws SQLException {
        List<Ad> list = new ArrayList<>();
        String sql = "SELECT a.*, s.store_name FROM ads a JOIN stores s ON a.store_id = s.store_id " +
                     "WHERE a.store_id = ? ORDER BY a.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private Ad map(ResultSet rs) throws SQLException {
        Ad ad = new Ad();
        ad.setAdId(rs.getInt("ad_id"));
        ad.setStoreId(rs.getInt("store_id"));
        ad.setBannerText(rs.getString("banner_text"));
        ad.setStatus(rs.getString("status"));
        ad.setStoreName(rs.getString("store_name"));
        try {
            Date sd = rs.getDate("start_date");
            Date ed = rs.getDate("end_date");
            ad.setStartDate(sd != null ? sd.toString() : null);
            ad.setEndDate(ed != null ? ed.toString() : null);
        } catch (SQLException ignore) { /* 컬럼 추가 전이면 그냥 null로 둬요 */ }
        return ad;
    }
}
