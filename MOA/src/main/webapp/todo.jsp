<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.TodoDAO, com.moa.model.Todo, com.moa.dao.QuickTodoDAO, com.moa.model.QuickTodo"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>다이어리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    List<Todo> todos = new TodoDAO().listByStore(storeId);
    int doneCount = 0;
    for (Todo t : todos) if (t.isDone()) doneCount++;
    int totalCount = todos.size();
    int rate = totalCount == 0 ? 0 : (int) Math.round(doneCount * 100.0 / totalCount);
    List<QuickTodo> quickTodos = new QuickTodoDAO().listByStore(storeId);
    String currentMenu = "todo";
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-journal-check"></i> 다이어리</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" id="kpiTotal"><%= totalCount %></div><div class="kpi-label">전체 할 일</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#16A34A;" id="kpiDone"><%= doneCount %></div><div class="kpi-label">완료</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#DC2626;" id="kpiPending"><%= totalCount - doneCount %></div><div class="kpi-label">미완료</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" id="kpiRate"><%= rate %>%</div><div class="kpi-label">완료율</div></div></div>
        </div>

        <div class="row g-3">
            <div class="col-lg-6">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-plus-circle"></i> 할 일 추가</h6>
                    <input type="text" id="todoInput" class="form-control mb-2" placeholder="할 일을 입력하고 엔터">
                    <button id="addBtn" class="btn-moa w-100 justify-content-center mb-3">체크리스트에 추가</button>
                    <div class="progress mb-3" style="height:8px; border-radius:6px;">
                        <div class="progress-bar" id="progressBar" role="progressbar" style="width:<%= rate %>%; background:linear-gradient(135deg, var(--primary), var(--accent));"></div>
                    </div>

                    <h6 class="mb-2" style="font-size:13px;"><i class="bi bi-lightning-charge"></i> 자주 쓰는 할 일 (눌러서 바로 추가, x로 삭제)</h6>
                    <div class="d-flex flex-wrap gap-2" id="quickList">
                        <% for (QuickTodo q : quickTodos) { %>
                        <span class="quick-add" data-id="<%= q.getQuickId() %>" data-text="<%= q.getLabel() %>">
                            <%= q.getLabel() %> <i class="bi bi-x quick-del" data-id="<%= q.getQuickId() %>"></i>
                        </span>
                        <% } %>
                        <span class="quick-add-new" id="quickAddNewBtn"><i class="bi bi-plus"></i> 새 항목</span>
                    </div>
                </div>

                <div class="moa-card">
                    <h6 class="mb-2"><i class="bi bi-info-circle"></i> 다이어리 활용 팁</h6>
                    <p style="font-size:12.5px; color:var(--text-muted); line-height:1.8; margin-bottom:0;">
                        매일 반복하는 마감 루틴(매출 등록, 재고 확인, 정산 등)을 다이어리에 등록해두면
                        빠뜨리지 않고 챙길 수 있어요. 완료율이 낮은 날이 이어지면 운영 루틴을 점검해보는 것도 좋아요.
                    </p>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="moa-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="mb-0"><i class="bi bi-check2-square"></i> 오늘의 체크리스트</h6>
                        <div class="d-flex" style="background:#f0f0f0; border-radius:8px; padding:3px;">
                            <div class="filter-tab active" data-filter="all" style="padding:5px 12px; border-radius:6px; cursor:pointer; font-size:12px; background:var(--navy); color:#fff;">전체</div>
                            <div class="filter-tab" data-filter="pending" style="padding:5px 12px; border-radius:6px; cursor:pointer; font-size:12px; color:#374151;">미완료</div>
                            <div class="filter-tab" data-filter="done" style="padding:5px 12px; border-radius:6px; cursor:pointer; font-size:12px; color:#374151;">완료</div>
                        </div>
                    </div>
                    <ul id="todoList" style="list-style:none; padding:0; margin:0;">
                        <% for (Todo t : todos) { %>
                        <li data-id="<%= t.getTodoId() %>" data-done="<%= t.isDone() %>" class="d-flex align-items-center gap-2" style="padding:12px 4px; border-bottom:1px solid var(--border);">
                            <input type="checkbox" class="doneCheck" <%= t.isDone() ? "checked" : "" %> style="width:18px; height:18px;">
                            <span style="flex:1; <%= t.isDone() ? "text-decoration:line-through; color:#9ca3af;" : "" %>"><%= t.getContent() %></span>
                            <i class="bi bi-trash delBtn" style="cursor:pointer; color:#DC2626;"></i>
                        </li>
                        <% } %>
                    </ul>
                    <p id="emptyMsg" class="text-muted text-center py-4 mb-0" style="<%= todos.isEmpty() ? "" : "display:none;" %>">할 일을 추가해보세요</p>
                </div>
            </div>
        </div>
    </main>
</div>

