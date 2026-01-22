<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>임계치 설정</title>

  <!-- ✅ (추가) 대시보드와 동일한 폰트 로드 -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&family=Roboto+Mono&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/egovframework/threshold.css" />

  <style>
    /* 1. 레이아웃 유지 및 스크롤 방지 */
    html, body {
      margin: 0 !important;
      padding: 0 !important;
      height: 100% !important;
      overflow: hidden !important;
      background: #FFFFFF !important;
      font-family: 'Noto Sans KR', sans-serif;
    }

    /* 2. 하단 여백 없이 화면 꽉 채우기 */
    .content-area {
      display: flex;
      flex-direction: column;
      height: calc(100vh - 64px) !important;
      padding: 20px !important;
      box-sizing: border-box;
    }

    .grid.grid-3x2 {
      flex: 1;
      display: grid !important;
      grid-template-columns: repeat(3, 1fr) !important;
      grid-template-rows: repeat(2, 1fr);
      gap: 20px !important;
    }

    /* 3. 카드 그림자 추가 (대시보드와 동일 스타일) */
    .card, .card.compact {
      background: #FFFFFF !important;
      border: 1px solid #e2e8f0 !important;
      border-radius: 12px !important;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05) !important;
      height: 100% !important;
      margin: 0 !important;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    /* ✅ 4. 헤더 시계 스타일 (대시보드 index.jsp 스타일 복사) */
    #real-time-clock {
      min-width: 180px !important;
      display: inline-block !important;
      text-align: center !important;
      font-family: 'Roboto Mono', monospace !important;
      background: rgba(255,255,255,0.15) !important;
      color: white !important;
      font-variant-numeric: tabular-nums;
      border-radius: 20px;
      padding: 4px 15px;
      margin-left: 20px;
      font-size: 14px;
      font-weight: 700;
    }
  </style>
</head>

<body class="page threshold-page">
  <jsp:include page="/WEB-INF/jsp/common/header.jsp" />
  <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />

  <div class="content-area" id="contentArea">
    <div class="page-top" id="pageTop" style="margin-bottom: 20px;">
      <div class="page-title">
        <h1 style="margin: 0; font-size: 24px; font-weight: 900;">임계치 설정</h1>
        <p style="margin: 5px 0 0 0; color: #64748B;">센서별 기준값을 설정하면 알림 페이지에서 이상 징후를 빠르게 확인할 수 있습니다.</p>
      </div>

      <div class="btn-row">
        <button class="btn primary" type="button" id="btnSave">저장</button>
        <button class="btn" type="button" id="btnReset">기본값으로 초기화</button>
      </div>
    </div>

    <div class="grid grid-3x2" id="grid">
      <section class="card">
        <div class="card-head">
          <div class="card-title"><strong>온도</strong><span>단위: ℃</span></div>
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
          <div class="card-title"><strong>습도</strong><span>단위: %</span></div>
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
          <div class="card-title"><strong>악취(NH3)</strong><span>단위: ppm</span></div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="nh3"></span></label>
        </div>
        <div class="form">
          <div class="row"><div class="label">상한(High)</div><div class="field"><input class="input" type="number" step="0.1" id="nh3_high" /><span class="unit">ppm</span></div></div>
          <div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" step="0.1" id="nh3_low" /><span class="unit">ppm</span></div></div>
          <div class="row"><div class="label">다시 알림</div><div class="field"><input class="input" type="number" id="nh3_realert_min" /><span class="unit">분</span></div></div>
        </div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title"><strong>피플카운트</strong><span>단위: 명</span></div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="people"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">상한(High)</div><div class="field"><input class="input" type="number" id="people_high" /><span class="unit">명</span></div></div></div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title"><strong>페이퍼타올</strong><span>단위: %</span></div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="towel"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" id="towel_threshold" /><span class="unit">%</span></div></div></div>
      </section>

      <section class="card compact">
        <div class="card-head">
          <div class="card-title"><strong>액체 비누</strong><span>단위: %</span></div>
          <label class="toggle"><small>알림</small><span class="switch" data-toggle="soap"></span></label>
        </div>
        <div class="form one"><div class="row"><div class="label">하한(Low)</div><div class="field"><input class="input" type="number" id="soap_threshold" /><span class="unit">%</span></div></div></div>
      </section>
    </div>
  </div>

  <div class="toast" id="toast">저장되었습니다.</div>

  <script>
    document.addEventListener("DOMContentLoaded", function() {

      // ✅ (삭제됨) 헤더 버튼을 시계로 갈아끼우는 코드 제거
      // -> header.jsp에 이미 #real-time-clock이 존재한다는 전제

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
