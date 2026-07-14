<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.SalesDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>매출 순위</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    List<Object[]> ranking = new SalesDAO().rankStores();
    String currentMenu = "ranking";
    String myStoreName = (String) session.getAttribute("storeName");
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-trophy-fill" style="color:#F59E0B;"></i> 매출 순위</h4>

        <% if (ranking.isEmpty()) { %>
            <div class="moa-card text-center py-5">
                <i class="bi bi-trophy" style="font-size:36px; opacity:0.3;"></i>
                <p class="text-muted mt-2 mb-0">아직 매출 데이터가 있는 매장이 없어요.</p>
            </div>
        <% } else { %>
            <div class="row g-3 mb-4 align-items-end">
                <% for (int p = 0; p < Math.min(3, ranking.size()); p++) {
                    Object[] row = ranking.get(p);
                    boolean isMe = row[0].equals(myStoreName);
                    String[] medal = {"🥇", "🥈", "🥉"};
                    int[] podiumHeight = {150, 120, 95};
                %>
                <div class="col-4">
                    <div class="moa-card text-center" style="padding-top:20px; height:<%= podiumHeight[p] %>px; display:flex; flex-direction:column; justify-content:center; <%= isMe ? "border-color:var(--primary); box-shadow:0 0 0 2px rgba(79,70,229,0.25);" : "" %>">
                        <div style="font-size:26px;"><%= medal[p] %></div>
                        <div style="font-weight:700; font-size:13px; margin-top:4px;"><%= row[0] %><% if (isMe) { %> <span class="badge" style="background:var(--primary); font-size:9px;">MY</span><% } %></div>
                        <div class="kpi-value" style="font-size:15px; margin-top:2px;">₩ <%= String.format("%,d", (Integer) row[1]) %></div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>

        <div class="row g-3">
            <div class="col-lg-8">
                <div class="moa-card">
                    <h6 class="mb-3">전체 순위</h6>
                    <% if (ranking.isEmpty()) { %>
                        <p class="text-muted mb-0">순위 데이터가 없어요.</p>
                    <% } else {
                        int rank = 1;
                        for (Object[] row : ranking) {
                            boolean isMe = row[0].equals(myStoreName);
                    %>
                        <div class="d-flex justify-content-between align-items-center" style="padding:11px 6px; border-bottom:1px solid var(--border); <%= isMe ? "background:rgba(79,70,229,0.05); border-radius:8px;" : "" %>">
                            <div><b style="color:var(--primary); width:28px; display:inline-block;">#<%= rank %></b> &nbsp; <%= row[0] %><% if (isMe) { %> <span class="badge" style="background:var(--primary); font-size:9px;">내 매장</span><% } %></div>
                            <div class="kpi-value" style="font-size:14.5px;">₩ <%= String.format("%,d", (Integer) row[1]) %></div>
                        </div>
                    <% rank++; } } %>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="moa-card">
                    <h6 class="mb-2"><i class="bi bi-info-circle"></i> 순위는 어떻게 계산돼요?</h6>
                    <p style="font-size:12.5px; color:var(--text-muted); line-height:1.7; margin-bottom:0;">
                        매출을 한 번이라도 등록한 매장들의 누적 총매출 기준으로 상위 20개 매장을 보여드려요.
                        더 자세한 매출 흐름은 <a href="stats.jsp">매출 통계</a>에서 확인할 수 있어요.
                    </p>
                </div>
            </div>
        </div>
    </main>
</div>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
