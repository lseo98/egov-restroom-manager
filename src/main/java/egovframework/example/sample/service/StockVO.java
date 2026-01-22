package egovframework.example.sample.service;

public class StockVO {
    private String typeKey;    // 소모품 종류 (LIQUID_SOAP, PAPER_TOWEL)
    private int currentLevel;  // 현재 잔량 (%)
    private int threshold;     // 보충 알림 기준치

    public String getTypeKey() {
        return typeKey;
    }
    public void setTypeKey(String typeKey) {
        this.typeKey = typeKey;
    }
    public int getCurrentLevel() {
        return currentLevel;
    }
    public void setCurrentLevel(int currentLevel) {
        this.currentLevel = currentLevel;
    }
    public int getThreshold() {
        return threshold;
    }
    public void setThreshold(int threshold) {
        this.threshold = threshold;
    }
}