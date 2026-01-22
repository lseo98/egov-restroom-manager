<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>센서 데이터</title>

  <!-- ✅ 공통 스타일(대시보드와 동일한 헤더/사이드바 스타일) -->
  <!-- ※ 프로젝트에서 실제로 쓰는 공통 css 경로로 맞추세요 -->
  <link rel="stylesheet" href="<c:url value='/css/egovframework/common.css'/>">

  <!-- ✅ 이 페이지 전용(본문만 꾸미는 css) -->
  <link rel="stylesheet" href="<c:url value='/css/egovframework/data.css'/>">
</head>

<body class="app">

  <!-- ✅ 헤더는 무조건 최상단 전체폭 (사이드바 위) -->
  <div class="app-header">
    <jsp:include page="../../../common/header.jsp" />
  </div>

  <!-- ✅ 헤더 아래: 좌(사이드바) + 우(본문) -->
  <div class="app-body">
    <div class="app-sidebar">
      <jsp:include page="../../../common/sidebar.jsp" />
    </div>

    <div class="app-main">
      <div class="page-header">
        <h2>Raw Data Log - Smart Restroom</h2>
      </div>

      <div class="filter-bar">
        <select name="sensorType">
          <option value="All">Sensor Type: All</option>
          <option value="Odor">Odor (NH3)</option>
          <option value="Temp">Temperature</option>
        </select>

        <input type="date" value="2026-01-16">
        <input type="text" placeholder="Search...">
        <button type="button">Refresh</button>
      </div>

      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Time</th>
              <th>Sensor Type</th>
              <th>Location</th>
              <th>Value</th>
              <th>Unit</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>17:15:55</td>
              <td>People Count</td>
              <td>Main Entrance</td>
              <td>487</td>
              <td>Count</td>
              <td><span class="status-badge status-normal">Normal (Green)</span></td>
            </tr>
            <tr>
              <td>17:15:02</td>
              <td>Odor (NH3)</td>
              <td>Stall 1</td>
              <td>1.2</td>
              <td>ppm</td>
              <td><span class="status-badge status-critical">CRITICAL (Red)</span></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <span>&lt;</span>
        <strong>1</strong> <span>2</span> <span>3</span> <span>4</span> <span>5</span>
        <span>&gt;</span>
      </div>
    </div>
  </div>

</body>
</html>
