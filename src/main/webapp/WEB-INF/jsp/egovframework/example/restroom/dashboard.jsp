<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Restroom Management System</title>

    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&family=Roboto+Mono&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <!-- ✅ Chart.js 제거 / ✅ Apache ECharts 추가 -->
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>

    <style>
        html, body { margin: 0; padding: 0; height: 100vh; width: 100vw; overflow: hidden; font-family: 'Noto Sans KR', sans-serif; background: #f6f7fb; }
        .wrapper { display: flex; height: calc(100vh - 64px); }
        .main { flex: 1; padding: 20px; display: flex; flex-direction: column; overflow: hidden; }
        .dash-grid { display: grid; grid-template-columns: 1.2fr 0.8fr; grid-template-rows: 6fr 4fr; gap: 20px; height: 100%; }
        .card { background: #fff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 18px; display: flex; flex-direction: column; min-height: 0; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .title { font-weight: 900; font-size: 1.2rem; margin-bottom: 12px; color: #1e293b; }

        .plan-container { flex: 1; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; display: flex; align-items: center; justify-content: center; min-height: 0; overflow: hidden; }
        .plan-svg { width: 100%; height: 100%; }
        .stall { fill: #f8fafc; stroke: #cbd5e1; stroke-width: 2; transition: all 0.3s; }
        .stall.occupied { fill: #fef2f2; stroke: #ef4444; stroke-width: 4; }
        .stall.vacant { fill: #f0fdf4; stroke: #22c55e; stroke-width: 4; }
        .stall-door { fill: #94a3b8; }
        .stall-num-text { fill: #475569; font-size: 20px !important; font-weight: 900; }
        .status-msg-text { font-size: 26px !important; font-weight: 900; }
        .area-label { fill: #94a3b8; font-size: 22px !important; font-weight: 700; }

        .status-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 20px; }
        .status-item { background: #f8fafc; padding: 20px 10px; border-radius: 10px; text-align: center; border: 1px solid #f1f5f9; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; }
        .status-item .label { font-size: 12px; color: #64748b; font-weight: 700; display: block; }
        .status-item .value { font-size: 1.3rem; font-weight: 900; }
        .val-temp { color: #ef4444; } .val-hum { color: #0ea5e9; } .val-odor { color: #22c55e; }
        .status-icon { font-size: 28px !important; margin-bottom: 2px; }

        .stock-section { flex: 1; display: flex; flex-direction: column; justify-content: space-around; }
        .stock-info { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 13px; font-weight: 700; color: #475569; }
        .progress-bar { height: 12px; background: #e2e8f0; border-radius: 6px; overflow: hidden; }
        .progress-fill { height: 100%; transition: width 0.5s ease-in-out; }

        .kpi-card { background: linear-gradient(135deg, #1e2a78 0%, #17215e 100%); color: white; position: relative; overflow: hidden; padding: 0 !important; }
        .kpi-header { padding: 18px 18px 0 18px; }
        .kpi-header .title { color: rgba(255,255,255,0.8); margin-bottom: 0; }
        .kpi-content { flex: 1; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .kpi-value { font-size: 5rem; font-weight: 900; letter-spacing: -2px; line-height: 1; }
        .kpi-unit { font-size: 1.5rem; opacity: 0.8; font-weight: 700; margin-top: 15px; }
        .kpi-footer { background: rgba(0,0,0,0.2); padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem; }
        .trend-up { color: #4ade80; display: flex; align-items: center; font-weight: 700; gap: 4px; }
        #real-time-clock { min-width: 180px !important; display: inline-block !important; text-align: center !important; font-family: 'Roboto Mono', monospace !important; background: rgba(255,255,255,0.15) !important; font-variant-numeric: tabular-nums; border-radius: 20px; padding: 4px 15px; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/common/header.jsp" />

    <div class="wrapper">
        <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />

        <main class="main">
            <div class="dash-grid">
                <div class="card">
                    <div class="title">실시간 재실 현황</div>
                    <div class="plan-container">
                        <svg class="plan-svg" viewBox="0 0 800 400" preserveAspectRatio="xMidYMid meet">
                            <rect x="15" y="15" width="770" height="370" rx="10" fill="#f1f5f9" stroke="#94a3b8" stroke-width="2" />
                            <rect x="35" y="35" width="230" height="330" rx="5" fill="#fff" stroke="#e2e8f0" stroke-width="1" />
                            <circle cx="85" cy="110" r="18" fill="#e2e8f0" /> <text x="115" y="118" class="area-label">세면대 1</text>
                            <circle cx="85" cy="220" r="18" fill="#e2e8f0" /> <text x="115" y="228" class="area-label">세면대 2</text>
                            <text x="60" y="345" fill="#cbd5e1" font-size="22" font-weight="900">ENTRANCE</text>

                            <c:forEach var="stall" items="${stallList}" varStatus="status">
                                <g>
                                    <rect class="stall ${stall.isOccupied == 1 ? 'occupied' : 'vacant'}"
                                          x="${(status.index % 2 == 0) ? 285 : 530}"
                                          y="${(status.index < 2) ? 35 : 210}"
                                          width="225" height="155" rx="4" />

                                    <text x="${(status.index % 2 == 0) ? 310 : 555}"
                                          y="${(status.index < 2) ? 85 : 260}" class="stall-num-text">
                                        ${stall.stallName}
                                    </text>

                                    <text x="${(status.index % 2 == 0) ? 310 : 555}"
                                          y="${(status.index < 2) ? 140 : 315}"
                                          fill="${stall.isOccupied == 1 ? '#ef4444' : '#22c55e'}" class="status-msg-text">
                                        ${stall.isOccupied == 1 ? '사용중' : '비어있음'}
                                    </text>
                                </g>
                            </c:forEach>
                        </svg>
                    </div>
                </div>

                <div class="card">
                    <div class="title">화장실 운영 상태</div>
                    <div class="status-grid">
                        <div class="status-item">
                            <span class="material-icons status-icon" style="color: #ef4444;">thermostat</span>
                            <span class="label">온도</span>
                            <div class="value val-temp">24.5°C</div>
                        </div>
                        <div class="status-item">
                            <span class="material-icons status-icon" style="color: #0ea5e9;">water_drop</span>
                            <span class="label">습도</span>
                            <div class="value val-hum">42%</div>
                        </div>
                        <div class="status-item">
                            <span class="material-icons status-icon" style="color: #22c55e;">air</span>
                            <span class="label">악취(NH3)</span>
                            <div class="value val-odor">0.12ppm</div>
                        </div>
                    </div>

                    <div class="stock-section">
                        <div class="stock-item">
                            <div class="stock-info"><span>페이퍼타올 재고</span><span>75%</span></div>
                            <div class="progress-bar"><div class="progress-fill" style="width: 75%; background: #2563eb;"></div></div>
                        </div>
                        <div class="stock-item">
                            <div class="stock-info"><span>휴지 재고</span><span>30%</span></div>
                            <div class="progress-bar"><div class="progress-fill" style="width: 30%; background: #ef4444;"></div></div>
                        </div>
                    </div>
                </div>

                <!-- ✅ Chart.js 캔버스 → ✅ ECharts 컨테이너 div -->
                <div class="card">
                    <div class="title">오늘 시간대별 이용 추이</div>
                    <div id="chartCanvas" style="flex:1; min-height:0; width:100%; height:100%;"></div>
                </div>

                <div class="card kpi-card">
                    <div class="kpi-header"><div class="title">오늘 누적 이용자</div></div>
                    <div class="kpi-content"><span class="kpi-value">482</span><span class="kpi-unit">명</span></div>
                    <div class="kpi-footer">
                        <span>전일 동시간 대비</span>
                        <span style="color:#4ade80; font-weight:700; display:flex; align-items:center; gap:4px;">
                            <span class="material-icons" style="font-size:18px;">trending_up</span>12.5%
                        </span>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        let lastTimeStr = "";

        function initClock() {
            const el = document.getElementById('real-time-clock');
            if (!el) { setTimeout(initClock, 50); return; }

            function update() {
                const now = new Date();
                const current =
                    now.getFullYear() + '-' +
                    String(now.getMonth() + 1).padStart(2, '0') + '-' +
                    String(now.getDate()).padStart(2, '0') + ' ' +
                    String(now.getHours()).padStart(2, '0') + ':' +
                    String(now.getMinutes()).padStart(2, '0');

                if (lastTimeStr !== current) {
                    el.textContent = current;
                    lastTimeStr = current;
                }
            }
            update();
            setInterval(update, 1000);
        }

        // ✅ ECharts 차트 (기존 Chart.js 로직을 그대로 ECharts로 구현)
        let occChart = null;
        let resizeBound = false;

        function initChart() {
            const dom = document.getElementById('chartCanvas');
            if (!dom) return;

            if (occChart) {
                occChart.dispose();
                occChart = null;
            }

            occChart = echarts.init(dom);

            const h = new Date().getHours();
            const labels = [];
            const values = [];
            for (let i = 9; i <= h; i++) {
                labels.push(i + '시');
                values.push(Math.floor(Math.random() * 20) + 30);
            }

            const option = {
                grid: { left: 34, right: 18, top: 18, bottom: 28 },
                tooltip: { trigger: 'axis' },
                xAxis: {
                    type: 'category',
                    data: labels,
                    boundaryGap: false,
                    axisTick: { show: false },
                    axisLine: { lineStyle: { color: '#e2e8f0' } },
                    axisLabel: { color: '#64748b', fontWeight: 700 }
                },
                yAxis: {
                    type: 'value',
                    axisLine: { show: false },
                    axisTick: { show: false },
                    axisLabel: { color: '#64748b', fontWeight: 700 },
                    splitLine: { lineStyle: { color: '#f1f5f9' } }
                },
                series: [{
                    name: '이용자',
                    type: 'line',
                    data: values,
                    smooth: true,
                    symbol: 'circle',
                    symbolSize: 7,
                    lineStyle: { width: 3 },
                    areaStyle: { opacity: 0.12 },
                    emphasis: { focus: 'series' }
                }]
            };

            occChart.setOption(option);

            if (!resizeBound) {
                window.addEventListener('resize', () => {
                    if (occChart) occChart.resize();
                });
                resizeBound = true;
            }
        }

        window.onload = function() {
            initClock();
            initChart();
        };

        function updateRealTime() {
            // 1. 데이터 전용 주소에 정보를 요청합니다
            fetch('/test1/getStallStatus.do')
                .then(response => response.json())
                .then(data => {
                    // 2. 가져온 데이터(data)를 바탕으로 SVG의 색상과 글자를 바꿉니다
                    data.forEach((stall, index) => {
                        const rect = document.querySelectorAll('.stall')[index];
                        const text = document.querySelectorAll('.status-msg-text')[index];

                        if (!rect || !text) return;

                        if (stall.isOccupied == 1) {
                            rect.setAttribute('class', 'stall occupied');
                            text.textContent = '사용중';
                            text.setAttribute('fill', '#ef4444');
                        } else {
                            rect.setAttribute('class', 'stall vacant');
                            text.textContent = '비어있음';
                            text.setAttribute('fill', '#22c55e');
                        }
                    });
                });
        }

        // 3. 3초(3000ms)마다 이 함수를 실행하도록 설정합니다
        setInterval(updateRealTime, 3000);
    </script>
</body>
</html>
