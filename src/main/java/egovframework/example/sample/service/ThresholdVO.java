package egovframework.example.sample.service;

public class ThresholdVO {
    private String sensorType;  // 설정 대상 센서 (TEMP, HUMIDITY 등)
    private Double minValue;    // 최소 허용치
    private Double maxValue;    // 최대 허용치
    private String unit;
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
    public String getUnit() { 
    	return unit; 
    } 
    public void setUnit(String unit) {
    	this.unit = unit; 
    }
    public int getAlertInterval() {
        return alertInterval;
    }
    public void setAlertInterval(int alertInterval) {
        this.alertInterval = alertInterval;
    }
}