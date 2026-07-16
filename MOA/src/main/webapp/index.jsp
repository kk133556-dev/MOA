<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.AdDAO, com.moa.model.Ad"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MOA - 소상공인 매출 관리 플랫폼</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    boolean loggedIn = session.getAttribute("name") != null;
    boolean isAdmin = "ADMIN".equals(session.getAttribute("memberType"));
    String ctaHref = loggedIn ? (isAdmin ? "admin_main.jsp" : "mypage.jsp") : "signup.jsp";
    String ctaText = loggedIn ? (isAdmin ? "관리자 콘솔로 이동" : "마이페이지로 이동") : "무료로 시작하기";
    List<Ad> ads = new AdDAO().listApproved();

    // 안드로이드 앱(WebView)에서 온 요청인지 확인해서, 앱에서는 마케팅용 랜딩페이지 대신
    // 로그인한 사람은 곧장 마이페이지로, 안 한 사람은 로그인만 있는 심플한 화면을 보여줘요.
    String ua = request.getHeader("User-Agent");
    boolean isApp = ua != null && ua.contains("MOAApp");
    if (isApp && loggedIn) {
        response.sendRedirect(isAdmin ? "admin_main.jsp" : "mypage.jsp");
        return;
    }
%>

<% if (isApp) { %>
    <div style="min-height:100vh; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:32px 28px; background:var(--navy);">
        <div style="text-align:center; margin-bottom:34px;">
            <div style="color:#fff; font-weight:800; font-size:30px; letter-spacing:0.5px;">MOA</div>
            <div style="color:#8b87a3; font-size:12.5px; margin-top:6px;">소상공인 매출 관리 플랫폼</div>
        </div>
        <div style="width:100%; max-width:340px; background:#fff; border-radius:16px; padding:26px 22px;">
            <h6 style="font-weight:700; margin-bottom:16px;"><i class="bi bi-box-arrow-in-right"></i> 로그인</h6>
            <form action="LoginServlet" method="post">
                <input type="hidden" name="loginType" value="BUSINESS">
                <div class="mb-2"><label class="form-label" style="font-size:12.5px;">아이디</label><input type="text" name="userId" class="form-control" required></div>
                <div class="mb-3"><label class="form-label" style="font-size:12.5px;">비밀번호</label><input type="password" name="userPw" class="form-control" required></div>
                <button type="submit" class="btn-moa w-100 justify-content-center">로그인</button>
            </form>
            <div class="d-flex justify-content-between mt-3" style="font-size:12px;">
                <a href="signup.jsp" class="text-decoration-none">회원가입</a>
                <a href="login.jsp?role=ADMIN" class="text-decoration-none text-muted">관리자 로그인</a>
            </div>
        </div>
        <% if ("1".equals(request.getParameter("error"))) { %>
            <div style="color:#f87171; font-size:12.5px; margin-top:16px;"><i class="bi bi-exclamation-circle-fill"></i> 아이디 또는 비밀번호가 올바르지 않아요.</div>
        <% } %>
        <% if ("1".equals(request.getParameter("pending"))) { %>
            <div style="color:#fbbf24; font-size:12.5px; margin-top:16px; text-align:center;"><i class="bi bi-hourglass-split"></i> 아직 관리자 승인 대기중인 계정이에요.</div>
        <% } %>
        <% if ("1".equals(request.getParameter("suspended"))) { %>
            <div style="color:#f87171; font-size:12.5px; margin-top:16px;"><i class="bi bi-slash-circle"></i> 이용이 정지된 계정이에요. 고객센터로 문의해주세요.</div>
        <% } %>
    </div>
    </body>
    </html>
    <% return; %>
<% } %>

<nav class="navbar navbar-light bg-white sticky-top" id="mainNav">
    <div class="container">
        <a href="index.jsp" class="navbar-brand" style="text-decoration:none;">MOA</a>
        <div class="d-flex gap-2 align-items-center">
            <% if (!isAdmin) { %>
                <a href="pricing.jsp" class="btn-moa-outline d-none d-md-inline-flex"><i class="bi bi-credit-card"></i> 요금제</a>
            <% } %>
            <% if (loggedIn) { %>
                <% if (isAdmin) { %>
                    <a href="admin_main.jsp" class="btn-moa"><i class="bi bi-speedometer2"></i> 관리자 콘솔</a>
                <% } else { %>
                    <a href="mypage.jsp" class="btn-moa"><i class="bi bi-speedometer2"></i> 마이페이지</a>
                <% } %>
                <a href="LogoutServlet" class="btn-moa-outline">로그아웃</a>
            <% } else { %>
                <a href="signup.jsp" class="btn-moa">회원가입</a>
            <% } %>
        </div>
    </div>
</nav>

