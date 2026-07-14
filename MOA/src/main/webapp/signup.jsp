<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MOA 회원가입</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <style>.signup-box { max-width: 400px; margin: 50px auto; background: #fff; padding: 32px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }</style>
</head>
<body>
<%
    String error = request.getParameter("error");
%>
<div class="signup-box">
    <div class="text-center mb-3"><a href="index.jsp" class="navbar-brand" style="font-size:22px;">MOA</a></div>
    <h5 class="text-center mb-4">소상공인 회원가입</h5>

    <% if ("pwmismatch".equals(error)) { %>
        <div class="alert alert-danger py-2" style="font-size:13px;">비밀번호가 서로 달라요.</div>
    <% } else if ("duplicate".equals(error)) { %>
        <div class="alert alert-danger py-2" style="font-size:13px;">이미 사용중인 아이디예요.</div>
    <% } %>

    <form action="SignupServlet" method="post">
        <div class="mb-2"><label class="form-label">대표자명</label><input type="text" name="ownerName" class="form-control" required></div>
        <div class="mb-2"><label class="form-label">아이디</label><input type="text" name="userId" class="form-control" required></div>
        <div class="mb-2"><label class="form-label">비밀번호</label><input type="password" name="userPw" class="form-control" required></div>
        <div class="mb-2"><label class="form-label">비밀번호 확인</label><input type="password" name="userPwConfirm" class="form-control" required></div>
        <hr>
        <div class="mb-2"><label class="form-label">매장명</label><input type="text" name="storeName" class="form-control" required></div>
        <div class="mb-2"><label class="form-label">매장 주소</label><input type="text" name="address" class="form-control" required></div>
        <div class="mb-3"><label class="form-label">사업자등록번호</label><input type="text" name="businessRegNo" class="form-control" placeholder="000-00-00000" required></div>
        <button type="submit" class="btn-moa w-100">가입하기</button>
    </form>

    <div class="text-center mt-3" style="font-size:13px;">이미 계정이 있으신가요? <a href="login.jsp">로그인</a></div>
</div>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
