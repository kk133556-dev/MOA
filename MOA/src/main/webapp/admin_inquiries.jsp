<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.InquiryDAO, com.moa.model.Inquiry"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null || !"ADMIN".equals(session.getAttribute("memberType"))) { response.sendRedirect("login.jsp?role=ADMIN"); return; }
    List<Inquiry> inquiries = new InquiryDAO().listAll();
    int pendingCount = 0;
    for (Inquiry i : inquiries) if ("PENDING".equals(i.getStatus())) pendingCount++;
    String currentMenu = "inquiries";
%>
<div class="d-flex">
    <%@ include file="admin_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-headset"></i> 문의 관리</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value"><%= inquiries.size() %></div><div class="kpi-label">전체 문의</div></div></div>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#F59E0B;"><%= pendingCount %></div><div class="kpi-label">미답변</div></div></div>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#16A34A;"><%= inquiries.size() - pendingCount %></div><div class="kpi-label">답변완료</div></div></div>
        </div>

        <% if (inquiries.isEmpty()) { %>
            <div class="moa-card text-center py-5"><p class="text-muted mb-0">접수된 문의가 없어요.</p></div>
        <% } else { for (Inquiry i : inquiries) { %>
            <div class="moa-card mb-3">
                <div class="d-flex justify-content-between">
                    <div><b><%= i.getMemberName() %></b> <span class="text-muted" style="font-size:12px;"><%= i.getCreatedAt() %></span></div>
                    <span class="badge <%= "PENDING".equals(i.getStatus()) ? "bg-warning" : "bg-success" %>"><%= "PENDING".equals(i.getStatus()) ? "대기중" : "답변완료" %></span>
                </div>
                <p class="mt-2 mb-2"><%= i.getContent() %></p>
                <% if (i.getAdminReply() != null) { %>
                    <div class="alert alert-light py-2 mb-0" style="font-size:13px;"><b>답변:</b> <%= i.getAdminReply() %></div>
                <% } else { %>
                    <form action="AdminReplyServlet" method="post" class="d-flex gap-2">
                        <input type="hidden" name="inquiryId" value="<%= i.getInquiryId() %>">
                        <input type="text" name="replyText" class="form-control" placeholder="답변을 입력하세요" required>
                        <button type="submit" class="btn-moa btn-moa-sm">답변</button>
                    </form>
                <% } %>
            </div>
        <% } } %>
    </main>
</div>
</body>
</html>
