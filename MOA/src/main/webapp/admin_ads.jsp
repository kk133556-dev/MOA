<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.AdDAO, com.moa.model.Ad"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>광고 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null || !"ADMIN".equals(session.getAttribute("memberType"))) { response.sendRedirect("login.jsp?role=ADMIN"); return; }
    AdDAO adDao = new AdDAO();
    List<Ad> pending = adDao.listPending();
    List<Ad> approved = adDao.listAllApprovedIncludingExpired();
    String currentMenu = "ads";
%>
<div class="d-flex">
    <%@ include file="admin_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-megaphone"></i> 광고 관리</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#F59E0B;"><%= pending.size() %></div><div class="kpi-label">승인 대기</div></div></div>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#16A34A;"><%= approved.size() %></div><div class="kpi-label">승인된 광고</div></div></div>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value"><%= pending.size() + approved.size() %></div><div class="kpi-label">전체 신청 수</div></div></div>
        </div>

        <h6 class="mb-3"><i class="bi bi-hourglass-split"></i> 승인 대기 중</h6>
        <% if (pending.isEmpty()) { %>
            <div class="moa-card text-center py-4 mb-4"><p class="text-muted mb-0">승인 대기중인 광고가 없어요.</p></div>
        <% } else { for (Ad ad : pending) { %>
            <div class="moa-card mb-3">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <div><b><%= ad.getStoreName() %></b><br><span style="font-size:13px;"><%= ad.getBannerText() %></span></div>
                    <form action="AdminAdServlet" method="post"><input type="hidden" name="adId" value="<%= ad.getAdId() %>"><input type="hidden" name="action" value="reject"><button class="btn-moa-outline btn-moa-sm" style="color:#DC2626;">반려</button></form>
                </div>
                <form action="AdminAdServlet" method="post" class="d-flex align-items-end gap-2 flex-wrap">
                    <input type="hidden" name="adId" value="<%= ad.getAdId() %>">
                    <input type="hidden" name="action" value="approve">
                    <div>
                        <label class="form-label" style="font-size:11px; margin-bottom:2px;">노출 시작일 (비우면 즉시)</label>
                        <input type="date" name="startDate" class="form-control form-control-sm">
                    </div>
                    <div>
                        <label class="form-label" style="font-size:11px; margin-bottom:2px;">노출 종료일 (비우면 무기한)</label>
                        <input type="date" name="endDate" class="form-control form-control-sm">
                    </div>
                    <button class="btn-moa btn-moa-sm">승인하기</button>
                </form>
            </div>
        <% } } %>

        <h6 class="mb-3 mt-4"><i class="bi bi-check-circle"></i> 승인된 광고 (전체)</h6>
        <% if (approved.isEmpty()) { %>
            <div class="moa-card text-center py-4"><p class="text-muted mb-0">승인된 광고가 없어요.</p></div>
        <% } else { %>
        <table class="table moa-table">
            <thead><tr><th>매장</th><th>배너 문구</th><th>노출 기간</th><th></th></tr></thead>
            <tbody>
            <% for (Ad ad : approved) { %>
                <tr>
                    <td><%= ad.getStoreName() %></td>
                    <td style="font-size:13px;"><%= ad.getBannerText() %></td>
                    <td style="font-size:12px; color:var(--text-muted);">
                        <%= ad.getStartDate() != null ? ad.getStartDate() : "제한없음" %> ~ <%= ad.getEndDate() != null ? ad.getEndDate() : "무기한" %>
                    </td>
                    <td>
                        <form action="AdminAdServlet" method="post" onsubmit="return confirm('이 광고를 삭제할까요?');">
                            <input type="hidden" name="adId" value="<%= ad.getAdId() %>">
                            <input type="hidden" name="action" value="delete">
                            <button class="btn-moa-outline btn-moa-sm" style="color:#DC2626;">삭제</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </main>
</div>
</body>
</html>
