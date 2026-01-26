<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>알림 - Smart Restroom</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/css/egovframework/dashboard.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/egovframework/alert.css?v=1.7'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/common/header.jsp" />

    <div class="wrapper">
        <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" />

        <main class="main">
            <div class="alert-page">
                <div class="alert-header-row">
                    <div class="alert-title">알림</div>
                    <button type="button" class="btn-excel" onclick="downloadAlertCSV();">
                        <span class="material-icons">file_download</span> CSV Download
                    </button>
                </div>

                <div class="alert-filter">
                    <div class="filter-group">
                        <span class="filter-label">TYPE:</span>
                        <select id="typeFilter" class="select">
                            <option value="ALL">ALL</option>
                            <option value="TEMP">TEMP</option>
                            <option value="HUMIDITY">HUMIDITY</option>
                            <option value="OCCUPANCY">OCCUPANCY</option>
                            <option value="NH3">NH3</option>
                            <option value="PEOPLE_IN">PEOPLE_IN</option>
                            <option value="LIQUID_SOAP">LIQUID_SOAP</option>
                            <option value="PAPER_TOWEL">PAPER_TOWEL</option>
                        </select>
                        <span class="filter-label">STATUS:</span>
                        <select id="statusFilter" class="select">
                            <option value="ALL">ALL</option>
                            <option value="WARNING">WARNING</option>
                            <option value="CRITICAL">CRITICAL</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <input type="date" id="startDate" class="input-date">
                        <span class="date-sep">~</span>
                        <input type="date" id="endDate" class="input-date">
                        <button type="button" class="btn-search" id="btnSearch">조회하기</button>
                    </div>
                </div>

                <div class="alert-card">
                    <table class="alert-table board">
                        <thead>
                            <tr>
                                <th>Alert Type</th>
                                <th>Value</th>      <th>Content</th>
                                <th>Severity</th>   <th class="col-created-at">Created At</th>
                            </tr>
                        </thead>
                        <tbody id="alertBody">
                            <tr>
                                <td colspan="5" style="text-align:center; padding:50px;">데이터를 불러오는 중입니다...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="alert-pagination" id="pagination"></div>
            </div>
        </main>
    </div>

    <div class="modal-backdrop" id="modalBackdrop">
        <div class="modal">
            <div class="modal-header">
                <div class="modal-title" id="modalTitle">Alert Detail</div>
                <button class="btn-close" type="button" onclick="Alerts.closeModal();">닫기</button>
            </div>
            <div class="modal-body" id="modalBody"></div>
        </div>
    </div>

    <script>
	    var contextPath = "${pageContext.request.contextPath}";
	
	    // 1. 페이지 로드 시 날짜 초기화 (오늘 날짜로 세팅)
	    window.onload = function() {
	        const today = new Date().toISOString().split('T')[0];
	        document.getElementById('startDate').value = today;
	        document.getElementById('endDate').value = today;
	    };
	
	    // 2. 알림 페이지 CSV 다운로드
	    function downloadAlertCSV() {
	        // Alerts 객체는 alert.js에서 정의됨 [cite: 2026-01-26]
	        if (typeof Alerts === 'undefined' || typeof Alerts.getFilteredAlerts !== 'function') {
	            alert("데이터를 불러오는 중입니다. 잠시 후 다시 시도해주세요.");
	            return;
	        }
	
	        const allAlerts = Alerts.getFilteredAlerts();
	
	        if (!allAlerts || allAlerts.length === 0) {
	            alert("다운로드할 데이터가 없습니다. 먼저 [조회하기]를 눌러주세요.");
	            return;
	        }
	
	        let csv = [];
	        // 헤더 순서: Type, Value, Content, Severity, Created At
	        csv.push(['"Alert Type"', '"Value"', '"Content"', '"Severity"', '"Created At"'].join(","));
	
	        allAlerts.forEach(a => {
	            const row = [
	                '"' + (a.alertType || '-') + '"',
	                '"' + (a.value || '-') + '"',      
	                '"' + (a.content || '-') + '"',
	                '"' + (a.severity || '-') + '"',   
	                '"\'' + (a.createdAt || '-') + '"'
	            ];
	            csv.push(row.join(","));
	        });
	
	        const csvContent = "\uFEFF" + csv.join("\n");
	        const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
	        const url = URL.createObjectURL(blob);
	
	        const link = document.createElement("a");
	        const todayStr = new Date().toISOString().slice(0, 10);
	        link.setAttribute("href", url);
	        link.setAttribute("download", "SmartRestroom_Alerts_" + todayStr + ".csv");
	
	        document.body.appendChild(link);
	        link.click();
	        document.body.removeChild(link);
	    }
	</script>
    
    <script src="<c:url value='/js/alert.js'/>"></script>

</body>
</html>