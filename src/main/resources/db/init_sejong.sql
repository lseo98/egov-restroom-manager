-- 1. 기존 DB가 있으면 삭제
DROP DATABASE IF EXISTS sejong;

-- 2. DB 새로 만들기
CREATE DATABASE sejong;
USE sejong;

-- 3. 공간 (stall) 테이블 생성
CREATE TABLE stall (
    stall_id INT AUTO_INCREMENT PRIMARY KEY,
    stall_name VARCHAR(50) NOT NULL,
    is_occupied TINYINT(1) DEFAULT 0
) ENGINE=InnoDB;

-- 4. 소모품 (consumable) 테이블 생성
CREATE TABLE consumable (
    consumable_id INT AUTO_INCREMENT PRIMARY KEY,
    type_key VARCHAR(50) UNIQUE NOT NULL,
    threshold INT NOT NULL DEFAULT 10,
    unit VARCHAR(10) NOT NULL DEFAULT '%',
    current_level INT DEFAULT 100
) ENGINE=InnoDB;

-- 5. 센서 임계값 (sensor_threshold) 테이블
CREATE TABLE sensor_threshold (
    threshold_id INT AUTO_INCREMENT PRIMARY KEY,
    sensor_type ENUM('TEMP', 'HUMIDITY', 'NH3', 'PEOPLE_IN') UNIQUE NOT NULL,
    min_value DECIMAL(10, 2),
    max_value DECIMAL(10, 2),
    unit VARCHAR(10)
) ENGINE=InnoDB;

-- 6. 방문객 관리 (visitor_manager) : 오늘 총 누적 및 10명 알림용
CREATE TABLE visitor_manager (
    manager_id INT PRIMARY KEY DEFAULT 1,
    daily_count INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (manager_id = 1)
) ENGINE=InnoDB;

-- 7. 시간별 통계 (hourly_stats) : 0시~23시 기록용 
CREATE TABLE hourly_stats (
    hour_id INT PRIMARY KEY,      -- 0, 1, 2 ... 23 (시간이 곧 ID)
    visit_count INT DEFAULT 0,     -- 해당 시간대 방문객 수
    yesterday_count INT DEFAULT 0    -- 전날 수치
) ENGINE=InnoDB;

-- 8. 센서 데이터 (sensor_reading) 테이블 생성
CREATE TABLE sensor_reading (
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    stall_id INT,
    sensor_type ENUM('TEMP', 'HUMIDITY', 'OCCUPANCY', 'NH3', 'PEOPLE_IN', 'LIQUID_SOAP', 'PAPER_TOWEL') NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sensor_stall FOREIGN KEY (stall_id) REFERENCES stall(stall_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. 알림 (alert) 테이블 생성
CREATE TABLE alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    alert_type ENUM('PEOPLE_OVER', 'CONSUMABLE_LOW', 'STINK_HIGH', 'TEMP_ABNORMAL', 'HUMIDITY_ABNORMAL') NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 10. 초기 데이터 삽입
INSERT INTO stall (stall_name) VALUES ('1번 칸'), ('2번 칸'), ('3번 칸'), ('4번 칸');

INSERT INTO consumable (type_key, threshold, unit, current_level) VALUES 
('LIQUID_SOAP', 10, '%', 80),
('PAPER_TOWEL', 10, '%', 40);

INSERT INTO sensor_threshold (sensor_type, min_value, max_value, unit) VALUES 
('TEMP', 18.00, 27.00, '℃'),
('HUMIDITY', 40.00, 60.00, '%'),
('NH3', 5.00, 10.00, 'ppm'),
('PEOPLE_IN', NULL, 10.00, '명');

-- 관리자 한 줄 생성
INSERT INTO visitor_manager (manager_id, daily_count) VALUES (1, 0);

-- 24개 시간대 미리 생성 
INSERT INTO hourly_stats (hour_id) VALUES 
(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),
(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23);

ALTER TABLE sensor_threshold ADD COLUMN alert_interval INT DEFAULT 10;

-- 11. 알림 온오프 설정 테이블
CREATE TABLE alert_setting (
    sensor_type VARCHAR(20) PRIMARY KEY,
    is_enabled TINYINT(1) DEFAULT 1 -- 1: 켬, 0: 끔
) ENGINE=InnoDB;

-- 6개 항목 초기값 설정 (모두 켜짐 상태)
INSERT INTO alert_setting (sensor_type) VALUES 
('TEMP'), 
('HUMIDITY'), 
('NH3'), 
('PEOPLE_IN'), 
('LIQUID_SOAP'), 
('PAPER_TOWEL');

ALTER TABLE sensor_reading ADD COLUMN status VARCHAR(20) DEFAULT 'normal';