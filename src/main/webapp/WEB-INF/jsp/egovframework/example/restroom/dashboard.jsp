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

    <link rel="stylesheet" href="<c:url value='/css/egovframework/dashboard.css'/>">

    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
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

                            <c:forEach var="stall" items="${data.stalls}" varStatus="status">
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
                            <div class="value val-temp">${data.temp.value}°C</div>
                        </div>
                        <div class="status-item">
                            <span class="material-icons status-icon" style="color: #0ea5e9;">water_drop</span>
                            <span class="label">습도</span>
                            <div class="value val-hum">${data.humi.value}%</div>
                        </div>
                        <div class="status-item">
                            <span class="material-icons status-icon" style="color: #6bcb77;">science</span>
                            <span class="label">악취(NH3)</span>
                            <div class="value val-odor">${data.nh3.value}ppm</div>
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

                <div class="card">
                    <div class="title">오늘 시간대별 이용 추이</div>
                    <div id="chartCanvas" class="chart-canvas"></div>
                </div>

                <div class="card kpi-card">
                    <div class="kpi-header"><div class="title">오늘 누적 이용자</div></div>
                    <div class="kpi-content">
                        <span class="kpi-value">${data.todaySum}</span><span class="kpi-unit">명</span>
                    </div>
                    <div class="kpi-footer">
                        <span>전일 동시간 대비</span>
                        <span id="trendBox" class="trend-up">
                            <span id="trendIcon" class="material-icons" style="font-size:18px;"></span>
                            <span id="percentVal">${data.diffPercent} %</span>
                        </span>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        let lastTimeStr = "";
        let lastPaperPct = -1; 
        let lastSoapPct = -1; 

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

        function initChart(labels = [], values = []) {
            const dom = document.getElementById('chartCanvas');
            if (!dom) return;

            const old = echarts.getInstanceByDom(dom);
            if (old) old.dispose();
            
            occChart = echarts.init(dom);

            occChart.setOption({
                grid: { left: 34, right: 18, top: 18, bottom: 28 },
                tooltip: { trigger: 'axis' },
                xAxis: {
                    type: 'category',
                    data: labels,
                    boundaryGap: false,
                    axisLine: { lineStyle: { color: '#e2e8f0' } },
                    axisLabel: { color: '#64748b', fontWeight: 700 }
                },
                yAxis: {
                    type: 'value',
                    axisLabel: { color: '#64748b', fontWeight: 700 },
                    splitLine: { lineStyle: { color: '#f1f5f9' } }
                },
                series: [{
                    name: '이용자',
                    type: 'line',
                    data: values,
                    smooth: true,
                    areaStyle: { opacity: 0.12 }
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
            const url = '${pageContext.request.contextPath}/getDashboardData.do?t=' + new Date().getTime();

            fetch(url)
                .then(r => r.json())
                .then(data => {

                    // 2. 화장실 칸 재실 현황 업데이트
                    if (data.stalls) {
                        data.stalls.forEach((stall, index) => {
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
                    }

                    // 3. 환경 센서 업데이트
                    if (data.temp) document.querySelector('.val-temp').textContent = data.temp.value + "°C";
                    if (data.humi) document.querySelector('.val-hum').textContent = data.humi.value + "%";
                    if (data.nh3)  document.querySelector('.val-odor').textContent = data.nh3.value + "ppm";

                    // 4. 누적 이용자 및 증감률 업데이트 (색상 수정 로직)
                    if (data.todaySum !== undefined) {
                        document.querySelector('.kpi-value').textContent = data.todaySum;
                    }

                    if (data.diffPercent !== undefined) {
                        const trendBox = document.getElementById('trendBox');
                        const trendIcon = document.getElementById('trendIcon');
                        const percentVal = document.getElementById('percentVal');

                        if (data.diffPercent === "-") {
                            percentVal.textContent = "- %";
                            trendBox.style.color = "#64748b";
                            trendIcon.textContent = "trending_flat";
                        } else {
                            const diff = parseFloat(data.diffPercent);
                            percentVal.textContent = Math.abs(diff).toFixed(1) + " %";
                            
                            if (diff > 0) {
                                trendBox.style.color = "#4ade80"; // 증가 시 연두색
                                trendIcon.textContent = "trending_up";
                            } else if (diff < 0) {
                                trendBox.style.color = "#ef4444"; // 감소 시 빨간색
                                trendIcon.textContent = "trending_down";
                            } else {
                                trendBox.style.color = "#64748b"; 
                                trendIcon.textContent = "trending_flat";
                            }
                        }
                    }

                    // 5. 시간별 이용 추이 차트 업데이트
                    if (data.hourlyStats && occChart) {
                        const labels = data.hourlyStats.map(s => s.hourId + "시");
                        const values = data.hourlyStats.map(s => s.visitCount);
                        occChart.setOption({
                            xAxis: { data: labels },
                            series: [{ data: values }]
                        });
                    }

                    // 6. 소모품 재고 업데이트
                    if (data.stocks) {
                        let paperPct = 0;
                        let soapPct = 0;
                        data.stocks.forEach(stock => {
                            if (stock.typeKey === 'PAPER_TOWEL') paperPct = stock.currentLevel;
                            if (stock.typeKey === 'LIQUID_SOAP') soapPct = stock.currentLevel;
                        });
                        if (paperPct !== lastPaperPct || soapPct !== lastSoapPct) {                         
                            initStockCharts(paperPct, soapPct);
                            lastPaperPct = paperPct;
                            lastSoapPct = soapPct;
                        }
                    }
                })
                .catch(err => console.error("데이터 동기화 실패:", err));
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
            
            const hLabels = [];
            const hValues = [];
            <c:forEach var="stat" items="${data.hourlyStats}">
                hLabels.push("${stat.hourId}시");
                hValues.push(${stat.visitCount});
            </c:forEach>
            initChart(hLabels, hValues);
            
            let paperVal = 0; 
            let soapVal = 0;

            <c:forEach var="s" items="${data.stocks}">
                if("${s.typeKey}" === "PAPER_TOWEL") paperVal = ${s.currentLevel};
                if("${s.typeKey}" === "LIQUID_SOAP") soapVal = ${s.currentLevel};
            </c:forEach>
            initStockCharts(paperVal, soapVal);
            
            lastPaperPct = paperVal; 
            lastSoapPct = soapVal;  

            bindResizeOnce();
            updateRealTime();
            setInterval(updateRealTime, 3000); 
        };
        </script>
    </body>
</html>