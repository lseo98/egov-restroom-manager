package egovframework.example.sample.service;

public class AlertSettingVO {
    private String sensorType; // 알림 종류 (TEMP, HUMIDITY, NH3, PEOPLE_IN 등)
    private int isEnabled;     // 1: 켬, 0: 끔

    public String getSensorType() {
        return sensorType;
    }
    public void setSensorType(String sensorType) {
        this.sensorType = sensorType;
    }
    public int getIsEnabled() {
        return isEnabled;
    }
    public void setIsEnabled(int isEnabled) {
        this.isEnabled = isEnabled;
    }
}