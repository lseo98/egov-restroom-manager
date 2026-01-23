package egovframework.example.sample.service;
import java.util.List;
import java.util.Map;

public interface RestroomService {
	// 1. 대시보드 데이터 조회
    Map<String, Object> getDashboardData() throws Exception;

    // 2. 임계치 설정 페이지용 모든 데이터 로드
    Map<String, Object> getThresholdSettings() throws Exception;

    // 3. 임계치 설정 페이지에서 수정한 모든 설정값 저장
    void updateThresholdSettings(Map<String, Object> data) throws Exception;
    
 	// 센서 로그 데이터
    List<SensorVO> getSensorLogs(Map<String, Object> paramMap) throws Exception;
}