package egovframework.example.sample.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.example.sample.service.AlertVO;
import egovframework.example.sample.service.RestroomService;
import egovframework.example.sample.service.SensorVO;

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
    @RequestMapping(value = "/alert.do")
    public String openAlarm(ModelMap model) throws Exception {
        return "restroom/alert"; 
    }
    // 6. 임계치 설정 데이터 로드 (JSON 반환)
    @RequestMapping(value = "/threshold/getSettings.do")
    @ResponseBody
    public Map<String, Object> getThresholdSettings() {
        try {
            return restroomService.getThresholdSettings();
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<String, Object>(); 
        }
    }

    @RequestMapping(value = "/threshold/saveSettings.do")
    @ResponseBody
    public Map<String, String> saveThresholdSettings(@RequestBody Map<String, Object> data) {
        Map<String, String> result = new HashMap<>();
        try {
            restroomService.updateThresholdSettings(data);
            result.put("status", "success");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "fail");
        }
        return result;
    }
    @RequestMapping(value = "/getSensorLogs.do")
    @ResponseBody
    public Map<String, Object> getSensorLogs(
            @RequestParam(value="startDate", required=false) String startDate,
            @RequestParam(value="endDate", required=false) String endDate) throws Exception {
        
        // 파라미터를 Map에 담아 서비스로 전달합니다.
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("startDate", startDate);
        paramMap.put("endDate", endDate);

        Map<String, Object> result = new HashMap<>();
        try {
            List<SensorVO> logs = restroomService.getSensorLogs(paramMap);
            result.put("status", "success");
            result.put("logs", logs);
        } catch (Exception e) {
            result.put("status", "fail");
        }
        return result;
    }
    /**
     * 알림 이력 데이터를 JSON 형태로 반환합니다.
     */
    @RequestMapping(value = "/getAlertLogs.do")
    @ResponseBody
    public Map<String, Object> getAlertLogs(@RequestParam Map<String, Object> paramMap) throws Exception {
        Map<String, Object> result = new HashMap<>();
        try {
            List<AlertVO> logs = restroomService.getAlertLogs(paramMap);
            
            result.put("status", "success");
            result.put("logs", logs);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "fail");
        }
        return result;
    }
    
    @RequestMapping(value = "/login.do")
    public String openLogin() {
        return "restroom/login"; 
    }
    
    @RequestMapping(value = "/loginAction.do")
    @ResponseBody
    public String loginAction(@RequestParam Map<String, Object> param, HttpSession session) throws Exception {
        
        // 1. DB에서 사용자 성명 조회 (restroomService 호출)
        String userName = restroomService.selectAdminLogin(param);
        
        if (userName != null) {
            // 2. 로그인 성공: 세션에 사용자 정보 저장
            session.setAttribute("userId", param.get("id"));
            session.setAttribute("userName", userName);
            return "success";
        } else {
            // 3. 로그인 실패
            return "fail";
        }
    }
    
    @RequestMapping(value = "/logout.do")
    public String logout(HttpSession session) {
        session.invalidate(); // 세션의 모든 정보 삭제
        return "redirect:/login.do"; // 로그인 페이지로 이동
    }
}