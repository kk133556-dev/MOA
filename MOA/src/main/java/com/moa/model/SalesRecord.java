package com.moa.model;

import java.sql.Date;

public class SalesRecord {
    private int salesId;
    private int storeId;
    private Date salesDate;
    private int totalAmount;
    private int cardAmount;
    private int cashAmount;
    private String receiptImage;

    public int getSalesId() { return salesId; }
    public void setSalesId(int salesId) { this.salesId = salesId; }

    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }

    public Date getSalesDate() { return salesDate; }
    public void setSalesDate(Date salesDate) { this.salesDate = salesDate; }

    public int getTotalAmount() { return totalAmount; }
    public void setTotalAmount(int totalAmount) { this.totalAmount = totalAmount; }

    public int getCardAmount() { return cardAmount; }
    public void setCardAmount(int cardAmount) { this.cardAmount = cardAmount; }

    public int getCashAmount() { return cashAmount; }
    public void setCashAmount(int cashAmount) { this.cashAmount = cashAmount; }

    public String getReceiptImage() { return receiptImage; }
    public void setReceiptImage(String receiptImage) { this.receiptImage = receiptImage; }
}
