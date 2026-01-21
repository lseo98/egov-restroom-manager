<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .menu-item {
        text-decoration: none;
        color: #57606f;
        font-weight: 500;
        font-size: 15px;
        display: block;
        padding: 8px 0px 8px 20px;
        margin-bottom: 4px;
        border-radius: 6px;
        position: relative;
        transition: background-color 0.2s;
        cursor: pointer;
    }

    .menu-item:hover { background-color: #e2e4e8; }

    .menu-item.active {
        background-color: #d1d8e0;
        color: #1a237e;
    }

    .menu-item.active::before {
        content: "";
        position: absolute;
        left: 0;
        top: 8px;
        bottom: 8px;
        width: 4px;
        background-color: #0969da;
        border-radius: 2px;
    }
</style>

<div style="width: 170px; background-color: #f1f2f6; border-right: 1px solid #d1d8e0; height: 100%; padding: 15px; float: left; box-sizing: border-box;">
    <h3 style="color: #2f3542; font-size: 1rem; border-bottom: 2px solid #1a237e; padding: 0px 0px 6px 0px; margin-top: 5px; margin-bottom: 15px;">관리 메뉴</h3>

    <ul style="list-style: none; padding: 0; margin: 0;">
        <li>
            <a href="${pageContext.request.contextPath}/dashboard.do"
               class="menu-item"
               id="menu-dashboard">대시보드</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/data.do"
               class="menu-item"
               id="menu-sensor-data">센서 데이터</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/threshold.do"
               class="menu-item"
               id="menu-threshold">임계치 설정</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/alarm.do"
               class="menu-item"
               id="menu-alarm">알림</a>
        </li>
    </ul>
</div>

<script>
(function () {
    const path = window.location.pathname;

    // 모든 메뉴에서 active 클래스 제거
    document.querySelectorAll('.menu-item').forEach(a => a.classList.remove('active'));

    // 현재 URL(path)이 어떤 .do 주소를 포함하는지에 따라 active 클래스 추가
    // index.jsp로 접속하거나 root(/)로 접속한 경우에도 대시보드가 활성화되도록 설정
    if (path.endsWith('/dashboard.do') || path.endsWith('/index.jsp') || path.endsWith('/')) {
        document.getElementById('menu-dashboard')?.classList.add('active');
    } else if (path.includes('/data.do')) {
        document.getElementById('menu-sensor-data')?.classList.add('active');
    } else if (path.includes('/threshold.do')) {
        document.getElementById('menu-threshold')?.classList.add('active');
    } else if (path.includes('/alarm.do')) {
        document.getElementById('menu-alarm')?.classList.add('active');
    }
})();
</script>