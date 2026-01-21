package egovframework.example.sample.service;

import java.util.List;

public interface RestroomService {
    /** 재실 리스트 가져오기 기능 */
    List<StallVO> selectStallList() throws Exception;
}