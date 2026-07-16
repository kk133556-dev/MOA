<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList, java.time.YearMonth, java.time.LocalDate, java.time.DayOfWeek, com.moa.dao.EmployeeDAO, com.moa.model.Employee, com.moa.dao.WorkScheduleDAO, com.moa.model.WorkSchedule"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>직원 관리 / 근무 캘린더</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .cal-table { width:100%; border-collapse:collapse; table-layout:fixed; }
        .cal-table th { text-align:center; font-size:12px; color:var(--text-muted); padding:8px 0; }
        .cal-table td { border:1px solid var(--border); vertical-align:top; height:96px; padding:5px; font-size:11.5px; cursor:pointer; transition:background .15s ease; }
        .cal-table td.cal-day:hover { background:rgba(79,70,229,0.06); }
        .cal-day-num { font-weight:700; font-size:12px; margin-bottom:4px; }
        .cal-today { background:rgba(79,70,229,0.05); }
        .cal-outside { background:#FAFAFC; color:#D1D5DB; cursor:default; }
        .cal-badge { background:#EEF2FF; border-radius:5px; padding:2px 5px; margin-bottom:3px; font-size:10.5px; }
        .role-chip { font-size:9px; padding:1px 4px; border-radius:4px; margin-left:3px; }
        .role-알바 { background:#DBEAFE; color:#1D4ED8; }
        .role-직원 { background:#DCFCE7; color:#166534; }
        .role-점장 { background:#FEF3C7; color:#92400E; }
        .role-매니저 { background:#FCE7F3; color:#9D174D; }

        /* 앱 전용 미니 캘린더 */
        .cal-table-app { width:100%; border-collapse:collapse; table-layout:fixed; }
        .cal-table-app th { text-align:center; font-size:10.5px; color:#8b87a3; padding:6px 0; font-weight:600; }
        .cal-table-app td { text-align:center; vertical-align:middle; height:42px; font-size:11.5px; cursor:pointer; position:relative; border-radius:8px; }
        .cal-table-app td.cal-day-app:active { background:#F3F0FF; }
        .cal-table-app td.cal-today-app { background:#8B5CF6; color:#fff; font-weight:800; border-radius:50%; }
        .cal-table-app td.cal-outside-app { color:#D1D5DB; cursor:default; }
        .cal-dot-wrap { display:flex; justify-content:center; gap:2px; margin-top:2px; }
        .cal-dot { width:5px; height:5px; border-radius:50%; background:#8B5CF6; }
        .cal-today-app .cal-dot { background:#fff; }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    String currentMenu = "staff";

    EmployeeDAO empDao = new EmployeeDAO();
    List<Employee> employees = empDao.listByStore(storeId);

    String ymParam = request.getParameter("ym");
    YearMonth ym = (ymParam != null && ymParam.matches("\\d{4}-\\d{2}")) ? YearMonth.parse(ymParam) : YearMonth.now();
    String ymStr = ym.toString();
    String prevYm = ym.minusMonths(1).toString();
    String nextYm = ym.plusMonths(1).toString();

    WorkScheduleDAO schedDao = new WorkScheduleDAO();
    List<WorkSchedule> schedules = schedDao.listByMonth(storeId, ymStr);
    Map<String, List<WorkSchedule>> byDate = new HashMap<>();
    for (WorkSchedule w : schedules) {
        byDate.computeIfAbsent(w.getWorkDate(), k -> new ArrayList<>()).add(w);
    }

    LocalDate firstOfMonth = ym.atDay(1);
    int leadBlanks = firstOfMonth.getDayOfWeek() == DayOfWeek.SUNDAY ? 0 : firstOfMonth.getDayOfWeek().getValue();
    int daysInMonth = ym.lengthOfMonth();
    String today = LocalDate.now().toString();
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 직원관리 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div style="font-size:19px; font-weight:800; color:#1E1B2E; margin-bottom:16px;"><i class="bi bi-people"></i> 직원 관리</div>

            <button type="button" data-bs-toggle="offcanvas" data-bs-target="#empAddSheet" style="width:100%; background:#8B5CF6; color:#fff; border:none; border-radius:14px; padding:14px; font-weight:700; font-size:14px; margin-bottom:18px;">
                <i class="bi bi-person-plus"></i> 직원 추가
            </button>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">직원 목록 (<%= employees.size() %>명)</div>
            <% if (employees.isEmpty()) { %>
                <div style="text-align:center; padding:24px 0; color:#8b87a3; font-size:12.5px; margin-bottom:16px;">등록된 직원이 없어요</div>
            <% } else { for (Employee e : employees) { %>
                <div class="emp-row" data-emp-id="<%= e.getEmployeeId() %>" style="background:#fff; border-radius:12px; padding:12px 14px; margin-bottom:8px; display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <b style="font-size:13.5px; color:#1E1B2E;"><%= e.getName() %></b>
                        <span class="role-chip role-<%= e.getRole() %>"><%= e.getRole() %></span>
                        <% if (e.getPhone() != null && !e.getPhone().isEmpty()) { %><div style="font-size:11.5px; color:#8b87a3; margin-top:2px;"><%= e.getPhone() %></div><% } %>
                        <% if (e.getMemo() != null && !e.getMemo().isEmpty()) { %><div style="font-size:11px; color:#8b87a3;"><i class="bi bi-sticky"></i> <%= e.getMemo() %></div><% } %>
                    </div>
                    <div class="d-flex align-items-center gap-1">
                        <button type="button" class="btn-moa-outline btn-moa-sm" title="정보 수정"><i class="bi bi-pencil"></i></button>
                        <form action="EmployeeServlet" method="post" onsubmit="event.stopPropagation(); return confirm('<%= e.getName() %> 직원을 삭제할까요?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="employeeId" value="<%= e.getEmployeeId() %>">
                            <button type="submit" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;" onclick="event.stopPropagation();"><i class="bi bi-trash"></i></button>
                        </form>
                    </div>
                </div>
            <% } } %>

            <div style="background:#fff; border-radius:16px; padding:14px; margin-top:18px;">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <a href="staff.jsp?ym=<%= prevYm %>" style="color:#1E1B2E; font-size:16px;"><i class="bi bi-chevron-left"></i></a>
                    <div style="font-size:13.5px; font-weight:700; color:#1E1B2E;"><%= ym.getYear() %>년 <%= ym.getMonthValue() %>월</div>
                    <a href="staff.jsp?ym=<%= nextYm %>" style="color:#1E1B2E; font-size:16px;"><i class="bi bi-chevron-right"></i></a>
                </div>
                <% if (employees.isEmpty()) { %>
                    <div style="font-size:11px; color:#F59E0B; margin-bottom:8px;"><i class="bi bi-exclamation-triangle"></i> 직원 등록 후 날짜를 눌러 근무를 배정할 수 있어요.</div>
                <% } %>
                <table class="cal-table-app">
                    <thead><tr><th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th></tr></thead>
                    <tbody>
                    <%
                        int dayCounterApp = 1;
                        int totalCellsApp = leadBlanks + daysInMonth;
                        int totalRowsApp = (int) Math.ceil(totalCellsApp / 7.0);
                        for (int row = 0; row < totalRowsApp; row++) {
                    %>
                        <tr>
                        <% for (int col = 0; col < 7; col++) {
                            int cellIndex = row * 7 + col;
                            if (cellIndex < leadBlanks || dayCounterApp > daysInMonth) { %>
                                <td class="cal-outside-app"></td>
                            <% } else {
                                String cellDate = ym.atDay(dayCounterApp).toString();
                                boolean isToday = cellDate.equals(today);
                                List<WorkSchedule> daySched = byDate.get(cellDate);
                        %>
                                <td class="cal-day-app <%= isToday ? "cal-today-app" : "" %>" data-date="<%= cellDate %>">
                                    <%= dayCounterApp %>
                                    <% if (daySched != null && !daySched.isEmpty()) { %>
                                        <div class="cal-dot-wrap"><span class="cal-dot"></span></div>
                                    <% } %>
                                </td>
                            <% dayCounterApp++; } %>
                        <% } %>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="offcanvas offcanvas-bottom" tabindex="-1" id="empAddSheet" style="border-radius:20px 20px 0 0; max-height:88vh;">
            <div class="offcanvas-header">
                <h6 class="offcanvas-title"><i class="bi bi-person-plus"></i> 직원 추가</h6>
                <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
            </div>
            <div class="offcanvas-body">
                <form action="EmployeeServlet" method="post">
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">이름</label><input type="text" name="name" class="form-control" required></div>
                    <div class="mb-2">
                        <label class="form-label" style="font-size:12px;">직책</label>
                        <select name="role" class="form-control">
                            <option value="알바">알바</option>
                            <option value="직원">직원</option>
                            <option value="점장">점장</option>
                            <option value="매니저">매니저</option>
                        </select>
                    </div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">연락처</label><input type="text" name="phone" class="form-control" placeholder="010-0000-0000"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">집주소</label><input type="text" name="address" class="form-control" placeholder="선택"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 성함</label><input type="text" name="guardianName" class="form-control" placeholder="선택"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 전화번호</label><input type="text" name="guardianPhone" class="form-control" placeholder="010-0000-0000"></div>
                    <div class="mb-3"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" class="form-control" placeholder="선택"></div>
                    <button type="submit" class="btn-moa w-100 justify-content-center">추가</button>
                </form>
            </div>
        </div>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 화면 ===================== -->
        <div class="p-4">
        <h4 class="mb-4"><i class="bi bi-people"></i> 직원 관리 / 근무 캘린더</h4>

        <div class="row g-3 mb-3">
            <div class="col-lg-4">
                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-person-plus"></i> 직원 추가</h6>
                    <form action="EmployeeServlet" method="post">
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">이름</label><input type="text" name="name" class="form-control" required></div>
                        <div class="mb-2">
                            <label class="form-label" style="font-size:12px;">직책</label>
                            <select name="role" class="form-control">
                                <option value="알바">알바</option>
                                <option value="직원">직원</option>
                                <option value="점장">점장</option>
                                <option value="매니저">매니저</option>
                            </select>
                        </div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">연락처</label><input type="text" name="phone" class="form-control" placeholder="010-0000-0000"></div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">집주소</label><input type="text" name="address" class="form-control" placeholder="선택"></div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 성함</label><input type="text" name="guardianName" class="form-control" placeholder="선택"></div>
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 전화번호</label><input type="text" name="guardianPhone" class="form-control" placeholder="010-0000-0000"></div>
                        <div class="mb-3"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" class="form-control" placeholder="선택"></div>
                        <button type="submit" class="btn-moa w-100 justify-content-center">추가</button>
                    </form>
                </div>
                <div class="moa-card mt-3">
                    <h6 class="mb-3"><i class="bi bi-people-fill"></i> 직원 목록 (<%= employees.size() %>명)</h6>
                    <% if (employees.isEmpty()) { %>
                        <p class="text-muted text-center py-3 mb-0" style="font-size:13px;">등록된 직원이 없어요</p>
                    <% } else { for (Employee e : employees) { %>
                        <div class="d-flex justify-content-between align-items-center emp-row" data-emp-id="<%= e.getEmployeeId() %>" style="padding:9px 2px; border-bottom:1px solid var(--border); cursor:pointer;">
                            <div>
                                <b style="font-size:13px;"><%= e.getName() %></b>
                                <span class="role-chip role-<%= e.getRole() %>"><%= e.getRole() %></span>
                                <% if (e.getPhone() != null && !e.getPhone().isEmpty()) { %><div style="font-size:11px; color:var(--text-muted);"><%= e.getPhone() %></div><% } %>
                                <% if (e.getMemo() != null && !e.getMemo().isEmpty()) { %><div style="font-size:11px; color:var(--text-muted);"><i class="bi bi-sticky"></i> <%= e.getMemo() %></div><% } %>
                            </div>
                            <div class="d-flex align-items-center gap-1">
                                <button type="button" class="btn-moa-outline btn-moa-sm" title="정보 수정"><i class="bi bi-pencil"></i></button>
                                <form action="EmployeeServlet" method="post" onsubmit="event.stopPropagation(); return confirm('<%= e.getName() %> 직원을 삭제할까요? 근무 일정도 같이 지워져요.');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="employeeId" value="<%= e.getEmployeeId() %>">
                                    <button type="submit" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;" onclick="event.stopPropagation();"><i class="bi bi-trash"></i></button>
                                </form>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="moa-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <a href="staff.jsp?ym=<%= prevYm %>" class="btn-moa-outline btn-moa-sm"><i class="bi bi-chevron-left"></i></a>
                        <h6 class="mb-0"><%= ym.getYear() %>년 <%= ym.getMonthValue() %>월</h6>
                        <a href="staff.jsp?ym=<%= nextYm %>" class="btn-moa-outline btn-moa-sm"><i class="bi bi-chevron-right"></i></a>
                    </div>
                    <% if (employees.isEmpty()) { %>
                        <div class="alert alert-warning py-2 mb-3" style="font-size:12.5px;"><i class="bi bi-exclamation-triangle"></i> 먼저 왼쪽에서 직원을 등록해야 날짜 클릭으로 근무를 배정할 수 있어요.</div>
                    <% } %>
                    <p style="font-size:11.5px; color:var(--text-muted);"><i class="bi bi-info-circle"></i> 날짜를 클릭하면 그 날짜에 근무자를 바로 배정할 수 있어요.</p>
                    <table class="cal-table">
                        <thead><tr><th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th></tr></thead>
                        <tbody>
                        <%
                            int dayCounter = 1;
                            int totalCells = leadBlanks + daysInMonth;
                            int totalRows = (int) Math.ceil(totalCells / 7.0);
                            for (int row = 0; row < totalRows; row++) {
                        %>
                            <tr>
                            <% for (int col = 0; col < 7; col++) {
                                int cellIndex = row * 7 + col;
                                if (cellIndex < leadBlanks || dayCounter > daysInMonth) { %>
                                    <td class="cal-outside"></td>
                                <% } else {
                                    String cellDate = ym.atDay(dayCounter).toString();
                                    boolean isToday = cellDate.equals(today);
                                    List<WorkSchedule> daySched = byDate.get(cellDate);
                            %>
                                    <td class="cal-day <%= isToday ? "cal-today" : "" %>" data-date="<%= cellDate %>">
                                        <div class="cal-day-num"><%= dayCounter %></div>
                                        <% if (daySched != null) { for (WorkSchedule w : daySched) { %>
                                            <div class="cal-badge"><%= w.getEmployeeName() %><% if (w.getShiftStart() != null) { %> <%= w.getShiftStart() %><% } %></div>
                                        <% } } %>
                                    </td>
                                <% dayCounter++; } %>
                            <% } %>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        </div>
    <% } %>
    </main>
</div>

<% if (isApp) { %>
<!-- 앱: 직원 정보 수정 (바텀시트) -->
<div class="offcanvas offcanvas-bottom" tabindex="-1" id="empDetailModal" style="border-radius:20px 20px 0 0; max-height:88vh;">
    <div class="offcanvas-header">
        <h6 class="offcanvas-title"><i class="bi bi-person-badge"></i> 직원 정보 수정</h6>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <form action="EmployeeServlet" method="post">
        <div class="offcanvas-body" style="font-size:13px;">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="employeeId" id="empEditId">
            <div class="mb-2"><label class="form-label" style="font-size:12px;">이름</label><input type="text" name="name" id="empEditName" class="form-control" required></div>
            <div class="mb-2">
                <label class="form-label" style="font-size:12px;">직책</label>
                <select name="role" id="empEditRole" class="form-control">
                    <option value="알바">알바</option>
                    <option value="직원">직원</option>
                    <option value="점장">점장</option>
                    <option value="매니저">매니저</option>
                </select>
            </div>
            <div class="mb-2"><label class="form-label" style="font-size:12px;">연락처</label><input type="text" name="phone" id="empEditPhone" class="form-control" placeholder="010-0000-0000"></div>
            <div class="mb-2"><label class="form-label" style="font-size:12px;">집주소</label><input type="text" name="address" id="empEditAddress" class="form-control"></div>
            <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 성함</label><input type="text" name="guardianName" id="empEditGuardianName" class="form-control"></div>
            <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 전화번호</label><input type="text" name="guardianPhone" id="empEditGuardianPhone" class="form-control" placeholder="010-0000-0000"></div>
            <div class="mb-3"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" id="empEditMemo" class="form-control"></div>
            <button type="submit" class="btn-moa w-100 justify-content-center">저장</button>
        </div>
    </form>
</div>

<!-- 앱: 날짜 클릭 시 뜨는 근무 배정 (바텀시트, 폰 캘린더처럼) -->
<div class="offcanvas offcanvas-bottom" tabindex="-1" id="dayModal" style="border-radius:20px 20px 0 0; max-height:88vh;">
    <div class="offcanvas-header">
        <h6 class="offcanvas-title" id="dayModalTitle"><i class="bi bi-calendar-event"></i> 근무 배정</h6>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body">
        <div id="dayScheduleList" class="mb-3"></div>
        <select id="modalEmployee" class="form-control mb-2">
            <% for (Employee e : employees) { %><option value="<%= e.getEmployeeId() %>"><%= e.getName() %> (<%= e.getRole() %>)</option><% } %>
        </select>
        <div class="row g-2 mb-2">
            <div class="col-6"><input type="time" id="modalStart" class="form-control" placeholder="출근"></div>
            <div class="col-6"><input type="time" id="modalEnd" class="form-control" placeholder="퇴근"></div>
        </div>
        <input type="text" id="modalMemo" class="form-control mb-3" placeholder="메모 (선택)">
        <button type="button" id="modalAddBtn" class="btn-moa w-100 justify-content-center">저장</button>
    </div>
</div>
<% } else { %>
<!-- 직원 정보 수정 모달 -->
<div class="modal fade" id="empDetailModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title"><i class="bi bi-person-badge"></i> 직원 정보 수정</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="EmployeeServlet" method="post">
                <div class="modal-body" style="font-size:13px;">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="employeeId" id="empEditId">
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">이름</label><input type="text" name="name" id="empEditName" class="form-control form-control-sm" required></div>
                    <div class="mb-2">
                        <label class="form-label" style="font-size:12px;">직책</label>
                        <select name="role" id="empEditRole" class="form-control form-control-sm">
                            <option value="알바">알바</option>
                            <option value="직원">직원</option>
                            <option value="점장">점장</option>
                            <option value="매니저">매니저</option>
                        </select>
                    </div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">연락처</label><input type="text" name="phone" id="empEditPhone" class="form-control form-control-sm" placeholder="010-0000-0000"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">집주소</label><input type="text" name="address" id="empEditAddress" class="form-control form-control-sm"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 성함</label><input type="text" name="guardianName" id="empEditGuardianName" class="form-control form-control-sm"></div>
                    <div class="mb-2"><label class="form-label" style="font-size:12px;">보호자 전화번호</label><input type="text" name="guardianPhone" id="empEditGuardianPhone" class="form-control form-control-sm" placeholder="010-0000-0000"></div>
                    <div class="mb-0"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" id="empEditMemo" class="form-control form-control-sm"></div>
                </div>
                <div class="modal-footer py-2">
                    <button type="button" class="btn-moa-outline btn-moa-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn-moa btn-moa-sm">저장</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 날짜 클릭 시 뜨는 근무 배정 모달 -->
<div class="modal fade" id="dayModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title" id="dayModalTitle"><i class="bi bi-calendar-event"></i> 근무 배정</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <h6 class="mb-2" style="font-size:13px;">이 날 근무자</h6>
                <div id="dayScheduleList" class="mb-3"></div>
                <hr>
                <h6 class="mb-2" style="font-size:13px;"><i class="bi bi-plus-circle"></i> 근무자 추가</h6>
                <div class="row g-2 mb-2">
                    <div class="col-6">
                        <select id="modalEmployee" class="form-control form-control-sm">
                            <% for (Employee e : employees) { %><option value="<%= e.getEmployeeId() %>"><%= e.getName() %> (<%= e.getRole() %>)</option><% } %>
                        </select>
                    </div>
                    <div class="col-3"><input type="time" id="modalStart" class="form-control form-control-sm"></div>
                    <div class="col-3"><input type="time" id="modalEnd" class="form-control form-control-sm"></div>
                </div>
                <input type="text" id="modalMemo" class="form-control form-control-sm mb-2" placeholder="메모 (선택)">
                <button type="button" id="modalAddBtn" class="btn-moa w-100 justify-content-center btn-moa-sm">이 날짜에 추가</button>
            </div>
        </div>
    </div>
</div>
<% } %>

<script>
    if (typeof bootstrap === 'undefined') {
        document.write('<scr' + 'ipt src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></scr' + 'ipt>');
    }
</script>
<script>
    var employeeData = {};
    <% for (Employee e : employees) { %>
        employeeData[<%= e.getEmployeeId() %>] = {
            name: '<%= e.getName().replace("'", "\\'") %>',
            role: '<%= e.getRole() %>',
            phone: '<%= e.getPhone() != null ? e.getPhone().replace("'", "\\'") : "" %>',
            address: '<%= e.getAddress() != null ? e.getAddress().replace("'", "\\'") : "" %>',
            memo: '<%= e.getMemo() != null ? e.getMemo().replace("'", "\\'") : "" %>',
            guardianName: '<%= e.getGuardianName() != null ? e.getGuardianName().replace("'", "\\'") : "" %>',
            guardianPhone: '<%= e.getGuardianPhone() != null ? e.getGuardianPhone().replace("'", "\\'") : "" %>'
        };
    <% } %>

    document.addEventListener('DOMContentLoaded', function () {
        var isAppPage = <%= isApp %>;
        var empDetailEl = document.getElementById('empDetailModal');
        var empDetailModal = isAppPage ? new bootstrap.Offcanvas(empDetailEl) : new bootstrap.Modal(empDetailEl);
        document.querySelectorAll('.emp-row').forEach(function (row) {
            row.addEventListener('click', function () {
                var emp = employeeData[row.dataset.empId];
                if (!emp) return;
                document.getElementById('empEditId').value = row.dataset.empId;
                document.getElementById('empEditName').value = emp.name || '';
                document.getElementById('empEditRole').value = emp.role || '알바';
                document.getElementById('empEditPhone').value = emp.phone || '';
                document.getElementById('empEditAddress').value = emp.address || '';
                document.getElementById('empEditGuardianName').value = emp.guardianName || '';
                document.getElementById('empEditGuardianPhone').value = emp.guardianPhone || '';
                document.getElementById('empEditMemo').value = emp.memo || '';
                empDetailModal.show();
            });
        });
    });

    var scheduleData = {};
    <%
        for (Map.Entry<String, List<WorkSchedule>> entry : byDate.entrySet()) {
    %>
        scheduleData['<%= entry.getKey() %>'] = [
        <% List<WorkSchedule> list = entry.getValue();
           for (int i = 0; i < list.size(); i++) { WorkSchedule w = list.get(i); %>
            { id: <%= w.getScheduleId() %>, name: '<%= w.getEmployeeName() %>', role: '<%= w.getEmployeeRole() %>', start: '<%= w.getShiftStart() != null ? w.getShiftStart() : "" %>', end: '<%= w.getShiftEnd() != null ? w.getShiftEnd() : "" %>' }<%= i < list.size()-1 ? "," : "" %>
        <% } %>
        ];
    <% } %>

    document.addEventListener('DOMContentLoaded', function () {
        var isAppPage2 = <%= isApp %>;
        var dayModalEl = document.getElementById('dayModal');
        var dayModal = isAppPage2 ? new bootstrap.Offcanvas(dayModalEl) : new bootstrap.Modal(dayModalEl);
        var currentDate = null;

        function renderDaySchedule(dateStr) {
            var list = scheduleData[dateStr] || [];
            var container = document.getElementById('dayScheduleList');
            if (list.length === 0) {
                container.innerHTML = '<p class="text-muted text-center py-2 mb-0" style="font-size:12.5px;">배정된 근무자가 없어요</p>';
                return;
            }
            container.innerHTML = '';
            list.forEach(function (item) {
                var row = document.createElement('div');
                row.className = 'd-flex justify-content-between align-items-center';
                row.style.cssText = 'padding:6px 2px; border-bottom:1px solid var(--border);';
                row.innerHTML = '<span style="font-size:13px;">' + item.name + ' <span class="role-chip role-' + item.role + '">' + item.role + '</span>' +
                    (item.start ? ' <span style="color:var(--text-muted); font-size:11.5px;">' + item.start + (item.end ? '~' + item.end : '') + '</span>' : '') + '</span>' +
                    '<i class="bi bi-trash" style="cursor:pointer; color:#DC2626;" data-id="' + item.id + '"></i>';
                row.querySelector('.bi-trash').addEventListener('click', function () {
                    if (!confirm('삭제할까요?')) return;
                    var params = new URLSearchParams();
                    params.append('action', 'delete');
                    params.append('scheduleId', item.id);
                    fetch('WorkScheduleServlet', { method: 'POST', body: params }).then(function () { location.reload(); });
                });
                container.appendChild(row);
            });
        }

        document.querySelectorAll('.cal-day, .cal-day-app').forEach(function (td) {
            td.addEventListener('click', function () {
                currentDate = td.dataset.date;
                document.getElementById('dayModalTitle').innerHTML = '<i class="bi bi-calendar-event"></i> ' + currentDate + ' 근무 배정';
                renderDaySchedule(currentDate);
                dayModal.show();
            });
        });

        var modalAddBtn = document.getElementById('modalAddBtn');
        if (modalAddBtn) {
            modalAddBtn.addEventListener('click', function () {
                var empSelect = document.getElementById('modalEmployee');
                if (!empSelect || !empSelect.value) { alert('직원을 먼저 등록해주세요.'); return; }
                var params = new URLSearchParams();
                params.append('action', 'add');
                params.append('employeeId', empSelect.value);
                params.append('workDate', currentDate);
                params.append('shiftStart', document.getElementById('modalStart').value);
                params.append('shiftEnd', document.getElementById('modalEnd').value);
                params.append('memo', document.getElementById('modalMemo').value);
                fetch('WorkScheduleServlet', { method: 'POST', body: params })
                    .then(function (r) { return r.json(); })
                    .then(function () { location.href = 'staff.jsp?ym=' + currentDate.substring(0, 7); });
            });
        }
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
