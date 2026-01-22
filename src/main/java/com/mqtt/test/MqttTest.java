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

public class MqttTest {
    // 설정 정보를 담을 변수들
    static String serverIp; 
    static String broker;
    static String dbUrl; 
    static String dbUser;
    static String dbPass;

    static Connection conn = null;
    static String lastProcessDate = ""; 
    static java.util.Map<String, Long> lastAlertTimeMap = new java.util.HashMap<>();

    public static void main(String[] args) {
        try {
            // 1. 설정 파일 로드
            loadConfig();
            
            System.out.println(">>> [시스템] 스마트 화장실 관리 모듈 가동 시작...");
            
            // 2. DB 연결
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            System.out.println(">>> [DB] MariaDB 연결 성공!");

            checkMidnightReset();
            startConsumableSimulation();

            // 3. MQTT 클라이언트 설정
            MqttClient client = new MqttClient(broker, "JavaClient_" + System.currentTimeMillis(), new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setAutomaticReconnect(true); 
            options.setCleanSession(true);

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

                        int stallId = 1; 
                        if (deviceName.contains("책상센서")) stallId = 2;
                        else if (deviceName.contains("식당5번")) stallId = 3;
                        else if (deviceName.contains("식당7번")) stallId = 4;
                        
                        if (json.has("occupancy")) {
                            double val = json.getDouble("occupancy");
                            saveToDb(stallId, "OCCUPANCY", val);
                            updateStallStatus(stallId, val == 1.0);
                        }
                        
                        if (json.has("temperature")) processSensorData("TEMP", json.getDouble("temperature"));
                        if (json.has("humidity")) processSensorData("HUMIDITY", json.getDouble("humidity"));
                        if (json.has("nh3")) processSensorData("NH3", json.getDouble("nh3"));

                        if (json.has("region_trigger_data")) {
                            JSONObject regionData = json.getJSONObject("region_trigger_data");
                            JSONArray regions = regionData.getJSONArray("region_count_data");
                            if (regions.length() > 0) {
                                int currentTotal = regions.getJSONObject(0).getInt("current_total");
                                saveToDb(0, "PEOPLE_IN", (double)currentTotal);
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
     * 외부 설정 파일을 읽어오는 함수
     */
    private static void loadConfig() throws IOException {
        Properties prop = new Properties();
        
        // 프로젝트의 src/main/resources 폴더 내 파일을 읽어옵니다.
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

    private static void processSensorData(String type, double value) {
        saveToDb(0, type, value);
        String selectSql = "SELECT min_value, max_value, alert_interval FROM sensor_threshold WHERE sensor_type = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
            pstmt.setString(1, type);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    double min = rs.getDouble("min_value");
                    double max = rs.getDouble("max_value");
                    int intervalMin = rs.getInt("alert_interval");
                    if (rs.wasNull()) intervalMin = 10; 
                    if ((!rs.wasNull() && value < min) || (max > 0 && value > max)) {
                        String alertType = type.equals("TEMP") ? "TEMP_ABNORMAL" : 
                                         type.equals("HUMIDITY") ? "HUMIDITY_ABNORMAL" : "STINK_HIGH";
                        long dynamicIntervalMs = intervalMin * 60 * 1000L;
                        checkAndCreateAlert(alertType, type + " 수치 이상 발생", "현재값: " + value, dynamicIntervalMs);
                    }
                }
            }
        } catch (Exception e) {}
    }

    private static void updateVisitorStats() {
        int currentHour = LocalTime.now().getHour();
        checkMidnightReset(); 
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

    private static void saveToDb(int stallId, String type, double value) {
        String sql = "INSERT INTO sensor_reading (stall_id, sensor_type, value) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { 
            if (stallId > 0) pstmt.setInt(1, stallId); 
            else pstmt.setNull(1, java.sql.Types.INTEGER); 
            pstmt.setString(2, type);
            pstmt.setDouble(3, value);
            pstmt.executeUpdate();
            if (stallId > 0) System.out.println(">>> [DB저장] " + type + "(" + stallId + "번 칸): " + value);
            else System.out.println(">>> [DB저장] " + type + ": " + value);
        } catch (Exception e) {
            System.out.println(">>> [DB저장 에러] " + e.getMessage());
        }
    }

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
        String sensorType = "";
        if (type.contains("TEMP")) sensorType = "TEMP";
        else if (type.contains("HUMIDITY")) sensorType = "HUMIDITY";
        else if (type.contains("STINK")) sensorType = "NH3";
        else if (type.contains("PEOPLE")) sensorType = "PEOPLE_IN";
        else if (type.contains("CONSUMABLE")) sensorType = title.contains("LIQUID_SOAP") ? "LIQUID_SOAP" : "PAPER_TOWEL";
        if (!isAlertEnabled(sensorType)) return;
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