<% if ("1".equals(request.getParameter("welcome"))) { %>
<div class="alert alert-success text-center mb-0 rounded-0"><i class="bi bi-check-circle-fill"></i> <%= session.getAttribute("name") %>님, 환영합니다!</div>
<% } %>
<% if ("1".equals(request.getParameter("error"))) { %>
<div class="alert alert-danger text-center mb-0 rounded-0"><i class="bi bi-exclamation-circle-fill"></i> 아이디 또는 비밀번호가 올바르지 않아요.</div>
<% } %>
<% if ("1".equals(request.getParameter("pending"))) { %>
<div class="alert alert-warning text-center mb-0 rounded-0"><i class="bi bi-hourglass-split"></i> 아직 관리자 승인 대기중인 계정이에요. 승인 후 로그인할 수 있어요.</div>
<% } %>
<% if ("1".equals(request.getParameter("suspended"))) { %>
<div class="alert alert-danger text-center mb-0 rounded-0"><i class="bi bi-slash-circle"></i> 이용이 정지된 계정이에요. 고객센터로 문의해주세요.</div>
<% } %>

<section class="hero-pro" style="position:relative; overflow:hidden;">
    <i class="bi bi-receipt hero-bg-icon"></i>
    <div class="container" style="position:relative; z-index:1;">
        <div class="row align-items-center g-5">
            <div class="col-lg-7">
                <span class="badge-pill"><i class="bi bi-shop"></i> 사업자등록증 등록 소상공인 전용</span>
                <h1>영수증 한 장이면<br><span class="grad-text">매출이 저절로</span> 정리돼요</h1>
                <p class="lead" style="font-size:16.5px; max-width:480px;">영수증 사진 한 장이면 AI가 매출을 자동으로 분석해드려요.<br class="d-none d-md-block">카드·현금 매출부터 순수익, 일별·월별 통계까지 한눈에.</p>
                <div class="d-flex gap-2 mt-4">
                    <a href="<%= ctaHref %>" class="btn-moa" style="font-size:15px; padding:13px 28px;"><i class="bi bi-arrow-right-circle"></i> <%= ctaText %></a>
                    <a href="#features" class="btn-moa-outline" style="font-size:15px; padding:13px 24px;">기능 둘러보기</a>
                </div>
            </div>

            <div class="col-lg-5">
                <% if (!loggedIn) { %>
                    <div class="hero-login-panel reveal">
                        <h6><i class="bi bi-box-arrow-in-right"></i> 로그인</h6>
                        <form action="LoginServlet" method="post">
                            <input type="hidden" name="loginType" value="BUSINESS">
                            <div class="mb-2"><label class="form-label">아이디</label><input type="text" name="userId" class="form-control" required></div>
                            <div class="mb-2"><label class="form-label">비밀번호</label><input type="password" name="userPw" class="form-control" required></div>
                            <button type="submit" class="btn-moa mt-1">로그인</button>
                        </form>
                        <div class="d-flex justify-content-between mt-2" style="font-size:11.5px;">
                            <a href="signup.jsp" class="text-decoration-none">회원가입</a>
                            <a href="login.jsp?role=ADMIN" class="text-decoration-none text-muted">관리자 로그인</a>
                        </div>
                    </div>
                <% } else { %>
                    <div class="hero-welcome-panel reveal">
                        <h6 class="mb-1" style="font-size:15px;"><%= session.getAttribute("name") %>님, 안녕하세요</h6>
                        <p style="opacity:0.85; font-size:12px; margin-bottom:14px;">자주 쓰는 메뉴로 바로 이동하세요</p>
                        <% if (isAdmin) { %>
                            <a href="admin_main.jsp" class="list-link"><span><i class="bi bi-speedometer2"></i> 관리자 콘솔</span><i class="bi bi-chevron-right"></i></a>
                            <a href="admin_members.jsp" class="list-link"><span><i class="bi bi-people"></i> 회원 관리</span><i class="bi bi-chevron-right"></i></a>
                            <a href="admin_inquiries.jsp" class="list-link"><span><i class="bi bi-headset"></i> 문의 관리</span><i class="bi bi-chevron-right"></i></a>
                            <a href="admin_ads.jsp" class="list-link"><span><i class="bi bi-megaphone"></i> 광고 관리</span><i class="bi bi-chevron-right"></i></a>
                        <% } else { %>
                            <a href="mypage.jsp" class="list-link"><span><i class="bi bi-speedometer2"></i> 마이페이지</span><i class="bi bi-chevron-right"></i></a>
                            <a href="ai_receipt.jsp" class="list-link"><span><i class="bi bi-camera"></i> 영수증 AI 스캔</span><i class="bi bi-chevron-right"></i></a>
                            <a href="todo.jsp" class="list-link"><span><i class="bi bi-journal-check"></i> 다이어리</span><i class="bi bi-chevron-right"></i></a>
                            <a href="ads_apply.jsp" class="list-link"><span><i class="bi bi-megaphone"></i> 광고 신청</span><i class="bi bi-chevron-right"></i></a>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>

        <% if (!ads.isEmpty()) { %>
        <div class="ad-marquee-wrap mt-5 reveal">
            <div class="ad-marquee-label"><span class="live-dot"></span> 실시간 매장 소식</div>
            <div class="ad-marquee-track">
                <div class="ad-marquee-content" id="adMarqueeContent">
                    <% for (int loop = 0; loop < 2; loop++) { // 두 번 반복해서 이어붙여야 끊김 없이 계속 흘러가요
                        for (Ad ad : ads) { %>
                        <span class="ad-marquee-item"><i class="bi bi-shop"></i> <b><%= ad.getStoreName() %></b> · <%= ad.getBannerText() %></span>
                    <% } } %>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</section>

<div class="trust-bar">
    <div class="container d-flex justify-content-around flex-wrap gap-3">
        <div class="item"><i class="bi bi-shop"></i> 3,400+ 등록 매장</div>
        <div class="item"><i class="bi bi-emoji-smile"></i> 98% 만족도</div>
        <div class="item"><i class="bi bi-graph-up-arrow"></i> 누적 분석 매출 4.2억+</div>
        <div class="item"><i class="bi bi-clock-history"></i> 실시간 24시간 분석</div>
    </div>
</div>

<section class="container py-5" id="features">
    <h4 class="text-center mb-2 reveal">MOA의 핵심 기능</h4>
    <p class="text-center text-muted mb-5 reveal">소상공인 사장님을 위한 진짜 필요한 기능만 담았어요</p>
    <div class="row g-4">
        <div class="col-md-3 col-6 reveal">
            <a href="ai_receipt.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-camera-fill"></i></div>
                <h6>영수증 AI 스캔</h6>
                <p class="text-muted" style="font-size:12.5px;">사진 한 장으로 매출을 자동 분석해요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="mypage.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-bar-chart-line-fill"></i></div>
                <h6>매출 분석</h6>
                <p class="text-muted" style="font-size:12.5px;">일별·월별 통계와 그래프를 확인해요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="todo.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-journal-check"></i></div>
                <h6>다이어리</h6>
                <p class="text-muted" style="font-size:12.5px;">오늘 할 일을 등록하고 체크해요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="inventory.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-box-seam-fill"></i></div>
                <h6>재고 · 발주</h6>
                <p class="text-muted" style="font-size:12.5px;">재고 부족을 확인하고 발주서를 만들어요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="ai_receipt.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-camera-fill"></i></div>
                <h6>매출 자동 집계</h6>
                <p class="text-muted" style="font-size:12.5px;">영수증 사진 한 장으로 매출을 자동으로 집계해요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="ads_apply.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-megaphone-fill"></i></div>
                <h6>광고 신청</h6>
                <p class="text-muted" style="font-size:12.5px;">메인 배너에 우리 매장을 노출해봐요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="support.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-headset"></i></div>
                <h6>1:1 문의</h6>
                <p class="text-muted" style="font-size:12.5px;">궁금한 점은 실시간으로 문의하세요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
        <div class="col-md-3 col-6 reveal">
            <a href="pricing.jsp" class="feature-card">
                <div class="feature-icon"><i class="bi bi-credit-card-2-front-fill"></i></div>
                <h6>요금제</h6>
                <p class="text-muted" style="font-size:12.5px;">매장 규모에 맞는 요금제를 선택해요.</p>
                <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
            </a>
        </div>
    </div>
</section>

<section class="container py-4 reveal">
    <div style="background:linear-gradient(120deg, var(--primary), var(--accent)); border-radius:20px; padding:50px; color:#fff; text-align:center;">
        <h3 style="font-weight:800;">지금 바로 시작해보세요</h3>
        <p style="opacity:0.9; margin:10px 0 20px; font-size:14px;">가입은 무료예요. 사업자등록증만 있으면 3분 안에 시작할 수 있어요.</p>
        <a href="<%= ctaHref %>" class="btn-moa-outline" style="background:#fff;"><i class="bi bi-arrow-right-circle"></i> <%= ctaText %></a>
    </div>
</section>

<footer class="moa-footer">
    <div class="container">
        <div class="row g-4">
            <div class="col-md-3"><h6>MOA</h6><p style="font-size:12px;">소상공인 매출 관리 플랫폼</p></div>
            <div class="col-6 col-md-2"><h6>서비스</h6><a href="ai_receipt.jsp">영수증 스캔</a><a href="inventory.jsp">재고관리</a></div>
            <div class="col-6 col-md-2"><h6>고객지원</h6><a href="support.jsp">1:1 문의</a></div>
            <div class="col-6 col-md-2"><h6>계정</h6><a href="signup.jsp">회원가입</a><a href="login.jsp?role=ADMIN">관리자 로그인</a></div>
            <div class="col-md-3"><h6>소식 받아보기</h6><div class="newsletter-input"><input type="email" placeholder="이메일 주소"><button class="btn-moa" style="padding:9px 16px; font-size:12px;">구독</button></div></div>
        </div>
        <hr style="border-color:#333;">
        <p style="font-size:11px; text-align:center;">&copy; 2026 MOA. All rights reserved.</p>
    </div>
</footer>

<script>
    window.addEventListener('scroll', function () { document.getElementById('mainNav').classList.toggle('scrolled', window.scrollY > 10); });
    var els = document.querySelectorAll('.reveal');
    var obs = new IntersectionObserver(function (entries) { entries.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); } }); }, { threshold: 0.1 });
    els.forEach(function (el) { obs.observe(el); });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
