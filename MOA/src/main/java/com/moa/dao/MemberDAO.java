package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Member;

public class MemberDAO {

    public Member login(String loginId, String password, String memberType) throws SQLException {
        String sql = "SELECT * FROM members WHERE login_id = ? AND password = ? AND member_type = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, loginId);
            ps.setString(2, password);
            ps.setString(3, memberType);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // 앱 자동 로그인(로그인 유지)용 - 기억 토큰을 저장/조회해요.
    public void setRememberToken(int memberId, String token) throws SQLException {
        String sql = "UPDATE members SET remember_token = ? WHERE member_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setInt(2, memberId);
            ps.executeUpdate();
        }
    }

    public Member findByRememberToken(String token) throws SQLException {
        String sql = "SELECT * FROM members WHERE remember_token = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public boolean isLoginIdTaken(String loginId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM members WHERE login_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, loginId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // 새로 가입하는 소상공인은 바로 활동 못하고, 관리자 승인 전까지 PENDING 상태예요.
    public int insert(Member m) throws SQLException {
        String sql = "INSERT INTO members (login_id, password, name, member_type, status) VALUES (?, ?, ?, 'BUSINESS', 'PENDING')";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, m.getLoginId());
            ps.setString(2, m.getPassword());
            ps.setString(3, m.getName());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    public void updatePlan(int memberId, String plan) throws SQLException {
        String sql = "UPDATE members SET plan = ? WHERE member_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, plan);
            ps.setInt(2, memberId);
            ps.executeUpdate();
        }
    }

    // 관리자가 회원 상태를 바꿀 때 (승인/정지/재활성화)
    public void updateStatus(int memberId, String status) throws SQLException {
        String sql = "UPDATE members SET status = ? WHERE member_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, memberId);
            ps.executeUpdate();
        }
    }

    public List<Member> listAll() throws SQLException {
        List<Member> list = new ArrayList<>();
        String sql = "SELECT * FROM members ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    // 회원을 삭제하면 그 회원의 매장에 딸린 매출/재고/다이어리/광고/결제/문의 데이터까지 전부 같이
    // 지워져야 앞뒤가 맞아요. 하나라도 실패하면 전체를 되돌리도록 트랜잭션으로 묶었어요.
    public void deleteMemberCascade(int memberId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            StoreDAO storeDao = new StoreDAO();
            var store = storeDao.findByMemberId(memberId, conn);
            if (store != null) {
                int storeId = store.getStoreId();
                new SalesDAO().deleteByStore(storeId, conn);
                new InventoryDAO().deleteByStore(storeId, conn);
                new TodoDAO().deleteByStore(storeId, conn);
                new AdDAO().deleteByStore(storeId, conn);
                new PaymentDAO().deleteByStore(storeId, conn);
                storeDao.deleteByMemberId(memberId, conn);
            }
            new InquiryDAO().deleteByMember(memberId, conn);

            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM members WHERE member_id = ?")) {
                ps.setInt(1, memberId);
                ps.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignore) {}
            throw e;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignore) {}
        }
    }

    private Member map(ResultSet rs) throws SQLException {
        Member m = new Member();
        m.setMemberId(rs.getInt("member_id"));
        m.setLoginId(rs.getString("login_id"));
        m.setName(rs.getString("name"));
        m.setMemberType(rs.getString("member_type"));
        m.setPlan(rs.getString("plan"));
        try { m.setStatus(rs.getString("status")); } catch (SQLException ignore) { m.setStatus("ACTIVE"); }
        return m;
    }
}
