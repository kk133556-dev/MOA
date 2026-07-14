<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate, com.moa.dao.InventoryDAO, com.moa.model.InventoryItem"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주서 작성</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .order-doc { background:#fff; border:1px solid var(--border); border-radius:10px; padding:36px 40px; }
        .order-doc-title { text-align:center; font-size:24px; font-weight:800; letter-spacing:8px; margin-bottom:28px; }
        .order-doc-meta { display:flex; justify-content:space-between; font-size:13px; color:#374151; margin-bottom:18px; padding-bottom:14px; border-bottom:2px solid var(--navy); }
        .order-doc-meta div b { display:block; font-size:11px; color:var(--text-muted); font-weight:600; margin-bottom:3px; }
        table.order-table { width:100%; border-collapse:collapse; font-size:13px; }
        table.order-table th { background:var(--navy); color:#fff; padding:10px; font-weight:600; font-size:12px; }
        table.order-table td { padding:9px 10px; border-bottom:1px solid var(--border); }
        table.order-table td.num { text-align:center; color:var(--text-muted); width:36px; }
        table.order-table input { border:1px solid var(--border); border-radius:6px; padding:5px 8px; width:100%; font-size:13px; }
        .order-doc-footer { display:flex; justify-content:space-between; align-items:flex-end; margin-top:24px; padding-top:16px; border-top:1px solid var(--border); font-size:12px; color:var(--text-muted); }
        .stamp-box { width:70px; height:70px; border:1.5px solid #DC2626; border-radius:50%; display:flex; align-items:center; justify-content:center; color:#DC2626; font-size:11px; font-weight:700; opacity:0.55; transform:rotate(-8deg); }
        @media print {
            .no-print { display:none !important; }
            body { background:#fff; }
            .order-doc { border:none; padding:0; }
        }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    List<InventoryItem> items = new InventoryDAO().listByStore(storeId);
    String storeName = (String) session.getAttribute("storeName");
    String currentMenu = "inventory";
    String today = LocalDate.now().toString();
    String docNo = "PO-" + LocalDate.now().toString().replace("-", "") + "-" + String.format("%03d", storeId);
%>
<div class="d-flex">
    <div class="no-print"><%@ include file="mypage_sidebar.jsp" %></div>
    <main class="flex-grow-1 p-4">
        <div class="d-flex justify-content-between align-items-center mb-3 no-print">
            <h4 class="mb-0"><i class="bi bi-file-earmark-text"></i> 발주서 작성</h4>
            <div class="d-flex gap-2">
                <a href="inventory.jsp" class="btn-moa-outline"><i class="bi bi-arrow-left"></i> 재고관리</a>
                <button id="printBtn" class="btn-moa-outline"><i class="bi bi-printer"></i> 인쇄/PDF</button>
                <button id="downloadBtn" class="btn-moa"><i class="bi bi-download"></i> 다운로드</button>
            </div>
        </div>

        <div class="order-doc" style="max-width:760px;">
            <div class="order-doc-title">발　주　서</div>
            <div class="order-doc-meta">
                <div><b>문서번호</b><%= docNo %></div>
                <div><b>작성일자</b><%= today %></div>
                <div><b>발주 매장</b><%= storeName != null ? storeName : "-" %></div>
            </div>

            <div class="mb-3">
                <label class="form-label" style="font-size:12px; color:var(--text-muted);">거래처명</label>
                <input type="text" id="vendor" class="form-control" placeholder="예: OO식자재마트" style="max-width:320px;">
            </div>

            <table class="order-table">
                <thead><tr><th style="width:36px;">No</th><th>품목명</th><th style="width:120px;">현재고</th><th style="width:120px;">안전재고</th><th style="width:140px;">발주수량</th><th style="width:80px;">단위</th></tr></thead>
                <tbody id="orderBody">
                <% if (items.isEmpty()) { %>
                    <tr><td colspan="6" class="text-center text-muted" style="padding:24px;">등록된 재고 품목이 없어요. 재고관리에서 먼저 품목을 추가해주세요.</td></tr>
                <% } else {
                    int no = 1;
                    for (InventoryItem it : items) {
                        boolean low = it.getQty() < it.getSafetyQty();
                        double suggested = low ? (it.getSafetyQty() - it.getQty()) : 0;
                %>
                    <tr>
                        <td class="num"><%= no++ %></td>
                        <td><%= it.getItemName() %><% if (low) { %> <span class="badge bg-danger" style="font-size:9px;">부족</span><% } %></td>
                        <td><%= it.getQty() %><%= it.getUnit() %></td>
                        <td><%= it.getSafetyQty() %><%= it.getUnit() %></td>
                        <td><input type="number" step="0.1" class="orderQty" value="<%= suggested %>"></td>
                        <td><%= it.getUnit() %></td>
                    </tr>
                <% } } %>
                </tbody>
            </table>

            <div class="order-doc-footer">
                <div>상기와 같이 발주를 요청합니다.<br>MOA 소상공인 매출 관리 플랫폼</div>
                <div class="stamp-box no-print">발주<br>확인</div>
            </div>
        </div>
    </main>
</div>

<script>
    document.getElementById('downloadBtn').addEventListener('click', function () {
        var vendor = document.getElementById('vendor').value || '(거래처 미입력)';
        var lines = ['발주서', '문서번호: <%= docNo %>', '거래처: ' + vendor, '작성일: <%= today %>', '----------------------'];
        document.querySelectorAll('#orderBody tr').forEach(function (tr) {
            var qtyInput = tr.querySelector('.orderQty');
            if (!qtyInput) return;
            var name = tr.children[1].textContent.replace('부족', '').trim();
            var qty = qtyInput.value;
            var unit = tr.children[5].textContent;
            if (parseFloat(qty) > 0) lines.push(name + ' : ' + qty + unit);
        });
        var blob = new Blob([lines.join('\n')], { type: 'text/plain;charset=utf-8' });
        var link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = '발주서_<%= docNo %>.txt';
        link.click();
    });
    document.getElementById('printBtn').addEventListener('click', function () { window.print(); });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
