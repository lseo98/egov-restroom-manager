/**
 * alert.js - 더미 데이터 20개 및 큰 화살표 페이지네이션 + CSV 다운로드용 전체 리스트 제공
 */

const Alerts = {
    currentPage: 1,
    rowsPerPage: 10,

    // ✅ CSV 다운로드/필터 결과 전체 저장용
    allAlerts: [],
    filteredAlerts: [],

    init: function() {
        // 1. 날짜 초기화 (오늘 날짜 세팅 및 미래 선택 방지)
        const today = new Date().toISOString().split('T')[0];
        const startDateInput = document.getElementById("startDate");
        const endDateInput = document.getElementById("endDate");

        if (startDateInput && endDateInput) {
            startDateInput.value = today;
            endDateInput.value = today;
            startDateInput.max = today;
            endDateInput.max = today;

            startDateInput.addEventListener("change", function() {
                if (startDateInput.value) endDateInput.min = startDateInput.value;
            });
            endDateInput.addEventListener("change", function() {
                if (endDateInput.value) startDateInput.max = endDateInput.value;
                else startDateInput.max = today;
            });
        }

        // 2. 조회 버튼 클릭 이벤트
        const btn = document.getElementById('btnSearch');
        if (btn) {
            btn.addEventListener('click', () => {
                this.currentPage = 1;
                this.fetchAlerts();
            });
        }

        // 3. 초기 실행
        this.fetchAlerts();
    },

    // ✅ CSV 다운로드에서 사용할 "전체 리스트 반환"
    getFilteredAlerts: function() {
        return this.filteredAlerts || [];
    },

    // 데이터 가져오기 (확인용 더미 데이터 20개)
    fetchAlerts: function() {
        const allDummyData = [
            { alertType: 'TEMP', title: '온도 초과 1', message: '남성 화장실 1구역 온도 임계치 초과', value: '30.5°C', createdAt: '2026-01-26 13:20:45' },
            { alertType: 'HUMIDITY', title: '습도 주의 2', message: '중앙 로비 습도가 너무 높습니다.', value: '82%', createdAt: '2026-01-26 12:45:12' },
            { alertType: 'NH3', title: '악취 감지 3', message: '지하 주차장 암모니아 농도 상승', value: '15ppm', createdAt: '2026-01-26 11:30:00' },
            { alertType: 'PEOPLE_IN', title: '밀집 경보 4', message: '세미나실 입구 인원 과다 진입', value: '45명', createdAt: '2026-01-26 10:15:33' },
            { alertType: 'LIQUID_SOAP', title: '잔량 부족 5', message: '서편 화장실 비누 잔량 부족', value: '8%', createdAt: '2026-01-25 09:05:21' },
            { alertType: 'TEMP', title: '온도 상승 6', message: '기계실 내부 온도 주의 단계', value: '28.2°C', createdAt: '2026-01-25 18:40:10' },
            { alertType: 'HUMIDITY', title: '저습도 경고 7', message: '서고 내부 습도가 너무 낮습니다.', value: '25%', createdAt: '2026-01-25 16:20:00' },
            { alertType: 'NH3', title: '농도 주의 8', message: '화장실 환풍기 가동 필요', value: '10ppm', createdAt: '2026-01-25 14:10:55' },
            { alertType: 'PEOPLE_IN', title: '인원 초과 9', message: '엘리베이터 홀 밀집도 증가', value: '52명', createdAt: '2026-01-25 12:00:30' },
            { alertType: 'PAPER_TOWEL', title: '비품 부족 10', message: '2층 화장실 페이퍼타올 부족', value: '5%', createdAt: '2026-01-25 10:30:15' },
            { alertType: 'TEMP', title: '데이터 확인용 11', message: '페이지네이션 테스트 데이터', value: '22.1°C', createdAt: '2026-01-24 13:20:45' },
            { alertType: 'HUMIDITY', title: '데이터 확인용 12', message: '페이지네이션 테스트 데이터', value: '45%', createdAt: '2026-01-24 12:45:12' },
            { alertType: 'NH3', title: '데이터 확인용 13', message: '페이지네이션 테스트 데이터', value: '2ppm', createdAt: '2026-01-24 11:30:00' },
            { alertType: 'PEOPLE_IN', title: '데이터 확인용 14', message: '페이지네이션 테스트 데이터', value: '10명', createdAt: '2026-01-24 10:15:33' },
            { alertType: 'LIQUID_SOAP', title: '데이터 확인용 15', message: '페이지네이션 테스트 데이터', value: '90%', createdAt: '2026-01-24 09:05:21' },
            { alertType: 'TEMP', title: '데이터 확인용 16', message: '페이지네이션 테스트 데이터', value: '24.5°C', createdAt: '2026-01-23 18:40:10' },
            { alertType: 'HUMIDITY', title: '데이터 확인용 17', message: '페이지네이션 테스트 데이터', value: '50%', createdAt: '2026-01-23 16:20:00' },
            { alertType: 'NH3', title: '데이터 확인용 18', message: '페이지네이션 테스트 데이터', value: '1ppm', createdAt: '2026-01-23 14:10:55' },
            { alertType: 'PEOPLE_IN', title: '데이터 확인용 19', message: '페이지네이션 테스트 데이터', value: '5명', createdAt: '2026-01-23 12:00:30' },
            { alertType: 'PAPER_TOWEL', title: '데이터 확인용 20', message: '페이지네이션 테스트 데이터', value: '80%', createdAt: '2026-01-23 10:30:15' }
        ];

        // ✅ 1) 전체 원본 저장
        this.allAlerts = allDummyData;

        // ✅ 2) (현재는 필터 없음) CSV용 전체 = 전체 원본
        //    나중에 TYPE/STATUS 필터 붙이면 여기서 this.filteredAlerts를 필터링 결과로 바꾸면 됨
        this.filteredAlerts = [...this.allAlerts];

        // ✅ 3) 화면 렌더링은 "현재 페이지 10개"만
        const start = (this.currentPage - 1) * this.rowsPerPage;
        const end = start + this.rowsPerPage;
        const pagedList = this.filteredAlerts.slice(start, end);

        const paging = {
            totalPages: Math.ceil(this.filteredAlerts.length / this.rowsPerPage)
        };

        this.renderTable(pagedList);
        this.renderPagination(paging);
    },

    renderTable: function(list) {
        const tbody = document.getElementById('alertBody');
        if (!tbody) return;

        if (!list || list.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:50px;">데이터가 없습니다.</td></tr>`;
            return;
        }

        let html = '';
        list.forEach(item => {
            const typeClass = `type-${String(item.alertType || '').toLowerCase()}`;
            html += `
                <tr class="alert-row" onclick="Alerts.openModal(${JSON.stringify(item).replace(/"/g, '&quot;')})">
                    <td><span class="type-pill ${typeClass}">${item.alertType || '-'}</span></td>
                    <td><span class="board-title">${item.title || '-'}</span></td>
                    <td><span class="board-msg">${item.message || '-'}</span></td>
                    <td><strong>${item.value || '-'}</strong></td>
                    <td class="col-created-at">${item.createdAt || '-'}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    },

    // 데이터 페이지와 똑같은 화살표 구성
    renderPagination: function(paging) {
        const nav = document.getElementById('pagination');
        if (!paging || !nav) return;

        const currentPage = this.currentPage;
        const totalPages = paging.totalPages;

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

        // [처음으로] 큰 화살표
        if (currentPage > 1) {
            html += `<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.goToPage(1)">
                        <span class="material-icons">first_page</span></a>`;
        }

        // [이전] 화살표
        html += `<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.goToPage(${Math.max(1, currentPage - 1)})">
                    <span class="material-icons">chevron_left</span></a>`;

        // 숫자 버튼
        for (let i = startPage; i <= endPage; i++) {
            html += `<a href="javascript:void(0);" class="page-link ${i === currentPage ? 'active' : ''}"
                        onclick="Alerts.goToPage(${i})">${i}</a>`;
        }

        // [다음] 화살표
        html += `<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.goToPage(${Math.min(totalPages, currentPage + 1)})">
                    <span class="material-icons">chevron_right</span></a>`;

        // [끝으로] 큰 화살표
        if (currentPage < totalPages) {
            html += `<a href="javascript:void(0);" class="page-link nav-arrow" onclick="Alerts.goToPage(${totalPages})">
                        <span class="material-icons">last_page</span></a>`;
        }

        nav.innerHTML = html;
    },

    goToPage: function(page) {
        this.currentPage = page;
        this.fetchAlerts();
    },

    openModal: function(item) {
        const modalBody = document.getElementById('modalBody');
        if (!modalBody) return;

        modalBody.innerHTML = `
            <div class="kv">
                <div class="k">Alert Type</div><div class="v">${item.alertType || '-'}</div>
                <div class="k">Title</div><div class="v">${item.title || '-'}</div>
                <div class="k">Value</div><div class="v" style="color:#b91c1c; font-weight:bold;">${item.value || '-'}</div>
                <div class="k">Created At</div><div class="v">${item.createdAt || '-'}</div>
                <div class="k">Message</div><div class="v">${item.message || '-'}</div>
            </div>
        `;
        const backdrop = document.getElementById('modalBackdrop');
        if (backdrop) backdrop.style.display = 'flex';
    },

    closeModal: function() {
        const backdrop = document.getElementById('modalBackdrop');
        if (backdrop) backdrop.style.display = 'none';
    }
};

document.addEventListener('DOMContentLoaded', () => {
    Alerts.init();
});
