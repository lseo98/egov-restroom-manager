<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<header style="background: #17215E; color:#fff; height:64px; display:flex; align-items:center; box-shadow: 0 6px 18px rgba(15,23,42,.10); position: relative; z-index: 1000;">
  <div style="width: 96%; margin:0 auto; display:flex; justify-content:space-between; align-items:center;">
    <div style="display:flex; align-items:center; gap:15px;">
      <span class="material-icons" style="font-size:30px; vertical-align: middle;">wc</span>
      <div style="font-weight:900; font-size:1.4rem; letter-spacing:-0.5px;">Restroom Management System</div>
      <div id="real-time-clock" style="margin-left:15px; font-size:16px; font-weight:400; color:rgba(255,255,255,0.9); background: rgba(255,255,255,0.15); padding: 4px 15px; border-radius: 20px; min-width: 180px; text-align: center;">
        연결 중...
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:25px;">
      <a href="${pageContext.request.contextPath}/dashboard.do" style="color:#fff; text-decoration:none; display:flex; align-items:center; gap:8px;">
        <span class="material-icons" style="font-size:24px;">home</span>
        <span style="font-size:14px; font-weight:700;">홈</span>
      </a>
      <a href="javascript:void(0);" onclick="openLogoutModal()" style="color:#fff; text-decoration:none; display:flex; align-items:center; gap:8px; opacity:.90;">
        <span class="material-icons" style="font-size:22px;">logout</span>
        <span style="font-size:14px; font-weight:700;">로그아웃</span>
      </a>
    </div>
  </div>
</header>

<div id="logoutModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:2000; justify-content:center; align-items:center;">
  <div style="background:#fff; width:320px; padding:30px; border-radius:15px; text-align:center; box-shadow:0 10px 25px rgba(0,0,0,0.2);">
    <span class="material-icons" style="font-size:48px; color:#17215E; margin-bottom:15px;">help_outline</span>
    <h3 style="margin:0 0 10px; color:#333; font-size:18px;">로그아웃 하시겠습니까?</h3>
    <p style="margin:0 0 25px; color:#666; font-size:14px;">관리자 세션이 종료됩니다.</p>
    <div style="display:flex; gap:10px; justify-content:center;">
      <button onclick="confirmLogout()" style="background:#17215E; color:#fff; border:none; padding:10px 20px; border-radius:8px; font-weight:700; cursor:pointer; flex:1;">로그아웃</button>
      <button onclick="closeLogoutModal()" style="background:#f1f5f9; color:#475569; border:none; padding:10px 20px; border-radius:8px; font-weight:700; cursor:pointer; flex:1;">취소</button>
    </div>
  </div>
</div>

<script>
(function() {
    // 3. 시계 기능
    function updateHeaderClock() {
        const el = document.getElementById('real-time-clock');
        if (!el) return;
        const now = new Date();
        const fmt = now.getFullYear() + '-' + 
                    String(now.getMonth() + 1).padStart(2, '0') + '-' + 
                    String(now.getDate()).padStart(2, '0') + ' ' + 
                    String(now.getHours()).padStart(2, '0') + ':' + 
                    String(now.getMinutes()).padStart(2, '0');
        if (el.textContent !== fmt) { el.textContent = fmt; }
    }
    updateHeaderClock(); 
    setInterval(updateHeaderClock, 1000);
})();

// 4. 로그아웃 모달 제어 로직
const modal = document.getElementById('logoutModal');

function openLogoutModal() {
    modal.style.display = 'flex';
}

function closeLogoutModal() {
    modal.style.display = 'none';
}

function confirmLogout() {
    location.href = "${pageContext.request.contextPath}/logout.do";
}

// 모달 바깥 영역 클릭 시 닫기
window.onclick = function(event) {
    if (event.target == modal) {
        closeLogoutModal();
    }
}
</script>