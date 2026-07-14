package com.moa.model;

public class ChatIntent {
    private int intentId;
    private String intentName;
    private String answerText;
    private String linkUrl;

    public int getIntentId() { return intentId; }
    public void setIntentId(int intentId) { this.intentId = intentId; }
    public String getIntentName() { return intentName; }
    public void setIntentName(String intentName) { this.intentName = intentName; }
    public String getAnswerText() { return answerText; }
    public void setAnswerText(String answerText) { this.answerText = answerText; }
    public String getLinkUrl() { return linkUrl; }
    public void setLinkUrl(String linkUrl) { this.linkUrl = linkUrl; }
}
