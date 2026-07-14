<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 관리자 콘솔 공용 사이드바. 각 admin_*.jsp에서 currentMenu 변수를 선언하고 include 하세요. --%>
<aside style="width:220px; background:var(--navy); min-height:100vh; padding:20px 14px; flex-shrink:0;">
    <div style="color:#fff; font-weight:800; font-size:18px; margin-bottom:24px;">MOA 관리자</div>
    <a href="admin_main.jsp" class="mypage-nav-link <%= "home".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> 대시보드</a>
    <a href="admin_members.jsp" class="mypage-nav-link <%= "members".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-people"></i> 회원 관리</a>
    <a href="admin_inquiries.jsp" class="mypage-nav-link <%= "inquiries".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-headset"></i> 문의 관리</a>
    <a href="admin_ads.jsp" class="mypage-nav-link <%= "ads".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-megaphone"></i> 광고 관리</a>
    <a href="admin_files.jsp" class="mypage-nav-link <%= "files".equals(currentMenu) ? "active" : "" %>"><i class="bi bi-folder2-open"></i> 파일 관리</a>
    <hr style="border-color:#3a3654;">
    <a href="index.jsp" class="mypage-nav-link"><i class="bi bi-house-door"></i> 홈으로</a>
    <a href="LogoutServlet" class="mypage-nav-link"><i class="bi bi-box-arrow-right"></i> 로그아웃</a>
</aside>
