/**
 * alert.js - 알림 페이지 핵심 로직 (5컬럼 더미 데이터 버전)
 */

const Alerts = {
    currentPage: 1,

    init: function() {
        // 1. 이벤트 리스너 등록
        document.getElementById('btnSearch').addEventListener('click', () => {
            this.currentPage = 1;
            this.fetchAlerts();
        });

        // 2. 초기 데이터 로드
        this.fetchAlerts();
    },

    // 데이터 가져오기 (더미 데이터 사용)
    fetchAlerts: function() {
        // --- 더미 데이터 시작 ---
        const dummyData = {
            list: [
                { alertType: 'TEMP', title: '온도 초과', message: '남성 화장실 1구역 온도 임계치 초과', value: '30.5°C', createdAt: '2026-01-26 13:20:45' },
                { alertType: 'HUMIDITY', title: '습도 주의', message: '중앙 로비 습도가 너무 높습니다.', value: '82%', createdAt: '2026-01-26 12:45:12' },
                { alertType: 'NH3', title: '악취 감지', message: '지하 주차장 암모니아 농도 상승', value: '15ppm', createdAt: '2026-01-26 11:30:00' },
                { alertType: 'PEOPLE_IN', title: '밀집 경보', message: '세미나실 입구 인원 과다 진입', value: '45명', createdAt: '2026-01-26 10:15:33' },
                { alertType: 'LIQUID_SOAP', title: '잔량 부족', message: '서편 화장실 비누 잔량 부족', value: '8%', createdAt: '2026-01-25 09:05:21' }
            ],
            pagination: {
                startPage: 1,
                endPage: 5
            }
        };

        this.renderTable(dummyData.list);
        this.renderPagination(dummyData.pagination);
        // --- 더미 데이터 끝 ---
    },

    // 테이블 렌더링 (5개 컬럼 적용)
    renderTable: function(list) {
        const tbody = document.getElementById('alertBody');
        if (!list || list.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:50px;">조건에 맞는 데이터가 없습니다.</td></tr>`;
            return;
        }

        let html = '';
        list.forEach(item => {
            const typeClass = `type-${item.alertType.toLowerCase()}`;
            
            html += `
                <tr class="alert-row" onclick="Alerts.openModal(${JSON.stringify(item).replace(/"/g, '&quot;')})">
                    <td><span class="type-pill ${typeClass}">${item.alertType}</span></td>
                    <td><span class="board-title">${item.title}</span></td>
                    <td><span class="board-msg">${item.message}</span></td>
                    <td><strong>${item.value}</strong></td>
                    <td class="col-created-at">${item.createdAt}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    },

    // 페이징 렌더링
    renderPagination: function(paging) {
        const container = document.getElementById('pagination');
        if (!paging) return;

        let html = '';
        for (let i = paging.startPage; i <= paging.endPage; i++) {
            html += `
                <a href="javascript:void(0)" 
                   class="page-link ${i === this.currentPage ? 'active' : ''}" 
                   onclick="Alerts.goToPage(${i})">${i}</a>
            `;
        }
        container.innerHTML = html;
    },

    goToPage: function(page) {
        this.currentPage = page;
        this.fetchAlerts();
    },

    // 모달 제어
    openModal: function(item) {
        const modalBody = document.getElementById('modalBody');
        
        modalBody.innerHTML = `
            <div class="kv">
                <div class="k">Alert Type</div><div class="v">${item.alertType}</div>
                <div class="k">Title</div><div class="v">${item.title}</div>
                <div class="k">Value</div><div class="v" style="color:#b91c1c; font-weight:bold;">${item.value}</div>
                <div class="k">Created At</div><div class="v">${item.createdAt}</div>
                <div class="k">Message</div><div class="v">${item.message}</div>
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