package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Inquiry;

public class InquiryDAO {

    public void insert(int memberId, String content) throws SQLException {
        String sql = "INSERT INTO inquiries (member_id, content) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.setString(2, content);
            ps.executeUpdate();
        }
    }

    public List<Inquiry> listByMember(int memberId) throws SQLException {
        List<Inquiry> list = new ArrayList<>();
        String sql = "SELECT * FROM inquiries WHERE member_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Inquiry> listAll() throws SQLException {
        List<Inquiry> list = new ArrayList<>();
        String sql = "SELECT i.*, m.name AS member_name FROM inquiries i JOIN members m ON i.member_id = m.member_id ORDER BY i.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Inquiry inq = map(rs);
                inq.setMemberName(rs.getString("member_name"));
                list.add(inq);
            }
        }
        return list;
    }

    public void reply(int inquiryId, String replyText) throws SQLException {
        String sql = "UPDATE inquiries SET admin_reply = ?, status = 'ANSWERED' WHERE inquiry_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, replyText);
            ps.setInt(2, inquiryId);
            ps.executeUpdate();
        }
    }

    public void deleteByMember(int memberId, Connection conn) throws SQLException {
        String sql = "DELETE FROM inquiries WHERE member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.executeUpdate();
        }
    }

    private Inquiry map(ResultSet rs) throws SQLException {
        Inquiry inq = new Inquiry();
        inq.setInquiryId(rs.getInt("inquiry_id"));
        inq.setMemberId(rs.getInt("member_id"));
        inq.setContent(rs.getString("content"));
        inq.setStatus(rs.getString("status"));
        inq.setCreatedAt(rs.getTimestamp("created_at"));
        try { inq.setAdminReply(rs.getString("admin_reply")); } catch (SQLException ignore) {}
        return inq;
    }
}
