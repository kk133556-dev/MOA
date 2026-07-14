package com.moa.model;

public class InventoryItem {
    private int itemId;
    private int storeId;
    private String itemName;
    private double qty;
    private double safetyQty;
    private String unit;

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public double getQty() { return qty; }
    public void setQty(double qty) { this.qty = qty; }
    public double getSafetyQty() { return safetyQty; }
    public void setSafetyQty(double safetyQty) { this.safetyQty = safetyQty; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}
