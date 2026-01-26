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
            <a href="${pageContext.request.contextPath}/alert.do"
               class="menu-item"
               id="menu-alert">알림</a>
        </li>
    </ul>
</div>

<script>
(function () {
    const path = window.location.pathname;

    // 모든 메뉴에서 active 클래스 제거
    document.querySelectorAll('.menu-item').forEach(function(a) {
        a.classList.remove('active');
    });

    // 현재 URL(path)에 따라 active 클래스 추가
    var menuId = "";
    if (path.indexOf('/dashboard.do') !== -1 || path.indexOf('/index.jsp') !== -1 || path === '/') {
        menuId = 'menu-dashboard';
    } else if (path.indexOf('/data.do') !== -1) {
        menuId = 'menu-sensor-data';
    } else if (path.indexOf('/threshold.do') !== -1) {
        menuId = 'menu-threshold';
    } else if (path.indexOf('/alert.do') !== -1) {
        menuId = 'menu-alert';
    }

    // 해당 엘리먼트가 존재할 때만 클래스 추가 (에러 방지)
    if (menuId) {
        var targetMenu = document.getElementById(menuId);
        if (targetMenu) {
            targetMenu.classList.add('active');
        }
    }
})();
</script>