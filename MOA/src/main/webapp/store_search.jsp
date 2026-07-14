<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.StoreDAO, com.moa.dao.SalesDAO, com.moa.model.StoreProfile"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>매장 검색</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    String keyword = request.getParameter("keyword");
    List<StoreProfile> results = (keyword != null && !keyword.isEmpty()) ? new StoreDAO().searchByName(keyword) : null;
    List<Object[]> topStores = new SalesDAO().rankStores();
    boolean loggedIn = session.getAttribute("storeId") != null;
    String currentMenu = "search";
%>
<% if (loggedIn) { %>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
<% } else { %>
<div class="container py-5" style="max-width:900px;">
    <div class="mb-3"><a href="index.jsp" class="btn-moa-outline"><i class="bi bi-house-door"></i> 홈으로</a></div>
<% } %>
        <h4 class="mb-4"><i class="bi bi-search"></i> 매장 검색</h4>

        <div class="moa-card mb-4">
            <form method="get" class="d-flex gap-2">
                <input type="text" name="keyword" class="form-control form-control-lg" placeholder="매장명으로 검색해보세요 (예: OO식당)" value="<%= keyword != null ? keyword : "" %>">
                <button type="submit" class="btn-moa" style="padding:0 28px;">검색</button>
            </form>
        </div>

        <div class="row g-3">
            <div class="col-lg-8">
                <% if (results != null) { %>
                    <h6 class="mb-3">'<%= keyword %>' 검색 결과 <span style="color:var(--text-muted); font-weight:400;">(<%= results.size() %>건)</span></h6>
                    <% if (results.isEmpty()) { %>
                        <div class="moa-card text-center py-5">
                            <i class="bi bi-emoji-frown" style="font-size:32px; opacity:0.3;"></i>
                            <p class="text-muted mt-2 mb-0">'<%= keyword %>'(으)로 등록된 매장이 없어요.</p>
                        </div>
                    <% } else { for (StoreProfile s : results) { %>
                        <div class="moa-card mb-2 d-flex justify-content-between align-items-center">
                            <div>
                                <b><i class="bi bi-shop" style="color:var(--primary);"></i> <%= s.getStoreName() %></b>
                                <div class="text-muted" style="font-size:13px; margin-top:2px;"><i class="bi bi-geo-alt"></i> <%= s.getAddress() %></div>
                            </div>
                        </div>
                    <% } } %>
                <% } else { %>
                    <h6 class="mb-3"><i class="bi bi-fire" style="color:#F59E0B;"></i> 이번 달 인기 매장</h6>
                    <% if (topStores.isEmpty()) { %>
                        <div class="moa-card text-center py-5">
                            <p class="text-muted mb-0">아직 매출 등록된 매장이 없어요.</p>
                        </div>
                    <% } else {
                        int rank = 1;
                        for (int i = 0; i < Math.min(8, topStores.size()); i++) {
                            Object[] row = topStores.get(i);
                    %>
                        <div class="moa-card mb-2 d-flex justify-content-between align-items-center">
                            <div><b style="color:var(--primary); width:24px; display:inline-block;">#<%= rank %></b> &nbsp; <%= row[0] %></div>
                            <span class="text-muted" style="font-size:12.5px;"><i class="bi bi-graph-up-arrow"></i> 매출 활동중</span>
                        </div>
                    <% rank++; } } %>
                <% } %>
            </div>

            <div class="col-lg-4">
                <div class="moa-card mb-3">
                    <h6 class="mb-2"><i class="bi bi-lightbulb"></i> 검색 팁</h6>
                    <p style="font-size:12.5px; color:var(--text-muted); line-height:1.7; margin-bottom:0;">
                        매장 이름의 일부만 입력해도 검색돼요. 예를 들어 "김밥"이라고 검색하면
                        이름에 "김밥"이 들어간 모든 매장이 나와요.
                    </p>
                </div>
                <div class="moa-card">
                    <h6 class="mb-2"><i class="bi bi-trophy"></i> 전체 매출 순위</h6>
                    <p style="font-size:12.5px; color:var(--text-muted); margin-bottom:10px;">우리 매장은 몇 등일까요?</p>
                    <a href="<%= loggedIn ? "ranking.jsp" : "login.jsp" %>" class="btn-moa-outline btn-moa-sm w-100 justify-content-center">순위 보러가기</a>
                </div>
            </div>
        </div>
<% if (loggedIn) { %>
    </main>
</div>
<% } else { %>
</div>
<% } %>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
