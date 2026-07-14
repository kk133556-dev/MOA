package com.moa.model;

import java.sql.Timestamp;

public class Payment {
    private int paymentId;
    private int storeId;
    private String plan;
    private int amount;
    private Timestamp createdAt;

    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getPlan() { return plan; }
    public void setPlan(String plan) { this.plan = plan; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
