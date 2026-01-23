<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Smart Restroom Management System</title>
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
                                          y="${(status.index < 2) ? 35 : 210}" width="225" height="155" rx="4" />
                                    <text x="${(status.index % 2 == 0) ? 310 : 555}" y="${(status.index < 2) ? 85 : 260}" class="stall-num-text">${stall.stallName}</text>
                                    <text x="${(status.index % 2 == 0) ? 310 : 555}" y="${(status.index < 2) ? 140 : 315}"
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
                        <div class="status-item" id="tempBox">
                            <span class="material-icons status-icon" style="color:#ef4444;">thermostat</span>
                            <span class="label">온도</span>
                            <div class="value val-temp">${data.temp.value}°C</div>
                        </div>

                        <div class="status-item" id="humBox">
                            <span class="material-icons status-icon" style="color:#0ea5e9;">water_drop</span>
                            <span class="label">습도</span>
                            <div class="value val-hum">${data.humi.value}%</div>
                        </div>

                        <div class="status-item" id="odorBox">
                            <span class="material-icons status-icon" style="color:#6bcb77;">science</span>
                            <span class="label">악취(NH3)</span>
                            <div class="value val-odor">${data.nh3.value}ppm</div>
                        </div>
                    </div>

                    <div class="stock-section">
                        <div class="stock-item">
                            <div class="stock-info">
                                <span class="stock-left">
                                    <span>페이퍼타올 재고</span>
                                    <span id="ptBadge" class="stock-badge"></span>
                                </span>
                                <span id="ptLabel">0%</span>
                            </div>
                            <div id="paperTowelChart" class="mini-stock-chart"></div>
                        </div>

                        <div class="stock-item">
                            <div class="stock-info">
                                <span class="stock-left">
                                    <span>액체비누 재고</span>
                                    <span id="soapBadge" class="stock-badge"></span>
                                </span>
                                <span id="soapLabel">0%</span>
                            </div>
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
                    <div class="kpi-content"><span class="kpi-value">${data.todaySum}</span><span class="kpi-unit">명</span></div>
                    <div class="kpi-footer">
                        <span>전일 동시간 대비</span>
                        <span id="trendBox">
                            <span id="trendIcon" class="material-icons" style="font-size:18px;"></span>
                            <span id="percentVal">${data.diffPercent} %</span>
                        </span>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script>
        var lastTimeStr = "", lastPaperPct = -1, lastSoapPct = -1;
        var occChart = null, paperChart = null, soapChart = null;
        var thresholdMap = null;

        function initClock() {
            var el = document.getElementById('real-time-clock');
            if (!el) { setTimeout(initClock, 50); return; }
            function update() {
                var now = new Date();
                var current = now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0')+'-'+String(now.getDate()).padStart(2,'0')+' '+String(now.getHours()).padStart(2,'0')+':'+String(now.getMinutes()).padStart(2,'0');
                if (lastTimeStr !== current) { el.textContent = current; lastTimeStr = current; }
            }
            update(); setInterval(update, 1000);
        }

        function initChart(labels, values) {
            var dom = document.getElementById('chartCanvas');
            if (!dom) return;
            if (occChart) occChart.dispose();
            occChart = echarts.init(dom);
            occChart.setOption({
                grid: { left: 34, right: 18, top: 18, bottom: 28 },
                tooltip: { trigger: 'axis' },
                xAxis: { type: 'category', data: labels, boundaryGap: false, axisLine: { lineStyle: { color: '#e2e8f0' } }, axisLabel: { color: '#64748b', fontWeight: 700 } },
                yAxis: { type: 'value', axisLabel: { color: '#64748b', fontWeight: 700 }, splitLine: { lineStyle: { color: '#f1f5f9' } } },
                series: [{ name: '이용자', type: 'line', data: values, smooth: true, areaStyle: { opacity: 0.12 } }]
            });
        }

        function initSingleStockChart(domId, pct, fillColor) {
            var dom = document.getElementById(domId);
            if (!dom) return null;
            var inst = echarts.getInstanceByDom(dom);
            if (inst) inst.dispose();
            var chart = echarts.init(dom);
            var safePct = Math.max(0, Math.min(100, Number(pct) || 0));
            chart.setOption({
                animation: true,
                grid: { left: 0, right: 0, top: 0, bottom: 0 },
                xAxis: { type: 'value', min: 0, max: 100, show: false },
                yAxis: { type: 'category', data: [''], show: false },
                series: [
                    { type: 'bar', data: [100], barWidth: 12, barGap: '-100%', silent: true, itemStyle: { color: '#e2e8f0', borderRadius: 6 } },
                    { type: 'bar', data: [safePct], barWidth: 12, z: 3, itemStyle: { color: fillColor, borderRadius: 6 } }
                ]
            });
            return chart;
        }

        function updateStockBadge(id, pct) {
            var el = document.getElementById(id);
            if (!el) return;
            var safePct = Number(pct) || 0;
            var isLow = safePct <= 30;
            el.className = 'stock-badge ' + (isLow ? 'status-insufficient' : 'status-sufficient');
            el.textContent = isLow ? '부족' : '충분';
        }

        function buildThresholdMap(thresholds) {
            var m = {};
            if (!thresholds || !thresholds.length) return m;
            thresholds.forEach(function(t){
                if (!t || !t.sensorType) return;
                m[t.sensorType] = { min: Number(t.minValue), max: Number(t.maxValue) };
            });
            return m;
        }

        // ✅ 요구사항 로직 구현: 센서별 상태 클래스 반환
        function getStatusClass(sensorObj, sensorType) {
            if (!sensorObj || !thresholdMap || !thresholdMap[sensorType]) return '';
            var v = Number(sensorObj.value);
            if (isNaN(v)) return '';
            var th = thresholdMap[sensorType];

            if (sensorType === 'NH3') {
                if (!isNaN(th.max) && v > th.max) return 'status-alert';   // Critical (빨강)
                if (!isNaN(th.min) && v > th.min) return 'status-warning'; // Warning (노랑)
            } else {
                // TEMP, HUMIDITY: 범위를 벗어나면 무조건 빨강
                if ((!isNaN(th.min) && v < th.min) || (!isNaN(th.max) && v > th.max)) return 'status-alert';
            }
            return '';
        }

        function setAlertBox(boxId, statusClass) {
            var el = document.getElementById(boxId);
            if (!el) return;
            el.classList.remove('status-alert', 'status-warning');
            if (statusClass) el.classList.add(statusClass);
        }

        function updateRealTime() {
            fetch('${pageContext.request.contextPath}/getDashboardData.do?t=' + new Date().getTime())
                .then(function(r){ return r.json(); })
                .then(function(data){
                    if (thresholdMap === null) thresholdMap = buildThresholdMap(data.thresholds);

                    if (data.stalls) {
                        data.stalls.forEach(function(stall, index){
                            var rect = document.querySelectorAll('.stall')[index];
                            var text = document.querySelectorAll('.status-msg-text')[index];
                            if (rect && text) {
                                rect.setAttribute('class', stall.isOccupied == 1 ? 'stall occupied' : 'stall vacant');
                                text.textContent = stall.isOccupied == 1 ? '사용중' : '비어있음';
                                text.setAttribute('fill', stall.isOccupied == 1 ? '#ef4444' : '#22c55e');
                            }
                        });
                    }

                    if (data.temp) document.querySelector('.val-temp').textContent = data.temp.value + "°C";
                    if (data.humi) document.querySelector('.val-hum').textContent = data.humi.value + "%";
                    if (data.nh3)  document.querySelector('.val-odor').textContent = data.nh3.value + "ppm";

                    // ✅ 색상 업데이트 적용
                    setAlertBox('tempBox', getStatusClass(data.temp, 'TEMP'));
                    setAlertBox('humBox',  getStatusClass(data.humi, 'HUMIDITY'));
                    setAlertBox('odorBox', getStatusClass(data.nh3,  'NH3'));

                    if (data.todaySum !== undefined) document.querySelector('.kpi-value').textContent = data.todaySum;

                    if (data.diffPercent !== undefined) {
                        var trendBox = document.getElementById('trendBox'), trendIcon = document.getElementById('trendIcon'), percentVal = document.getElementById('percentVal');
                        if (data.diffPercent === "-") {
                            percentVal.textContent = "- %"; trendBox.style.color = "#64748b"; trendIcon.textContent = "trending_flat";
                        } else {
                            var diff = parseFloat(data.diffPercent);
                            percentVal.textContent = Math.abs(diff).toFixed(1) + " %";
                            if (diff > 0) { trendBox.style.color = "#4ade80"; trendIcon.textContent = "trending_up"; }
                            else if (diff < 0) { trendBox.style.color = "#ef4444"; trendIcon.textContent = "trending_down"; }
                            else { trendBox.style.color = "#64748b"; trendIcon.textContent = "trending_flat"; }
                        }
                    }

                    if (data.stocks) {
                        var p = 0, s = 0;
                        data.stocks.forEach(function(st){
                            if (st.typeKey === 'PAPER_TOWEL') p = st.currentLevel;
                            if (st.typeKey === 'LIQUID_SOAP') s = st.currentLevel;
                        });
                        if (p !== lastPaperPct || s !== lastSoapPct) {
                            var sGray = '#8e97a3';
                            paperChart = initSingleStockChart('paperTowelChart', p, sGray);
                            soapChart  = initSingleStockChart('soapChart', s, sGray);
                            document.getElementById('ptLabel').textContent = p + '%';
                            document.getElementById('soapLabel').textContent = s + '%';
                            updateStockBadge('ptBadge', p);
                            updateStockBadge('soapBadge', s);
                            lastPaperPct = p; lastSoapPct = s;
                        }
                    }
                });
        }

        window.onload = function() {
            initClock();
            var hL = [], hV = [];
            <c:forEach var="h" items="${data.hourlyStats}">
                hL.push("${h.hourId}시"); hV.push(${h.visitCount});
            </c:forEach>
            initChart(hL, hV);
            updateRealTime();
            setInterval(updateRealTime, 3000);
            window.addEventListener('resize', function(){
                if (occChart) occChart.resize();
                if (paperChart) paperChart.resize();
                if (soapChart) soapChart.resize();
            });
        };
    </script>
</body>
</html>