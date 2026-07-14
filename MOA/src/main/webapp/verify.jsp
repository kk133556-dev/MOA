<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>본인 확인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("memberId") == null) { response.sendRedirect("login.jsp"); return; }
    String plan = request.getParameter("plan");
%>
<div class="container py-5" style="max-width:420px;">
    <h4 class="text-center mb-1">본인 확인</h4>
    <p class="text-center text-muted mb-4" style="font-size:13px;">결제 전, 휴대폰 인증번호로 본인 확인을 해주세요</p>

    <div class="moa-card">
        <div class="mb-2">
            <label class="form-label">휴대폰 번호</label>
            <div class="d-flex gap-2">
                <input type="tel" id="phone" class="form-control" placeholder="010-0000-0000">
                <button type="button" id="sendBtn" class="btn-moa-outline">인증번호 받기</button>
            </div>
        </div>
        <div id="codeBox" style="display:none;">
            <div class="d-flex gap-2 mb-2">
                <input type="text" id="code" class="form-control" placeholder="인증번호 6자리" maxlength="6">
                <button type="button" id="confirmBtn" class="btn-moa">확인</button>
            </div>
            <div id="msg" style="font-size:12px; color:#6b7280;"></div>
        </div>

        <form id="verifyForm" action="VerifyServlet" method="post" style="display:none;">
            <input type="hidden" name="plan" value="<%= plan %>">
        </form>
    </div>
</div>

<script>
    var demoCode = null;
    document.getElementById('sendBtn').addEventListener('click', function () {
        var phone = document.getElementById('phone').value.trim();
        if (!phone) { alert('휴대폰 번호를 입력해주세요'); return; }
        demoCode = String(Math.floor(100000 + Math.random() * 900000));
        document.getElementById('codeBox').style.display = 'block';
        document.getElementById('msg').textContent = '인증번호를 보냈어요. (데모: ' + demoCode + ')';
    });
    document.getElementById('confirmBtn').addEventListener('click', function () {
        var input = document.getElementById('code').value.trim();
        if (input === demoCode) {
            document.getElementById('verifyForm').submit();
        } else {
            document.getElementById('msg').innerHTML = '<span style="color:#dc3545;">인증번호가 일치하지 않아요</span>';
        }
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
