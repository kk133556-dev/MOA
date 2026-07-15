<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList, java.time.YearMonth, java.time.LocalDate, java.time.DayOfWeek, com.moa.dao.EmployeeDAO, com.moa.model.Employee, com.moa.dao.WorkScheduleDAO, com.moa.model.WorkSchedule"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>직원 관리 / 근무 캘린더</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .cal-table { width:100%; border-collapse:collapse; table-layout:fixed; }
        .cal-table th { text-align:center; font-size:12px; color:var(--text-muted); padding:8px 0; }
        .cal-table td { border:1px solid var(--border); vertical-align:top; height:96px; padding:5px; font-size:11.5px; }
        .cal-day-num { font-weight:700; font-size:12px; margin-bottom:4px; }
        .cal-today { background:rgba(79,70,229,0.05); }
        .cal-outside { background:#FAFAFC; color:#D1D5DB; }
        .cal-badge { display:flex; align-items:center; justify-content:space-between; background:#EEF2FF; border-radius:5px; padding:2px 5px; margin-bottom:3px; font-size:10.5px; }
        .cal-badge .del-x { cursor:pointer; color:#DC2626; }
        .role-chip { font-size:9px; padding:1px 4px; border-radius:4px; margin-left:3px; }
        .role-알바 { background:#DBEAFE; color:#1D4ED8; }
        .role-직원 { background:#DCFCE7; color:#166534; }
        .role-점장 { background:#FEF3C7; color:#92400E; }
        .role-매니저 { background:#FCE7F3; color:#9D174D; }
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
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-people"></i> 직원 관리 / 근무 캘린더</h4>

        <div class="row g-3 mb-3">
            <div class="col-lg-4">
                <div class="moa-card mb-3">
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
                        <div class="mb-3"><label class="form-label" style="font-size:12px;">메모</label><input type="text" name="memo" class="form-control" placeholder="선택"></div>
                        <button type="submit" class="btn-moa w-100 justify-content-center">추가</button>
                    </form>
                </div>

                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-people-fill"></i> 직원 목록 (<%= employees.size() %>명)</h6>
                    <% if (employees.isEmpty()) { %>
                        <p class="text-muted text-center py-3 mb-0" style="font-size:13px;">등록된 직원이 없어요</p>
                    <% } else { for (Employee e : employees) { %>
                        <div class="d-flex justify-content-between align-items-center" style="padding:9px 2px; border-bottom:1px solid var(--border);">
                            <div>
                                <b style="font-size:13px;"><%= e.getName() %></b>
                                <span class="role-chip role-<%= e.getRole() %>"><%= e.getRole() %></span>
                                <% if (e.getPhone() != null && !e.getPhone().isEmpty()) { %><div style="font-size:11px; color:var(--text-muted);"><%= e.getPhone() %></div><% } %>
                            </div>
                            <form action="EmployeeServlet" method="post" onsubmit="return confirm('<%= e.getName() %> 직원을 삭제할까요? 근무 일정도 같이 지워져요.');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="employeeId" value="<%= e.getEmployeeId() %>">
                                <button type="submit" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;"><i class="bi bi-trash"></i></button>
                            </form>
                        </div>
                    <% } } %>
                </div>

                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-calendar-plus"></i> 근무 일정 추가</h6>
                    <% if (employees.isEmpty()) { %>
                        <p class="text-muted" style="font-size:12.5px;">먼저 직원을 등록해주세요.</p>
                    <% } else { %>
                        <form id="scheduleForm">
                            <div class="mb-2">
                                <label class="form-label" style="font-size:12px;">직원</label>
                                <select id="schedEmployee" class="form-control">
                                    <% for (Employee e : employees) { %><option value="<%= e.getEmployeeId() %>"><%= e.getName() %> (<%= e.getRole() %>)</option><% } %>
                                </select>
                            </div>
                            <div class="mb-2"><label class="form-label" style="font-size:12px;">날짜</label><input type="date" id="schedDate" class="form-control" value="<%= today %>"></div>
                            <div class="row g-2 mb-2">
                                <div class="col-6"><label class="form-label" style="font-size:12px;">시작</label><input type="time" id="schedStart" class="form-control"></div>
                                <div class="col-6"><label class="form-label" style="font-size:12px;">종료</label><input type="time" id="schedEnd" class="form-control"></div>
                            </div>
                            <div class="mb-3"><input type="text" id="schedMemo" class="form-control" placeholder="메모 (선택)"></div>
                            <button type="button" id="addSchedBtn" class="btn-moa w-100 justify-content-center">근무 일정 추가</button>
                        </form>
                    <% } %>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="moa-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <a href="staff.jsp?ym=<%= prevYm %>" class="btn-moa-outline btn-moa-sm"><i class="bi bi-chevron-left"></i></a>
                        <h6 class="mb-0"><%= ym.getYear() %>년 <%= ym.getMonthValue() %>월</h6>
                        <a href="staff.jsp?ym=<%= nextYm %>" class="btn-moa-outline btn-moa-sm"><i class="bi bi-chevron-right"></i></a>
                    </div>
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
                                    <td class="<%= isToday ? "cal-today" : "" %>" data-date="<%= cellDate %>">
                                        <div class="cal-day-num"><%= dayCounter %></div>
                                        <% if (daySched != null) { for (WorkSchedule w : daySched) { %>
                                            <div class="cal-badge">
                                                <span><%= w.getEmployeeName() %><% if (w.getShiftStart() != null) { %> <%= w.getShiftStart() %><% } %></span>
                                                <i class="bi bi-x del-x" data-id="<%= w.getScheduleId() %>"></i>
                                            </div>
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
    </main>
</div>

<script>
    var currentYm = '<%= ymStr %>';

    document.getElementById('addSchedBtn') && document.getElementById('addSchedBtn').addEventListener('click', function () {
        var params = new URLSearchParams();
        params.append('action', 'add');
        params.append('employeeId', document.getElementById('schedEmployee').value);
        params.append('workDate', document.getElementById('schedDate').value);
        params.append('shiftStart', document.getElementById('schedStart').value);
        params.append('shiftEnd', document.getElementById('schedEnd').value);
        params.append('memo', document.getElementById('schedMemo').value);
        if (!params.get('workDate')) { alert('날짜를 선택해주세요.'); return; }
        fetch('WorkScheduleServlet', { method: 'POST', body: params })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.result === 'ok') {
                    var targetYm = params.get('workDate').substring(0, 7);
                    location.href = 'staff.jsp?ym=' + targetYm;
                } else {
                    alert('추가에 실패했어요.');
                }
            });
    });

    document.querySelectorAll('.del-x').forEach(function (el) {
        el.addEventListener('click', function () {
            if (!confirm('이 근무 일정을 삭제할까요?')) return;
            var params = new URLSearchParams();
            params.append('action', 'delete');
            params.append('scheduleId', el.dataset.id);
            fetch('WorkScheduleServlet', { method: 'POST', body: params })
                .then(function () { location.href = 'staff.jsp?ym=' + currentYm; });
        });
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
