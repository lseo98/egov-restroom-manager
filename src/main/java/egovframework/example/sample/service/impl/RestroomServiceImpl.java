package egovframework.example.sample.service.impl;

import java.util.*;
import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.example.sample.service.*;

@Service("restroomService")
public class RestroomServiceImpl implements RestroomService {

    @Resource(name="restroomMapper")
    private RestroomMapper mapper;

    @Override
    public Map<String, Object> getDashboardData() throws Exception {
        Map<String, Object> totalData = new HashMap<>();

        totalData.put("stalls", mapper.selectStallList());
        totalData.put("temp", mapper.selectLatestSensor("TEMP"));
        totalData.put("humi", mapper.selectLatestSensor("HUMIDITY"));
        totalData.put("nh3", mapper.selectLatestSensor("NH3"));
        totalData.put("stocks", mapper.selectStockList());
        totalData.put("todayVisitor", mapper.selectTodayVisitor());
        totalData.put("hourlyStats", mapper.selectHourlyStats());
        totalData.put("settings", mapper.selectAlertSettings());

        // ✅ 추가(임계치 DB 연결): 센서 임계치 전체 내려주기
        totalData.put("thresholds", mapper.selectAllThresholds());

        VisitorVO compare = mapper.selectVisitComparison();
        int todaySum = compare.getTodayCount();
        int yesterdaySum = compare.getYesterdayCount();

        if (yesterdaySum == 0) {
            totalData.put("diffPercent", "-");
        } else {
            double percent = ((double)(todaySum - yesterdaySum) / yesterdaySum) * 100;
            totalData.put("diffPercent", String.format("%.1f", percent));
        }

        totalData.put("todaySum", todaySum);
        totalData.put("yesterdaySum", yesterdaySum);

        return totalData;
    }

    @Override
    public Map<String, Object> getThresholdSettings() throws Exception {
        Map<String, Object> settings = new HashMap<>();
        settings.put("thresholds", mapper.selectAllThresholds());
        settings.put("alerts", mapper.selectAlertSettings());
        settings.put("consumables", mapper.selectConsumableThresholds());
        return settings;
    }

    @Transactional
    @Override
    public void updateThresholdSettings(Map<String, Object> data) throws Exception {
        updateSensorThresholds(data);
        updateAlertSettings(data);
        updateConsumableThresholds(data);
    }

    private void updateSensorThresholds(Map<String, Object> data) throws Exception {
        String[] sensors = {"temp", "hum", "nh3", "people"};
        String[] dbTypes = {"TEMP", "HUMIDITY", "NH3", "PEOPLE_IN"};

        for (int i = 0; i < sensors.length; i++) {
            Map<String, Object> sData = (Map<String, Object>) data.get(sensors[i]);
            if (sData == null) continue;

            ThresholdVO vo = new ThresholdVO();
            vo.setSensorType(dbTypes[i]);

            Object realertObj = sData.get("realertMin");
            int realertMin = (realertObj != null) ? Integer.parseInt(String.valueOf(realertObj)) : 10;
            vo.setAlertInterval(realertMin);

            if ("nh3".equals(sensors[i])) {
                vo.setMinValue(Double.parseDouble(String.valueOf(sData.get("warning"))));
                vo.setMaxValue(Double.parseDouble(String.valueOf(sData.get("critical"))));
            } else if ("people".equals(sensors[i])) {
                vo.setMinValue(0.0);
                vo.setMaxValue(Double.parseDouble(String.valueOf(sData.get("high"))));
            } else {
                vo.setMinValue(Double.parseDouble(String.valueOf(sData.get("low"))));
                vo.setMaxValue(Double.parseDouble(String.valueOf(sData.get("high"))));
            }
            mapper.updateSensorThreshold(vo);
        }
    }

    private void updateAlertSettings(Map<String, Object> data) throws Exception {
        String[] keys = {"temp", "hum", "nh3", "people", "towel", "soap"};
        String[] dbTypes = {"TEMP", "HUMIDITY", "NH3", "PEOPLE_IN", "PAPER_TOWEL", "LIQUID_SOAP"};

        for (int i = 0; i < keys.length; i++) {
            Map<String, Object> sData = (Map<String, Object>) data.get(keys[i]);
            if (sData == null) continue;

            AlertSettingVO vo = new AlertSettingVO();
            vo.setSensorType(dbTypes[i]);

            boolean isAlert = Boolean.parseBoolean(String.valueOf(sData.get("alert")));
            vo.setIsEnabled(isAlert ? 1 : 0);

            mapper.updateAlertSetting(vo);
        }
    }

    private void updateConsumableThresholds(Map<String, Object> data) throws Exception {
        String[] keys = {"towel", "soap"};
        String[] dbTypes = {"PAPER_TOWEL", "LIQUID_SOAP"};

        for (int i = 0; i < keys.length; i++) {
            Map<String, Object> sData = (Map<String, Object>) data.get(keys[i]);
            if (sData == null) continue;

            StockVO vo = new StockVO();
            vo.setTypeKey(dbTypes[i]);

            vo.setThreshold(Integer.parseInt(String.valueOf(sData.get("threshold"))));

            mapper.updateConsumableThreshold(vo);
        }
    }

    @Override
    public List<SensorVO> getSensorLogs(Map<String, Object> paramMap) throws Exception {
        return mapper.selectSensorLogList(paramMap);
    }
    
    @Override
    public List<AlertVO> getAlertLogs(Map<String, Object> paramMap) throws Exception {
        // XML의 id인 selectAlertLogList와 연결됩니다.
        return mapper.selectAlertLogList(paramMap);
    }
}
