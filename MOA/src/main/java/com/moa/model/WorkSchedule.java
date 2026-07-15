package com.moa.model;

public class WorkSchedule {
    private int scheduleId;
    private int storeId;
    private int employeeId;
    private String employeeName; // 목록 표시용 (JOIN 결과)
    private String employeeRole; // 목록 표시용 (JOIN 결과)
    private String workDate;
    private String shiftStart;
    private String shiftEnd;
    private String memo;

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
    public String getEmployeeRole() { return employeeRole; }
    public void setEmployeeRole(String employeeRole) { this.employeeRole = employeeRole; }
    public String getWorkDate() { return workDate; }
    public void setWorkDate(String workDate) { this.workDate = workDate; }
    public String getShiftStart() { return shiftStart; }
    public void setShiftStart(String shiftStart) { this.shiftStart = shiftStart; }
    public String getShiftEnd() { return shiftEnd; }
    public void setShiftEnd(String shiftEnd) { this.shiftEnd = shiftEnd; }
    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }
}
