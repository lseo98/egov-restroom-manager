package egovframework.example.sample.service;

import java.io.Serializable;

/** 화장실 칸 상태를 담는 객체 */
public class StallVO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int stallId;      // stall_id
    private String stallName; // stall_name
    private int isOccupied;   // is_occupied (0:비어있음, 1:사용중)

    // Getter & Setter
    public int getStallId() { return stallId; }
    public void setStallId(int stallId) { this.stallId = stallId; }
    public String getStallName() { return stallName; }
    public void setStallName(String stallName) { this.stallName = stallName; }
    public int getIsOccupied() { return isOccupied; }
    public void setIsOccupied(int isOccupied) { this.isOccupied = isOccupied; }
}