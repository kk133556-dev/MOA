package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.Employee;

public class EmployeeDAO {

    public List<Employee> listByStore(int storeId) throws SQLException {
        List<Employee> list = new ArrayList<>();
        String sql = "SELECT * FROM employees WHERE store_id = ? ORDER BY created_at ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int insert(int storeId, String name, String role, String phone, String address, String memo, String guardianName, String guardianPhone) throws SQLException {
        String sql = "INSERT INTO employees (store_id, name, role, phone, address, memo, guardian_name, guardian_phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, storeId);
            ps.setString(2, name);
            ps.setString(3, role);
            ps.setString(4, phone);
            ps.setString(5, address);
            ps.setString(6, memo);
            ps.setString(7, guardianName);
            ps.setString(8, guardianPhone);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // 본인 매장 직원 정보 수정 (오타 수정 등)
    public void updateOwnedByStore(int employeeId, int storeId, String name, String role, String phone,
                                    String address, String memo, String guardianName, String guardianPhone) throws SQLException {
        String sql = "UPDATE employees SET name = ?, role = ?, phone = ?, address = ?, memo = ?, guardian_name = ?, guardian_phone = ? " +
                "WHERE employee_id = ? AND store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, role);
            ps.setString(3, phone);
            ps.setString(4, address);
            ps.setString(5, memo);
            ps.setString(6, guardianName);
            ps.setString(7, guardianPhone);
            ps.setInt(8, employeeId);
            ps.setInt(9, storeId);
            ps.executeUpdate();
        }
    }

    // 본인 매장 직원만 지울 수 있게 store_id도 같이 확인해요.
    public void deleteOwnedByStore(int employeeId, int storeId) throws SQLException {
        String sql = "DELETE FROM employees WHERE employee_id = ? AND store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, storeId);
            ps.executeUpdate();
        }
    }

    private Employee map(ResultSet rs) throws SQLException {
        Employee e = new Employee();
        e.setEmployeeId(rs.getInt("employee_id"));
        e.setStoreId(rs.getInt("store_id"));
        e.setName(rs.getString("name"));
        e.setRole(rs.getString("role"));
        e.setPhone(rs.getString("phone"));
        e.setAddress(rs.getString("address"));
        e.setMemo(rs.getString("memo"));
        e.setGuardianName(rs.getString("guardian_name"));
        e.setGuardianPhone(rs.getString("guardian_phone"));
        return e;
    }
}
