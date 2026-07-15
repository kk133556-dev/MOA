<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate, java.time.format.DateTimeFormatter, com.moa.dao.SalesDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>매출 통계</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    String currentMenu = "stats";

    SalesDAO dao = new SalesDAO();
    List<Object[]> monthly = dao.monthlyByStore(storeId, 12);
    List<Object[]> yearly = dao.yearlyByStore(storeId);

    String thisMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
    String lastMonth = LocalDate.now().minusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
    int thisMonthTotal = dao.sumByMonth(storeId, thisMonth);
    int lastMonthTotal = dao.sumByMonth(storeId, lastMonth);
    double changeRate = lastMonthTotal == 0 ? 0 : ((double)(thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    int grandTotal = dao.sumByStore(storeId);
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="mb-0"><i class="bi bi-bar-chart"></i> 매출 통계</h4>
            <div class="d-flex gap-2">
                <a href="ExportCsvServlet" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-spreadsheet"></i> 엑셀(XLSX)</a>
                <a href="report_print.jsp" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value">₩ <%= String.format("%,d", grandTotal) %></div><div class="kpi-label">누적 매출</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value">₩ <%= String.format("%,d", thisMonthTotal) %></div><div class="kpi-label">이번 달 매출 (<%= thisMonth %>)</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value">₩ <%= String.format("%,d", lastMonthTotal) %></div><div class="kpi-label">지난 달 매출 (<%= lastMonth %>)</div></div></div>
            <div class="col-md-3 col-6">
                <div class="kpi-card">
                    <div class="kpi-value" style="color:<%= changeRate >= 0 ? "#16A34A" : "#DC2626" %>;">
                        <i class="bi bi-<%= changeRate >= 0 ? "arrow-up-right" : "arrow-down-right" %>"></i>
                        <%= String.format("%.1f", Math.abs(changeRate)) %>%
                    </div>
                    <div class="kpi-label">전월 대비 증감</div>
                </div>
            </div>
        </div>

        <div class="moa-card mb-4" style="min-height:460px;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="mb-0">매출 추이</h6>
                <div class="d-flex" style="background:#f0f0f0; border-radius:8px; padding:4px;">
                    <div class="role-tab-stats active" id="tabMonthly" style="padding:6px 16px; border-radius:6px; cursor:pointer; font-size:13px; background:var(--navy); color:#fff;">월별</div>
                    <div class="role-tab-stats" id="tabYearly" style="padding:6px 16px; border-radius:6px; cursor:pointer; font-size:13px; color:#374151;">연도별</div>
                </div>
            </div>
            <% if (monthly.isEmpty() && yearly.isEmpty()) { %>
                <div class="text-center text-muted py-5" style="padding-top:120px;">
                    <i class="bi bi-bar-chart" style="font-size:40px; opacity:0.3;"></i>
                    <p class="mt-2">아직 매출 데이터가 없어요. 매출을 등록하면 여기에 그래프가 나와요.</p>
                </div>
            <% } else { %>
                <div style="position:relative; height:340px;">
                    <canvas id="statsChart"></canvas>
                </div>
            <% } %>
        </div>

        <div class="moa-card">
            <h6 class="mb-3">월별 상세 내역</h6>
            <table class="table moa-table">
                <thead><tr><th>월</th><th>총 매출</th><th>카드</th><th>현금</th></tr></thead>
                <tbody>
                <% if (monthly.isEmpty()) { %>
                    <tr><td colspan="4" class="text-center text-muted">데이터가 없어요</td></tr>
                <% } else { for (int i = monthly.size()-1; i >= 0; i--) { Object[] row = monthly.get(i); %>
                    <tr>
                        <td><%= row[0] %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[1]) %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[2]) %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[3]) %></td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
    var monthlyLabels = [<% for (int i=0;i<monthly.size();i++){ %>'<%= monthly.get(i)[0] %>'<%= i<monthly.size()-1?",":"" %><% } %>];
    var monthlyValues = [<% for (int i=0;i<monthly.size();i++){ %><%= monthly.get(i)[1] %><%= i<monthly.size()-1?",":"" %><% } %>];
    var yearlyLabels = [<% for (int i=0;i<yearly.size();i++){ %>'<%= yearly.get(i)[0] %>'<%= i<yearly.size()-1?",":"" %><% } %>];
    var yearlyValues = [<% for (int i=0;i<yearly.size();i++){ %><%= yearly.get(i)[1] %><%= i<yearly.size()-1?",":"" %><% } %>];

    var tabMonthly = document.getElementById('tabMonthly');
    var tabYearly = document.getElementById('tabYearly');
    function activate(tab) {
        [tabMonthly, tabYearly].forEach(function (t) {
            t.classList.remove('active');
            t.style.background = 'transparent'; t.style.color = '#374151';
        });
        tab.classList.add('active');
        tab.style.background = 'var(--navy)'; tab.style.color = '#fff';
    }

    var ctx = document.getElementById('statsChart');
    var chart = null;
    if (ctx) {
        // 월별 데이터가 비어있으면 연도별을 기본으로 보여줘요. (둘 다 있으면 월별이 기본)
        var startWithYearly = (monthlyValues.length === 0 && yearlyValues.length > 0);
        chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: startWithYearly ? yearlyLabels : monthlyLabels,
                datasets: [{ label: '매출', data: startWithYearly ? yearlyValues : monthlyValues, backgroundColor: 'rgba(79,70,229,0.75)', borderRadius: 6, maxBarThickness: 46 }]
            },
            options: {
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { callback: function(v){ return '₩' + v.toLocaleString(); } } } }
            }
        });
        if (startWithYearly) activate(tabYearly); else activate(tabMonthly);
    }

    if (tabMonthly) tabMonthly.addEventListener('click', function () {
        activate(tabMonthly);
        chart.data.labels = monthlyLabels; chart.data.datasets[0].data = monthlyValues; chart.update();
    });
    if (tabYearly) tabYearly.addEventListener('click', function () {
        activate(tabYearly);
        chart.data.labels = yearlyLabels; chart.data.datasets[0].data = yearlyValues; chart.update();
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
