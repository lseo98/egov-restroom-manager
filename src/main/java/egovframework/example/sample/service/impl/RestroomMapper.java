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
}