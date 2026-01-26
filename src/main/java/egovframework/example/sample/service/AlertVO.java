package egovframework.example.sample.service;

public class AlertVO {
    private int alertId;      // 알림 고유 번호
    private String alertType; // 알림 종류
    private String severity;  // WARNING 또는 CRITICAL
    private String content;   // 알림 내용
    private String value;     // 알림 수치/메시지 
    private String createdAt; // 발생 시각

    public int getAlertId() {
        return alertId;
    }
    public void setAlertId(int alertId) {
        this.alertId = alertId;
    }
    public String getAlertType() {
        return alertType;
    }
    public void setAlertType(String alertType) {
        this.alertType = alertType;
    }
    public String getSeverity() { 
        return severity; 
    }
    public void setSeverity(String severity) {
        this.severity = severity; 
    }
    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public String getValue() {
        return value;
    }
    public void setValue(String value) {
        this.value = value;
    }
    public String getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}