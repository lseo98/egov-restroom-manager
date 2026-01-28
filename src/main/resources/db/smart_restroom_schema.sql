-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        12.1.2-MariaDB - MariaDB Server
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- sejong 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `sejong` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `sejong`;

-- 테이블 sejong.admin_user 구조 내보내기
CREATE TABLE IF NOT EXISTS `admin_user` (
  `user_id` varchar(20) NOT NULL,
  `user_pw` varchar(100) NOT NULL,
  `user_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.alert 구조 내보내기
CREATE TABLE IF NOT EXISTS `alert` (
  `alert_id` int(11) NOT NULL AUTO_INCREMENT,
  `alert_type` varchar(50) NOT NULL,
  `severity` enum('WARNING','CRITICAL') NOT NULL DEFAULT 'WARNING',
  `content` varchar(255) DEFAULT NULL,
  `value` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`alert_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1183 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.alert_setting 구조 내보내기
CREATE TABLE IF NOT EXISTS `alert_setting` (
  `sensor_type` varchar(20) NOT NULL,
  `is_enabled` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`sensor_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.consumable 구조 내보내기
CREATE TABLE IF NOT EXISTS `consumable` (
  `consumable_id` int(11) NOT NULL AUTO_INCREMENT,
  `type_key` varchar(50) NOT NULL,
  `threshold` int(11) NOT NULL DEFAULT 10,
  `unit` varchar(10) NOT NULL DEFAULT '%',
  `current_level` int(11) DEFAULT 100,
  PRIMARY KEY (`consumable_id`),
  UNIQUE KEY `type_key` (`type_key`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.hourly_stats 구조 내보내기
CREATE TABLE IF NOT EXISTS `hourly_stats` (
  `hour_id` int(11) NOT NULL,
  `visit_count` int(11) DEFAULT 0,
  `yesterday_count` int(11) DEFAULT 0,
  PRIMARY KEY (`hour_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.sensor_reading 구조 내보내기
CREATE TABLE IF NOT EXISTS `sensor_reading` (
  `reading_id` int(11) NOT NULL AUTO_INCREMENT,
  `stall_id` int(11) DEFAULT NULL,
  `sensor_type` enum('TEMP','HUMIDITY','OCCUPANCY','NH3','PEOPLE_IN','LIQUID_SOAP','PAPER_TOWEL') NOT NULL,
  `value` varchar(50) DEFAULT NULL,
  `measured_at` timestamp NULL DEFAULT current_timestamp(),
  `status` varchar(20) DEFAULT 'normal',
  PRIMARY KEY (`reading_id`),
  KEY `fk_sensor_stall` (`stall_id`),
  CONSTRAINT `fk_sensor_stall` FOREIGN KEY (`stall_id`) REFERENCES `stall` (`stall_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18054 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.sensor_threshold 구조 내보내기
CREATE TABLE IF NOT EXISTS `sensor_threshold` (
  `threshold_id` int(11) NOT NULL AUTO_INCREMENT,
  `sensor_type` enum('TEMP','HUMIDITY','NH3','PEOPLE_IN') NOT NULL,
  `min_value` decimal(10,2) DEFAULT NULL,
  `max_value` decimal(10,2) DEFAULT NULL,
  `unit` varchar(10) DEFAULT NULL,
  `alert_interval` int(11) DEFAULT 10,
  PRIMARY KEY (`threshold_id`),
  UNIQUE KEY `sensor_type` (`sensor_type`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.stall 구조 내보내기
CREATE TABLE IF NOT EXISTS `stall` (
  `stall_id` int(11) NOT NULL AUTO_INCREMENT,
  `stall_name` varchar(50) NOT NULL,
  `is_occupied` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`stall_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 sejong.visitor_manager 구조 내보내기
CREATE TABLE IF NOT EXISTS `visitor_manager` (
  `manager_id` int(11) NOT NULL DEFAULT 1,
  `daily_count` int(11) DEFAULT 0,
  `last_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`manager_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`manager_id` = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
