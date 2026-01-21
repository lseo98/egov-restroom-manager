package egovframework.example.sample.service.impl;

import java.util.List;
import egovframework.example.sample.service.StallVO;
import egovframework.rte.psl.dataaccess.mapper.Mapper; 

@Mapper("restroomMapper")
public interface RestroomMapper {
    /** 모든 칸의 재실 현황 조회 */
    List<StallVO> selectStallList() throws Exception;
}