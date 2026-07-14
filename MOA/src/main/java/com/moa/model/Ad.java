package com.moa.model;

public class Ad {
    private int adId;
    private int storeId;
    private String bannerText;
    private String status;
    private String storeName;
    private String startDate;
    private String endDate;

    public int getAdId() { return adId; }
    public void setAdId(int adId) { this.adId = adId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getBannerText() { return bannerText; }
    public void setBannerText(String bannerText) { this.bannerText = bannerText; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStoreName() { return storeName; }
    public void setStoreName(String storeName) { this.storeName = storeName; }
    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
}
