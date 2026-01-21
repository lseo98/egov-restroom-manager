package egovframework.example.sample.web;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody; 
import egovframework.example.sample.service.RestroomService;
import egovframework.example.sample.service.StallVO;

@Controller
public class RestroomController {

    @Resource(name = "restroomService")
    private RestroomService restroomService;

    // 1. 대시보드 화면 (전체 레이아웃 + 첫 데이터)
    @RequestMapping(value = "/dashboard.do")
    public String openDashboard(ModelMap model) throws Exception {
        List<StallVO> stallList = restroomService.selectStallList();
        model.addAttribute("stallList", stallList);
        return "restroom/dashboard";
    }

    // 2. 실시간 데이터 업데이트 (JSON 데이터만 반환)
    @RequestMapping(value = "/getStallStatus.do")
    @ResponseBody 
    public List<StallVO> getStallStatus() throws Exception {
        return restroomService.selectStallList();
    }
    
    // 3. 임계치 설정 화면
    @RequestMapping(value = "/threshold.do")
    public String openThreshold(ModelMap model) throws Exception {
        return "restroom/threshold"; 
    }

    // 4. 센서 데이터 이력 화면 추가
    @RequestMapping(value = "/data.do")
    public String openSensorData(ModelMap model) throws Exception {
        // 나중에 센서 기록 리스트를 DB에서 가져오려면 여기에 코드를 추가하면 됩니다.
        return "restroom/data"; 
    }

    // 5. 알림 이력 화면 추가
    @RequestMapping(value = "/alarm.do")
    public String openAlarm(ModelMap model) throws Exception {
        // 나중에 발생한 알림 리스트를 DB에서 가져오려면 여기에 코드를 추가하면 됩니다.
        return "restroom/alarm"; 
    }
}