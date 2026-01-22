package egovframework.example.sample.service;

public class VisitorVO {
    private int dailyCount;     // 금일 누적 방문자
    private int hourId;         // 시간 (0~23)
    private int visitCount;     // 해당 시간대 방문자
    private int yesterdayCount; // 어제 같은 시간대 방문자
    private int todayCount;

    public int getDailyCount() {
        return dailyCount;
    }
    public void setDailyCount(int dailyCount) {
        this.dailyCount = dailyCount;
    }
    public int getHourId() {
        return hourId;
    }
    public void setHourId(int hourId) {
        this.hourId = hourId;
    }
    public int getVisitCount() {
        return visitCount;
    }
    public void setVisitCount(int visitCount) {
        this.visitCount = visitCount;
    }
    public int getTodayCount() {
        return todayCount;
    }
    public void setTodayCount(int todayCount) {
        this.todayCount = todayCount;
    }
    public int getYesterdayCount() {
        return yesterdayCount;
    }
    public void setYesterdayCount(int yesterdayCount) {
        this.yesterdayCount = yesterdayCount;
    }
    
}