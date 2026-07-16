package com.moa.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.moa.db.DBUtil;
import com.moa.model.WorkSchedule;

public class WorkScheduleDAO {

    // 특정 연-월(yyyy-MM)의 근무 일정을 전부 가져와요. (달력 화면 그릴 때 사용)
    public List<WorkSchedule> listByMonth(int storeId, String yearMonth) throws SQLException {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = "SELECT ws.*, e.name AS employee_name, e.role AS employee_role " +
                     "FROM work_schedules ws JOIN employees e ON ws.employee_id = e.employee_id " +
                     "WHERE ws.store_id = ? AND DATE_FORMAT(ws.work_date, '%Y-%m') = ? " +
                     "ORDER BY ws.work_date ASC, ws.shift_start ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, yearMonth);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // 특정 날짜(yyyy-MM-dd)의 근무자만 뽑아요. 챗봇이 "오늘 누가 출근이야?" 같은 질문에 답할 때 써요.
    public List<WorkSchedule> listByDate(int storeId, String workDate) throws SQLException {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = "SELECT ws.*, e.name AS employee_name, e.role AS employee_role " +
                     "FROM work_schedules ws JOIN employees e ON ws.employee_id = e.employee_id " +
                     "WHERE ws.store_id = ? AND ws.work_date = ? " +
                     "ORDER BY ws.shift_start ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, storeId);
            ps.setString(2, workDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int insert(int storeId, int employeeId, String workDate, String shiftStart, String shiftEnd, String memo) throws SQLException {
        String sql = "INSERT INTO work_schedules (store_id, employee_id, work_date, shift_start, shift_end, memo) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, storeId);
            ps.setInt(2, employeeId);
            ps.setDate(3, Date.valueOf(workDate));
            if (shiftStart != null && !shiftStart.isEmpty()) ps.setTime(4, Time.valueOf(shiftStart + ":00")); else ps.setNull(4, Types.TIME);
            if (shiftEnd != null && !shiftEnd.isEmpty()) ps.setTime(5, Time.valueOf(shiftEnd + ":00")); else ps.setNull(5, Types.TIME);
            ps.setString(6, memo);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    public void deleteOwnedByStore(int scheduleId, int storeId) throws SQLException {
        String sql = "DELETE FROM work_schedules WHERE schedule_id = ? AND store_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, storeId);
            ps.executeUpdate();
        }
    }

    private WorkSchedule map(ResultSet rs) throws SQLException {
        WorkSchedule w = new WorkSchedule();
        w.setScheduleId(rs.getInt("schedule_id"));
        w.setStoreId(rs.getInt("store_id"));
        w.setEmployeeId(rs.getInt("employee_id"));
        w.setEmployeeName(rs.getString("employee_name"));
        w.setEmployeeRole(rs.getString("employee_role"));
        w.setWorkDate(rs.getDate("work_date").toString());
        Time st = rs.getTime("shift_start");
        Time et = rs.getTime("shift_end");
        w.setShiftStart(st != null ? st.toString().substring(0, 5) : null);
        w.setShiftEnd(et != null ? et.toString().substring(0, 5) : null);
        w.setMemo(rs.getString("memo"));
        return w;
    }
}
