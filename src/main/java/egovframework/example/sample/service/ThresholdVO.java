package egovframework.example.sample.service;

public class ThresholdVO {
    private String sensorType;  // 설정 대상 센서 (TEMP, HUMIDITY 등)
    private double minValue;    // 최소 허용치
    private double maxValue;    // 최대 허용치
    private int alertInterval;  // 알림 반복 주기 (분)

    public String getSensorType() {
        return sensorType;
    }
    public void setSensorType(String sensorType) {
        this.sensorType = sensorType;
    }
    public double getMinValue() {
        return minValue;
    }
    public void setMinValue(double minValue) {
        this.minValue = minValue;
    }
    public double getMaxValue() {
        return maxValue;
    }
    public void setMaxValue(double maxValue) {
        this.maxValue = maxValue;
    }
    public int getAlertInterval() {
        return alertInterval;
    }
    public void setAlertInterval(int alertInterval) {
        this.alertInterval = alertInterval;
    }
}