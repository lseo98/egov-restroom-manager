/**
 * Smart Restroom - Alert Log Script (IIFE Style)
 */
(function() {
    let allAlerts = [];      // 서버에서 가져온 전체 데이터
    let filteredAlerts = []; // 필터링된 데이터
    let currentPage = 1;     // 현재 페이지
    const rowsPerPage = 10;  // 페이지당 줄 수

    function init() {
        // 날짜 입력창 제약 설정은 JSP의 window.onload에서 수행하므로
        // 여기서는 버튼 이벤트 연결만 담당합니다.
        const btnSearch = document.getElementById("btnSearch");
        if(btnSearch) {
            btnSearch.onclick = function() {
                currentPage = 1; // 검색 시 1페이지로 리셋
                fetchAlerts();
            };
        }
        
        // 초기 로드 시 실행 (JSP에서 btnSearch.click()을 하므로 생략 가능하나 안전을 위해 유지)
        // fetchAlerts(); 
    }

    function fetchAlerts() {
        const type = document.getElementById('typeFilter').value;
        const start = document.getElementById('startDate').value;
        const end = document.getElementById('endDate').value;
        const status = 'ALL'; // 심각도 필터는 'ALL'로 고정

        const url = contextPath + "/getAlertLogs.do?alertType=" + type + 
                    "&severity=" + status + "&startDate=" + start + "&endDate=" + end;

        const tbody = document.getElementById('alertBody');
        if (tbody) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:50px;">데이터를 조회 중입니다...</td></tr>';

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data.status === "success" && Array.isArray(data.logs)) {
                    allAlerts = data.logs;
                    filteredAlerts = [...allAlerts];
                    renderPage(1);
                }
            })
            .catch(err => console.error("데이터 로드 에러:", err));
    }

    function renderPage(pageNum) {
        currentPage = pageNum;
        const tbody = document.getElementById('alertBody');
        if(!tbody) return;

        const start = (pageNum - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        const pagedData = filteredAlerts.slice(start, end);

        let html = "";
        pagedData.forEach(item => {
            const typeClass = "type-" + String(item.alertType || '').toLowerCase();
            const sevClass = (item.severity === 'CRITICAL') ? 'badge-critical' : 'badge-warning';
            
            // 데이터 보호를 위해 JSON 문자열화 시 작은따옴표 처리
            const itemJson = JSON.stringify(item).replace(/'/g, "\\'");

            html += '<tr class="alert-row" onclick=\'Alerts.openModal(' + itemJson + ')\' style="cursor:pointer;">';
            html += '    <td><span class="type-pill ' + typeClass + '">' + (item.alertType || '-') + '</span></td>';
            html += '    <td><strong style="color:#1e293b;">' + (item.value || '-') + '</strong></td>';
            html += '    <td><span class="board-title">' + (item.content || '-') + '</span></td>';
            html += '    <td><span class="badge ' + sevClass + '">' + (item.severity || 'WARNING') + '</span></td>';
            html += '    <td class="col-created-at">' + (item.createdAt || '-') + '</td>';
            html += '</tr>';
        });

        tbody.innerHTML = html || '<tr><td colspan="5" style="text-align:center; padding:50px;">조건에 맞는 데이터가 없습니다.</td></tr>';
        renderPagination(pageNum);
    }

    function renderPagination(pageNum) {
        const nav = document.getElementById('pagination');
        if(!nav) return;

        const totalPages = Math.ceil(filteredAlerts.length / rowsPerPage);
        
        if (totalPages <= 1) { 
            nav.innerHTML = ""; 
            return; 
        }

        const pageBlock = 10; 
        const currentBlock = Math.ceil(pageNum / pageBlock); 
        const startPage = (currentBlock - 1) * pageBlock + 1; 
        let endPage = startPage + pageBlock - 1; 

        if (endPage > totalPages) endPage = totalPages; 

        let html = "";
        
        // [처음] 화살표
        if (startPage > 1) {
            html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.renderPage(1)">' +
                    '<span class="material-icons">first_page</span></a>';
        }
        
        // [이전] 화살표
        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.renderPage(' + Math.max(1, pageNum - 1) + ')">' +
                '<span class="material-icons">chevron_left</span></a>';

        // 숫자 번호
        for (let i = startPage; i <= endPage; i++) {
            html += '<a href="javascript:void(0);" class="page-link ' + (i === pageNum ? 'active' : '') + 
                    '" onclick="Alerts.renderPage(' + i + ')">' + i + '</a>';
        }

        // [다음] 화살표
        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.renderPage(' + Math.min(totalPages, pageNum + 1) + ')">' +
                '<span class="material-icons">chevron_right</span></a>';
        
        // [다음 뭉치로] - 현재 뭉치 끝번호보다 1 큰 페이지(다음 뭉치의 시작)로 이동
	    if (endPage < totalPages) {
	        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.renderPage(' + (endPage + 1) + ')">' +
	                '<span class="material-icons">last_page</span></a>';
	    }
        
        nav.innerHTML = html;
    }

    // ✅ Alerts 객체 내부의 openModal 함수를 아래 내용으로 교체하세요.
	function openModal(item) {
	    const modalBody = document.getElementById('modalBody');
	    if (!modalBody) return;
	
	    // 심각도 및 타입 클래스 설정
	    const sevClass = (item.severity === 'CRITICAL') ? 'badge-critical' : 'badge-warning';
	    const typeClass = 'type-' + String(item.alertType || '').toLowerCase();
	
	    // 이미지와 동일한 구조 생성
	    var html = '<div class="kv-container">';
	    html += '    <div class="kv">';
	    
	    html += '        <div class="k">Alter Type:</div>';
	    html += '        <div class="v"><span class="type-pill ' + typeClass + '">' + (item.alertType || '-') + '</span></div>';
	    
	    html += '        <div class="k">Severity:</div>';
	    html += '        <div class="v"><span class="badge ' + sevClass + '">' + (item.severity || 'WARNING') + '</span></div>';
	    
	    html += '        <div class="k">Content:</div>';
	    html += '        <div class="v">' + (item.content || '-') + '</div>';
	    
	    html += '        <div class="k">Value:</div>';
	    html += '        <div class="v v-highlight">' + (item.value || '-') + '</div>';
	    
	    html += '        <div class="k">Created At:</div>';
	    html += '        <div class="v">' + (item.createdAt || '-') + '</div>';
	    
	    html += '    </div>';
	    html += '</div>';
	
	    modalBody.innerHTML = html;
	    document.getElementById('modalBackdrop').style.display = 'flex';
	}
    function closeModal() {
        const backdrop = document.getElementById('modalBackdrop');
        if (backdrop) backdrop.style.display = 'none';
    }

    // 외부(window)에서 접근 가능하도록 공개할 함수들 정의
    window.Alerts = { 
        renderPage: renderPage,
        fetchAlerts: fetchAlerts,
        getFilteredAlerts: function() { 
            return filteredAlerts; 
        },
        openModal: openModal,
        closeModal: closeModal
    };

    // DOM 로드 완료 시 초기화 실행
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
    
})();