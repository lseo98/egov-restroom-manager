package egovframework.example.sample.service.impl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import egovframework.example.sample.service.RestroomService;
import egovframework.example.sample.service.StallVO;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("restroomService")
public class RestroomServiceImpl extends EgovAbstractServiceImpl implements RestroomService {

    @Resource(name="restroomMapper")
    private RestroomMapper restroomMapper;

    @Override
    public List<StallVO> selectStallList() throws Exception {
        return restroomMapper.selectStallList();
    }
}