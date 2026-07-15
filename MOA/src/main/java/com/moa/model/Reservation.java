package com.moa.model;

public class Reservation {
    private int reservationId;
    private int storeId;
    private String customerName;
    private String phone;
    private String reservationDate;
    private String reservationTime;
    private int partySize;
    private String menuOrder;
    private int prepaymentAmount;
    private String status;
    private String memo;

    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getReservationDate() { return reservationDate; }
    public void setReservationDate(String reservationDate) { this.reservationDate = reservationDate; }
    public String getReservationTime() { return reservationTime; }
    public void setReservationTime(String reservationTime) { this.reservationTime = reservationTime; }
    public int getPartySize() { return partySize; }
    public void setPartySize(int partySize) { this.partySize = partySize; }
    public String getMenuOrder() { return menuOrder; }
    public void setMenuOrder(String menuOrder) { this.menuOrder = menuOrder; }
    public int getPrepaymentAmount() { return prepaymentAmount; }
    public void setPrepaymentAmount(int prepaymentAmount) { this.prepaymentAmount = prepaymentAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }
}
