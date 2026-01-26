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

        if(startDateInput && endDateInput) {
            startDateInput.value = today;
            endDateInput.value = today;

            startDateInput.max = today; // 오늘 이후는 선택 불가
            endDateInput.max = today;   // 오늘 이후는 선택 불가
            
            // 2. 달력 상호 제한 로직 실행
            initDateLimit();
        }
        
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
    
        startDateInput.addEventListener("change", function() {
            if (startDateInput.value) {
                endDateInput.min = startDateInput.value;
            }
        });
    
        endDateInput.addEventListener("change", function() {
            if (endDateInput.value) {
                startDateInput.max = endDateInput.value;
            } else {
                startDateInput.max = today;
            }
        });
    }

    function fetchLogs() {
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;
    
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
        if(!tbody) return;

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
        if(!nav) return;

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

    // ---------------------------------------------------------
    // ✅ 수정된 핵심 부분: 객체 내부에 쉼표(,)로 구분하여 함수를 정의해야 함
    // ---------------------------------------------------------
    window.DataLog = { 
        renderPage: renderPage,
        getFilteredLogs: function() { 
            return filteredLogs; 
        } 
    };

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
    
})();