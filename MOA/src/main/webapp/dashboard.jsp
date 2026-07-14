<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.SalesDAO, com.moa.model.SalesRecord"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>대시보드</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null) { response.sendRedirect("login.jsp"); return; }
    Integer storeId = (Integer) session.getAttribute("storeId");
    List<SalesRecord> salesList = new SalesDAO().listByStore(storeId);
    int total = new SalesDAO().sumByStore(storeId);
%>
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4><%= session.getAttribute("storeName") %> 대시보드</h4>
        <div><%= session.getAttribute("name") %>님 &nbsp; <a href="LogoutServlet" class="btn-moa-outline">로그아웃</a></div>
    </div>

    <div class="moa-nav">
        <a href="index.jsp"><i class="bi bi-house-door"></i> 홈</a>
        <a href="dashboard.jsp" class="active"><i class="bi bi-speedometer2"></i> 대시보드</a>
        <a href="ai_receipt.jsp"><i class="bi bi-camera"></i> 영수증 AI 스캔</a>
        <a href="todo.jsp"><i class="bi bi-journal-check"></i> 다이어리</a>
        <a href="inventory.jsp"><i class="bi bi-box-seam"></i> 재고관리</a>
        <a href="ranking.jsp"><i class="bi bi-trophy"></i> 매출순위</a>
        <a href="store_search.jsp"><i class="bi bi-search"></i> 매장검색</a>
        <a href="ads_apply.jsp"><i class="bi bi-megaphone"></i> 광고신청</a>
        <a href="support.jsp"><i class="bi bi-headset"></i> 고객센터</a>
        <a href="pricing.jsp"><i class="bi bi-credit-card"></i> 요금제</a>
    </div>

    <% if ("1".equals(request.getParameter("planUpdated"))) { %>
        <div class="alert alert-success"><i class="bi bi-check-circle"></i> 요금제가 변경됐어요!</div>
    <% } %>

    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value">₩ <%= String.format("%,d", total) %></div><div class="kpi-label">누적 매출</div></div></div>
        <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value"><%= salesList.size() %>건</div><div class="kpi-label">등록 건수</div></div></div>
        <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value"><%= session.getAttribute("plan") != null ? session.getAttribute("plan") : "BASIC" %></div><div class="kpi-label">현재 요금제</div></div></div>
    </div>

    <div class="row g-3">
        <div class="col-lg-5">
            <div class="moa-card mb-3">
                <h6><i class="bi bi-plus-circle"></i> 오늘 매출 등록</h6>
                <p style="font-size:12px; color:var(--text-muted);">직접 입력하거나, <a href="ai_receipt.jsp">영수증 AI 스캔</a>을 이용해보세요.</p>
                <form action="SalesServlet" method="post">
                    <div class="mb-2"><label class="form-label">총 매출</label><input type="number" name="total" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">카드 매출</label><input type="number" name="card" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">현금 매출</label><input type="number" name="cash" class="form-control" required></div>
                    <button type="submit" class="btn-moa w-100 justify-content-center">저장</button>
                </form>
            </div>
        </div>
        <div class="col-lg-7">
            <div class="moa-card" style="height:100%;">
                <h6><i class="bi bi-graph-up"></i> 매출 추이</h6>
                <% if (salesList.isEmpty()) { %>
                    <p class="text-muted text-center py-5">아직 등록된 매출이 없어요</p>
                <% } else { %>
                    <canvas id="salesChart" height="120"></canvas>
                <% } %>
            </div>
        </div>
    </div>

    <div class="moa-card mt-3">
        <div class="d-flex justify-content-between align-items-center">
            <h6 class="mb-0"><i class="bi bi-table"></i> 매출 기록</h6>
            <div class="d-flex gap-2">
                <a href="ExportCsvServlet" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-spreadsheet"></i> 엑셀(CSV)</a>
                <a href="report_print.jsp" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
            </div>
        </div>
        <table class="table moa-table mt-2">
            <thead><tr><th>날짜</th><th>총 매출</th><th>카드</th><th>현금</th></tr></thead>
            <tbody>
            <% if (salesList.isEmpty()) { %>
                <tr><td colspan="4" class="text-center text-muted">아직 등록된 매출이 없어요</td></tr>
            <% } else { for (SalesRecord r : salesList) { %>
                <tr><td><%= r.getSalesDate() %></td><td><%= r.getTotalAmount() %>원</td><td><%= r.getCardAmount() %>원</td><td><%= r.getCashAmount() %>원</td></tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

<% if (!salesList.isEmpty()) { %>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
    var labels = [<% for (int i = salesList.size()-1; i>=0; i--) { %>'<%= salesList.get(i).getSalesDate() %>'<%= i>0?",":"" %><% } %>];
    var values = [<% for (int i = salesList.size()-1; i>=0; i--) { %><%= salesList.get(i).getTotalAmount() %><%= i>0?",":"" %><% } %>];
    new Chart(document.getElementById('salesChart'), {
        type: 'line',
        data: { labels: labels, datasets: [{ label: '매출', data: values, borderColor: '#4F46E5', backgroundColor: 'rgba(79,70,229,0.08)', fill: true, tension: 0.3 }] },
        options: { plugins: { legend: { display: false } } }
    });
</script>
<% } %>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
