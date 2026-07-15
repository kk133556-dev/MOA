<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate, com.moa.dao.ReservationDAO, com.moa.model.Reservation"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>예약 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .res-card { border:1px solid var(--border); border-radius:12px; padding:14px 16px; margin-bottom:10px; background:#fff; }
        .res-card.soon { border-color:#F59E0B; background:#FFFBEB; }
        .res-card.today { border-color:#DC2626; background:#FEF2F2; }
        .time-chip { font-size:11.5px; background:#F3F4F6; border:1px solid var(--border); padding:5px 10px; border-radius:14px; cursor:pointer; }
        .time-chip:hover { background:#E5E7EB; }
        .time-chip.active { background:var(--primary); color:#fff; border-color:var(--primary); }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    String currentMenu = "reservation";

    ReservationDAO dao = new ReservationDAO();
    List<Reservation> upcoming = dao.listUpcoming(storeId);
    LocalDate today = LocalDate.now();
    LocalDate soonCutoff = today.plusDays(2); // D-2 이내면 "임박"으로 강조
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-calendar-check"></i> 예약 관리</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value"><%= upcoming.size() %></div><div class="kpi-label">다가오는 예약</div></div></div>
            <%
                int todayCount = 0, soonCount = 0;
                for (Reservation r : upcoming) {
                    LocalDate d = LocalDate.parse(r.getReservationDate());
                    if (d.isEqual(today)) todayCount++;
                    else if (!d.isAfter(soonCutoff)) soonCount++;
                }
            %>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= todayCount>0?"#DC2626":"#16A34A" %>;"><%= todayCount %></div><div class="kpi-label">오늘 예약</div></div></div>
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= soonCount>0?"#F59E0B":"#16A34A" %>;"><%= soonCount %></div><div class="kpi-label">임박 예약 (2일 이내)</div></div></div>
        </div>

        <div class="row g-3">
            <div class="col-lg-5">
                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-plus-circle"></i> 새 예약 등록</h6>
                    <% if ("1".equals(request.getParameter("done"))) { %>
                        <div class="alert alert-success py-2" style="font-size:12.5px;"><i class="bi bi-check-circle"></i> 예약이 등록됐어요!</div>
                    <% } %>
                    <form action="ReservationServlet" method="post">
                        <div class="row g-2 mb-2">
                            <div class="col-7"><label class="form-label" style="font-size:12px;">예약자 성함</label><input type="text" name="customerName" class="form-control" required></div>
                            <div class="col-5"><label class="form-label" style="font-size:12px;">인원</label><input type="number" name="partySize" class="form-control" value="1" min="1" required></div>
                        </div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">전화번호</label><input type="text" name="phone" class="form-control" placeholder="010-0000-0000" required></div>
                        <div class="row g-2 mb-1">
                            <div class="col-6"><label class="form-label" style="font-size:12px;">예약 날짜</label><input type="date" name="date" id="resDate" class="form-control" required></div>
                            <div class="col-6"><label class="form-label" style="font-size:12px;">예약 시간</label><input type="time" name="time" id="resTime" class="form-control" required></div>
                        </div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">주문 메뉴</label><input type="text" name="menuOrder" class="form-control" placeholder="예: A세트 10인분"></div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">선결제 금액</label><input type="number" name="prepayment" class="form-control" placeholder="0" value="0"></div>
                        <div class="mb-3"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" class="form-control" placeholder="선택"></div>
                        <button type="submit" class="btn-moa w-100 justify-content-center">예약 등록</button>
                    </form>
                </div>
            </div>

            <div class="col-lg-7">
                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-bell"></i> 다가오는 예약</h6>
                    <% if (upcoming.isEmpty()) { %>
                        <div class="text-center text-muted py-5">
                            <i class="bi bi-calendar-x" style="font-size:32px; opacity:0.3;"></i>
                            <p class="mt-2 mb-0">예정된 예약이 없어요.</p>
                        </div>
                    <% } else { for (Reservation r : upcoming) {
                        LocalDate d = LocalDate.parse(r.getReservationDate());
                        boolean isToday = d.isEqual(today);
                        boolean isSoon = !isToday && !d.isAfter(soonCutoff);
                        String cardClass = isToday ? "today" : (isSoon ? "soon" : "");
                        String statusBadge = "PENDING".equals(r.getStatus()) ? "bg-warning" : "CONFIRMED".equals(r.getStatus()) ? "bg-success" : "bg-secondary";
                        String statusText = "PENDING".equals(r.getStatus()) ? "대기" : "CONFIRMED".equals(r.getStatus()) ? "확정" : r.getStatus();
                    %>
                        <div class="res-card <%= cardClass %>">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <b style="font-size:14px;"><%= r.getReservationDate() %> <%= r.getReservationTime() %></b>
                                    <% if (isToday) { %><span class="badge bg-danger ms-1" style="font-size:9.5px;">오늘</span><% } else if (isSoon) { %><span class="badge" style="background:#F59E0B; font-size:9.5px;">임박</span><% } %>
                                    <div style="font-size:13px; margin-top:4px;"><i class="bi bi-person"></i> <%= r.getCustomerName() %> · <%= r.getPhone() %> · <%= r.getPartySize() %>명</div>
                                    <% if (r.getMenuOrder() != null && !r.getMenuOrder().isEmpty()) { %><div style="font-size:12.5px; color:var(--text-muted); margin-top:2px;"><i class="bi bi-basket"></i> <%= r.getMenuOrder() %></div><% } %>
                                    <% if (r.getPrepaymentAmount() > 0) { %><div style="font-size:12.5px; color:var(--text-muted);"><i class="bi bi-cash"></i> 선결제 <%= String.format("%,d", r.getPrepaymentAmount()) %>원</div><% } %>
                                    <% if (r.getMemo() != null && !r.getMemo().isEmpty()) { %><div style="font-size:12.5px; color:var(--text-muted);"><i class="bi bi-sticky"></i> <%= r.getMemo() %></div><% } %>
                                </div>
                                <span class="badge <%= statusBadge %>"><%= statusText %></span>
                            </div>
                            <div class="d-flex gap-2 mt-2">
                                <% if ("PENDING".equals(r.getStatus())) { %>
                                <form action="ReservationServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">
                                    <input type="hidden" name="status" value="CONFIRMED">
                                    <button class="btn-moa-outline btn-moa-sm">확정하기</button>
                                </form>
                                <% } %>
                                <form action="ReservationServlet" method="post" style="display:inline;" onsubmit="return confirm('이 예약을 삭제할까요?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">
                                    <button class="btn-moa-outline btn-moa-sm" style="color:#DC2626;">삭제</button>
                                </form>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="chat_widget.jsp" />
</body>
</html>
