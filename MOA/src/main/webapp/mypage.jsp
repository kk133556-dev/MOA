<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, com.moa.dao.SalesDAO, com.moa.model.SalesRecord, com.moa.dao.ReservationDAO, com.moa.model.Reservation, java.time.LocalDate, com.moa.dao.AdDAO, com.moa.model.Ad, com.moa.dao.TodoDAO, com.moa.model.Todo"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>마이페이지</title>
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
    List<Reservation> soonReservations = new ArrayList<>();
    try {
        LocalDate todayLd = LocalDate.now();
        LocalDate cutoff = todayLd.plusDays(2);
        for (Reservation r : new ReservationDAO().listUpcoming(storeId)) {
            LocalDate d = LocalDate.parse(r.getReservationDate());
            if (!d.isAfter(cutoff)) soonReservations.add(r);
        }
    } catch (Exception ignore) { /* 예약 테이블이 아직 없어도 마이페이지는 정상 동작해야 해요 */ }
    String currentMenu = "home";

    // 홈 화면에 보여줄 광고 배너 + 다이어리 미리보기
    List<Ad> homeAds = new ArrayList<>();
    try { homeAds = new AdDAO().listApproved(); } catch (Exception ignore) {}
    List<Todo> homeTodos = new ArrayList<>();
    try {
        for (Todo t : new TodoDAO().listByStore(storeId)) {
            if (!t.isDone()) homeTodos.add(t);
            if (homeTodos.size() >= 3) break;
        }
    } catch (Exception ignore) {}

    // 안드로이드 앱에서 왔는지는 mypage_sidebar.jsp include에서 이미 ua/isApp을 선언해줘요 (아래에서 재사용).
    String memberName = String.valueOf(session.getAttribute("name"));
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 홈 대시보드 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div class="mb-3">
                <div style="font-size:19px; font-weight:800; color:#1E1B2E;"><%= session.getAttribute("storeName") %></div>
                <div style="font-size:12.5px; color:#8b87a3;"><%= memberName %>님, 안녕하세요</div>
            </div>

            <% if ("1".equals(request.getParameter("planUpdated"))) { %>
                <div class="alert alert-success py-2" style="font-size:12.5px; border-radius:12px;"><i class="bi bi-check-circle"></i> 요금제가 변경됐어요!</div>
            <% } %>

            <% if (!soonReservations.isEmpty()) { %>
            <div style="background:linear-gradient(135deg,#8B5CF6,#6366F1); border-radius:16px; padding:14px 16px; color:#fff; margin-bottom:14px;">
                <div style="font-size:13px; font-weight:700;"><i class="bi bi-bell-fill"></i> 다가오는 예약 <%= soonReservations.size() %>건</div>
                <div style="font-size:11.5px; opacity:0.92; margin-top:5px; line-height:1.6;">
                    <% for (int i = 0; i < Math.min(2, soonReservations.size()); i++) { Reservation r = soonReservations.get(i); %>
                        <%= r.getReservationDate() %> <%= r.getReservationTime() %> · <%= r.getCustomerName() %>님 <%= r.getPartySize() %>명<br>
                    <% } %>
                </div>
                <a href="reservation.jsp" style="display:inline-block; margin-top:9px; background:rgba(255,255,255,0.22); color:#fff; padding:7px 13px; border-radius:9px; font-size:11.5px; text-decoration:none; font-weight:600;">예약 확인하기 →</a>
            </div>
            <% } %>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:20px;">
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">누적 매출</div>
                    <div style="font-size:16px; font-weight:800; color:#1E1B2E;">₩<%= String.format("%,d", total) %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">등록 건수</div>
                    <div style="font-size:16px; font-weight:800; color:#1E1B2E;"><%= salesList.size() %>건</div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:14px;">
                    <div style="font-size:11px; color:#8b87a3; margin-bottom:5px;">현재 요금제</div>
                    <div style="font-size:16px; font-weight:800; color:#1E1B2E;"><%= session.getAttribute("plan") != null ? session.getAttribute("plan") : "BASIC" %></div>
                </div>
                <a href="stats.jsp" style="background:#1E1B2E; border-radius:14px; padding:14px; text-decoration:none; display:flex; flex-direction:column; justify-content:center;">
                    <div style="font-size:11px; color:#a39fc0; margin-bottom:5px;">통계 자세히</div>
                    <div style="font-size:15px; font-weight:800; color:#fff;"><i class="bi bi-bar-chart"></i> 보러가기</div>
                </a>
            </div>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">빠른 메뉴</div>
            <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:8px; margin-bottom:22px; text-align:center;">
                <a href="ai_receipt.jsp" style="text-decoration:none; color:inherit;">
                    <div style="width:48px; height:48px; border-radius:14px; background:#F3F0FF; display:flex; align-items:center; justify-content:center; margin:0 auto 6px;"><i class="bi bi-camera" style="color:#8B5CF6; font-size:19px;"></i></div>
                    <div style="font-size:10.5px; color:#1E1B2E;">영수증</div>
                </a>
                <a href="inventory.jsp" style="text-decoration:none; color:inherit;">
                    <div style="width:48px; height:48px; border-radius:14px; background:#EFF6FF; display:flex; align-items:center; justify-content:center; margin:0 auto 6px;"><i class="bi bi-box-seam" style="color:#3B82F6; font-size:19px;"></i></div>
                    <div style="font-size:10.5px; color:#1E1B2E;">재고</div>
                </a>
                <a href="staff.jsp" style="text-decoration:none; color:inherit;">
                    <div style="width:48px; height:48px; border-radius:14px; background:#F0FDF4; display:flex; align-items:center; justify-content:center; margin:0 auto 6px;"><i class="bi bi-people" style="color:#22C55E; font-size:19px;"></i></div>
                    <div style="font-size:10.5px; color:#1E1B2E;">직원</div>
                </a>
                <a href="todo.jsp" style="text-decoration:none; color:inherit;">
                    <div style="width:48px; height:48px; border-radius:14px; background:#FFF7ED; display:flex; align-items:center; justify-content:center; margin:0 auto 6px;"><i class="bi bi-journal-check" style="color:#F97316; font-size:19px;"></i></div>
                    <div style="font-size:10.5px; color:#1E1B2E;">다이어리</div>
                </a>
            </div>

            <button type="button" data-bs-toggle="offcanvas" data-bs-target="#salesAddSheet" style="width:100%; background:#8B5CF6; color:#fff; border:none; border-radius:14px; padding:14px; font-weight:700; font-size:14px; margin-bottom:20px;">
                <i class="bi bi-plus-circle"></i> 오늘 매출 등록
            </button>

            <div style="background:#fff; border-radius:16px; padding:16px; margin-bottom:16px;">
                <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;"><i class="bi bi-graph-up"></i> 최근 매출 추이</div>
                <% if (salesList.isEmpty()) { %>
                    <div style="text-align:center; padding:30px 0; color:#8b87a3; font-size:12.5px;">아직 등록된 매출이 없어요</div>
                <% } else { %>
                    <div style="position:relative; height:180px;"><canvas id="salesChart"></canvas></div>
                <% } %>
            </div>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">최근 매출 기록</div>
            <% if (salesList.isEmpty()) { %>
                <div style="text-align:center; padding:20px 0; color:#8b87a3; font-size:12.5px;">등록된 기록이 없어요</div>
            <% } else { for (int i = 0; i < Math.min(5, salesList.size()); i++) { SalesRecord r = salesList.get(i); %>
                <div style="display:flex; justify-content:space-between; align-items:center; background:#fff; border-radius:12px; padding:12px 14px; margin-bottom:8px;">
                    <div>
                        <div style="font-size:12px; color:#8b87a3;"><%= r.getSalesDate() %></div>
                        <div style="font-size:14px; font-weight:700; color:#1E1B2E;">₩<%= String.format("%,d", r.getTotalAmount()) %></div>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <% if (r.getReceiptImage() != null) { %><i class="bi bi-image" style="color:#8B5CF6; font-size:16px;"></i><% } %>
                        <form action="SalesDeleteServlet" method="post" onsubmit="return confirm('이 매출 기록을 삭제할까요?');">
                            <input type="hidden" name="action" value="deleteSelected">
                            <input type="hidden" name="returnTo" value="mypage.jsp">
                            <input type="hidden" name="salesId" value="<%= r.getSalesId() %>">
                            <button type="submit" style="background:none; border:none; color:#DC2626; font-size:15px; padding:0;"><i class="bi bi-trash"></i></button>
                        </form>
                    </div>
                </div>
            <% } } %>
            <% if (salesList.size() > 5) { %>
                <a href="stats.jsp" style="display:block; text-align:center; font-size:12.5px; font-weight:600; margin-top:8px; color:#8B5CF6;">전체 기록 보기 →</a>
            <% } %>

            <% if (!homeAds.isEmpty()) { %>
            <div style="background:linear-gradient(135deg,#1E1B2E,#332D52); border-radius:16px; padding:16px; margin-top:16px; color:#fff;">
                <div style="font-size:11px; color:#a39fc0; margin-bottom:8px; display:flex; align-items:center; gap:5px;"><span style="width:6px; height:6px; border-radius:50%; background:#34D399; display:inline-block;"></span> 실시간 매장 소식</div>
                <% Ad homeAd = homeAds.get((int)(System.currentTimeMillis() / 5000) % homeAds.size()); %>
                <div style="font-size:13px; font-weight:700;"><i class="bi bi-shop"></i> <%= homeAd.getStoreName() %></div>
                <div style="font-size:12px; color:#c4c1d6; margin-top:3px;"><%= homeAd.getBannerText() %></div>
            </div>
            <% } %>

            <div style="background:#fff; border-radius:16px; padding:16px; margin-top:16px;">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div style="font-size:13px; font-weight:700; color:#1E1B2E;"><i class="bi bi-journal-check"></i> 다이어리</div>
                    <a href="todo.jsp" style="font-size:11.5px; color:#8B5CF6; font-weight:600; text-decoration:none;">전체보기 →</a>
                </div>
                <% if (homeTodos.isEmpty()) { %>
                    <div style="text-align:center; padding:14px 0; color:#8b87a3; font-size:12.5px;">할 일을 등록해보세요</div>
                <% } else { for (Todo t : homeTodos) { %>
                    <div style="display:flex; align-items:center; gap:8px; padding:7px 0; font-size:12.5px; color:#374151;">
                        <i class="bi bi-circle" style="color:#D1D5DB; font-size:11px;"></i> <%= t.getContent() %>
                    </div>
                <% } } %>
            </div>
        </div>

        <!-- 매출등록 바텀시트 (앱 전용) -->
        <div class="offcanvas offcanvas-bottom" tabindex="-1" id="salesAddSheet" style="border-radius:20px 20px 0 0; max-height:85vh;">
            <div class="offcanvas-header">
                <h6 class="offcanvas-title"><i class="bi bi-plus-circle"></i> 오늘 매출 등록</h6>
                <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
            </div>
            <div class="offcanvas-body">
                <form action="SalesServlet" method="post">
                    <div class="mb-2"><label class="form-label">총 매출</label><input type="number" name="total" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">카드 매출</label><input type="number" name="card" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">현금 매출</label><input type="number" name="cash" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">주류매출</label><input type="number" name="liquor" class="form-control form-control-sm" placeholder="0"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">수수료</label><input type="number" name="fee" class="form-control form-control-sm" placeholder="0"></div>
                    <div class="mb-3"><label class="form-label" style="font-size:12px;">기타지출</label><input type="number" name="other" class="form-control form-control-sm" placeholder="0"></div>
                    <button type="submit" class="btn-moa w-100 justify-content-center">저장</button>
                </form>
            </div>
        </div>
        <script>
            if (typeof bootstrap === 'undefined') {
                document.write('<scr' + 'ipt src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></scr' + 'ipt>');
            }
        </script>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 대시보드 ===================== -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="mb-0"><%= session.getAttribute("storeName") %> 마이페이지</h4>
            <div><%= memberName %>님</div>
        </div>

        <% if ("1".equals(request.getParameter("planUpdated"))) { %>
            <div class="alert alert-success"><i class="bi bi-check-circle"></i> 요금제가 변경됐어요!</div>
        <% } %>

        <% if (!soonReservations.isEmpty()) { %>
        <div class="alert alert-warning d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <i class="bi bi-bell-fill"></i> <b>다가오는 예약이 <%= soonReservations.size() %>건 있어요!</b>
                <div style="font-size:12.5px; margin-top:4px;">
                    <% for (int i = 0; i < Math.min(3, soonReservations.size()); i++) { Reservation r = soonReservations.get(i); %>
                        <%= r.getReservationDate() %> <%= r.getReservationTime() %> · <%= r.getCustomerName() %>님 <%= r.getPartySize() %>명<%= i < Math.min(3, soonReservations.size())-1 ? " / " : "" %>
                    <% } %>
                </div>
            </div>
            <a href="reservation.jsp" class="btn-moa-sm btn-moa">예약 확인하기</a>
        </div>
        <% } %>

        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value">₩ <%= String.format("%,d", total) %></div><div class="kpi-label">누적 매출</div></div></div>
            <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value"><%= salesList.size() %>건</div><div class="kpi-label">등록 건수</div></div></div>
            <div class="col-6 col-md-3"><div class="kpi-card"><div class="kpi-value"><%= session.getAttribute("plan") != null ? session.getAttribute("plan") : "BASIC" %></div><div class="kpi-label">현재 요금제</div></div></div>
            <div class="col-6 col-md-3"><a href="stats.jsp" class="kpi-card" style="display:block; text-decoration:none; color:inherit;"><div class="kpi-value"><i class="bi bi-bar-chart"></i></div><div class="kpi-label">월별/연도별 통계 보기</div></a></div>
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
                        <a class="d-block mb-2" data-bs-toggle="collapse" href="#detailFields" style="font-size:12px;"><i class="bi bi-chevron-down"></i> 주류매출·수수료·기타지출 추가 입력 (선택)</a>
                        <div class="collapse" id="detailFields">
                            <div class="mb-2"><label class="form-label" style="font-size:12px;">주류매출</label><input type="number" name="liquor" class="form-control form-control-sm" placeholder="0"></div>
                            <div class="mb-2"><label class="form-label" style="font-size:12px;">수수료</label><input type="number" name="fee" class="form-control form-control-sm" placeholder="0"></div>
                            <div class="mb-2"><label class="form-label" style="font-size:12px;">기타지출</label><input type="number" name="other" class="form-control form-control-sm" placeholder="0"></div>
                        </div>
                        <button type="submit" class="btn-moa w-100 justify-content-center">저장</button>
                    </form>
                </div>
            </div>
            <div class="col-lg-7">
                <div class="moa-card d-flex flex-column" style="height:100%; min-height:340px;">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="mb-0"><i class="bi bi-graph-up"></i> 최근 매출 추이</h6>
                        <% if (!salesList.isEmpty()) { %><a href="stats.jsp" style="font-size:12px; font-weight:600;">전체 통계 보기 →</a><% } %>
                    </div>
                    <% if (salesList.isEmpty()) { %>
                        <div class="flex-grow-1 d-flex align-items-center justify-content-center">
                            <p class="text-muted text-center mb-0">아직 등록된 매출이 없어요<br><span style="font-size:12px;">매출을 등록하면 여기에 그래프가 나와요</span></p>
                        </div>
                    <% } else { %>
                        <div class="flex-grow-1" style="position:relative; min-height:260px;">
                            <canvas id="salesChart"></canvas>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="moa-card mt-3">
            <div class="d-flex justify-content-between align-items-center">
                <h6 class="mb-0"><i class="bi bi-table"></i> 매출 기록</h6>
                <div class="d-flex gap-2">
                    <a href="ExportCsvServlet" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-spreadsheet"></i> 엑셀(XLSX)</a>
                    <a href="report_print.jsp" class="btn-moa-outline btn-moa-sm"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
                </div>
            </div>
            <% if ("1".equals(request.getParameter("salesDeleted"))) { %>
                <div class="alert alert-success py-2 mt-2" style="font-size:12.5px;"><i class="bi bi-check-circle"></i> 삭제됐어요.</div>
            <% } %>
            <form action="SalesDeleteServlet" method="post" id="salesDeleteForm">
                <input type="hidden" name="action" id="salesDeleteAction" value="deleteSelected">
                <input type="hidden" name="returnTo" value="mypage.jsp">
                <div class="d-flex justify-content-between align-items-center mt-2 mb-1">
                    <label style="font-size:12px; color:var(--text-muted);"><input type="checkbox" id="checkAll" style="margin-right:5px;">전체 선택</label>
                    <div class="d-flex gap-2">
                        <button type="button" id="btnDeleteSelected" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;" disabled>선택 삭제</button>
                        <button type="button" id="btnDeleteAll" class="btn-moa-outline btn-moa-sm" style="color:#991B1B; border-color:#991B1B;">전체 삭제</button>
                    </div>
                </div>
                <table class="table moa-table mt-1">
                    <thead><tr><th style="width:32px;"></th><th>날짜</th><th>총 매출</th><th>카드</th><th>현금</th><th>영수증</th></tr></thead>
                    <tbody>
                    <% if (salesList.isEmpty()) { %>
                        <tr><td colspan="6" class="text-center text-muted">아직 등록된 매출이 없어요</td></tr>
                    <% } else { for (int i = 0; i < Math.min(10, salesList.size()); i++) { SalesRecord r = salesList.get(i); %>
                        <tr>
                            <td><input type="checkbox" class="rowCheck" name="salesId" value="<%= r.getSalesId() %>"></td>
                            <td><%= r.getSalesDate() %></td><td><%= r.getTotalAmount() %>원</td><td><%= r.getCardAmount() %>원</td><td><%= r.getCashAmount() %>원</td>
                            <td><% if (r.getReceiptImage() != null) { %><a href="#" class="receiptViewBtn" data-src="<%= r.getReceiptImage() %>"><i class="bi bi-image"></i> 보기</a><% } else { %><span class="text-muted">-</span><% } %></td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </form>
            <% if (salesList.size() > 10) { %>
                <div class="text-end"><a href="stats.jsp" style="font-size:12.5px;">전체 기록 보기 →</a></div>
            <% } %>
        </div>
    <% } %>
    </main>
</div>

<!-- 영수증 이미지 팝업 -->
<div class="modal fade" id="receiptModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title" style="font-size:14px;"><i class="bi bi-image"></i> 영수증 원본</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>
            <div class="modal-body text-center">
                <img id="receiptModalImg" src="" alt="영수증" style="max-width:100%; border-radius:8px;">
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn-moa-outline btn-moa-sm" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<% if (!salesList.isEmpty()) { %>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
    var labels = [<% for (int i = Math.min(9, salesList.size()-1); i>=0; i--) { %>'<%= salesList.get(i).getSalesDate() %>'<%= i>0?",":"" %><% } %>];
    var values = [<% for (int i = Math.min(9, salesList.size()-1); i>=0; i--) { %><%= salesList.get(i).getTotalAmount() %><%= i>0?",":"" %><% } %>];
    new Chart(document.getElementById('salesChart'), {
        type: 'line',
        data: { labels: labels, datasets: [{ label: '매출', data: values, borderColor: '#4F46E5', backgroundColor: 'rgba(79,70,229,0.08)', fill: true, tension: 0.3 }] },
        options: {
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { ticks: { callback: function(v){ return '₩' + v.toLocaleString(); } } } }
        }
    });
</script>
<% } %>
<script>
    var checkAll = document.getElementById('checkAll');
    var rowChecks = document.querySelectorAll('.rowCheck');
    var btnDeleteSelected = document.getElementById('btnDeleteSelected');
    var btnDeleteAll = document.getElementById('btnDeleteAll');
    var deleteForm = document.getElementById('salesDeleteForm');
    var deleteAction = document.getElementById('salesDeleteAction');

    function updateSelectedBtn() {
        if (!btnDeleteSelected) return;
        var anyChecked = Array.from(rowChecks).some(function (c) { return c.checked; });
        btnDeleteSelected.disabled = !anyChecked;
    }
    if (checkAll) {
        checkAll.addEventListener('change', function () {
            rowChecks.forEach(function (c) { c.checked = checkAll.checked; });
            updateSelectedBtn();
        });
    }
    rowChecks.forEach(function (c) { c.addEventListener('change', updateSelectedBtn); });

    if (btnDeleteSelected) {
        btnDeleteSelected.addEventListener('click', function () {
            var count = Array.from(rowChecks).filter(function (c) { return c.checked; }).length;
            if (!confirm('선택한 ' + count + '건의 매출 기록을 삭제할까요?')) return;
            deleteAction.value = 'deleteSelected';
            deleteForm.submit();
        });
    }
    if (btnDeleteAll) {
        btnDeleteAll.addEventListener('click', function () {
            if (!confirm('이 매장의 매출 기록을 전부 삭제할까요? 이 작업은 되돌릴 수 없어요.')) return;
            deleteAction.value = 'deleteAll';
            deleteForm.submit();
        });
    }

    // 영수증 이미지 보기 팝업
    var receiptModalEl = document.getElementById('receiptModal');
    var receiptModal = receiptModalEl ? new bootstrap.Modal(receiptModalEl) : null;
    document.querySelectorAll('.receiptViewBtn').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            document.getElementById('receiptModalImg').src = btn.dataset.src;
            if (receiptModal) receiptModal.show();
        });
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
