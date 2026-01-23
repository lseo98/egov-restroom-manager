package egovframework.example.sample.service;

public class SensorVO {
    private int readingId;      // 기록 번호
    private Integer stallId;    // 센서가 설치된 칸 번호 (없을 수 있음)
    private String status;
    private String sensorType;  // 센서 종류 (TEMP, HUMIDITY, NH3)
    private double value;       // 측정값
    private String readingTime; // 측정 시간

    public int getReadingId() {
        return readingId;
    }
    public void setReadingId(int readingId) {
        this.readingId = readingId;
    }
    public Integer getStallId() {
        return stallId;
    }
    public void setStallId(Integer stallId) {
        this.stallId = stallId;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getSensorType() {
        return sensorType;
    }
    public void setSensorType(String sensorType) {
        this.sensorType = sensorType;
    }
    public double getValue() {
        return value;
    }
    public void setValue(double value) {
        this.value = value;
    }
    public String getReadingTime() {
        return readingTime;
    }
    public void setReadingTime(String readingTime) {
        this.readingTime = readingTime;
    }
}
