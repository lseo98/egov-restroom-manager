/**
 * Smart Restroom - Raw Data Log Script
 */
(function() {
    let allLogs = [];      // 서버에서 가져온 원본 데이터
    let filteredLogs = []; // 필터링된 데이터
    const rowsPerPage = 10; // 페이지당 줄 수

    function init() {
    const today = new Date().toISOString().split('T')[0]; // 오늘 날짜 (YYYY-MM-DD)

    // 1. 달력 초기값 설정 및 '미래 날짜' 선택 방지 (max 설정)
    const startDateInput = document.getElementById("startDate");
    const endDateInput = document.getElementById("endDate");

    startDateInput.value = today;
    endDateInput.value = today;

    startDateInput.max = today; // 오늘 이후는 선택 불가
    endDateInput.max = today;   // 오늘 이후는 선택 불가

    // 2. 달력 상호 제한 로직 실행
    initDateLimit();
    
    // 초기 데이터 로드
    fetchLogs();
    
    const btnSearch = document.getElementById("btnSearch");
    if(btnSearch) {
        btnSearch.onclick = function() {
            fetchLogs();
        };
    }
}

    function initDateLimit() {
	    const startDateInput = document.getElementById("startDate");
	    const endDateInput = document.getElementById("endDate");
	    const today = new Date().toISOString().split('T')[0];
	
	    // 시작일 변경 시: 종료일의 '최솟값'을 시작일로 제한 (시작일 이전 선택 불가)
	    startDateInput.addEventListener("change", function() {
	        if (startDateInput.value) {
	            endDateInput.min = startDateInput.value;
	        }
	    });
	
	    // 종료일 변경 시: 시작일의 '최댓값'을 종료일로 제한 (종료일 이후 선택 불가)
	    // 단, 오늘 날짜보다는 커질 수 없음
	    endDateInput.addEventListener("change", function() {
	        if (endDateInput.value) {
	            startDateInput.max = endDateInput.value;
	        } else {
	            startDateInput.max = today;
	        }
	    });
	}

    function fetchLogs() {
	    // 1. 달력 입력창에서 날짜 문자열(YYYY-MM-DD)을 가져옴
	    const startDate = document.getElementById("startDate").value;
	    const endDate = document.getElementById("endDate").value;
	
	    // 2. URL 뒤에 ?startDate=...&endDate=... 형식으로 파라미터 추가
	    const url = contextPath + "/getSensorLogs.do?startDate=" + startDate + "&endDate=" + endDate;
	
	    fetch(url)
	        .then(res => res.json())
	        .then(data => {
	            if (data.status === "success") {
	                allLogs = data.logs || [];
	                applyFilter(); // 가져온 후 센서 종류 필터도 적용
	            }
	        })
	        .catch(err => console.error("조회 실패:", err));
	}

    function applyFilter() {
        const checkedSensors = Array.from(document.querySelectorAll('#sensorFilters input:checked'))
                                    .map(cb => cb.value);
        filteredLogs = allLogs.filter(log => checkedSensors.includes(log.sensorType));
        renderPage(1);
    }

    function getStatusTag(statusValue) {
        const val = statusValue || "Normal";
        const cssClass = "badge-" + val.toLowerCase(); 
        return '<span class="badge ' + cssClass + '">' + val + '</span>';
    }

    function renderPage(pageNum) {
        const tbody = document.getElementById('dataBody');
        const start = (pageNum - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        const pagedData = filteredLogs.slice(start, end);

        let html = "";
        pagedData.forEach(log => {
            const locationText = (log.stallId !== null && log.stallId !== undefined) 
                                 ? log.stallId + "번 칸" 
                                 : "-";

            html += '<tr>';
            html += '    <td>' + (log.readingTime || '-') + '</td>';
            html += '    <td>' + (log.sensorType || '-') + '</td>';
            html += '    <td>' + locationText + '</td>'; 
            html += '    <td>' + (log.value || '0') + '</td>';
            html += '    <td>' + getStatusTag(log.status) + '</td>'; 
            html += '</tr>';
        });

        tbody.innerHTML = html || '<tr><td colspan="5" style="text-align:center; padding:50px;">조건에 맞는 데이터가 없습니다.</td></tr>';
        renderPagination(pageNum);
    }

    function renderPagination(currentPage) {
        const nav = document.getElementById('pagination');
        const totalPages = Math.ceil(filteredLogs.length / rowsPerPage);
        
        if (totalPages <= 1) { 
            nav.innerHTML = ""; 
            return; 
        }

        const pageBlock = 10; 
        const currentBlock = Math.ceil(currentPage / pageBlock); 
        const startPage = (currentBlock - 1) * pageBlock + 1; 
        let endPage = startPage + pageBlock - 1; 

        if (endPage > totalPages) endPage = totalPages; 

        let html = "";

        if (startPage > 1) {
            html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + (startPage - 1) + ')">' +
                    '<span class="material-icons">first_page</span></a>';
        }

        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + Math.max(1, currentPage - 1) + ')">' +
                '<span class="material-icons">chevron_left</span></a>';

        for (let i = startPage; i <= endPage; i++) {
            html += '<a href="javascript:void(0);" class="page-link ' + (i === currentPage ? 'active' : '') + 
                    '" onclick="DataLog.renderPage(' + i + ')">' + i + '</a>';
        }

        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + Math.min(totalPages, currentPage + 1) + ')">' +
                '<span class="material-icons">chevron_right</span></a>';

        if (endPage < totalPages) {
            html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + (endPage + 1) + ')">' +
                    '<span class="material-icons">last_page</span></a>';
        }

        nav.innerHTML = html;
    }

    window.DataLog = { renderPage: renderPage };

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();