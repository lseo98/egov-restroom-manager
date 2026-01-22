<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Raw Data Log</title>

  <!-- css 경로는 이미 고치셨다면 이대로 -->
  <link rel="stylesheet" href="<c:url value='/css/egovframework/data.css'/>">
</head>
<body>

  <!-- ✅ 헤더를 최상단(전체폭)으로 -->
  <header class="app-header">
    <jsp:include page="../../../common/header.jsp" />
  </header>

  <!-- ✅ 헤더 아래 영역: 사이드바 + 메인 -->
  <div class="app-body">
    <aside class="app-sidebar">
      <jsp:include page="../../../common/sidebar.jsp" />
    </aside>

    <main class="app-main">
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
    </main>
  </div>

</body>
</html>
