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

        // ✅ 필터링된 "전체 페이지 데이터"를 CSV로 변환하는 함수
        function downloadCSV() {
            // 1. DataLog 객체를 통해 filteredLogs 데이터 가져오기
            if (typeof DataLog === 'undefined' || typeof DataLog.getFilteredLogs !== 'function') {
                alert("데이터 로직을 불러오는 중입니다. 잠시 후 다시 시도해주세요.");
                return;
            }

            const allData = DataLog.getFilteredLogs();

            if (!allData || allData.length === 0) {
                alert("다운로드할 데이터가 없습니다. 먼저 조회를 해주세요.");
                return;
            }

            // 2. CSV 데이터 생성
            let csv = [];
            // 컬럼 헤더 정의
            const header = ["Time", "Sensor Type", "Location", "Value", "Status"];
            csv.push(header.map(h => '"' + h + '"').join(","));

            // 3. 전체 데이터 반복 처리
            allData.forEach(log => {
                const locationText = (log.stallId !== null && log.stallId !== undefined) 
                                     ? log.stallId + "번 칸" 
                                     : "-";
                
                let row = [
                    '"\'' + (log.readingTime || '-') + '"', // 엑셀 시간 깨짐 방지 (')
                    '"' + (log.sensorType || '-') + '"',
                    '"' + locationText + '"',
                    '"' + (log.value || '0') + '"',
                    '"' + (log.status || 'Normal') + '"'
                ];
                csv.push(row.join(","));
            });

            // 4. BOM(한글 깨짐 방지) 및 파일 다운로드 처리
            const csvContent = "\uFEFF" + csv.join("\n");
            const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
            const url = URL.createObjectURL(blob);
            
            const link = document.createElement("a");
            const today = new Date().toISOString().slice(0, 10);
            
            link.setAttribute("href", url);
            link.setAttribute("download", "Restroom_Full_Log_" + today + ".csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    </script>
    
    <script src="<c:url value='/js/data.js'/>"></script>
</body>
</html>