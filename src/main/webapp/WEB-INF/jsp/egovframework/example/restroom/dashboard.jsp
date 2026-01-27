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
                            <span class="material-icons status-icon" style="color:#FF6B6B;">thermostat</span>
                            <span class="label">온도</span>
                            <div class="value val-temp">${data.temp.value}</div>
                        </div>

                        <div class="status-item" id="humBox">
                            <span class="material-icons status-icon" style="color:#0ea5e9;">water_drop</span>
                            <span class="label">습도</span>
                            <div class="value val-hum">${data.humi.value}</div>
                        </div>

                        <div class="status-item" id="odorBox">
                            <span class="material-icons status-icon" style="color:#6bcb77;">science</span>
                            <span class="label">악취(NH3)</span>
                            <div class="value val-odor">${data.nh3.value}</div>
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
                    <div class="kpi-content">
                        <span class="kpi-value">${data.todaySum}</span>
                        <span class="kpi-unit">명</span>
                    </div>
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


        function initChart(labels, todayValues, yesterdayValues) {
            var dom = document.getElementById('chartCanvas');
            if (!dom) return;
            if (occChart) occChart.dispose();
            
            occChart = echarts.init(dom);
            occChart.setOption({
                grid: { left: '4%', right: '4%', top: '18%', bottom: '8%', containLabel: true },
                tooltip: { 
                    trigger: 'axis',
                    backgroundColor: 'rgba(255, 255, 255, 0.98)',
                    borderRadius: 8,
                    padding: 12,
                    borderColor: '#e2e8f0',
                    textStyle: { color: '#334155', fontSize: 13 },
                    shadowBlur: 10,
                    shadowColor: 'rgba(0,0,0,0.05)',
                    // 툴팁 레이아웃 수정 (빨간줄 방지를 위해 문자열 결합 방식 사용)
                    formatter: function(params) {
                        var res = '<div style="font-weight:bold; color:#1e293b; margin-bottom:8px; border-bottom:1px solid #f1f5f9; padding-bottom:4px;">' + params[0].name + ' 이용 현황</div>';
                        params.forEach(function(item) {
                            var color = item.color;
                            var isToday = item.seriesName === '오늘';
                            var valColor = isToday ? '#454f80' : '#94a3b8';
                            
                            res += '<div style="display:flex; justify-content:space-between; align-items:center; gap:20px; margin: 4px 0;">' +
                                       '<span style="display:flex; align-items:center; color:#64748b;">' +
                                           '<span style="display:inline-block; width:8px; height:8px; border-radius:50%; background:' + color + '; margin-right:8px;"></span>' +
                                           item.seriesName +
                                       '</span>' +
                                       '<span style="font-weight:bold; color:' + valColor + ';">' +
                                           item.value + ' <small style="font-weight:normal;">명</small>' +
                                       '</span>' +
                                   '</div>';
                        });
                        return res;
                    }
                },
                legend: {
                    data: ['오늘', '어제'],
                    right: '5%',
                    top: '0',
                    icon: 'roundRect',
                    itemWidth: 15,
                    itemHeight: 10,
                    itemGap: 20,
                    textStyle: { color: '#64748b', fontWeight: 600, fontSize: 13 }
                },
                xAxis: { 
                    type: 'category', 
                    data: labels, 
                    boundaryGap: false, 
                    axisLine: { lineStyle: { color: '#e2e8f0' } }, 
                    axisLabel: { color: '#94a3b8', fontWeight: 600, margin: 15 } 
                },
                yAxis: { 
                    type: 'value', 
                    splitLine: { lineStyle: { color: '#f1f5f9' } },
                    axisLabel: { color: '#94a3b8', fontWeight: 600 } 
                },
                series: [
                    { 
                        name: '오늘', 
                        type: 'line', 
                        data: todayValues, 
                        smooth: 0.45,
                        symbol: 'circle',
                        symbolSize: 6,
                        showSymbol: false,
                        itemStyle: { color: '#454f80' }, 
                        lineStyle: { width: 3, cap: 'round' },
                        areaStyle: { 
                            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                                { offset: 0, color: 'rgba(79, 70, 229, 0.15)' },
                                { offset: 1, color: 'rgba(79, 70, 229, 0)' }
                            ]) 
                        },
                        emphasis: { showSymbol: true, itemStyle: { borderWidth: 2, borderColor: '#fff' } }
                    },
                    { 
                        name: '어제', 
                        type: 'line', 
                        data: yesterdayValues, 
                        smooth: 0.45,
                        symbol: 'none',
                        itemStyle: { color: '#cbd5e1' },
                        lineStyle: { width: 2, type: 'dashed', dashOffset: 5 },
                        emphasis: { lineStyle: { width: 2, color: '#94a3b8' } }
                    }
                ]
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

        // ✅ '부족' 애니메이션 제거 및 DB threshold와 직접 비교
        function updateStockBadge(id, current, threshold) {
            var el = document.getElementById(id);
            if (!el) return;
            var curVal = parseFloat(current) || 0;
            var thrVal = parseFloat(threshold) || 0;
            var isLow = curVal <= thrVal;
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

        function getStatusClass(sensorObj, sensorType) {
            if (!sensorObj || !thresholdMap || !thresholdMap[sensorType]) return '';
            var v = parseFloat(sensorObj.value);
            if (isNaN(v)) return '';
            var th = thresholdMap[sensorType];
            if (sensorType === 'NH3') {
                if (!isNaN(th.max) && v > th.max) return 'status-critical';
                if (!isNaN(th.min) && v > th.min) return 'status-warning';
            } else {
                if ((!isNaN(th.min) && v < th.min) || (!isNaN(th.max) && v > th.max)) return 'status-warning';
            }
            return '';
        }

        function setAlertBox(boxId, statusClass) {
            var el = document.getElementById(boxId);
            if (!el) return;
            el.classList.remove('status-alert', 'status-warning', 'status-critical');
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

                    if (data.temp) document.querySelector('.val-temp').textContent = data.temp.value;
                    if (data.humi) document.querySelector('.val-hum').textContent = data.humi.value;
                    if (data.nh3)  document.querySelector('.val-odor').textContent = data.nh3.value;

                    setAlertBox('tempBox', getStatusClass(data.temp, 'TEMP'));
                    setAlertBox('humBox',  getStatusClass(data.humi, 'HUMIDITY'));
                    setAlertBox('odorBox', getStatusClass(data.nh3,  'NH3'));

                    // ✅ 소모품 업데이트: 이미지 테이블 구조에 따라 st.threshold(DB 실제값) 사용
                    if (data.stocks) {
                        data.stocks.forEach(function(st) {
                            if (st.typeKey === 'PAPER_TOWEL') {
                                if (st.currentLevel !== lastPaperPct) {
                                    paperChart = initSingleStockChart('paperTowelChart', st.currentLevel, '#8e97a3');
                                    document.getElementById('ptLabel').textContent = st.currentLevel + '%';
                                    updateStockBadge('ptBadge', st.currentLevel, st.threshold);
                                    lastPaperPct = st.currentLevel;
                                }
                            }
                            if (st.typeKey === 'LIQUID_SOAP') {
                                if (st.currentLevel !== lastSoapPct) {
                                    soapChart = initSingleStockChart('soapChart', st.currentLevel, '#8e97a3');
                                    document.getElementById('soapLabel').textContent = st.currentLevel + '%';
                                    updateStockBadge('soapBadge', st.currentLevel, st.threshold);
                                    lastSoapPct = st.currentLevel;
                                }
                            }
                        });
                    }

                    if (data.todaySum !== undefined) document.querySelector('.kpi-value').textContent = data.todaySum;
                    if (data.diffPercent !== undefined) {
                        var tb = document.getElementById('trendBox'), ti = document.getElementById('trendIcon'), pv = document.getElementById('percentVal');
                        if (data.diffPercent === "-") {
                            pv.textContent = "- %"; tb.style.color = "#64748b"; ti.textContent = "";
                        } else {
                            var d = parseFloat(data.diffPercent); pv.textContent = Math.abs(d).toFixed(1) + " %";
                            if (d > 0) { tb.style.color = "#4ade80"; ti.textContent = "trending_up"; }
                            else if (d < 0) { tb.style.color = "#ef4444"; ti.textContent = "trending_down"; }
                            else { tb.style.color = "#64748b"; ti.textContent = ""; }
                        }
                    }
                });
        }

        window.onload = function() {
        	var hL = [], hV_today = [], hV_yesterday = [];

            <c:forEach var="h" items="${data.hourlyStats}">
                hL.push("${h.hourId}시"); 
                // DB 컬럼명에 맞춰 오늘(visitCount)과 어제(yesterdayCount) 추출
                hV_today.push(${h.visitCount});
                hV_yesterday.push(${h.yesterdayCount});
            </c:forEach>

            initChart(hL, hV_today, hV_yesterday);
            
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