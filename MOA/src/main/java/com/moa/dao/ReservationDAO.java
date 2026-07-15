package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Reservation;

public class ReservationDAO {

    public int insert(int storeId, String customerName, String phone, String date, String time,
                       int partySize, String menuOrder, int prepayment, String memo) throws SQLException {
        String sql = "INSERT INTO reservations (store_id, customer_name, phone, reservation_date, reservation_time, " +
                     "party_size, menu_order, prepayment_amount, status, memo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, storeId);
            ps.setString(2, customerName);
            ps.setString(3, phone);
            ps.setDate(4, Date.valueOf(date));
            ps.setTime(5, Time.valueOf(time + ":00"));
            ps.setInt(6, partySize);
            ps.setString(7, menuOrder);
            ps.setInt(8, prepayment);
            ps.setString(9, memo);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // 오늘부터 미래(취소 제외) 예약 전부, 가까운 날짜 순으로. 마이페이지 알림/예약 페이지 둘 다에서 써요.
    public List<Reservation> listUpcoming(int storeId) throws SQLException {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE store_id = ? AND status != 'CANCELED' " +
                     "AND reservation_date >= CURDATE() ORDER BY reservation_date ASC, reservation_time ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // 지난 예약 포함 전체 내역 (히스토리 확인용)
    public List<Reservation> listAll(int storeId) throws SQLException {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE store_id = ? ORDER BY reservation_date DESC, reservation_time DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public void updateStatus(int reservationId, int storeId, String status) throws SQLException {
        String sql = "UPDATE reservations SET status = ? WHERE reservation_id = ? AND store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reservationId);
            ps.setInt(3, storeId);
            ps.executeUpdate();
        }
    }

    public void deleteOwnedByStore(int reservationId, int storeId) throws SQLException {
        String sql = "DELETE FROM reservations WHERE reservation_id = ? AND store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ps.setInt(2, storeId);
            ps.executeUpdate();
        }
    }

    private Reservation map(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setReservationId(rs.getInt("reservation_id"));
        r.setStoreId(rs.getInt("store_id"));
        r.setCustomerName(rs.getString("customer_name"));
        r.setPhone(rs.getString("phone"));
        r.setReservationDate(rs.getDate("reservation_date").toString());
        Time t = rs.getTime("reservation_time");
        r.setReservationTime(t != null ? t.toString().substring(0, 5) : "");
        r.setPartySize(rs.getInt("party_size"));
        r.setMenuOrder(rs.getString("menu_order"));
        r.setPrepaymentAmount(rs.getInt("prepayment_amount"));
        r.setStatus(rs.getString("status"));
        r.setMemo(rs.getString("memo"));
        return r;
    }
}
