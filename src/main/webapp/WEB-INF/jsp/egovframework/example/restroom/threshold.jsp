<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>임계치 설정  - Smart Restroom</title>

  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&family=Roboto+Mono&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/egovframework/threshold.css" />

  <style>
    /* 1. 레이아웃 및 배경 */
    html, body {
      margin: 0 !important; padding: 0 !important;
      height: 100% !important; overflow: hidden !important;
      background: #F8FAFC !important; 
      font-family: 'Noto Sans KR', sans-serif;
    }

    .content-area {
      display: flex; flex-direction: column;
      height: calc(100vh - 64px) !important;
      padding: 24px !important; box-sizing: border-box;
    }

    .grid.grid-3x2 {
      flex: 1; display: grid !important;
      grid-template-columns: repeat(3, 1fr) !important;
      grid-template-rows: repeat(2, 1fr);
      gap: 24px !important;
    }

    /* 2. 카드 스타일 */
    .card, .card.compact {
      background: #FFFFFF !important;
      border: 1px solid #E2E8F0 !important;
      border-radius: 16px !important; 
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03) !important;
      height: 100% !important; margin: 0 !important;
      display: flex; flex-direction: column; justify-content: space-between;
      padding: 20px !important;
    }

    .card-title-wrapper {
      display: flex; align-items: center; gap: 12px;
    }
    
    .card-title-wrapper .material-icons {
      font-size: 28px !important;
    }
    
    .card-title-wrapper strong {
      font-size: 19px !important; font-weight: 800 !important;
      color: #1E293B; display: flex; align-items: baseline; gap: 8px;
    }

    .appropriate-value {
      font-weight: 400; font-size: 13px; color: #94A3B8;
    }

    .unit-text {
      padding-left: 40px; font-size: 12px; color: #64748B; margin-top: 2px;
    }

    /* 헤더 시계 스타일 */
    #real-time-clock {
      min-width: 180px !important; display: inline-block !important;
      text-align: center !important; font-family: 'Roboto Mono', monospace !important;
      background: rgba(255,255,255,0.15) !important;
      font-variant-numeric: tabular-nums; border-radius: 20px;
      padding: 4px 15px; margin-left: 20px; font-size: 14px; font-weight: 700;
    }
  </style>
</head>

<body class="page threshold-page">
  <script> var contextPath = "${pageContext.request.contextPath}"; </script>
  <jsp:include page="/WEB-INF/jsp/common/header.jsp" />
  <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />

  <div class="content-area" id="contentArea">
    <div class="page-top" id="pageTop" style="margin-bottom: 24px;">
      <div class="page-title">
        <h1 style="margin: 0; font-size: 26px; font-weight: 900; color: #0F172A;">임계치 설정</h1>
        <p style="margin: 6px 0 0 0; color: #64748B;">센서별 기준값을 설정하면 알림 페이지에서 이상 징후를 빠르게 확인할 수 있습니다.</p>
      </div>

      <div class="btn-row">
        <button class="btn primary" type="button" id="btnSave">저장</button>
        <button class="btn" type="button" id="btnReset">기본값으로 초기화</button>
      </div>
    </div>

    <div class="grid grid-3x2" id="grid">
      <section class="card">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #FF6B6B;">thermostat</span>
              <strong>온도 <span class="appropriate-value">(적정: 18~27℃)</span></strong>
            </div>
            <div class="unit-text">단위: ℃</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="temp"></span></label>
        </div>
        <div class="form">
          <div class="row"><div class="label">상한(High)</div><div class="field"><input class="input" type="number" step="0.1" id="temp_high" /><span class="unit">℃</span></div></div>
          <div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" step="0.1" id="temp_low" /><span class="unit">℃</span></div></div>
          <div class="row"><div class="label">다시 알림</div><div class="field"><input class="input" type="number" id="temp_realert_min" /><span class="unit">분</span></div></div>
        </div>
      </section>

      <section class="card">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #4D96FF;">opacity</span>
              <strong>습도 <span class="appropriate-value">(적정: 40~60%)</span></strong>
            </div>
            <div class="unit-text">단위: %</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="hum"></span></label>
        </div>
        <div class="form">
          <div class="row"><div class="label">상한(High)</div><div class="field"><input class="input" type="number" id="hum_high" /><span class="unit">%</span></div></div>
          <div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" id="hum_low" /><span class="unit">%</span></div></div>
          <div class="row"><div class="label">다시 알림</div><div class="field"><input class="input" type="number" id="hum_realert_min" /><span class="unit">분</span></div></div>
        </div>
      </section>

      <section class="card">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #6BCB77;">science</span>
              <strong>악취(NH3) <span class="appropriate-value">(적정: 5ppm 이하)</span></strong>
            </div>
            <div class="unit-text">단위: ppm</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="nh3"></span></label>
        </div>
        <div class="form">
          <div class="row"><div class="label">주의(Warning)</div><div class="field"><input class="input" type="number" step="0.1" id="nh3_high" /><span class="unit">ppm</span></div></div>
          <div class="row"><div class="label">긴급(Critical)</div><div class="field"><input class="input" type="number" step="0.1" id="nh3_low" /><span class="unit">ppm</span></div></div>
          <div class="row"><div class="label">다시 알림</div><div class="field"><input class="input" type="number" id="nh3_realert_min" /><span class="unit">분</span></div></div>
        </div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #64748B;">groups</span>
              <strong>피플카운트</strong>
            </div>
            <div class="unit-text">단위: 명</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="people"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">상한(High)</div><div class="field"><input class="input" type="number" id="people_high" /><span class="unit">명</span></div></div></div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #64748B;">layers</span>
              <strong>페이퍼타올</strong>
            </div>
            <div class="unit-text">단위: %</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="towel"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" id="towel_threshold" /><span class="unit">%</span></div></div></div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title">
            <div class="card-title-wrapper">
              <span class="material-icons" style="color: #64748B;">clean_hands</span>
              <strong>액체 비누</strong>
            </div>
            <div class="unit-text">단위: %</div>
          </div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="soap"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" id="soap_threshold" /><span class="unit">%</span></div></div></div>
      </section>
    </div>
  </div>

  <div class="toast" id="toast">저장되었습니다.</div>

  <script>
    document.addEventListener("DOMContentLoaded", function() {
      function updateClock() {
        const el = document.getElementById('real-time-clock');
        if (!el) return;

        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        const hh = String(now.getHours()).padStart(2, '0');
        const mm = String(now.getMinutes()).padStart(2, '0');

        el.textContent = y + '-' + m + '-' + d + ' ' + hh + ':' + mm;
      }

      updateClock();
      setInterval(updateClock, 1000);
    });
  </script>
  <script src="${pageContext.request.contextPath}/js/threshold.js"></script>
</body>
</html>