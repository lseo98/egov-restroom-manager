/**
 * Smart Restroom - Raw Data Log Script
 */
(function() {
    let allLogs = [];      // 서버에서 가져온 원본 데이터
    let filteredLogs = []; // 필터링된 데이터
    const rowsPerPage = 10; // 페이지당 줄 수

    function init() {
        fetchLogs();
        const btnSearch = document.getElementById("btnSearch");
        if(btnSearch) btnSearch.onclick = applyFilter;

        const today = new Date().toISOString().split('T')[0];
        document.getElementById("startDate").value = today;
        document.getElementById("endDate").value = today;
    }

    function fetchLogs() {
        fetch(contextPath + "/getSensorLogs.do")
            .then(res => res.json())
            .then(data => {
                if (data.status === "success") {
                    allLogs = data.logs || [];
                    filteredLogs = [...allLogs];
                    renderPage(1);
                }
            })
            .catch(err => console.error("데이터 로드 실패:", err));
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

    // ✅ 페이지네이션 생성 (10개씩 블록 단위로 표시)
function renderPagination(currentPage) {
    const nav = document.getElementById('pagination');
    const totalPages = Math.ceil(filteredLogs.length / rowsPerPage);
    
    if (totalPages <= 1) { 
        nav.innerHTML = ""; 
        return; 
    }

    const pageBlock = 10; // 한 번에 보여줄 페이지 번호 개수
    const currentBlock = Math.ceil(currentPage / pageBlock); // 현재 페이지가 몇 번째 블록인지 계산
    const startPage = (currentBlock - 1) * pageBlock + 1; // 블록의 시작 번호 (1, 11, 21...)
    let endPage = startPage + pageBlock - 1; // 블록의 끝 번호 (10, 20, 30...)

    if (endPage > totalPages) endPage = totalPages; // 전체 페이지를 넘지 않도록 제한

    let html = "";

    // 1. [이전 블록] 화살표: 첫 번째 블록이 아닐 때만 표시
    if (startPage > 1) {
        html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + (startPage - 1) + ')">' +
                '<span class="material-icons">first_page</span></a>';
    }

    // 2. [이전 페이지] 화살표
    html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + Math.max(1, currentPage - 1) + ')">' +
            '<span class="material-icons">chevron_left</span></a>';

    // 3. [숫자 버튼]: 현재 블록의 시작번호부터 끝번호까지만 반복문 수행
    for (let i = startPage; i <= endPage; i++) {
        html += '<a href="javascript:void(0);" class="page-link ' + (i === currentPage ? 'active' : '') + 
                '" onclick="DataLog.renderPage(' + i + ')">' + i + '</a>';
    }

    // 4. [다음 페이지] 화살표
    html += '<a href="javascript:void(0);" class="page-link nav-arrow" onclick="DataLog.renderPage(' + Math.min(totalPages, currentPage + 1) + ')">' +
            '<span class="material-icons">chevron_right</span></a>';

    // 5. [다음 블록] 화살표: 마지막 블록이 아닐 때만 표시
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