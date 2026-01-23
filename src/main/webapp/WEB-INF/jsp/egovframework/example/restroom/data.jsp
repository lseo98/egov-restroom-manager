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
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono&display=swap" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/common/header.jsp" />
    <div class="wrapper">
        <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />
        <main class="main">
            <div class="data-page">
                <div class="data-header-row">
                    <div class="data-title">Raw Data Log</div>
                    <button type="button" class="btn-excel" onclick="downloadCSV();">
                        <span class="material-icons">file_download</span> CSV Download
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

        // ✅ 화면에 보이는 10개가 아닌, 필터링된 "전체 데이터"를 CSV로 저장하는 함수
        function downloadCSV() {
            // data.js 내부에 캡슐화되어 있을 수 있으므로 filteredLogs에 접근 시도
            // 만약 undefined라면 data.js 구조에 맞게 로직 구성
            if (typeof filteredLogs === 'undefined') {
                // 이 영역은 data.js 외부에서 filteredLogs에 접근하지 못할 경우를 대비한 안전장치입니다.
                alert("데이터 로딩 중입니다. 잠시 후 다시 시도해주세요.");
                return;
            }

            if (filteredLogs.length === 0) {
                alert("다운로드할 데이터가 없습니다.");
                return;
            }

            let csv = [];
            // 헤더 추가
            csv.push(['"Time"', '"Sensor Type"', '"Location"', '"Value"', '"Status"'].join(","));

            // 전체 데이터 반복
            filteredLogs.forEach(log => {
                const locationText = (log.stallId !== null && log.stallId !== undefined) 
                                     ? log.stallId + "번 칸" 
                                     : "-";
                
                let row = [
                    '"\'' + (log.readingTime || '-') + '"', // 엑셀 #### 방지
                    '"' + (log.sensorType || '-') + '"',
                    '"' + locationText + '"',
                    '"' + (log.value || '0') + '"',
                    '"' + (log.status || 'Normal') + '"'
                ];
                csv.push(row.join(","));
            });

            const csvContent = "\uFEFF" + csv.join("\n");
            const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
            const url = URL.createObjectURL(blob);
            const link = document.createElement("a");
            const today = new Date().toISOString().slice(0, 10);
            
            link.setAttribute("href", url);
            link.setAttribute("download", "Restroom_All_Data_" + today + ".csv");
            link.click();
        }
    </script>
    
    <script src="<c:url value='/js/data.js'/>"></script>
</body>
</html>