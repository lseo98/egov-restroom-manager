package egovframework.example.sample.web;

import java.util.Map;
import javax.annotation.Resource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody; 
import egovframework.example.sample.service.RestroomService;

@Controller
public class RestroomController {

    @Resource(name = "restroomService")
    private RestroomService restroomService;

    // 1. 대시보드 첫 진입 화면
    @RequestMapping(value = "/dashboard.do")
    public String openDashboard(ModelMap model) throws Exception {
        Map<String, Object> dashboardData = restroomService.getDashboardData();
        model.addAttribute("data", dashboardData);
        return "restroom/dashboard";
    }

    // 2. 실시간 데이터 업데이트 (JSON 데이터 반환)
    @RequestMapping(value = "/getDashboardData.do")
    @ResponseBody 
    public Map<String, Object> getDashboardData() throws Exception {
        return restroomService.getDashboardData();
    }
    
    // 3. 임계치 설정 화면
    @RequestMapping(value = "/threshold.do")
    public String openThreshold(ModelMap model) throws Exception {
        return "restroom/threshold"; 
    }

    // 4. 센서 데이터 이력 화면
    @RequestMapping(value = "/data.do")
    public String openSensorData(ModelMap model) throws Exception {
        return "restroom/data"; 
    }

    // 5. 알림 이력 화면
    @RequestMapping(value = "/alarm.do")
    public String openAlarm(ModelMap model) throws Exception {
        return "restroom/alarm"; 
    }
}