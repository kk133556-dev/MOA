<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 마이페이지 공통 사이드바. 각 페이지에서 <%@ include file="mypage_sidebar.jsp" %> 로 불러써요.
     현재 페이지 강조를 위해 이 파일을 include 하기 전에 currentMenu 변수를 String으로 선언해두면
     자동으로 active 클래스가 붙어요. (예: <% String currentMenu = "inventory"; %>) --%>
<aside style="width:220px; background:var(--navy); min-height:100vh; padding:20px 14px; flex-shrink:0;">
    <div style="color:#fff; font-weight:800; font-size:18px; margin-bottom:24px;">
        <a href="mypage.jsp" style="color:#fff; text-decoration:none;">MOA</a>
    </div>
    <a href="mypage.jsp" class="mypage-nav-link <%= "home".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> 마이페이지</a>
    <a href="ai_receipt.jsp" class="mypage-nav-link <%= "receipt".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-camera"></i> 영수증 AI 스캔</a>
    <a href="stats.jsp" class="mypage-nav-link <%= "stats".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-bar-chart"></i> 매출 통계</a>
    <a href="todo.jsp" class="mypage-nav-link <%= "todo".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-journal-check"></i> 다이어리</a>
    <a href="inventory.jsp" class="mypage-nav-link <%= "inventory".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-box-seam"></i> 재고관리</a>
    <a href="ads_apply.jsp" class="mypage-nav-link <%= "ads".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-megaphone"></i> 광고신청</a>
    <a href="support.jsp" class="mypage-nav-link <%= "support".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-headset"></i> 고객센터</a>
    <a href="pricing.jsp" class="mypage-nav-link <%= "pricing".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-credit-card"></i> 요금제</a>
    <hr style="border-color:#3a3654;">
    <a href="index.jsp" class="mypage-nav-link"><i class="bi bi-house-door"></i> 홈으로</a>
    <a href="LogoutServlet" class="mypage-nav-link"><i class="bi bi-box-arrow-right"></i> 로그아웃</a>
</aside>
