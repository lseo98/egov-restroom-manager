package egovframework.example.sample.service;
import java.util.Map;

public interface RestroomService {
    // 대시보드에 필요한 모든 데이터를 묶어서 가져오는 기능
    Map<String, Object> getDashboardData() throws Exception;
}