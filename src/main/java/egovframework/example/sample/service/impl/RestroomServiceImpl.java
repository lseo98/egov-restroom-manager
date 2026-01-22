package egovframework.example.sample.service.impl;

import java.util.*;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import egovframework.example.sample.service.*;

@Service("restroomService")
public class RestroomServiceImpl implements RestroomService {
    
    @Resource(name="restroomMapper")
    private RestroomMapper mapper;

    @Override
    public Map<String, Object> getDashboardData() throws Exception {
        Map<String, Object> totalData = new HashMap<>();
        
        // 각각의 데이터를 뽑아서 하나의 Map에 담습니다.
        totalData.put("stalls", mapper.selectStallList());
        totalData.put("temp", mapper.selectLatestSensor("TEMP"));
        totalData.put("humi", mapper.selectLatestSensor("HUMIDITY"));
        totalData.put("nh3", mapper.selectLatestSensor("NH3"));
        totalData.put("stocks", mapper.selectStockList());
        totalData.put("todayVisitor", mapper.selectTodayVisitor());
        totalData.put("todayVisitor", mapper.selectTodayVisitor());
        totalData.put("hourlyStats", mapper.selectHourlyStats());
        totalData.put("settings", mapper.selectAlertSettings());
        
        // 전일 대비 비교 데이터 가져오기
        VisitorVO compare = mapper.selectVisitComparison();
        int todaySum = compare.getTodayCount();
        int yesterdaySum = compare.getYesterdayCount();

     // 1. diffPercent 계산 및 입력 (변수 범위 문제 해결)
        if (yesterdaySum == 0) {
            totalData.put("diffPercent", "-"); 
        } else {
            // 어제 데이터가 있을 때만 percent 변수를 생성하고 계산합니다.
            double percent = ((double)(todaySum - yesterdaySum) / yesterdaySum) * 100;
            totalData.put("diffPercent", String.format("%.1f", percent));
        }

        // 2. 나머지 합계 데이터 입력
        totalData.put("todaySum", todaySum);
        totalData.put("yesterdaySum", yesterdaySum);
        
        return totalData;
    }
}