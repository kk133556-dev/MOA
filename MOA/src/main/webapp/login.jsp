<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.AdDAO, com.moa.model.Ad"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MOA 로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .login-page-wrap { min-height:100vh; display:flex; align-items:center; }
        .login-box { max-width: 360px; margin: 0 auto; background: #fff; padding: 32px; border-radius: 14px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border:1px solid var(--border); }
        .role-tab { flex: 1; text-align: center; padding: 8px 0; cursor: pointer; border-radius: 8px; font-size: 14px; transition: all .2s ease; }
        .role-tab.active { background: var(--navy); color: #fff; }
        .login-ad-panel { max-width:380px; margin:0 auto; }
        .login-ad-item { background:#fff; border:1px solid var(--border); border-radius:12px; padding:16px 18px; margin-bottom:10px; display:flex; align-items:center; gap:12px; }
    </style>
</head>
<body>
<%
    String error = request.getParameter("error");
    String role = request.getParameter("role");
    if (role == null) role = "BUSINESS";
%>
<div class="login-page-wrap">
<div class="container">
    <div class="text-center mb-3">
        <a href="index.jsp" style="font-size:13px; color:var(--text-muted); text-decoration:none;"><i class="bi bi-arrow-left"></i> 홈으로</a>
    </div>
    <div class="row justify-content-center">
        <div class="col-lg-5">
            <div class="login-box">
                <div class="text-center mb-4"><a href="index.jsp" class="navbar-brand" style="font-size:22px;">MOA</a></div>
                <h5 class="text-center mb-4">로그인</h5>

                <div class="d-flex mb-3" style="background:#f0f0f0; border-radius:8px; padding:4px;">
                    <div class="role-tab" id="tabBusiness" onclick="selectRole('BUSINESS')">소상공인</div>
                    <div class="role-tab" id="tabAdmin" onclick="selectRole('ADMIN')">관리자</div>
                </div>

                <% if ("pending".equals(request.getParameter("signup"))) { %>
                    <div class="alert alert-info py-2" style="font-size:12.5px;"><i class="bi bi-hourglass-split"></i> 가입 신청 완료! 관리자 승인 후 로그인할 수 있어요.</div>
                <% } %>
                <% if ("1".equals(error)) { %>
                    <div class="alert alert-danger py-2" style="font-size:13px;"><i class="bi bi-exclamation-circle"></i> 아이디 또는 비밀번호가 올바르지 않아요.</div>
                <% } %>

                <form action="LoginServlet" method="post">
                    <input type="hidden" name="loginType" id="loginType" value="<%= role %>">
                    <div class="mb-3">
                        <label class="form-label" style="font-size:13px;">아이디</label>
                        <input type="text" name="userId" class="form-control" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label" style="font-size:13px;">비밀번호</label>
                        <input type="password" name="userPw" class="form-control" required>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-3" style="font-size:12.5px;">
                        <label class="d-flex align-items-center gap-1" style="cursor:pointer;">
                            <input type="checkbox" name="saveId" style="width:14px; height:14px;"> 아이디 저장
                        </label>
                        <a href="support.jsp" class="text-muted text-decoration-none">아이디·비밀번호 찾기</a>
                    </div>
                    <button type="submit" class="btn-moa w-100 justify-content-center">로그인</button>
                </form>

                <div class="text-center mt-3" style="font-size:13px;">
                    계정이 없으신가요? <a href="signup.jsp">회원가입</a>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<script>
    function selectRole(r) {
        document.getElementById('loginType').value = r;
        document.getElementById('tabBusiness').classList.toggle('active', r === 'BUSINESS');
        document.getElementById('tabAdmin').classList.toggle('active', r === 'ADMIN');
    }
    selectRole('<%= role %>');
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
