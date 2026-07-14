<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.MemberDAO, com.moa.dao.InquiryDAO, com.moa.dao.AdDAO, com.moa.model.Member"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 콘솔</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null || !"ADMIN".equals(session.getAttribute("memberType"))) { response.sendRedirect("login.jsp?role=ADMIN"); return; }
    List<Member> members = new MemberDAO().listAll();
    int pendingMembers = 0, businessCount = 0;
    for (Member m : members) {
        if ("PENDING".equals(m.getStatus())) pendingMembers++;
        if ("BUSINESS".equals(m.getMemberType())) businessCount++;
    }
    int pendingInquiries = 0;
    List<com.moa.model.Inquiry> inquiries = new InquiryDAO().listAll();
    for (com.moa.model.Inquiry i : inquiries) if ("PENDING".equals(i.getStatus())) pendingInquiries++;
    AdDAO adDao = new AdDAO();
    int pendingAds = adDao.listPending().size();
    int activeAds = adDao.listAllApprovedIncludingExpired().size();
    String currentMenu = "home";
%>
<div class="d-flex">
    <%@ include file="admin_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><%= session.getAttribute("name") %>님, 관리자 콘솔</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value"><%= members.size() %></div><div class="kpi-label">전체 회원 (소상공인 <%= businessCount %>명)</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= pendingMembers>0?"#F59E0B":"#16A34A" %>;"><%= pendingMembers %></div><div class="kpi-label">회원 승인 대기</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= pendingInquiries>0?"#F59E0B":"#16A34A" %>;"><%= pendingInquiries %></div><div class="kpi-label">미답변 문의</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:<%= pendingAds>0?"#F59E0B":"#16A34A" %>;"><%= pendingAds %></div><div class="kpi-label">광고 승인 대기</div></div></div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <a href="admin_members.jsp" class="feature-card">
                    <div class="feature-icon"><i class="bi bi-people-fill"></i></div>
                    <h6>회원 관리</h6>
                    <p class="text-muted" style="font-size:12.5px;">전체 소상공인/관리자 계정을 확인하고, 승인·정지·삭제까지 할 수 있어요.</p>
                    <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="admin_inquiries.jsp" class="feature-card">
                    <div class="feature-icon"><i class="bi bi-headset"></i></div>
                    <h6>문의 관리</h6>
                    <p class="text-muted" style="font-size:12.5px;">1:1 문의에 답변을 남길 수 있어요. 현재 <%= pendingInquiries %>건 대기중이에요.</p>
                    <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="admin_ads.jsp" class="feature-card">
                    <div class="feature-icon"><i class="bi bi-megaphone-fill"></i></div>
                    <h6>광고 관리</h6>
                    <p class="text-muted" style="font-size:12.5px;">배너 광고를 노출 기간까지 지정해서 승인하고, 삭제도 할 수 있어요. 현재 <%= activeAds %>건 노출중이에요.</p>
                    <span class="arrow">바로가기 <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-lg-7">
                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-clock-history"></i> 최근 가입 회원</h6>
                    <table class="table moa-table mb-0">
                        <thead><tr><th>ID</th><th>이름</th><th>구분</th><th>상태</th></tr></thead>
                        <tbody>
                        <% int shown = 0; for (Member m : members) { if (shown >= 6) break; shown++;
                            String st = m.getStatus() != null ? m.getStatus() : "ACTIVE";
                            String badgeClass = "PENDING".equals(st) ? "bg-warning" : "SUSPENDED".equals(st) ? "bg-danger" : "bg-success";
                            String badgeText = "PENDING".equals(st) ? "승인대기" : "SUSPENDED".equals(st) ? "정지됨" : "정상";
                        %>
                            <tr>
                                <td><%= m.getLoginId() %></td>
                                <td><%= m.getName() %></td>
                                <td><%= "BUSINESS".equals(m.getMemberType()) ? "소상공인" : "관리자" %></td>
                                <td><span class="badge <%= badgeClass %>"><%= badgeText %></span></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="col-lg-5">
                <div class="moa-card">
                    <h6 class="mb-3"><i class="bi bi-info-circle"></i> 시스템 상태</h6>
                    <div class="d-flex justify-content-between" style="padding:8px 0; border-bottom:1px solid var(--border); font-size:13px;"><span>서버</span><span class="badge bg-success">정상</span></div>
                    <div class="d-flex justify-content-between" style="padding:8px 0; border-bottom:1px solid var(--border); font-size:13px;"><span>데이터베이스</span><span class="badge bg-success">연결됨</span></div>
                    <div class="d-flex justify-content-between" style="padding:8px 0; font-size:13px;"><span>노출중 광고</span><span class="badge bg-primary"><%= activeAds %>건</span></div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
