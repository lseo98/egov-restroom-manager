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

    // 1. 처음 화면에 접속할 때 전체 레이아웃을 그려주는 주소
    @RequestMapping(value = "/dashboard.do")
    public String openDashboard(ModelMap model) throws Exception {
        List<StallVO> stallList = restroomService.selectStallList();
        model.addAttribute("stallList", stallList);
        return "restroom/dashboard";
    }

    // 2. 화면 새로고침 없이 '데이터'만 3초마다 보내주는 주소
    @RequestMapping(value = "/getStallStatus.do")
    @ResponseBody // JSP 파일이 아니라 '순수 데이터'만 보낸다는 선언
    public List<StallVO> getStallStatus() throws Exception {
        // DB에서 현재 칸들의 상태 리스트만 딱 뽑아서 보냅니다.
        return restroomService.selectStallList();
    }
}