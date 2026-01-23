package egovframework.example.sample.service.impl;

import java.util.List;
import egovframework.example.sample.service.*;
import egovframework.rte.psl.dataaccess.mapper.Mapper;

@Mapper("restroomMapper")
public interface RestroomMapper {
    List<StallVO> selectStallList() throws Exception;
    SensorVO selectLatestSensor(String sensorType) throws Exception;
    List<StockVO> selectStockList() throws Exception;
    int selectTodayVisitor() throws Exception;
    List<VisitorVO> selectHourlyStats() throws Exception;
    List<AlertSettingVO> selectAlertSettings() throws Exception;
    VisitorVO selectVisitComparison() throws Exception;
    
    List<SensorVO> selectSensorLogList() throws Exception;
    
    // 1. 임계치 및 알림 설정 조회용 메서드
    List<ThresholdVO> selectAllThresholds() throws Exception;
    List<StockVO> selectConsumableThresholds() throws Exception;

    // 2. 설정값 저장용 메서드 (Update)
    int updateSensorThreshold(ThresholdVO thresholdVO) throws Exception;
    int updateAlertSetting(AlertSettingVO alertSettingVO) throws Exception;
    int updateConsumableThreshold(StockVO stockVO) throws Exception;
}