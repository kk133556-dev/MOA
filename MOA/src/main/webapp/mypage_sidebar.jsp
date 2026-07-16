<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 마이페이지 공통 사이드바. 각 페이지에서 <%@ include file="mypage_sidebar.jsp" %> 로 불러써요.
     현재 페이지 강조를 위해 이 파일을 include 하기 전에 currentMenu 변수를 String으로 선언해두면
     자동으로 active 클래스가 붙어요. (예: <% String currentMenu = "inventory"; %>)
     안드로이드 앱(WebView)에서는 User-Agent에 "MOAApp"이 붙어서 오기 때문에, 그걸로 앱 접속 여부를 판단해서
     PC/모바일웹은 기존 사이드바 그대로, 앱은 하단 탭바로 바꿔줘요. --%>
<%
    String ua = request.getHeader("User-Agent");
    boolean isApp = ua != null && ua.contains("MOAApp");
    if (currentMenu == null) currentMenu = "";
%>
<% if (isApp) { %>
<style>
    body { padding-bottom: 74px !important; }
    .moa-bottom-nav {
        position: fixed; left:0; right:0; bottom:0; z-index:1050;
        display:flex; background:var(--navy); border-top:1px solid rgba(255,255,255,0.08);
        padding-bottom: env(safe-area-inset-bottom, 0);
    }
    .moa-bottom-nav a {
        flex:1; display:flex; flex-direction:column; align-items:center; gap:2px;
        padding:9px 2px 8px; color:#8b87a3; text-decoration:none; font-size:10.5px;
    }
    .moa-bottom-nav a i { font-size:19px; }
    .moa-bottom-nav a.active { color:#fff; }
    .moa-bottom-nav a.active i { color:#8B5CF6; }
</style>
<% } else { %>
<aside style="width:220px; background:var(--navy); min-height:100vh; padding:20px 14px; flex-shrink:0;">
    <div style="color:#fff; font-weight:800; font-size:18px; margin-bottom:24px;">
        <a href="mypage.jsp" style="color:#fff; text-decoration:none;">MOA</a>
    </div>
    <a href="mypage.jsp" class="mypage-nav-link <%= "home".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> 마이페이지</a>
    <a href="ai_receipt.jsp" class="mypage-nav-link <%= "receipt".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-camera"></i> 영수증 AI 스캔</a>
    <a href="stats.jsp" class="mypage-nav-link <%= "stats".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-bar-chart"></i> 매출 통계</a>
    <a href="todo.jsp" class="mypage-nav-link <%= "todo".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-journal-check"></i> 다이어리</a>
    <a href="inventory.jsp" class="mypage-nav-link <%= "inventory".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-box-seam"></i> 재고관리</a>
    <a href="staff.jsp" class="mypage-nav-link <%= "staff".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-people"></i> 직원관리</a>
    <a href="reservation.jsp" class="mypage-nav-link <%= "reservation".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-calendar-check"></i> 예약관리</a>
    <a href="ads_apply.jsp" class="mypage-nav-link <%= "ads".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-megaphone"></i> 광고신청</a>
    <a href="support.jsp" class="mypage-nav-link <%= "support".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-headset"></i> 고객센터</a>
    <a href="pricing.jsp" class="mypage-nav-link <%= "pricing".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-credit-card"></i> 요금제</a>
    <hr style="border-color:#3a3654;">
    <a href="index.jsp" class="mypage-nav-link"><i class="bi bi-house-door"></i> 홈으로</a>
    <a href="LogoutServlet" class="mypage-nav-link"><i class="bi bi-box-arrow-right"></i> 로그아웃</a>
</aside>
<% } %>

<% if (isApp) { %>
<nav class="moa-bottom-nav">
    <a href="mypage.jsp" class="<%= "home".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-speedometer2"></i>홈</a>
    <a href="ai_receipt.jsp" class="<%= "receipt".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-camera"></i>영수증</a>
    <a href="stats.jsp" class="<%= "stats".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-bar-chart"></i>통계</a>
    <a href="reservation.jsp" class="<%= "reservation".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-calendar-check"></i>예약</a>
    <a href="#" data-bs-toggle="offcanvas" data-bs-target="#moaMoreMenu" class="<%= (currentMenu != null && (currentMenu.equals("todo")||currentMenu.equals("inventory")||currentMenu.equals("staff")||currentMenu.equals("ads")||currentMenu.equals("support")||currentMenu.equals("pricing"))) ? "active" : "" %>"><i class="bi bi-grid-3x3-gap"></i>더보기</a>
</nav>

<div class="offcanvas offcanvas-bottom" tabindex="-1" id="moaMoreMenu" style="background:var(--navy); max-height:60vh;">
    <div class="offcanvas-header">
        <h6 class="offcanvas-title" style="color:#fff;">전체 메뉴</h6>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body">
        <a href="todo.jsp" class="mypage-nav-link <%= "todo".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-journal-check"></i> 다이어리</a>
        <a href="inventory.jsp" class="mypage-nav-link <%= "inventory".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-box-seam"></i> 재고관리</a>
        <a href="staff.jsp" class="mypage-nav-link <%= "staff".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-people"></i> 직원관리</a>
        <a href="ads_apply.jsp" class="mypage-nav-link <%= "ads".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-megaphone"></i> 광고신청</a>
        <a href="support.jsp" class="mypage-nav-link <%= "support".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-headset"></i> 고객센터</a>
        <a href="pricing.jsp" class="mypage-nav-link <%= "pricing".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-credit-card"></i> 요금제</a>
        <hr style="border-color:#3a3654;">
        <a href="index.jsp" class="mypage-nav-link"><i class="bi bi-house-door"></i> 홈으로</a>
        <a href="LogoutServlet" class="mypage-nav-link"><i class="bi bi-box-arrow-right"></i> 로그아웃</a>
    </div>
</div>
<script>
    // 더보기(오프캔버스) 동작에 필요한 bootstrap JS가 이 페이지에 아직 없으면 로드해줘요.
    if (typeof bootstrap === 'undefined') {
        document.write('<scr' + 'ipt src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></scr' + 'ipt>');
    }
</script>
<% } %>