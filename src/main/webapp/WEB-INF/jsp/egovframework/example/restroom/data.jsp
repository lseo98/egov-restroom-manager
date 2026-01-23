<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Raw Data Log - Smart Restroom</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/css/egovframework/dashboard.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/egovframework/data.css?v=1.8'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/common/header.jsp" />
    <div class="wrapper">
        <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />
        <main class="main">
            <div class="data-page">
                <div class="data-header-row">
                    <div class="data-title">Raw Data Log</div>
                    <button type="button" class="btn-excel" onclick="alert('Excel 다운로드 기능을 준비 중입니다.');">
                        <span class="material-icons">file_download</span> Excel Download
                    </button>
                </div>

                <div class="data-filter">
                    <div class="filter-group">
                        <span class="filter-label">SENSORS:</span>
                        <div class="checkbox-group" id="sensorFilters">
                            <label><input type="checkbox" value="TEMP" checked> TEMP</label>
                            <label><input type="checkbox" value="HUMIDITY" checked> HUMIDITY</label>
                            <label><input type="checkbox" value="OCCUPANCY" checked> OCCUPANCY</label>
                            <label><input type="checkbox" value="NH3" checked> NH3</label>
                            <label><input type="checkbox" value="PEOPLE_IN" checked> PEOPLE_IN</label>
                            <label><input type="checkbox" value="LIQUID_SOAP" checked> LIQUID_SOAP</label>
                            <label><input type="checkbox" value="PAPER_TOWEL" checked> PAPER_TOWEL</label>
                        </div>
                    </div>
                    <div class="filter-group">
                        <input type="date" id="startDate" class="input-date">
                        <span class="date-sep">~</span>
                        <input type="date" id="endDate" class="input-date">
                        <button type="button" class="btn-search" id="btnSearch">조회하기</button>
                    </div>
                </div>

                <div class="data-card">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Sensor Type</th>
                                <th>Location</th>
                                <th>Value</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="dataBody">
                            <tr><td colspan="5" style="text-align:center; padding:50px;">데이터를 불러오는 중입니다...</td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="data-pagination" id="pagination"></div>
            </div>
        </main>
    </div>

    <script>
        var contextPath = "${pageContext.request.contextPath}";
    </script>
    
    <script src="<c:url value='/js/data.js'/>"></script>
</body>
</html>