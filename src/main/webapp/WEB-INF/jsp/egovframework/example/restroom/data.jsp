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
                        <input type="date" value="2026-01-22" class="input-date">
                        <span class="date-sep">~</span>
                        <input type="date" value="2026-01-22" class="input-date">
                        <button type="button" class="btn-search" onclick="applyFilter()">조회하기</button>
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
                        <tbody id="dataBody"></tbody>
                    </table>
                </div>
                <div class="data-pagination" id="pagination"></div>
            </div>
        </main>
    </div>

    <script>
        // 대량 더미 데이터 (3페이지 분량 확보)
        const allData = [
            ["13:55:10", "TEMP", "Main Hall", "24.2 ℃", "badge-normal", "Normal"],
            ["13:54:02", "NH3", "Stall 1", "0.05 ppm", "badge-normal", "Normal"],
            ["13:52:44", "PEOPLE_IN", "Entrance", "5", "badge-normal", "Normal"],
            ["13:50:00", "LIQUID_SOAP", "Stall 2", "100%", "badge-refill", "REFILLED"],
            ["13:48:12", "HUMIDITY", "Main Hall", "48%", "badge-normal", "Normal"],
            ["13:45:05", "OCCUPANCY", "Stall 3", "Empty", "badge-normal", "Normal"],
            ["13:40:22", "PAPER_TOWEL", "Stall 1", "90%", "badge-normal", "Normal"],
            ["13:38:11", "TEMP", "Main Hall", "23.8 ℃", "badge-normal", "Normal"],
            ["13:35:55", "NH3", "Stall 2", "1.25 ppm", "badge-critical", "Critical"],
            ["13:32:02", "LIQUID_SOAP", "Stall 1", "95%", "badge-refill", "REFILLED"],
            ["13:30:44", "PEOPLE_IN", "Entrance", "42", "badge-normal", "Normal"],
            ["13:28:10", "HUMIDITY", "Main Hall", "45%", "badge-normal", "Normal"],
            ["13:25:00", "OCCUPANCY", "Stall 1", "In Use", "badge-warning", "Occupied"],
            ["13:22:12", "PAPER_TOWEL", "Stall 2", "15%", "badge-critical", "Low"],
            ["13:20:00", "TEMP", "Stall 1", "25.0 ℃", "badge-normal", "Normal"],
            ["13:18:12", "NH3", "Stall 3", "0.02 ppm", "badge-normal", "Normal"],
            ["13:15:44", "PEOPLE_IN", "Entrance", "12", "badge-normal", "Normal"],
            ["13:12:05", "LIQUID_SOAP", "Stall 2", "20%", "badge-warning", "Low"],
            ["13:10:00", "HUMIDITY", "Main Hall", "50%", "badge-normal", "Normal"],
            ["13:05:44", "OCCUPANCY", "Stall 2", "Empty", "badge-normal", "Normal"],
            ["13:00:10", "PAPER_TOWEL", "Stall 3", "100%", "badge-refill", "REFILLED"],
            ["12:55:00", "TEMP", "Main Hall", "23.5 ℃", "badge-normal", "Normal"],
            ["12:52:12", "NH3", "Stall 1", "0.80 ppm", "badge-warning", "Warning"],
            ["12:50:00", "PEOPLE_IN", "Entrance", "3", "badge-normal", "Normal"],
            ["12:48:44", "LIQUID_SOAP", "Stall 1", "40%", "badge-normal", "Normal"],
            ["12:45:00", "HUMIDITY", "Stall 2", "42%", "badge-normal", "Normal"],
            ["12:42:12", "OCCUPANCY", "Stall 3", "In Use", "badge-warning", "Occupied"],
            ["12:40:00", "PAPER_TOWEL", "Stall 2", "60%", "badge-normal", "Normal"],
            ["12:38:05", "TEMP", "Main Hall", "22.9 ℃", "badge-normal", "Normal"],
            ["12:35:12", "NH3", "Stall 2", "0.01 ppm", "badge-normal", "Normal"],
            ["12:30:00", "PEOPLE_IN", "Entrance", "25", "badge-normal", "Normal"],
            ["12:28:12", "LIQUID_SOAP", "Stall 2", "100%", "badge-refill", "REFILLED"],
            ["12:25:00", "HUMIDITY", "Main Hall", "47%", "badge-normal", "Normal"],
            ["12:22:44", "OCCUPANCY", "Stall 1", "Empty", "badge-normal", "Normal"],
            ["12:20:00", "PAPER_TOWEL", "Stall 1", "85%", "badge-normal", "Normal"]
        ];

        let filteredData = [...allData];
        const rowsPerPage = 10;

        // 필터 적용 로직
        function applyFilter() {
            const selectedSensors = Array.from(document.querySelectorAll('#sensorFilters input:checked')).map(cb => cb.value);
            filteredData = allData.filter(row => selectedSensors.includes(row[1]));
            renderPage(1);
        }

        // 페이지 렌더링 (따옴표 결합 방식으로 에디터 에러 원천 차단)
        function renderPage(pageNum) {
            const tbody = document.getElementById('dataBody');
            const start = (pageNum - 1) * rowsPerPage;
            const end = start + rowsPerPage;
            const pagedData = filteredData.slice(start, end);

            let html = "";
            pagedData.forEach(function(row) {
                html += '<tr>';
                html += '    <td>' + row[0] + '</td>';
                html += '    <td>' + row[1] + '</td>';
                html += '    <td>' + row[2] + '</td>';
                html += '    <td>' + row[3] + '</td>';
                html += '    <td><span class="badge ' + row[4] + '">' + row[5] + '</span></td>';
                html += '</tr>';
            });

            tbody.innerHTML = html || '<tr><td colspan="5" style="text-align:center; padding:50px;">데이터가 없습니다.</td></tr>';
            renderPagination(pageNum);
        }

        // 페이지네이션 생성 로직
        function renderPagination(currentPage) {
            const nav = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredData.length / rowsPerPage);
            
            let html = '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="renderPage(' + Math.max(1, currentPage-1) + ')"><span class="material-icons">chevron_left</span></a>';
            for (let i = 1; i <= totalPages; i++) {
                html += '<a href="javascript:void(0);" class="page-link ' + (i === currentPage ? 'active' : '') + '" onclick="renderPage(' + i + ')">' + i + '</a>';
            }
            html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="renderPage(' + Math.min(totalPages, currentPage+1) + ')"><span class="material-icons">chevron_right</span></a>';
            
            nav.innerHTML = html;
        }

        // 초기 페이지 로드
        window.onload = function() {
            renderPage(1);
        };
    </script>
</body>
</html>