package com.moa.model;

public class Employee {
    private int employeeId;
    private int storeId;
    private String name;
    private String role;
    private String phone;
    private String memo;

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }
}
