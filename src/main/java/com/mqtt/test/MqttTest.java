package com.mqtt.test;

import java.io.FileNotFoundException; 
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalTime;
import java.util.Properties;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * 스마트 화장실 IoT 데이터 관리 및 모니터링 시스템
 * MQTT를 통해 수신된 센서 데이터를 분석하여 DB 저장 및 알림을 수행함
 */
public class MqttTest {
    // 서버 및 데이터베이스 설정 변수
    static String serverIp; 
    static String broker;
    static String dbUrl; 
    static String dbUser;
    static String dbPass;

    static Connection conn = null;
    static String lastProcessDate = ""; 
    // 알림 중복 방지를 위한 센서별 마지막 발송 시간 저장
    static java.util.Map<String, Long> lastAlertTimeMap = new java.util.HashMap<>();

    public static void main(String[] args) {
        try {
            // 1. 시스템 설정 로드 (config.properties)
            loadConfig();
            
            System.out.println(">>> [시스템] 스마트 화장실 관리 모듈 가동 시작...");
            
            // 2. 데이터베이스(MariaDB) 연결 설정
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            System.out.println(">>> [DB] MariaDB 연결 성공!");

            // 3. 자정 통계 초기화 확인 및 소모품 시뮬레이션 시작
            checkMidnightReset();
            startConsumableSimulation();

            // 4. MQTT 클라이언트 초기화 및 연결 설정
            MqttClient client = new MqttClient(broker, "JavaClient_" + System.currentTimeMillis(), new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setAutomaticReconnect(true); 
            options.setCleanSession(true);

            // 5. MQTT 메시지 수신 이벤트 콜백 설정
            client.setCallback(new MqttCallback() {
                @Override
                public void messageArrived(String topic, MqttMessage message) throws Exception {
                    String payload = new String(message.getPayload(), "UTF-8");
                    System.out.println("\n===========================================");
                    System.out.println("[데이터 수신] 토픽: " + topic);
                    System.out.println("[원본 JSON] " + payload);
                    
                    try {
                        JSONObject json = new JSONObject(payload);
                        String deviceName = json.optString("deviceName", "이름없음");

                        // 장치 이름에 따른 화장실 칸(Stall) ID 매핑
                        int stallId = 1; 
                        if (deviceName.contains("책상센서")) stallId = 2;
                        else if (deviceName.contains("식당5번")) stallId = 3;
                        else if (deviceName.contains("식당7번")) stallId = 4;
                        
                        // 재실 센서 데이터 처리
                        if (json.has("occupancy")) {
                            double val = json.getDouble("occupancy");
                            String occStatus = (val == 1.0) ? "occupied" : "vacant"; 
                            
                            saveToDb(stallId, "OCCUPANCY", String.valueOf((int) val), occStatus);
                            updateStallStatus(stallId, val == 1.0);
                        }
                        
                        // 환경 센서 데이터(온도, 습도, 암모니아) 처리
                        if (json.has("temperature")) processSensorData("TEMP", json.getDouble("temperature"));
                        if (json.has("humidity")) processSensorData("HUMIDITY", json.getDouble("humidity"));
                        if (json.has("nh3")) processSensorData("NH3", json.getDouble("nh3"));

                        // 구역 내 유동인구 데이터 처리
                        if (json.has("region_trigger_data")) {
                            JSONObject regionData = json.getJSONObject("region_trigger_data");
                            JSONArray regions = regionData.getJSONArray("region_count_data");
                            if (regions.length() > 0) {
                                int currentTotal = regions.getJSONObject(0).getInt("current_total");
                                // PEOPLE_IN 데이터는 별도의 상태 없이 저장
                                saveToDb(0, "PEOPLE_IN", String.valueOf(currentTotal), null);
                                for(int i=0; i < currentTotal; i++) {
                                    updateVisitorStats();
                                }
                            }
                        }
                    } catch (Exception e) {
                        System.out.println(">>> [에러] JSON 처리 실패: " + e.getMessage());
                    }
                }
                @Override public void connectionLost(Throwable cause) {}
                @Override public void deliveryComplete(IMqttDeliveryToken token) {}
            });

            client.connect(options);
            client.subscribe("#"); // 모든 토픽 구독
            System.out.println(">>> [MQTT] 서버 구독 성공! 데이터를 기다리는 중...");

            while (true) { Thread.sleep(100); }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 외부 설정 파일(config.properties) 로드
     */
    private static void loadConfig() throws IOException {
        Properties prop = new Properties();
        try (InputStream is = MqttTest.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (is == null) {
                throw new FileNotFoundException("config.properties 파일을 resources 폴더에서 찾을 수 없습니다.");
            }
            prop.load(is);
            serverIp = prop.getProperty("server.ip");
            broker = "tcp://" + serverIp + ":1883";
            dbUrl = prop.getProperty("db.url");
            dbUser = prop.getProperty("db.user");
            dbPass = prop.getProperty("db.pass");
        }
    }

    /**
     * 날짜 변경 시 방문객 통계 초기화 및 어제 데이터 백업
     */
    private static void checkMidnightReset() {
        String todayDate = java.time.LocalDate.now().toString();
        String lastUpdateInDb = "";
        String selectSql = "SELECT last_updated FROM visitor_manager WHERE manager_id = 1";
        try (PreparedStatement pstmt = conn.prepareStatement(selectSql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                Timestamp ts = rs.getTimestamp("last_updated");
                if (ts != null) {
                    lastUpdateInDb = ts.toLocalDateTime().toLocalDate().toString();
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [날짜 확인 에러] " + e.getMessage());
        }

        // DB 기록 날짜와 오늘 날짜가 다를 경우 초기화 수행
        if (!todayDate.equals(lastUpdateInDb)) {
            System.out.println(">>> [시스템] 날짜 변경 감지 (DB: " + lastUpdateInDb + " -> 오늘: " + todayDate + ")");
            String shiftSql = "UPDATE hourly_stats SET yesterday_count = visit_count, visit_count = 0";
            String resetSql = "UPDATE visitor_manager SET daily_count = 0, last_updated = CURRENT_TIMESTAMP WHERE manager_id = 1";
            try (PreparedStatement ps1 = conn.prepareStatement(shiftSql);
                 PreparedStatement ps2 = conn.prepareStatement(resetSql)) {
                ps1.executeUpdate();
                ps2.executeUpdate();
                System.out.println(">>> [시스템] 자정 리셋 및 날짜 갱신 완료.");
            } catch (Exception e) {
                System.out.println(">>> [리셋 에러] " + e.getMessage());
            }
        }
        lastProcessDate = todayDate;
    }

    /**
     * 센서 임계치 비교 및 상태(normal, warning, critical) 판별
     */
    private static void processSensorData(String type, double value) {
        String status = "normal";
        String alertType = "";
        String alertTitle = "";
        String unit = "";
        
        String selectSql = "SELECT min_value, max_value, alert_interval, unit FROM sensor_threshold WHERE sensor_type = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
            pstmt.setString(1, type);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    double minVal = rs.getDouble("min_value");
                    double maxVal = rs.getDouble("max_value");
                    int intervalMin = rs.getInt("alert_interval");
                    if (rs.wasNull()) intervalMin = 10;
                    
                    unit = rs.getString("unit");
                    if (rs.wasNull()) unit = "";

                    // 상태 판별 로직
                    if (type.equals("NH3")) {
                        // NH3는 주의(min 이상)와 위험(max 이상) 2단계 알림
                        if (value >= maxVal) { 
                            status = "critical";
                            alertType = "NH3";
                            alertTitle = "악취 [위험] 감지";
                        } else if (value >= minVal) {
                            status = "warning";
                            alertType = "NH3";
                            alertTitle = "악취 [주의] 발생";
                        }
                    } else {
                        // 기타 센서는 범위를 벗어나면 무조건 warning 처리
                        if ((!rs.wasNull() && value < minVal) || (maxVal > 0 && value > maxVal)) {
                            status = "warning";
                            alertType = type;
                            alertTitle = type + " 수치 이상 발생";
                        }
                    }
                    
                    String valueWithUnit = value + unit;
                    saveToDb(0, type, valueWithUnit, status);

                    // 이상 수치 발견 시 알림 주기(dynamicIntervalMs)에 맞춰 알림 생성
                    if (!status.equals("normal")) {
                        long dynamicIntervalMs = intervalMin * 60 * 1000L;
                        checkAndCreateAlert(alertType, status, alertTitle, "현재값: " + value + unit, dynamicIntervalMs);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [데이터 처리 에러] " + e.getMessage());
        }
    }
    
    /**
     * 방문객 통계 업데이트 (영업시간 제한 로직 포함)
     */
    private static void updateVisitorStats() {
        int currentHour = LocalTime.now().getHour();
        checkMidnightReset(); 
        
        // 08:00 ~ 18:59 사이의 데이터만 통계에 반영
        if (currentHour < 8 || currentHour > 18) {
            System.out.println(">>> [시스템] 영업 외 시간(08:00~18:59 제외) 방문객은 통계에서 제외합니다. (현재: " + currentHour + "시)");
            return;
        }
        
        String updateDaily = "UPDATE visitor_manager SET daily_count = daily_count + 1 WHERE manager_id = 1";
        String updateHourly = "UPDATE hourly_stats SET visit_count = visit_count + 1 WHERE hour_id = ?";
        String selectCumulative = "SELECT SUM(visit_count) AS today_sum, SUM(yesterday_count) AS yesterday_sum FROM hourly_stats WHERE hour_id <= ?";
        String selectDaily = "SELECT daily_count FROM visitor_manager WHERE manager_id = 1";
        try (PreparedStatement psDaily = conn.prepareStatement(updateDaily);
             PreparedStatement psHourly = conn.prepareStatement(updateHourly);
             PreparedStatement psSum = conn.prepareStatement(selectCumulative);
             PreparedStatement psSelectD = conn.prepareStatement(selectDaily)) {
            psDaily.executeUpdate(); 
            psHourly.setInt(1, currentHour);
            psHourly.executeUpdate(); 
            
            psSum.setInt(1, currentHour);
            try (ResultSet rsSum = psSum.executeQuery()) {
                if (rsSum.next()) {
                    int todayCumulative = rsSum.getInt("today_sum");
                    int yesterdayCumulative = rsSum.getInt("yesterday_sum");
                    int diff = todayCumulative - yesterdayCumulative;
                    String trend = (diff > 0) ? "(어제보다 " + diff + "명 많음)" : (diff < 0 ? "(어제보다 " + Math.abs(diff) + "명 적음)" : "(어제와 동일)");
                    System.out.println("\n>>> [누적비교] 0시 ~ " + currentHour + "시 기준");
                    System.out.println(">>> 오늘 누적: " + todayCumulative + "명 / 어제 동시간 누적: " + yesterdayCumulative + "명 " + trend);
                }
            }
            // 10명 단위로 누적 이용객 알림 생성
            try (ResultSet rsD = psSelectD.executeQuery()) {
                if (rsD.next()) {
                    int count = rsD.getInt("daily_count");
                    if (count > 0 && count % 10 == 0) {
                    	createAlert("PEOPLE_IN", "warning", "이용객 누적 알림", "오늘 누적 " + count + "명 돌파");
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [통계 업데이트 에러] " + e.getMessage());
        }
    }

    /**
     * 소모품 잔량 시뮬레이션 및 부족 시 알림 처리
     */
    private static void updateAndSaveLevel(String typeKey) {
        String selectSql = "SELECT current_level, threshold FROM consumable WHERE type_key = ?";
        String updateSql = "UPDATE consumable SET current_level = ? WHERE type_key = ?";
        
        try (PreparedStatement psSelect = conn.prepareStatement(selectSql);
             PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
            
            psSelect.setString(1, typeKey);
            try (ResultSet rs = psSelect.executeQuery()) {
                if (rs.next()) {
                    int current = rs.getInt("current_level");
                    int threshold = rs.getInt("threshold");
                    int nextLevel;
                    String status = "normal";

                    // 0% 도달 시 즉시 100% 리필, 그 외에는 랜덤(2~7%) 감소
                    if (current <= 0) {
                        nextLevel = 100;
                        status = "refilled";
                    } else {
                        int decrease = (int)(Math.random() * 6) + 2; 
                        nextLevel = Math.max(0, current - decrease);
                        
                        if (nextLevel <= 0) {
                            nextLevel = 0;
                            status = "warning"; 
                        } else if (nextLevel <= threshold) {
                            status = "warning";
                        }
                    }

                    psUpdate.setInt(1, nextLevel);
                    psUpdate.setString(2, typeKey);
                    psUpdate.executeUpdate();
                    
                    saveToDb(0, typeKey, nextLevel + "%", status);

                    if (status.equals("warning")) {
                    	createAlert(typeKey, status, typeKey + " 잔량 부족", "현재 잔량: " + nextLevel + "%");
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [소모품 에러] " + e.getMessage());
        }
    }

    /**
     * 센서 데이터를 DB(sensor_reading)에 저장
     */
    private static void saveToDb(int stallId, String type, String value, String status) {
        String sql = "INSERT INTO sensor_reading (stall_id, sensor_type, value, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { 
            if (stallId > 0) pstmt.setInt(1, stallId); 
            else pstmt.setNull(1, java.sql.Types.INTEGER); 
            pstmt.setString(2, type);
            pstmt.setString(3, value);
            pstmt.setString(4, status);
            pstmt.executeUpdate();
            
            if (stallId > 0) System.out.println(">>> [DB저장] " + type + "(" + stallId + "번 칸): " + value);
            System.out.println(">>> [DB저장] " + type + ": " + value + " (상태: " + status + ")");
        } catch (Exception e) {
            System.out.println(">>> [DB저장 에러] " + e.getMessage());
        }
    }

    /**
     * 화장실 개별 칸의 실시간 재실 상태 업데이트
     */
    private static void updateStallStatus(int stallId, boolean isOccupied) {
        String sql = "UPDATE stall SET is_occupied = ? WHERE stall_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, isOccupied ? 1 : 0);
            pstmt.setInt(2, stallId);
            pstmt.executeUpdate();
            System.out.println(">>> [상태변경] " + stallId + "번 칸: " + (isOccupied ? "사용중" : "비었음"));
        } catch (Exception e) {}
    }

    /**
     * 알림 데이터 생성 (설정 테이블의 On/Off 여부 확인 포함)
     */
    private static void createAlert(String type, String severity, String title, String msg) {
        String sensorType = type;
        
        if (!isAlertEnabled(sensorType)) return;
        
        // ✅ 1. SQL 문에서 컬럼명을 DB와 동일하게 수정 [cite: 2026-01-26]
        // (title -> content / message -> value)
        String sql = "INSERT INTO alert (alert_type, severity, content, value) VALUES (?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, type);           // alert_type
            pstmt.setString(2, severity.toUpperCase()); // severity
            pstmt.setString(3, title);          // content (자바 변수명 title은 그대로 써도 무방)
            pstmt.setString(4, msg);            // value (자바 변수명 msg는 그대로 써도 무방)
            
            pstmt.executeUpdate();
            System.out.println(">>> [알림 생성] " + title + " [" + severity + "]");
        } catch (Exception e) {
            // 이제 여기서 "Unknown column" 에러가 나지 않을 거예요! [cite: 2026-01-26]
            System.out.println(">>> [알림 저장 에러] " + e.getMessage());
        }
    }
    
    /**
     * 특정 센서의 알림 설정 활성화 여부 확인
     */
    private static boolean isAlertEnabled(String sensorType) {
        String sql = "SELECT is_enabled FROM alert_setting WHERE sensor_type = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sensorType);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt("is_enabled") == 1;
            }
        } catch (Exception e) {}
        return false;
    }
    
    /**
     * 중복 알림 방지를 위한 발송 주기 체크 후 알림 생성
     */
    private static void checkAndCreateAlert(String type, String severity, String title, String msg, long dynamicInterval) {
        long currentTime = System.currentTimeMillis();
        long lastTime = lastAlertTimeMap.getOrDefault(type, 0L);
        
        // 지정된 간격이 경과했을 때만 알림 발생
        if (currentTime - lastTime > dynamicInterval) {
        	createAlert(type, severity, title, msg);
            lastAlertTimeMap.put(type, currentTime); 
        }
    }

    /**
     * 소모품(비누, 타올) 시뮬레이션을 위한 백그라운드 스레드 시작
     */
    private static void startConsumableSimulation() {
        new Thread(() -> {
            while (true) {
                try {
                    // 1분마다 감소 로직 수행
                    Thread.sleep(60000);
                    updateAndSaveLevel("LIQUID_SOAP");
                    updateAndSaveLevel("PAPER_TOWEL");
                } catch (Exception e) {}
            }
        }).start();
    }
}