<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>요금제</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .plan-feature-table th, .plan-feature-table td { text-align:center; vertical-align:middle; }
        .plan-feature-table td:first-child, .plan-feature-table th:first-child { text-align:left; }
        .check-yes { color:#16A34A; font-size:16px; }
        .check-no { color:#d1d5db; font-size:16px; }
    </style>
</head>
<body>
<%
    boolean loggedIn = session.getAttribute("storeId") != null;
    String myPlan = loggedIn ? (String) session.getAttribute("plan") : null;
    if (myPlan == null) myPlan = "BASIC";
    String currentMenu = "pricing";
%>
<% if (loggedIn) { %>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 요금제 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div style="text-align:center; margin-bottom:6px;">
                <div style="font-size:19px; font-weight:800; color:#1E1B2E;">요금제를 선택하세요</div>
                <p style="font-size:12.5px; color:#8b87a3; margin-top:6px;">현재 <b style="color:#8B5CF6;"><%= myPlan %></b> 요금제를 이용중이에요</p>
            </div>

            <div style="display:flex; flex-direction:column; gap:12px; margin:18px 0 24px;">
                <div style="background:#fff; border-radius:16px; padding:18px; <%= "BASIC".equals(myPlan) ? "box-shadow:0 0 0 2px #8B5CF6;" : "" %>">
                    <div style="font-size:11px; color:#8b87a3; font-weight:700; letter-spacing:0.5px;">BASIC</div>
                    <div style="font-size:20px; font-weight:800; color:#1E1B2E; margin:6px 0;">무료</div>
                    <p style="font-size:12.5px; color:#8b87a3; margin-bottom:12px;">기본 매출 기록</p>
                    <% if ("BASIC".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>기본 제공</button>
                    <% } %>
                </div>
                <div style="background:#fff; border-radius:16px; padding:18px; <%= "STANDARD".equals(myPlan) ? "box-shadow:0 0 0 2px #8B5CF6;" : "" %>">
                    <div style="font-size:11px; color:#8b87a3; font-weight:700; letter-spacing:0.5px;">STANDARD</div>
                    <div style="font-size:20px; font-weight:800; color:#1E1B2E; margin:6px 0;">29,000원</div>
                    <p style="font-size:12.5px; color:#8b87a3; margin-bottom:12px;">매출 통계 + 그래프</p>
                    <% if ("STANDARD".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <a href="verify.jsp?plan=STANDARD" class="btn-moa w-100 justify-content-center">가입하기</a>
                    <% } %>
                </div>
                <div style="background:#fff; border-radius:16px; padding:18px; <%= "PRO".equals(myPlan) ? "box-shadow:0 0 0 2px #8B5CF6;" : "" %>">
                    <div style="font-size:11px; color:#8b87a3; font-weight:700; letter-spacing:0.5px;">PRO</div>
                    <div style="font-size:20px; font-weight:800; color:#1E1B2E; margin:6px 0;">59,000원</div>
                    <p style="font-size:12.5px; color:#8b87a3; margin-bottom:12px;">광고 신청 + 우선지원</p>
                    <% if ("PRO".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <a href="verify.jsp?plan=PRO" class="btn-moa w-100 justify-content-center">가입하기</a>
                    <% } %>
                </div>
            </div>

            <div style="background:#fff; border-radius:16px; padding:16px;">
                <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;"><i class="bi bi-list-check"></i> 요금제별 기능 비교</div>
                <div style="overflow-x:auto;">
                <table class="table plan-feature-table" style="font-size:12px;">
                    <thead><tr><th>기능</th><th>BASIC</th><th>STD</th><th>PRO</th></tr></thead>
                    <tbody>
                        <tr><td>매출등록·영수증스캔</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                        <tr><td>다이어리/재고관리</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                        <tr><td>매출 통계 그래프</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                        <tr><td>엑셀/PDF 리포트</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                        <tr><td>메인 배너 광고</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                        <tr><td>1:1 우선 상담</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    </tbody>
                </table>
                </div>
            </div>
        </div>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 화면 (로그인) ===================== -->
        <h4 class="text-center mb-2">요금제를 선택하세요</h4>
        <p class="text-center text-muted mb-5" style="font-size:13.5px;">
            현재 <b style="color:var(--primary);"><%= myPlan %></b> 요금제를 이용중이에요
        </p>

        <div class="row g-4 justify-content-center mb-5">
            <div class="col-md-3">
                <div class="moa-card text-center" style="<%= "BASIC".equals(myPlan) ? "border-color:var(--primary); box-shadow:0 0 0 2px rgba(79,70,229,0.2);" : "" %>">
                    <div class="text-muted">BASIC</div>
                    <div class="kpi-value my-2">무료</div>
                    <p style="font-size:13px;">기본 매출 기록</p>
                    <% if ("BASIC".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>기본 제공</button>
                    <% } %>
                </div>
            </div>
            <div class="col-md-3">
                <div class="moa-card text-center" style="<%= "STANDARD".equals(myPlan) ? "border-color:var(--primary); box-shadow:0 0 0 2px rgba(79,70,229,0.2);" : "" %>">
                    <div class="text-muted">STANDARD</div>
                    <div class="kpi-value my-2">29,000원</div>
                    <p style="font-size:13px;">매출 통계 + 그래프</p>
                    <% if ("STANDARD".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <a href="verify.jsp?plan=STANDARD" class="btn-moa w-100 justify-content-center">가입하기</a>
                    <% } %>
                </div>
            </div>
            <div class="col-md-3">
                <div class="moa-card text-center" style="<%= "PRO".equals(myPlan) ? "border-color:var(--primary); box-shadow:0 0 0 2px rgba(79,70,229,0.2);" : "" %>">
                    <div class="text-muted">PRO</div>
                    <div class="kpi-value my-2">59,000원</div>
                    <p style="font-size:13px;">광고 신청 + 우선지원</p>
                    <% if ("PRO".equals(myPlan)) { %>
                        <button class="btn-moa-outline w-100 justify-content-center" disabled>현재 이용중</button>
                    <% } else { %>
                        <a href="verify.jsp?plan=PRO" class="btn-moa w-100 justify-content-center">가입하기</a>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="moa-card" style="max-width:760px; margin:0 auto;">
            <h6 class="mb-3"><i class="bi bi-list-check"></i> 요금제별 기능 비교</h6>
            <table class="table plan-feature-table">
                <thead><tr><th>기능</th><th>BASIC</th><th>STANDARD</th><th>PRO</th></tr></thead>
                <tbody>
                    <tr><td>매출 등록 &amp; 영수증 AI 스캔</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    <tr><td>다이어리 / 재고관리</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    <tr><td>매출 통계 (월별/연도별 그래프)</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    <tr><td>엑셀/PDF 리포트 다운로드</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    <tr><td>메인 배너 광고 신청</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                    <tr><td>1:1 우선 상담</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                </tbody>
            </table>
        </div>
    <% } %>
    </main>
</div>
<% } else { %>
<div class="container py-5">
    <!-- ===================== 비로그인(게스트) 화면 ===================== -->
    <h4 class="text-center mb-2">요금제를 선택하세요</h4>
    <p class="text-center text-muted mb-5" style="font-size:13.5px;">매장 규모에 맞는 요금제를 선택하세요</p>

    <div class="row g-4 justify-content-center mb-5">
        <div class="col-md-3">
            <div class="moa-card text-center">
                <div class="text-muted">BASIC</div>
                <div class="kpi-value my-2">무료</div>
                <p style="font-size:13px;">기본 매출 기록</p>
                <button class="btn-moa-outline w-100 justify-content-center" disabled>기본 제공</button>
            </div>
        </div>
        <div class="col-md-3">
            <div class="moa-card text-center">
                <div class="text-muted">STANDARD</div>
                <div class="kpi-value my-2">29,000원</div>
                <p style="font-size:13px;">매출 통계 + 그래프</p>
                <a href="verify.jsp?plan=STANDARD" class="btn-moa w-100 justify-content-center">가입하기</a>
            </div>
        </div>
        <div class="col-md-3">
            <div class="moa-card text-center">
                <div class="text-muted">PRO</div>
                <div class="kpi-value my-2">59,000원</div>
                <p style="font-size:13px;">광고 신청 + 우선지원</p>
                <a href="verify.jsp?plan=PRO" class="btn-moa w-100 justify-content-center">가입하기</a>
            </div>
        </div>
    </div>

    <div class="moa-card" style="max-width:760px; margin:0 auto;">
        <h6 class="mb-3"><i class="bi bi-list-check"></i> 요금제별 기능 비교</h6>
        <table class="table plan-feature-table">
            <thead><tr><th>기능</th><th>BASIC</th><th>STANDARD</th><th>PRO</th></tr></thead>
            <tbody>
                <tr><td>매출 등록 &amp; 영수증 AI 스캔</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                <tr><td>다이어리 / 재고관리</td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                <tr><td>매출 통계 (월별/연도별 그래프)</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                <tr><td>엑셀/PDF 리포트 다운로드</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                <tr><td>메인 배너 광고 신청</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
                <tr><td>1:1 우선 상담</td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-dash check-no"></i></td><td><i class="bi bi-check-lg check-yes"></i></td></tr>
            </tbody>
        </table>
    </div>

    <div class="text-center mt-4"><a href="index.jsp" class="btn-moa-outline">← 홈으로</a></div>
</div>
<% } %>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