<style>
    .quick-add { font-size:11.5px; background:#F3F4F6; border:1px solid var(--border); padding:6px 10px; border-radius:14px; cursor:pointer; display:inline-flex; align-items:center; gap:4px; }
    .quick-add:hover { background:var(--primary); color:#fff; border-color:var(--primary); }
    .quick-add .quick-del { font-size:13px; opacity:0.6; }
    .quick-add .quick-del:hover { opacity:1; color:#DC2626; }
    .quick-add-new { font-size:11.5px; background:#fff; border:1.5px dashed var(--border); padding:6px 10px; border-radius:14px; cursor:pointer; color:var(--primary); font-weight:600; }
    .quick-add-new:hover { border-color:var(--primary); background:rgba(79,70,229,0.05); }
</style>

<script>
    var list = document.getElementById('todoList');
    var emptyMsg = document.getElementById('emptyMsg');

    function updateKpis() {
        var items = list.querySelectorAll('li');
        var total = items.length;
        var done = list.querySelectorAll('.doneCheck:checked').length;
        var rate = total === 0 ? 0 : Math.round(done * 100 / total);
        document.getElementById('kpiTotal').textContent = total;
        document.getElementById('kpiDone').textContent = done;
        document.getElementById('kpiPending').textContent = total - done;
        document.getElementById('kpiRate').textContent = rate + '%';
        document.getElementById('progressBar').style.width = rate + '%';
    }

    function applyFilter() {
        var active = document.querySelector('.filter-tab.active').dataset.filter;
        var items = list.querySelectorAll('li');
        var visibleCount = 0;
        items.forEach(function (li) {
            var isDone = li.querySelector('.doneCheck').checked;
            var show = active === 'all' || (active === 'done' && isDone) || (active === 'pending' && !isDone);
            li.style.display = show ? 'flex' : 'none';
            if (show) visibleCount++;
        });
        emptyMsg.style.display = (items.length === 0) ? 'block' : (visibleCount === 0 ? 'block' : 'none');
        emptyMsg.textContent = items.length === 0 ? '할 일을 추가해보세요' : '해당하는 항목이 없어요';
    }

    document.querySelectorAll('.filter-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            document.querySelectorAll('.filter-tab').forEach(function (t) {
                t.classList.remove('active'); t.style.background = 'transparent'; t.style.color = '#374151';
            });
            tab.classList.add('active'); tab.style.background = 'var(--navy)'; tab.style.color = '#fff';
            applyFilter();
        });
    });

    function bindItem(li) {
        li.querySelector('.doneCheck').addEventListener('change', function () {
            var span = li.querySelector('span');
            span.style.textDecoration = this.checked ? 'line-through' : 'none';
            span.style.color = this.checked ? '#9ca3af' : '';
            postAction('toggle', li.dataset.id);
            updateKpis();
            applyFilter();
        });
        li.querySelector('.delBtn').addEventListener('click', function () {
            postAction('delete', li.dataset.id);
            li.remove();
            updateKpis();
            applyFilter();
        });
    }
    document.querySelectorAll('#todoList li').forEach(bindItem);

    function postAction(action, todoId) {
        var params = new URLSearchParams();
        params.append('action', action);
        if (todoId) params.append('todoId', todoId);
        return fetch('TodoServlet', { method: 'POST', body: params });
    }

    function addTodo(presetText) {
        var input = document.getElementById('todoInput');
        var text = presetText || input.value.trim();
        if (!text) return;
        var params = new URLSearchParams();
        params.append('action', 'add');
        params.append('content', text);
        fetch('TodoServlet', { method: 'POST', body: params })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var li = document.createElement('li');
                li.className = 'd-flex align-items-center gap-2';
                li.style.cssText = 'padding:12px 4px; border-bottom:1px solid var(--border);';
                li.dataset.id = data.todoId;
                li.dataset.done = 'false';
                li.innerHTML = '<input type="checkbox" class="doneCheck" style="width:18px; height:18px;">' +
                                '<span style="flex:1;">' + text.replace(/</g, '&lt;') + '</span>' +
                                '<i class="bi bi-trash delBtn" style="cursor:pointer; color:#DC2626;"></i>';
                list.appendChild(li);
                bindItem(li);
                updateKpis();
                applyFilter();
                if (!presetText) input.value = '';
                input.focus();
            });
    }
    document.getElementById('addBtn').addEventListener('click', function () { addTodo(); });
    document.getElementById('todoInput').addEventListener('keydown', function (e) { if (e.key === 'Enter') addTodo(); });

    var quickList = document.getElementById('quickList');

    function bindQuickChip(chip) {
        chip.addEventListener('click', function (e) {
            if (e.target.classList.contains('quick-del')) return; // x 클릭은 아래에서 따로 처리
            addTodo(chip.dataset.text);
        });
        chip.querySelector('.quick-del').addEventListener('click', function (e) {
            e.stopPropagation();
            var params = new URLSearchParams();
            params.append('action', 'delete');
            params.append('quickId', chip.dataset.id);
            fetch('QuickTodoServlet', { method: 'POST', body: params }).then(function () { chip.remove(); });
        });
    }
    document.querySelectorAll('.quick-add').forEach(bindQuickChip);

    document.getElementById('quickAddNewBtn').addEventListener('click', function () {
        var label = prompt('자주 쓰는 할 일로 등록할 문구를 입력하세요');
        if (!label || !label.trim()) return;
        var params = new URLSearchParams();
        params.append('action', 'add');
        params.append('label', label.trim());
        fetch('QuickTodoServlet', { method: 'POST', body: params })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var chip = document.createElement('span');
                chip.className = 'quick-add';
                chip.dataset.id = data.quickId;
                chip.dataset.text = label.trim();
                chip.innerHTML = label.trim().replace(/</g, '&lt;') + ' <i class="bi bi-x quick-del" data-id="' + data.quickId + '"></i>';
                quickList.insertBefore(chip, document.getElementById('quickAddNewBtn'));
                bindQuickChip(chip);
            });
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
