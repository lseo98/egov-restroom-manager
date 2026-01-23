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
      <a href="${pageContext.request.contextPath}/index.jsp" style="color:#fff; text-decoration:none; display:flex; align-items:center; gap:8px;">
        <span class="material-icons" style="font-size:24px;">home</span>
        <span style="font-size:14px; font-weight:700;">홈</span>
      </a>
      <a href="#" style="color:#fff; text-decoration:none; display:flex; align-items:center; gap:8px; opacity:.90;">
        <span class="material-icons" style="font-size:22px;">logout</span>
        <span style="font-size:14px; font-weight:700;">로그아웃</span>
      </a>
    </div>
  </div>
</header>