<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.InventoryDAO, com.moa.model.InventoryItem"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>재고 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        tr.low-stock-row { background: rgba(220,38,38,0.06); }
        .stock-bar-wrap { width:80px; height:6px; background:#E5E7EB; border-radius:4px; overflow:hidden; display:inline-block; vertical-align:middle; margin-left:8px; }
        .stock-bar-fill { height:100%; border-radius:4px; }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    List<InventoryItem> items = new InventoryDAO().listByStore(storeId);
    int lowCount = 0;
    for (InventoryItem it : items) if (it.getQty() < it.getSafetyQty()) lowCount++;
    String currentMenu = "inventory";
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-box-seam"></i> 재고 관리</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value"><%= items.size() %></div><div class="kpi-label">전체 품목</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= lowCount>0 ? "#DC2626" : "#16A34A" %>;"><%= lowCount %></div><div class="kpi-label">안전 수량 미만</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value"><%= items.size() - lowCount %></div><div class="kpi-label">정상 재고</div></div></div>
            <div class="col-md-3 col-6"><a href="order_form.jsp" class="kpi-card" style="display:block; text-decoration:none; color:inherit;"><div class="kpi-value"><i class="bi bi-file-earmark-text"></i></div><div class="kpi-label">발주서 작성하기</div></a></div>
        </div>

        <div class="row g-3">
            <div class="col-lg-8">
                <div class="moa-card">
                    <% if (lowCount > 0) { %>
                        <div class="alert alert-danger py-2"><i class="bi bi-exclamation-triangle"></i> <b><%= lowCount %>개</b> 품목이 안전 수량 미만이에요. <a href="order_form.jsp">발주서 작성하러 가기 →</a></div>
                    <% } %>
                    <table class="table moa-table mb-0">
                        <thead><tr><th>품목</th><th>현재 수량</th><th>안전 수량</th><th>재고 상태</th><th></th></tr></thead>
                        <tbody>
                        <% if (items.isEmpty()) { %>
                            <tr><td colspan="5" class="text-center text-muted py-4">등록된 품목이 없어요</td></tr>
                        <% } else { for (InventoryItem it : items) {
                            boolean low = it.getQty() < it.getSafetyQty();
                            double ratio = it.getSafetyQty() <= 0 ? 1.0 : Math.min(1.0, it.getQty() / (it.getSafetyQty() * 2));
                            String barColor = low ? "#DC2626" : (ratio < 0.6 ? "#F59E0B" : "#16A34A");
                        %>
                            <tr class="<%= low ? "low-stock-row" : "" %>">
                                <td><%= it.getItemName() %></td>
                                <td class="<%= low ? "low-stock" : "" %>">
                                    <%= it.getQty() %><%= it.getUnit() %>
                                    <span class="stock-bar-wrap"><span class="stock-bar-fill" style="width:<%= (int)(ratio*100) %>%; background:<%= barColor %>;"></span></span>
                                </td>
                                <td><%= it.getSafetyQty() %><%= it.getUnit() %></td>
                                <td>
                                    <% if (low) { %>
                                        <span class="badge bg-danger"><i class="bi bi-exclamation-triangle"></i> 부족</span>
                                    <% } else if (ratio < 0.6) { %>
                                        <span class="badge" style="background:#F59E0B;">주의</span>
                                    <% } else { %>
                                        <span class="badge bg-success">정상</span>
                                    <% } %>
                                </td>
                                <td>
                                    <form action="InventoryServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="itemId" value="<%= it.getItemId() %>">
                                        <button type="submit" class="btn-moa-outline btn-moa-sm">삭제</button>
                                    </form>
                                </td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-plus-circle"></i> 품목 추가</h6>
                    <form action="InventoryServlet" method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-2"><label class="form-label" style="font-size:12px;">품목명</label><input type="text" name="itemName" class="form-control" required></div>
                        <div class="row g-2 mb-2">
                            <div class="col-6"><label class="form-label" style="font-size:12px;">현재 수량</label><input type="number" step="0.1" name="qty" class="form-control" required></div>
                            <div class="col-6"><label class="form-label" style="font-size:12px;">안전 수량</label><input type="number" step="0.1" name="safetyQty" class="form-control" required></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="font-size:12px;">단위</label>
                            <select name="unit" class="form-control">
                                <option value="개">개</option>
                                <option value="수">수</option>
                                <option value="ml">ml</option>
                                <option value="L">L</option>
                                <option value="g">g</option>
                                <option value="kg">kg</option>
                                <option value="박스">박스</option>
                                <option value="봉">봉</option>
                            </select>
                        </div>
                        <button type="submit" class="btn-moa w-100 justify-content-center">추가하기</button>
                    </form>
                </div>
                <div class="moa-card">
                    <h6 class="mb-2"><i class="bi bi-info-circle"></i> 재고 관리 팁</h6>
                    <p style="font-size:12.5px; color:var(--text-muted); line-height:1.7; margin-bottom:0;">
                        안전 수량은 "이 수량 밑으로 떨어지면 위험한 최소 수량"이에요.
                        현재 수량이 안전 수량 밑으로 떨어지면 빨간색으로, 안전 수량의 1.2배 이내로 가까워지면
                        주황색으로 미리 표시돼서 발주 타이밍을 놓치지 않게 도와드려요.
                    </p>
                </div>
            </div>
        </div>
    </main>
</div>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
