package com.mqtt.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalTime;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.json.JSONArray;
import org.json.JSONObject;

public class MqttTest {
    // 1. 설정 정보
    static String serverIp = "192.168.0.60"; 
    static String broker = "tcp://" + serverIp + ":1883";
    static String dbUrl = "jdbc:mariadb://localhost:3306/sejong"; 
    static String dbUser = "root";
    static String dbPass = "1234";

    static Connection conn = null;
    
    // 날짜가 바뀌었는지 체크하기 위한 변수 (오늘 날짜 저장)
    static String lastProcessDate = java.time.LocalDate.now().toString();
    
    // 알림 종류별로 마지막 발생 시간을 기록할 장부
    static java.util.Map<String, Long> lastAlertTimeMap = new java.util.HashMap<>();

    public static void main(String[] args) {
        try {
            System.out.println(">>> [시스템] 스마트 화장실 관리 모듈 가동 시작...");
            
            // 2. DB 연결
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            System.out.println(">>> [DB] MariaDB 연결 성공!");

            // 3. 소모품 시뮬레이션 시작
            startConsumableSimulation();

            // 4. MQTT 클라이언트 설정
            MqttClient client = new MqttClient(broker, "JavaClient_" + System.currentTimeMillis(), new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setAutomaticReconnect(true); 
            options.setCleanSession(true);

            // 5. 메시지 수신 시 처리 로직
            client.setCallback(new MqttCallback() {
                @Override
                public void messageArrived(String topic, MqttMessage message) throws Exception {
                    String payload = new String(message.getPayload(), "UTF-8");
                    
                    // [로그] 원본 데이터 출력
                    System.out.println("\n===========================================");
                    System.out.println("[데이터 수신] 토픽: " + topic);
                    System.out.println("[원본 JSON] " + payload);
                    
                    try {
                        JSONObject json = new JSONObject(payload);
                        String deviceName = json.optString("deviceName", "이름없음");

                        int stallId = 1; 
                        if (deviceName.contains("책상센서")) stallId = 2;
                        else if (deviceName.contains("식당5번")) stallId = 3;
                        else if (deviceName.contains("식당7번")) stallId = 4;
                        
                        // [재실 데이터]
                        if (json.has("occupancy")) {
                            double val = json.getDouble("occupancy");
                            saveToDb(stallId, "OCCUPANCY", val);
                            updateStallStatus(stallId, val == 1.0);
                        }
                        
                        // [환경 데이터]
                        if (json.has("temperature")) processSensorData("TEMP", json.getDouble("temperature"));
                        if (json.has("humidity")) processSensorData("HUMIDITY", json.getDouble("humidity"));
                        if (json.has("nh3")) processSensorData("NH3", json.getDouble("nh3"));

                        // [피플 카운터]
                        if (json.has("region_trigger_data")) {
                            JSONObject regionData = json.getJSONObject("region_trigger_data");
                            JSONArray regions = regionData.getJSONArray("region_count_data");
                            
                            if (regions.length() > 0) {
                                // 첫 번째 영역의 실제 인원수(current_total)를 가져옵니다.
                                int currentTotal = regions.getJSONObject(0).getInt("current_total");
                                
                                // 고정값 1.0 대신 실제 인원수를 저장합니다.
                                saveToDb(0, "PEOPLE_IN", (double)currentTotal);
                                
                                // 인원수만큼 반복해서 통계를 업데이트하거나 로직을 보정해야 합니다.
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
            client.subscribe("#");
            System.out.println(">>> [MQTT] 서버 구독 성공! 데이터를 기다리는 중...");

            while (true) { Thread.sleep(100); }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 환경 센서 처리 및 임계치 체크
     */
    private static void processSensorData(String type, double value) {
        saveToDb(0, type, value);

        // 1. SQL 쿼리에 alert_interval 추가
        String selectSql = "SELECT min_value, max_value, alert_interval FROM sensor_threshold WHERE sensor_type = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
            pstmt.setString(1, type);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    double min = rs.getDouble("min_value");
                    double max = rs.getDouble("max_value");
                    
                    // 2. DB에서 설정된 분(minute) 값을 읽어옴 (데이터가 없으면 기본값 10분)
                    int intervalMin = rs.getInt("alert_interval");
                    if (rs.wasNull()) intervalMin = 10; 

                    boolean hasMin = !rs.wasNull();

                    if ((hasMin && value < min) || (max > 0 && value > max)) {
                        String alertType = type.equals("TEMP") ? "TEMP_ABNORMAL" : 
                                         type.equals("HUMIDITY") ? "HUMIDITY_ABNORMAL" : "STINK_HIGH";
                        
                        // 3. 분 단위를 밀리초(ms)로 변환하여 전달
                        long dynamicIntervalMs = intervalMin * 60 * 1000L;
                        checkAndCreateAlert(alertType, type + " 수치 이상 발생", "현재값: " + value, dynamicIntervalMs);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [센서처리 에러] " + e.getMessage());
        }
    }

    /**
     * 시간대별 통계 및 오늘 누적 인원 업데이트
     */
    /**
     * [수정] 오늘/어제 동일 시간대까지의 '누적' 인원 비교 로직
     */
    private static void updateVisitorStats() {
        int currentHour = LocalTime.now().getHour();
        checkMidnightReset(); // 자정 리셋 체크

        String updateDaily = "UPDATE visitor_manager SET daily_count = daily_count + 1 WHERE manager_id = 1";
        String updateHourly = "UPDATE hourly_stats SET visit_count = visit_count + 1 WHERE hour_id = ?";
        
        // [핵심] 0시부터 현재 시간(currentHour)까지의 누적 합계를 구하는 쿼리
        String selectCumulative = "SELECT SUM(visit_count) AS today_sum, SUM(yesterday_count) AS yesterday_sum " +
                                  "FROM hourly_stats WHERE hour_id <= ?";
        
        String selectDaily = "SELECT daily_count FROM visitor_manager WHERE manager_id = 1";

        try (PreparedStatement psDaily = conn.prepareStatement(updateDaily);
             PreparedStatement psHourly = conn.prepareStatement(updateHourly);
             PreparedStatement psSum = conn.prepareStatement(selectCumulative);
             PreparedStatement psSelectD = conn.prepareStatement(selectDaily)) {
            
            // 1. 카운트 업데이트
            psDaily.executeUpdate(); 
            psHourly.setInt(1, currentHour);
            psHourly.executeUpdate(); 

            // 2. 누적 합계 비교 출력
            psSum.setInt(1, currentHour);
            try (ResultSet rsSum = psSum.executeQuery()) {
                if (rsSum.next()) {
                    int todayCumulative = rsSum.getInt("today_sum");
                    int yesterdayCumulative = rsSum.getInt("yesterday_sum");
                    int diff = todayCumulative - yesterdayCumulative;
                    
                    String trend = (diff > 0) ? "(어제보다 " + diff + "명 많음)" : 
                                   (diff < 0 ? "(어제보다 " + Math.abs(diff) + "명 적음)" : "(어제와 동일)");
                    
                    System.out.println("\n>>> [누적비교] 0시 ~ " + currentHour + "시 기준");
                    System.out.println(">>> 오늘 누적: " + todayCumulative + "명 / 어제 동시간 누적: " + yesterdayCumulative + "명 " + trend);
                }
            }

            // 3. 10명마다 알림 
            try (ResultSet rsD = psSelectD.executeQuery()) {
                if (rsD.next()) {
                    int count = rsD.getInt("daily_count");
                    if (count > 0 && count % 10 == 0) {
                        createAlert("PEOPLE_OVER", "이용객 누적 알림", "오늘 누적 " + count + "명 돌파");
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [통계 업데이트 에러] " + e.getMessage());
        }
    }
    
    private static void checkMidnightReset() {
        String today = java.time.LocalDate.now().toString();
        
        // 저장된 날짜와 실제 오늘 날짜가 다르면 '자정'이 지난 것으로 판단
        if (!today.equals(lastProcessDate)) {
            System.out.println(">>> [시스템] 날짜 변경 감지! 데이터 백업 및 리셋을 시작합니다.");
            
            String shiftSql = "UPDATE hourly_stats SET yesterday_count = visit_count, visit_count = 0";
            String resetDailySql = "UPDATE visitor_manager SET daily_count = 0 WHERE manager_id = 1";
            
            try (PreparedStatement ps1 = conn.prepareStatement(shiftSql);
                 PreparedStatement ps2 = conn.prepareStatement(resetDailySql)) {
                ps1.executeUpdate();
                ps2.executeUpdate();
                
                lastProcessDate = today; // 기준 날짜를 오늘로 갱신
                System.out.println(">>> [시스템] 자정 리셋 완료.");
            } catch (Exception e) {
                System.out.println(">>> [리셋 에러] " + e.getMessage());
            }
        }
    }

    /**
     * 소모품 시뮬레이션 로직
     */
    private static void updateAndSaveLevel(String typeKey) {
        int randomRefillPoint = (int)(Math.random() * 8) + 3; 
        String updateSql = "UPDATE consumable SET current_level = CASE WHEN current_level <= ? THEN 100 ELSE current_level - 1 END WHERE type_key = ?";
        String selectSql = "SELECT current_level, threshold FROM consumable WHERE type_key = ?";
        
        try (PreparedStatement pstmtUpdate = conn.prepareStatement(updateSql);
             PreparedStatement pstmtSelect = conn.prepareStatement(selectSql)) {
            
            pstmtUpdate.setInt(1, randomRefillPoint);
            pstmtUpdate.setString(2, typeKey);
            pstmtUpdate.executeUpdate();
            
            pstmtSelect.setString(1, typeKey);
            try (ResultSet rs = pstmtSelect.executeQuery()) {
                if (rs.next()) {
                    int level = rs.getInt("current_level");
                    int threshold = rs.getInt("threshold");
                    saveToDb(0, typeKey, (double)level);

                    if (level == threshold) {
                        createAlert("CONSUMABLE_LOW", typeKey + " 잔량 부족", "현재 잔량: " + level + "%");
                    }
                }
            }
        } catch (Exception e) {}
    }

    /**
     * [로그 포함] DB 저장 함수
     */
    private static void saveToDb(int stallId, String type, double value) {
        String sql = "INSERT INTO sensor_reading (stall_id, sensor_type, value) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { 
            if (stallId > 0) pstmt.setInt(1, stallId); 
            else pstmt.setNull(1, java.sql.Types.INTEGER); 
            pstmt.setString(2, type);
            pstmt.setDouble(3, value);
            pstmt.executeUpdate();

            // [로그] 저장 내용 출력
            if (stallId > 0) {
                System.out.println(">>> [DB저장] " + type + "(" + stallId + "번 칸): " + value);
            } else {
                System.out.println(">>> [DB저장] " + type + ": " + value);
            }
        } catch (Exception e) {
            System.out.println(">>> [DB저장 에러] " + e.getMessage());
        }
    }

    /**
     * [로그 포함] 칸 상태 업데이트 함수
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

    private static void createAlert(String type, String title, String msg) {
        // 알림 종류를 DB 설정 테이블의 이름과 맞추는 작업
        String sensorType = "";
        if (type.contains("TEMP")) sensorType = "TEMP";
        else if (type.contains("HUMIDITY")) sensorType = "HUMIDITY";
        else if (type.contains("STINK")) sensorType = "NH3";
        else if (type.contains("PEOPLE")) sensorType = "PEOPLE_IN";
        else if (type.contains("CONSUMABLE")) {
            // 소모품은 제목(title)에 포함된 단어로 비누인지 타월인지 구분
            sensorType = title.contains("LIQUID_SOAP") ? "LIQUID_SOAP" : "PAPER_TOWEL";
        }

        // DB에서 이 센서의 알림이 켜져 있는지 확인
        if (!isAlertEnabled(sensorType)) {
            System.out.println(">>> [알림 차단됨] " + sensorType + " 설정이 OFF 상태입니다.");
            return; // 0(OFF)이면 여기서 함수가 종료되어 DB에 저장되지 않음
        }

        // 알림이 ON(1)일 때만 실행되는 기존 로직
        String sql = "INSERT INTO alert (alert_type, title, message) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, type);
            pstmt.setString(2, title);
            pstmt.setString(3, msg);
            pstmt.executeUpdate();
            System.out.println(">>> [알림 생성] " + title + " (" + type + ")");
        } catch (Exception e) {
            System.out.println(">>> [알림 저장 에러] " + e.getMessage());
        }
    }
    
 // DB의 alert_setting 테이블에서 ON/OFF 상태를 읽어오는 함수
    private static boolean isAlertEnabled(String sensorType) {
        String sql = "SELECT is_enabled FROM alert_setting WHERE sensor_type = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sensorType);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("is_enabled") == 1; // 1이면 true, 0이면 false
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [설정 확인 에러] " + e.getMessage());
        }
        return false; // 에러 나거나 설정 없으면 기본적으로 끔
    }
    
    private static void checkAndCreateAlert(String type, String title, String msg, long dynamicInterval) {
        long currentTime = System.currentTimeMillis();
        long lastTime = lastAlertTimeMap.getOrDefault(type, 0L);

        if (currentTime - lastTime > dynamicInterval) {
            createAlert(type, title, msg);
            lastAlertTimeMap.put(type, currentTime); 
        }
    }

    private static void startConsumableSimulation() {
        new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(15000);
                    updateAndSaveLevel("LIQUID_SOAP");
                    updateAndSaveLevel("PAPER_TOWEL");
                } catch (Exception e) {}
            }
        }).start();
    }
}