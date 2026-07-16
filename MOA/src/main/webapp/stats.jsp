<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate, java.time.format.DateTimeFormatter, com.moa.dao.SalesDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
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
    List<Object[]> daily = dao.dailyByStore(storeId, 30);
    List<Object[]> monthly = dao.monthlyByStore(storeId, 12);
    List<Object[]> yearly = dao.yearlyByStore(storeId);

    String thisMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
    String lastMonth = LocalDate.now().minusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
    int thisMonthTotal = dao.sumByMonth(storeId, thisMonth);
    int lastMonthTotal = dao.sumByMonth(storeId, lastMonth);
    double changeRate = lastMonthTotal == 0 ? 0 : ((double)(thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    int grandTotal = dao.sumByStore(storeId);

    // 일별 탭용: 오늘 vs 어제
    String todayStr = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
    String yesterdayStr = LocalDate.now().minusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE);
    int todayTotal = dao.sumByDate(storeId, todayStr);
    int yesterdayTotal = dao.sumByDate(storeId, yesterdayStr);
    double dailyChangeRate = yesterdayTotal == 0 ? 0 : ((double)(todayTotal - yesterdayTotal) / yesterdayTotal) * 100;

    // 연도별 탭용: 올해 vs 작년
    String thisYear = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy"));
    String lastYear = LocalDate.now().minusYears(1).format(DateTimeFormatter.ofPattern("yyyy"));
    int thisYearTotal = dao.sumByYear(storeId, thisYear);
    int lastYearTotal = dao.sumByYear(storeId, lastYear);
    double yearlyChangeRate = lastYearTotal == 0 ? 0 : ((double)(thisYearTotal - lastYearTotal) / lastYearTotal) * 100;
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 통계 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div style="font-size:19px; font-weight:800; color:#1E1B2E;"><i class="bi bi-bar-chart"></i> 매출 통계</div>
                <div class="d-flex gap-1">
                    <a href="ExportCsvServlet" style="width:34px; height:34px; border-radius:10px; background:#fff; display:flex; align-items:center; justify-content:center; color:#1E1B2E; text-decoration:none;"><i class="bi bi-file-earmark-spreadsheet"></i></a>
                    <a href="report_print.jsp" style="width:34px; height:34px; border-radius:10px; background:#fff; display:flex; align-items:center; justify-content:center; color:#1E1B2E; text-decoration:none;"><i class="bi bi-file-earmark-pdf"></i></a>
                </div>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:16px;">
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">누적 매출</div>
                    <div style="font-size:15px; font-weight:800; color:#1E1B2E;">₩<%= String.format("%,d", grandTotal) %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">이번 달 (<%= thisMonth %>)</div>
                    <div style="font-size:15px; font-weight:800; color:#1E1B2E;">₩<%= String.format("%,d", thisMonthTotal) %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">지난 달 (<%= lastMonth %>)</div>
                    <div style="font-size:15px; font-weight:800; color:#1E1B2E;">₩<%= String.format("%,d", lastMonthTotal) %></div>
                </div>
                <div style="background:#1E1B2E; border-radius:14px; padding:14px;">
                    <div id="compareDailyApp" style="display:none;">
                        <% if (yesterdayTotal == 0) { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전일 대비</div>
                            <div style="font-size:13px; font-weight:700; color:#9CA3AF;">데이터 없음</div>
                        <% } else { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전일 대비</div>
                            <div style="font-size:15px; font-weight:800; color:<%= dailyChangeRate > 0 ? "#4ADE80" : (dailyChangeRate < 0 ? "#F87171" : "#9CA3AF") %>;">
                                <i class="bi bi-<%= dailyChangeRate > 0 ? "arrow-up-right" : (dailyChangeRate < 0 ? "arrow-down-right" : "dash") %>"></i> <%= String.format("%.1f", Math.abs(dailyChangeRate)) %>%
                            </div>
                        <% } %>
                    </div>
                    <div id="compareMonthlyApp" style="display:none;">
                        <% if (lastMonthTotal == 0) { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전월 대비</div>
                            <div style="font-size:13px; font-weight:700; color:#9CA3AF;">데이터 없음</div>
                        <% } else { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전월 대비</div>
                            <div style="font-size:15px; font-weight:800; color:<%= changeRate > 0 ? "#4ADE80" : (changeRate < 0 ? "#F87171" : "#9CA3AF") %>;">
                                <i class="bi bi-<%= changeRate > 0 ? "arrow-up-right" : (changeRate < 0 ? "arrow-down-right" : "dash") %>"></i> <%= String.format("%.1f", Math.abs(changeRate)) %>%
                            </div>
                        <% } %>
                    </div>
                    <div id="compareYearlyApp" style="display:none;">
                        <% if (lastYearTotal == 0) { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전년 대비</div>
                            <div style="font-size:13px; font-weight:700; color:#9CA3AF;">데이터 없음</div>
                        <% } else { %>
                            <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">전년 대비</div>
                            <div style="font-size:15px; font-weight:800; color:<%= yearlyChangeRate > 0 ? "#4ADE80" : (yearlyChangeRate < 0 ? "#F87171" : "#9CA3AF") %>;">
                                <i class="bi bi-<%= yearlyChangeRate > 0 ? "arrow-up-right" : (yearlyChangeRate < 0 ? "arrow-down-right" : "dash") %>"></i> <%= String.format("%.1f", Math.abs(yearlyChangeRate)) %>%
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div style="background:#fff; border-radius:16px; padding:16px; margin-bottom:16px;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div style="font-size:13px; font-weight:700; color:#1E1B2E;">매출 추이</div>
                    <div class="d-flex" style="background:#F7F6FB; border-radius:8px; padding:3px;">
                        <div class="role-tab-stats" id="tabDaily" style="padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; color:#374151;">일별</div>
                        <div class="role-tab-stats active" id="tabMonthly" style="padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; background:var(--navy); color:#fff;">월별</div>
                        <div class="role-tab-stats" id="tabYearly" style="padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; color:#374151;">연도별</div>
                    </div>
                </div>
                <% if (daily.isEmpty() && monthly.isEmpty() && yearly.isEmpty()) { %>
                    <div class="text-center" style="padding:40px 0; color:#8b87a3;">
                        <i class="bi bi-bar-chart" style="font-size:32px; opacity:0.3;"></i>
                        <p class="mt-2" style="font-size:12.5px;">아직 매출 데이터가 없어요</p>
                    </div>
                <% } else { %>
                    <div style="position:relative; height:220px;">
                        <canvas id="statsChart"></canvas>
                    </div>
                <% } %>
            </div>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">일별 상세 내역 <span style="font-weight:400; font-size:11px; color:#8b87a3;">(최근 30일)</span></div>
            <% if (daily.isEmpty()) { %>
                <div style="text-align:center; padding:20px 0; color:#8b87a3; font-size:12.5px; margin-bottom:16px;">데이터가 없어요</div>
            <% } else { for (int i = daily.size()-1; i >= 0; i--) { Object[] row = daily.get(i); %>
                <div style="display:flex; justify-content:space-between; align-items:center; background:#fff; border-radius:12px; padding:12px 14px; margin-bottom:8px;">
                    <div style="font-size:12.5px; color:#8b87a3;"><%= row[0] %></div>
                    <div style="font-size:14px; font-weight:700; color:#1E1B2E;">₩<%= String.format("%,d", (Integer) row[1]) %></div>
                </div>
            <% } } %>

            <div style="font-size:13px; font-weight:700; margin:16px 0 10px; color:#1E1B2E;">월별 상세 내역</div>
            <% if (monthly.isEmpty()) { %>
                <div style="text-align:center; padding:20px 0; color:#8b87a3; font-size:12.5px;">데이터가 없어요</div>
            <% } else { for (int i = monthly.size()-1; i >= 0; i--) { Object[] row = monthly.get(i); %>
                <div style="display:flex; justify-content:space-between; align-items:center; background:#fff; border-radius:12px; padding:12px 14px; margin-bottom:8px;">
                    <div style="font-size:12.5px; color:#8b87a3;"><%= row[0] %></div>
                    <div style="font-size:14px; font-weight:700; color:#1E1B2E;">₩<%= String.format("%,d", (Integer) row[1]) %></div>
                </div>
            <% } } %>
        </div>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 통계 화면 ===================== -->
        <div class="p-4">
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
                    <div id="compareDaily" style="display:none;">
                        <% if (yesterdayTotal == 0) { %>
                            <div class="kpi-value" style="color:#9CA3AF; font-size:16px;">비교 데이터 없음</div>
                            <div class="kpi-label">전일 대비 <span class="badge" style="font-size:9.5px; background:#9CA3AF; margin-left:2px;">어제 기록 없음</span></div>
                        <% } else { %>
                            <div class="kpi-value" style="color:<%= dailyChangeRate > 0 ? "#16A34A" : (dailyChangeRate < 0 ? "#DC2626" : "#6B7280") %>;">
                                <i class="bi bi-<%= dailyChangeRate > 0 ? "arrow-up-right" : (dailyChangeRate < 0 ? "arrow-down-right" : "dash") %>"></i>
                                <%= String.format("%.1f", Math.abs(dailyChangeRate)) %>%
                            </div>
                            <div class="kpi-label">
                                전일 대비
                                <span class="badge" style="font-size:9.5px; background:<%= dailyChangeRate > 0 ? "#16A34A" : (dailyChangeRate < 0 ? "#DC2626" : "#9CA3AF") %>; margin-left:2px;">
                                    <%= dailyChangeRate > 0 ? "▲ 상승" : (dailyChangeRate < 0 ? "▼ 하락" : "- 동일") %>
                                </span>
                            </div>
                        <% } %>
                    </div>
                    <div id="compareMonthly" style="display:none;">
                        <% if (lastMonthTotal == 0) { %>
                            <div class="kpi-value" style="color:#9CA3AF; font-size:16px;">비교 데이터 없음</div>
                            <div class="kpi-label">전월 대비 <span class="badge" style="font-size:9.5px; background:#9CA3AF; margin-left:2px;">지난달 기록 없음</span></div>
                        <% } else { %>
                            <div class="kpi-value" style="color:<%= changeRate > 0 ? "#16A34A" : (changeRate < 0 ? "#DC2626" : "#6B7280") %>;">
                                <i class="bi bi-<%= changeRate > 0 ? "arrow-up-right" : (changeRate < 0 ? "arrow-down-right" : "dash") %>"></i>
                                <%= String.format("%.1f", Math.abs(changeRate)) %>%
                            </div>
                            <div class="kpi-label">
                                전월 대비
                                <span class="badge" style="font-size:9.5px; background:<%= changeRate > 0 ? "#16A34A" : (changeRate < 0 ? "#DC2626" : "#9CA3AF") %>; margin-left:2px;">
                                    <%= changeRate > 0 ? "▲ 상승" : (changeRate < 0 ? "▼ 하락" : "- 동일") %>
                                </span>
                            </div>
                        <% } %>
                    </div>
                    <div id="compareYearly" style="display:none;">
                        <% if (lastYearTotal == 0) { %>
                            <div class="kpi-value" style="color:#9CA3AF; font-size:16px;">비교 데이터 없음</div>
                            <div class="kpi-label">전년 대비 <span class="badge" style="font-size:9.5px; background:#9CA3AF; margin-left:2px;">작년 기록 없음</span></div>
                        <% } else { %>
                            <div class="kpi-value" style="color:<%= yearlyChangeRate > 0 ? "#16A34A" : (yearlyChangeRate < 0 ? "#DC2626" : "#6B7280") %>;">
                                <i class="bi bi-<%= yearlyChangeRate > 0 ? "arrow-up-right" : (yearlyChangeRate < 0 ? "arrow-down-right" : "dash") %>"></i>
                                <%= String.format("%.1f", Math.abs(yearlyChangeRate)) %>%
                            </div>
                            <div class="kpi-label">
                                전년 대비
                                <span class="badge" style="font-size:9.5px; background:<%= yearlyChangeRate > 0 ? "#16A34A" : (yearlyChangeRate < 0 ? "#DC2626" : "#9CA3AF") %>; margin-left:2px;">
                                    <%= yearlyChangeRate > 0 ? "▲ 상승" : (yearlyChangeRate < 0 ? "▼ 하락" : "- 동일") %>
                                </span>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <div class="moa-card mb-4" style="min-height:460px;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="mb-0">매출 추이</h6>
                <div class="d-flex" style="background:#f0f0f0; border-radius:8px; padding:4px;">
                    <div class="role-tab-stats" id="tabDailyWeb" style="padding:6px 16px; border-radius:6px; cursor:pointer; font-size:13px; color:#374151;">일별</div>
                    <div class="role-tab-stats active" id="tabMonthlyWeb" style="padding:6px 16px; border-radius:6px; cursor:pointer; font-size:13px; background:var(--navy); color:#fff;">월별</div>
                    <div class="role-tab-stats" id="tabYearlyWeb" style="padding:6px 16px; border-radius:6px; cursor:pointer; font-size:13px; color:#374151;">연도별</div>
                </div>
            </div>
            <% if (daily.isEmpty() && monthly.isEmpty() && yearly.isEmpty()) { %>
                <div class="text-center text-muted py-5" style="padding-top:120px;">
                    <i class="bi bi-bar-chart" style="font-size:40px; opacity:0.3;"></i>
                    <p class="mt-2">아직 매출 데이터가 없어요. 매출을 등록하면 여기에 그래프가 나와요.</p>
                </div>
            <% } else { %>
                <div style="position:relative; height:340px;">
                    <canvas id="statsChartWeb"></canvas>
                </div>
            <% } %>
        </div>

        <div class="moa-card mb-4">
            <h6 class="mb-3">일별 상세 내역 <span style="font-weight:400; font-size:12px; color:var(--text-muted);">(최근 30일)</span></h6>
            <table class="table moa-table">
                <thead><tr><th>날짜</th><th>총 매출</th><th>카드</th><th>현금</th></tr></thead>
                <tbody>
                <% if (daily.isEmpty()) { %>
                    <tr><td colspan="4" class="text-center text-muted">데이터가 없어요</td></tr>
                <% } else { for (int i = daily.size()-1; i >= 0; i--) { Object[] row = daily.get(i); %>
                    <tr>
                        <td><%= row[0] %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[1]) %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[2]) %></td>
                        <td>₩ <%= String.format("%,d", (Integer) row[3]) %></td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
            <p style="font-size:11.5px; color:var(--text-muted); margin-bottom:0;">개별 기록 삭제는 <a href="mypage.jsp">마이페이지</a>에서 할 수 있어요.</p>
        </div>

        <div class="moa-card">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="mb-0">월별 상세 내역</h6>
                <div class="d-flex align-items-center gap-2">
                    <label style="font-size:12px; color:var(--text-muted);"><input type="checkbox" id="checkAllMonths" style="margin-right:5px;">전체 선택</label>
                    <button type="button" id="btnDeleteSelectedMonths" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;" disabled>선택 삭제</button>
                    <button type="button" id="btnDeleteAllMonths" class="btn-moa-outline btn-moa-sm" style="color:#991B1B; border-color:#991B1B;">전체 삭제</button>
                </div>
            </div>
            <% if ("1".equals(request.getParameter("salesDeleted"))) { %>
                <div class="alert alert-success py-2" style="font-size:12.5px;"><i class="bi bi-check-circle"></i> 삭제됐어요.</div>
            <% } %>
            <form action="SalesDeleteServlet" method="post" id="monthDeleteForm">
                <input type="hidden" name="action" id="monthDeleteAction" value="deleteMonths">
                <input type="hidden" name="returnTo" value="stats.jsp">
                <table class="table moa-table">
                    <thead><tr><th style="width:32px;"></th><th>월</th><th>총 매출</th><th>카드</th><th>현금</th></tr></thead>
                    <tbody>
                    <% if (monthly.isEmpty()) { %>
                        <tr><td colspan="5" class="text-center text-muted">데이터가 없어요</td></tr>
                    <% } else { for (int i = monthly.size()-1; i >= 0; i--) { Object[] row = monthly.get(i); %>
                        <tr>
                            <td><input type="checkbox" class="monthCheck" name="ym" value="<%= row[0] %>"></td>
                            <td><%= row[0] %></td>
                            <td>₩ <%= String.format("%,d", (Integer) row[1]) %></td>
                            <td>₩ <%= String.format("%,d", (Integer) row[2]) %></td>
                            <td>₩ <%= String.format("%,d", (Integer) row[3]) %></td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </form>
        </div>
        </div>
    <% } %>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
    var dailyLabels = [<% for (int i=0;i<daily.size();i++){ %>'<%= daily.get(i)[0] %>'<%= i<daily.size()-1?",":"" %><% } %>];
    var dailyValues = [<% for (int i=0;i<daily.size();i++){ %><%= daily.get(i)[1] %><%= i<daily.size()-1?",":"" %><% } %>];
    var monthlyLabels = [<% for (int i=0;i<monthly.size();i++){ %>'<%= monthly.get(i)[0] %>'<%= i<monthly.size()-1?",":"" %><% } %>];
    var monthlyValues = [<% for (int i=0;i<monthly.size();i++){ %><%= monthly.get(i)[1] %><%= i<monthly.size()-1?",":"" %><% } %>];
    var yearlyLabels = [<% for (int i=0;i<yearly.size();i++){ %>'<%= yearly.get(i)[0] %>'<%= i<yearly.size()-1?",":"" %><% } %>];
    var yearlyValues = [<% for (int i=0;i<yearly.size();i++){ %><%= yearly.get(i)[1] %><%= i<yearly.size()-1?",":"" %><% } %>];

    var isAppPage = <%= isApp %>;
    var tabDaily = document.getElementById(isAppPage ? 'tabDaily' : 'tabDailyWeb');
    var tabMonthly = document.getElementById(isAppPage ? 'tabMonthly' : 'tabMonthlyWeb');
    var tabYearly = document.getElementById(isAppPage ? 'tabYearly' : 'tabYearlyWeb');
    var compareDaily = document.getElementById(isAppPage ? 'compareDailyApp' : 'compareDaily');
    var compareMonthly = document.getElementById(isAppPage ? 'compareMonthlyApp' : 'compareMonthly');
    var compareYearly = document.getElementById(isAppPage ? 'compareYearlyApp' : 'compareYearly');

    function activate(tab) {
        [tabDaily, tabMonthly, tabYearly].forEach(function (t) {
            t.classList.remove('active');
            t.style.background = 'transparent'; t.style.color = '#374151';
        });
        tab.classList.add('active');
        tab.style.background = 'var(--navy)'; tab.style.color = '#fff';

        [compareDaily, compareMonthly, compareYearly].forEach(function (c) { if (c) c.style.display = 'none'; });
        var toShow = tab === tabDaily ? compareDaily : (tab === tabYearly ? compareYearly : compareMonthly);
        if (toShow) toShow.style.display = 'block';
    }

    var ctx = document.getElementById(isAppPage ? 'statsChart' : 'statsChartWeb');
    var chart = null;
    if (ctx) {
        var defaultTab = monthlyValues.length > 0 ? 'monthly' : (yearlyValues.length > 0 ? 'yearly' : 'daily');
        var defaultLabels = defaultTab === 'monthly' ? monthlyLabels : (defaultTab === 'yearly' ? yearlyLabels : dailyLabels);
        var defaultValues = defaultTab === 'monthly' ? monthlyValues : (defaultTab === 'yearly' ? yearlyValues : dailyValues);
        chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: defaultLabels,
                datasets: [{ label: '매출', data: defaultValues, backgroundColor: 'rgba(79,70,229,0.75)', borderRadius: 6, maxBarThickness: 46 }]
            },
            options: {
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { callback: function(v){ return '₩' + v.toLocaleString(); } } } }
            }
        });
        if (defaultTab === 'monthly') activate(tabMonthly);
        else if (defaultTab === 'yearly') activate(tabYearly);
        else activate(tabDaily);
    } else if (compareMonthly) {
        compareMonthly.style.display = 'block';
    }

    if (tabDaily) tabDaily.addEventListener('click', function () {
        activate(tabDaily);
        chart.data.labels = dailyLabels; chart.data.datasets[0].data = dailyValues; chart.update();
    });
    if (tabMonthly) tabMonthly.addEventListener('click', function () {
        activate(tabMonthly);
        chart.data.labels = monthlyLabels; chart.data.datasets[0].data = monthlyValues; chart.update();
    });
    if (tabYearly) tabYearly.addEventListener('click', function () {
        activate(tabYearly);
        chart.data.labels = yearlyLabels; chart.data.datasets[0].data = yearlyValues; chart.update();
    });

    var checkAllMonths = document.getElementById('checkAllMonths');
    var monthChecks = document.querySelectorAll('.monthCheck');
    var btnDeleteSelectedMonths = document.getElementById('btnDeleteSelectedMonths');
    var btnDeleteAllMonths = document.getElementById('btnDeleteAllMonths');
    var monthDeleteForm = document.getElementById('monthDeleteForm');

    function updateMonthBtn() {
        if (!btnDeleteSelectedMonths) return;
        var anyChecked = Array.from(monthChecks).some(function (c) { return c.checked; });
        btnDeleteSelectedMonths.disabled = !anyChecked;
    }
    if (checkAllMonths) {
        checkAllMonths.addEventListener('change', function () {
            monthChecks.forEach(function (c) { c.checked = checkAllMonths.checked; });
            updateMonthBtn();
        });
    }
    monthChecks.forEach(function (c) { c.addEventListener('change', updateMonthBtn); });

    if (btnDeleteSelectedMonths) {
        btnDeleteSelectedMonths.addEventListener('click', function () {
            var count = Array.from(monthChecks).filter(function (c) { return c.checked; }).length;
            if (!confirm('선택한 ' + count + '개월의 매출 기록을 통째로 삭제할까요?')) return;
            document.getElementById('monthDeleteAction').value = 'deleteMonths';
            monthDeleteForm.submit();
        });
    }
    if (btnDeleteAllMonths) {
        btnDeleteAllMonths.addEventListener('click', function () {
            if (!confirm('이 매장의 매출 기록을 전부 삭제할까요? 이 작업은 되돌릴 수 없어요.')) return;
            document.getElementById('monthDeleteAction').value = 'deleteAll';
            monthDeleteForm.submit();
        });
    }
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
