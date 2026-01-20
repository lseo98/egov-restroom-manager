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

    .menu-item:hover {
        background-color: #e2e4e8;
    }

    /* 활성화 스타일 */
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
            <a href="${pageContext.request.contextPath}/index.jsp" 
               class="menu-item active" 
               id="menu-dashboard" 
               onclick="activateMenu(this)">대시보드</a>
        </li>
        <li><a href="#" class="menu-item" onclick="activateMenu(this)">센서 데이터</a></li>
        <li><a href="#" class="menu-item" onclick="activateMenu(this)">임계치 설정</a></li>
        <li><a href="#" class="menu-item" onclick="activateMenu(this)">알림</a></li>
    </ul>
</div>

<script>
    function activateMenu(element) {
        // 클릭 즉시 시각적인 효과를 주기 위한 코드
        const items = document.querySelectorAll('.menu-item');
        items.forEach(item => item.classList.remove('active'));
        element.classList.add('active');
        
        // href가 '#'이 아니면 페이지가 이동(새로고침)되면서 
        // 다시 위 HTML의 'active' 설정값을 읽어오게 됩니다.
    }
</script>