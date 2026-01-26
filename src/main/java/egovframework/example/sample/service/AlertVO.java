package egovframework.example.sample.service;

public class AlertVO {
    private int alertId;      // 알림 고유 번호
    private String alertType; // 알림 종류
    private String severity;  // WARNING 또는 CRITICAL
    private String title;     // 알림 제목
    private String message;   // 알림 상세 내용
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
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }
    public String getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}