<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결제하기</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("phoneVerified") == null) { response.sendRedirect("pricing.jsp"); return; }
    String plan = request.getParameter("plan");
    String planName = "STANDARD".equals(plan) ? "스탠다드" : "프로";
    int price = "STANDARD".equals(plan) ? 29000 : 59000;
%>
<div class="container py-5" style="max-width:420px;">
    <h4 class="text-center mb-1">결제하기</h4>
    <p class="text-center text-muted mb-4" style="font-size:13px;">본인 확인 완료 ✅</p>

    <div class="moa-card mb-3">
        <div class="d-flex justify-content-between"><span>MOA <%= planName %> 요금제</span><b>₩ <%= String.format("%,d", price) %></b></div>
    </div>

    <div class="moa-card">
        <form action="PricingServlet" method="post" id="payForm">
            <input type="hidden" name="plan" value="<%= plan %>">
            <div class="mb-2"><label class="form-label">카드번호</label><input type="text" class="form-control" placeholder="0000 0000 0000 0000" required></div>
            <div class="row g-2 mb-2">
                <div class="col-6"><label class="form-label">유효기간</label><input type="text" class="form-control" placeholder="MM/YY" required></div>
                <div class="col-6"><label class="form-label">CVC</label><input type="text" class="form-control" placeholder="000" required></div>
            </div>
            <button type="submit" class="btn-moa w-100">₩ <%= String.format("%,d", price) %> 결제하기</button>
            <p style="font-size:11px; color:#9ca3af; text-align:center; margin-top:10px;">실제 결제 연동 전 데모예요. 카드 정보는 저장되지 않아요.</p>
        </form>
    </div>
</div>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
