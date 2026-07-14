<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.MemberDAO, com.moa.model.Member"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null || !"ADMIN".equals(session.getAttribute("memberType"))) { response.sendRedirect("login.jsp?role=ADMIN"); return; }
    List<Member> members = new MemberDAO().listAll();
    int pendingCount = 0, activeCount = 0, suspendedCount = 0;
    for (Member m : members) {
        String st = m.getStatus() != null ? m.getStatus() : "ACTIVE";
        if ("PENDING".equals(st)) pendingCount++;
        else if ("SUSPENDED".equals(st)) suspendedCount++;
        else activeCount++;
    }
    String currentMenu = "members";
%>
<div class="d-flex">
    <%@ include file="admin_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-1"><i class="bi bi-people"></i> 회원 관리</h4>
        <p class="text-muted mb-4" style="font-size:13px;">신규 가입한 소상공인은 승인해야 로그인할 수 있어요.</p>

        <% if ("1".equals(request.getParameter("deleted"))) { %>
            <div class="alert alert-success py-2"><i class="bi bi-check-circle"></i> 회원과 연관 데이터가 삭제됐어요.</div>
        <% } %>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value"><%= members.size() %></div><div class="kpi-label">전체 회원</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#F59E0B;"><%= pendingCount %></div><div class="kpi-label">승인 대기</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#16A34A;"><%= activeCount %></div><div class="kpi-label">정상 활동</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#DC2626;"><%= suspendedCount %></div><div class="kpi-label">정지됨</div></div></div>
        </div>

        <table class="table moa-table">
            <thead><tr><th>ID</th><th>이름</th><th>구분</th><th>상태</th><th>요금제</th><th>관리</th></tr></thead>
            <tbody>
            <% for (Member m : members) {
                String st = m.getStatus() != null ? m.getStatus() : "ACTIVE";
                String badgeClass = "PENDING".equals(st) ? "bg-warning" : "SUSPENDED".equals(st) ? "bg-danger" : "bg-success";
                String badgeText = "PENDING".equals(st) ? "승인대기" : "SUSPENDED".equals(st) ? "정지됨" : "정상";
            %>
                <tr>
                    <td><%= m.getLoginId() %></td>
                    <td><%= m.getName() %></td>
                    <td><%= "BUSINESS".equals(m.getMemberType()) ? "소상공인" : "관리자" %></td>
                    <td><span class="badge <%= badgeClass %>"><%= badgeText %></span></td>
                    <td><%= m.getPlan() != null ? m.getPlan() : "-" %></td>
                    <td class="d-flex gap-1">
                        <% if (!"ADMIN".equals(m.getMemberType())) { %>
                            <% if ("PENDING".equals(st)) { %>
                                <form action="AdminMemberServlet" method="post" style="display:inline;"><input type="hidden" name="memberId" value="<%= m.getMemberId() %>"><input type="hidden" name="action" value="approve"><button class="btn-moa btn-moa-sm">승인</button></form>
                            <% } else if ("SUSPENDED".equals(st)) { %>
                                <form action="AdminMemberServlet" method="post" style="display:inline;"><input type="hidden" name="memberId" value="<%= m.getMemberId() %>"><input type="hidden" name="action" value="reactivate"><button class="btn-moa-outline btn-moa-sm">재활성화</button></form>
                            <% } else { %>
                                <form action="AdminMemberServlet" method="post" style="display:inline;"><input type="hidden" name="memberId" value="<%= m.getMemberId() %>"><input type="hidden" name="action" value="suspend"><button class="btn-moa-outline btn-moa-sm" style="color:#DC2626;">정지</button></form>
                            <% } %>
                            <form action="AdminMemberServlet" method="post" style="display:inline;" onsubmit="return confirm('<%= m.getName() %> 회원을 삭제하면 매출/재고/광고 등 모든 데이터가 함께 삭제돼요. 계속할까요?');">
                                <input type="hidden" name="memberId" value="<%= m.getMemberId() %>"><input type="hidden" name="action" value="delete">
                                <button class="btn-moa-outline btn-moa-sm" style="color:#991B1B; border-color:#991B1B;">삭제</button>
                            </form>
                        <% } %>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </main>
</div>
</body>
</html>
