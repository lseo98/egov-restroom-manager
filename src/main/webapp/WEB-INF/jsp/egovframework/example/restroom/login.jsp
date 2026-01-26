<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Admin Login - Smart Restroom</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <style>
        html, body {
            margin: 0; padding: 0;
            height: 100%; width: 100%;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f4f7f9; 
            overflow: hidden;
        }

        .login-container {
            display: flex; flex-direction: column; 
            justify-content: center; align-items: center;
            height: 100vh; width: 100vw;
        }

        .login-header {
            display: flex; align-items: center;
            gap: 12px; margin-bottom: 30px;
            color: #17215E; 
        }

        .login-header .material-icons { font-size: 40px; }

        .login-header h1 {
            margin: 0; font-size: 28px; 
            font-weight: 900; letter-spacing: -0.5px;
        }

        .login-card {
            width: 400px; 
            padding: 50px 40px; 
            background: #ffffff; 
            border-radius: 20px; 
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .login-card h2 {
            margin-bottom: 30px; font-weight: 900;
            color: #17215E; font-size: 20px; 
            letter-spacing: 0.5px; opacity: 0.9;
        }

        .input-group { margin-bottom: 20px; text-align: left;  }
        .input-group label { 
            display: block; margin-bottom: 8px; 
            font-size: 14px; 
            font-weight: 700; color: #64748B; 
        }

        .input-group input {
            width: 100%; padding: 14px 16px; 
            border: 2px solid #E2E8F0; 
            border-radius: 10px;
            box-sizing: border-box; font-size: 16px; 
            transition: border-color 0.2s;
            background-color: #fdfdfd;
        }
        .input-group input:focus { 
            outline: none; 
            border-color: #4D96FF; 
            background-color: #fff;
        }

        .btn-login {
            width: 100%; padding: 16px; 
            margin-top: 20px; 
            background: #17215E; color: #fff;
            border: none; border-radius: 10px;
            font-size: 18px; 
            font-weight: 900;
            cursor: pointer; transition: background 0.2s;
            box-shadow: 0 4px 12px rgba(23, 33, 94, 0.2);
        }
        .btn-login:hover { background: #25338d; }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-header">
        <span class="material-icons">wc</span>
        <h1>Restroom Management System</h1>
    </div>

    <div class="login-card">
        <h2>ADMIN LOGIN</h2>
        
        <div class="input-group">
            <label>ID</label>
            <input type="text" id="userId" name="id" placeholder="아이디를 입력하세요">
        </div>
        
        <div class="input-group">
            <label>PASSWORD</label>
            <input type="password" id="userPw" name="pw" placeholder="비밀번호를 입력하세요" 
                   onkeyup="if(window.event.keyCode==13){fnLogin()}">
        </div>
        
        <button class="btn-login" onclick="fnLogin()">LOGIN</button>
    </div>
</div>

<script>
    var contextPath = "${pageContext.request.contextPath}";

    function fnLogin() {
        const idValue = document.getElementById('userId').value;
        const pwValue = document.getElementById('userPw').value;

        if(!idValue || !pwValue) {
            alert('아이디와 비밀번호를 모두 입력해주세요.');
            return;
        }

        const url = contextPath + '/loginAction.do?id=' + encodeURIComponent(idValue) + '&pw=' + encodeURIComponent(pwValue);

        fetch(url)
            .then(res => res.text())
            .then(data => {
                if(data.includes('success')) {
                    location.href = contextPath + '/dashboard.do';
                } else {
                    alert('로그인 정보가 올바르지 않습니다.');
                }
            })
            .catch(err => {
                console.error('로그인 에러:', err);
                alert('서버 통신 중 오류가 발생했습니다.');
            });
    }
</script>

</body>
</html>