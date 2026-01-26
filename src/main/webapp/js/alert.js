/**
 * alert.js - 타입별 색상 복구 및 필터링 통합 버전
 */

const Alerts = {
    currentPage: 1,
    rowsPerPage: 10,
    allAlerts: [], 
    filteredAlerts: [],

    init: function() {
        const today = new Date().toISOString().split('T')[0];
        const startDateInput = document.getElementById("startDate");
        const endDateInput = document.getElementById("endDate");

        if (startDateInput && endDateInput) {
            startDateInput.value = today;
            endDateInput.value = today;
        }

        const btn = document.getElementById('btnSearch');
        if (btn) {
            btn.addEventListener('click', () => {
                this.currentPage = 1; 
                this.fetchAlerts();   
            });
        }

        this.fetchAlerts();
    },

    getFilteredAlerts: function() {
        return this.allAlerts || [];
    },

    fetchAlerts: function() {
        const type = document.getElementById('typeFilter').value;
        const status = document.getElementById('statusFilter').value;
        const start = document.getElementById('startDate').value;
        const end = document.getElementById('endDate').value;

        const tbody = document.getElementById('alertBody');
        if (tbody) tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:50px;">데이터를 조회 중입니다...</td></tr>`;

        const url = `${contextPath}/getAlertLogs.do?alertType=${type}&severity=${status}&startDate=${start}&endDate=${end}`;

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data.status === "success" && Array.isArray(data.logs)) {
                    this.allAlerts = data.logs; 
                    this.filteredAlerts = [...this.allAlerts];
                    this.render(); 
                } else {
                    throw new Error("데이터 형식이 올바르지 않습니다.");
                }
            })
            .catch(err => {
                console.error("데이터 로드 에러:", err);
                if (tbody) tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; color:red; padding:50px;">조회 실패: ${err.message}</td></tr>`;
            });
    },

    render: function() {
        const start = (this.currentPage - 1) * this.rowsPerPage;
        const end = start + this.rowsPerPage;
        const pagedList = this.filteredAlerts.slice(start, end);

        const paging = {
            totalPages: Math.ceil(this.filteredAlerts.length / this.rowsPerPage)
        };

        this.renderTable(pagedList);
        this.renderPagination(paging);
    },

    // 4. 테이블 그리기 함수 (색상 로직 복구)
    renderTable: function(list) {
        const tbody = document.getElementById('alertBody');
        if (!tbody) return;

        if (list.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:50px;">조회된 알림 내역이 없습니다.</td></tr>`;
            return;
        }

        let html = '';
        list.forEach(item => {
            // ✅ 핵심: 알림 타입별 소문자 클래스 생성 (예: type-temp, type-humidity)
            const typeClass = `type-${String(item.alertType || '').toLowerCase()}`;
            const sevClass = (item.severity === 'CRITICAL') ? 'badge-critical' : 'badge-warning';
            
            html += `
                <tr class="alert-row" onclick='Alerts.openModal(${JSON.stringify(item)})' style="cursor:pointer;">
                    <td><span class="type-pill ${typeClass}">${item.alertType || '-'}</span></td>
                    <td><strong style="color:#1e293b;">${item.value || '-'}</strong></td> 
                    <td><span class="board-title">${item.content || '-'}</span></td>
                    <td><span class="badge ${sevClass}">${item.severity || 'WARNING'}</span></td> 
                    <td class="col-created-at">${item.createdAt || '-'}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    },

    renderPagination: function(paging) {
        const nav = document.getElementById('pagination');
        if (!nav) return;
        if (paging.totalPages <= 1) {
            nav.innerHTML = "";
            return;
        }

        let html = "";
        for (let i = 1; i <= paging.totalPages; i++) {
            html += `<a href="javascript:void(0);" class="page-link ${i === this.currentPage ? 'active' : ''}"
                        onclick="Alerts.goToPage(${i})">${i}</a>`;
        }
        nav.innerHTML = html;
    },

    goToPage: function(page) {
        this.currentPage = page;
        this.render();
    },

    openModal: function(item) {
        const modalBody = document.getElementById('modalBody');
        if (!modalBody) return;

        modalBody.innerHTML = `
            <div style="line-height:2.2; font-size:14px;">
                <b>알림 타입:</b> <span class="type-pill type-${String(item.alertType).toLowerCase()}">${item.alertType}</span><br>
                <b>심각도:</b> <span class="badge ${(item.severity === 'CRITICAL') ? 'badge-critical' : 'badge-warning'}">${item.severity}</span><br>
                <b>내용:</b> ${item.content || '-'}<br>
                <b>현재 수치:</b> <span style="color:#b91c1c; font-weight:bold;">${item.value || '-'}</span><br>
                <b>발생 시간:</b> ${item.createdAt}
            </div>
        `;
        document.getElementById('modalBackdrop').style.display = 'flex';
    },

    closeModal: function() {
        document.getElementById('modalBackdrop').style.display = 'none';
    }
};

document.addEventListener('DOMContentLoaded', () => {
    Alerts.init();
});