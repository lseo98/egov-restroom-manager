package com.mqtt.test;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * 서버가 시작될 때 MQTT 로직을 자동으로 실행해주는 리스너입니다.
 */
@WebListener
public class AppStartListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // 서버 가동 시 실행
        System.out.println("===========================================");
        System.out.println(">>> [시스템] 서버 가동 감지! MQTT 모듈을 자동으로 시작합니다.");
        System.out.println("===========================================");

        // MqttTest의 main 함수를 별도의 쓰레드에서 실행
        new Thread(() -> {
            try {
                MqttTest.main(new String[0]);
            } catch (Exception e) {
                System.out.println(">>> [리스너 에러] MQTT 실행 중 오류 발생: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println(">>> [시스템] 서버가 종료되어 MQTT 모듈을 정지합니다.");
    }
}