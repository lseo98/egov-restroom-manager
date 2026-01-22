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

    <!-- ✅ 외부 CSS 연결 -->
    <link rel="stylesheet" href="<c:url value='/css/egovframework/dashboard.css'/>">

    <!-- ✅ Apache ECharts -->
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
</head>

<body>
    <jsp:include page="/WEB-INF/jsp/common/header.jsp" />

    <div class="wrapper">
        <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />

        <main class="main">
            <div class="dash-grid">

                <!-- 좌상: 도면 -->
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

                <!-- 우상: 운영 상태 + 재고(ECharts) -->
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
                            <div class="stock-info"><span>페이퍼타올 재고</span><span id="ptLabel">75%</span></div>
                            <div id="paperTowelChart" class="mini-stock-chart"></div>
                        </div>

                        <div class="stock-item">
                            <div class="stock-info"><span>액체비누 재고</span><span id="soapLabel">60%</span></div>
                            <div id="soapChart" class="mini-stock-chart"></div>
                        </div>
                    </div>
                </div>

                <!-- 좌하: 이용 추이(ECharts) -->
                <div class="card">
                    <div class="title">오늘 시간대별 이용 추이</div>
                    <div id="chartCanvas" class="chart-canvas"></div>
                </div>

                <!-- 우하: KPI -->
                <div class="card kpi-card">
                    <div class="kpi-header"><div class="title">오늘 누적 이용자</div></div>
                    <div class="kpi-content"><span class="kpi-value">482</span><span class="kpi-unit">명</span></div>
                    <div class="kpi-footer">
                        <span>전일 동시간 대비</span>
                        <span class="trend-up">
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

        let occChart = null;

        function initChart() {
            const dom = document.getElementById('chartCanvas');
            if (!dom) return;

            const old = echarts.getInstanceByDom(dom);
            if (old) old.dispose();

            occChart = echarts.init(dom);

            const h = new Date().getHours();
            const labels = [];
            const values = [];
            for (let i = 9; i <= h; i++) {
                labels.push(i + '시');
                values.push(Math.floor(Math.random() * 20) + 30);
            }

            occChart.setOption({
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
            });
        }

        let paperChart = null;
        let soapChart = null;

        function initStockCharts(paperPct = 75, soapPct = 60) {
            paperChart = initSingleStockChart('paperTowelChart', paperPct, '#2563eb');
            soapChart  = initSingleStockChart('soapChart', soapPct, '#f59e0b');

            const ptLabel = document.getElementById('ptLabel');
            const soapLabel = document.getElementById('soapLabel');
            if (ptLabel) ptLabel.textContent = (Number(paperPct) || 0) + '%';
            if (soapLabel) soapLabel.textContent = (Number(soapPct) || 0) + '%';
        }

        function initSingleStockChart(domId, pct, fillColor) {
            const dom = document.getElementById(domId);
            if (!dom) return null;

            const old = echarts.getInstanceByDom(dom);
            if (old) old.dispose();

            const chart = echarts.init(dom);
            const safePct = Math.max(0, Math.min(100, Number(pct) || 0));

            chart.setOption({
                animation: true,
                grid: { left: 0, right: 0, top: 0, bottom: 0, containLabel: false },
                xAxis: { type: 'value', min: 0, max: 100, show: false },
                yAxis: { type: 'category', data: [''], show: false },
                series: [
                    {
                        type: 'bar',
                        data: [100],
                        barWidth: 12,
                        barGap: '-100%',
                        silent: true,
                        itemStyle: { color: '#e2e8f0', borderRadius: 6 }
                    },
                    {
                        type: 'bar',
                        data: [safePct],
                        barWidth: 12,
                        z: 3,
                        itemStyle: { color: fillColor, borderRadius: 6 }
                    }
                ]
            });

            return chart;
        }

        function updateRealTime() {
            fetch('/test1/getStallStatus.do')
                .then(r => r.json())
                .then(data => {
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

                    // ✅ 서버가 재고를 같이 주면 여기서 갱신
                    // if (data.summary) initStockCharts(data.summary.paperTowelPct, data.summary.soapPct);
                });
        }

        let resizeBound = false;
        function bindResizeOnce() {
            if (resizeBound) return;
            window.addEventListener('resize', () => {
                if (occChart) occChart.resize();
                if (paperChart) paperChart.resize();
                if (soapChart) soapChart.resize();
            });
            resizeBound = true;
        }

        window.onload = function() {
            initClock();
            initChart();
            initStockCharts(75, 60);
            bindResizeOnce();

            updateRealTime();
            setInterval(updateRealTime, 3000);
        };
    </script>
</body>
</html>
