<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate, com.moa.dao.SalesDAO, com.moa.model.SalesRecord"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>매출 기록부</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Pretendard', -apple-system, sans-serif; padding: 40px 50px; color:#111827; background:#f4f4f6; }
        .doc { background:#fff; max-width:820px; margin:0 auto; padding:44px 50px; border:1px solid #e5e7eb; }
        .doc-title { text-align:center; font-size:26px; font-weight:800; letter-spacing:10px; margin-bottom:6px; }
        .doc-sub { text-align:center; font-size:12px; color:#6b7280; margin-bottom:24px; }
        .doc-meta { display:flex; justify-content:space-between; font-size:13px; padding:14px 0; border-top:2px solid #1E1B2E; border-bottom:1px solid #1E1B2E; margin-bottom:24px; }
        .doc-meta div b { display:block; font-size:11px; color:#6b7280; font-weight:600; margin-bottom:3px; }
        h3.section-title { font-size:14px; font-weight:800; margin:26px 0 10px; padding-left:10px; border-left:4px solid #4F46E5; }
        table { width:100%; border-collapse:collapse; font-size:12.5px; margin-bottom:8px; }
        th, td { border:1px solid #d1d5db; padding:8px 10px; text-align:left; }
        th { background:#F3F4F6; font-weight:700; font-size:11.5px; }
        td.num, th.num { text-align:right; }
        tfoot td { font-weight:800; background:#EEF2FF; }
        .doc-footer { display:flex; justify-content:space-between; align-items:flex-end; margin-top:30px; padding-top:16px; border-top:1px solid #e5e7eb; font-size:11.5px; color:#6b7280; }
        .stamp-box { width:64px; height:64px; border:1.5px solid #DC2626; border-radius:50%; display:flex; align-items:center; justify-content:center; color:#DC2626; font-size:10.5px; font-weight:700; opacity:0.55; transform:rotate(-8deg); }
        @media print {
            .no-print { display:none !important; }
            body { background:#fff; padding:0; }
            .doc { border:none; padding:0; max-width:none; }
        }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    Integer storeId = (Integer) session.getAttribute("storeId");
    SalesDAO dao = new SalesDAO();
    List<SalesRecord> list = dao.listByStore(storeId);
    List<Object[]> monthly = dao.monthlyByStore(storeId, 12);
    int total = dao.sumByStore(storeId);
    String storeName = (String) session.getAttribute("storeName");
    String today = LocalDate.now().toString();
    String docNo = "SR-" + LocalDate.now().toString().replace("-", "") + "-" + String.format("%03d", storeId == null ? 0 : storeId);
%>
<div class="no-print mb-3" style="max-width:820px; margin:0 auto 16px;">
    <button class="btn btn-primary" onclick="window.print()"><i class="bi bi-printer"></i> 인쇄 / PDF로 저장</button>
    <a href="mypage.jsp" class="btn btn-outline-secondary">마이페이지로</a>
</div>

<div class="doc">
    <div class="doc-title">매　출　기　록　부</div>
    <div class="doc-sub">MOA 소상공인 매출 관리 플랫폼 · 공식 발급 기록</div>

    <div class="doc-meta">
        <div><b>문서번호</b><%= docNo %></div>
        <div><b>발급일자</b><%= today %></div>
        <div><b>매장명</b><%= storeName != null ? storeName : "-" %></div>
        <div><b>누적 매출</b>₩ <%= String.format("%,d", total) %></div>
    </div>

    <h3 class="section-title">월별 집계 요약</h3>
    <table>
        <thead><tr><th>월</th><th class="num">총 매출</th><th class="num">카드 매출</th><th class="num">현금 매출</th></tr></thead>
        <tbody>
        <% if (monthly.isEmpty()) { %>
            <tr><td colspan="4" style="text-align:center; color:#9ca3af;">집계할 데이터가 없어요</td></tr>
        <% } else {
            int sumTotal = 0, sumCard = 0, sumCash = 0;
            for (int i = monthly.size()-1; i >= 0; i--) {
                Object[] row = monthly.get(i);
                sumTotal += (Integer) row[1]; sumCard += (Integer) row[2]; sumCash += (Integer) row[3];
        %>
            <tr>
                <td><%= row[0] %></td>
                <td class="num">₩ <%= String.format("%,d", (Integer) row[1]) %></td>
                <td class="num">₩ <%= String.format("%,d", (Integer) row[2]) %></td>
                <td class="num">₩ <%= String.format("%,d", (Integer) row[3]) %></td>
            </tr>
        <% }
        %>
        <tfoot>
            <tr><td>합계 (최근 <%= monthly.size() %>개월)</td><td class="num">₩ <%= String.format("%,d", sumTotal) %></td><td class="num">₩ <%= String.format("%,d", sumCard) %></td><td class="num">₩ <%= String.format("%,d", sumCash) %></td></tr>
        </tfoot>
        <% } %>
        </tbody>
    </table>

    <h3 class="section-title">일별 상세 내역</h3>
    <table>
        <thead><tr><th>날짜</th><th class="num">총매출</th><th class="num">카드매출</th><th class="num">현금매출</th></tr></thead>
        <tbody>
        <% if (list.isEmpty()) { %>
            <tr><td colspan="4" style="text-align:center; color:#9ca3af;">등록된 매출 기록이 없어요</td></tr>
        <% } else { for (SalesRecord r : list) { %>
            <tr>
                <td><%= r.getSalesDate() %></td>
                <td class="num">₩ <%= String.format("%,d", r.getTotalAmount()) %></td>
                <td class="num">₩ <%= String.format("%,d", r.getCardAmount()) %></td>
                <td class="num">₩ <%= String.format("%,d", r.getCashAmount()) %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>

    <div class="doc-footer">
        <div>본 기록부는 MOA 플랫폼에 등록된 매출 데이터를 기준으로 자동 생성되었습니다.<br>발급일 기준 실시간 데이터이며, 세무/회계 증빙용으로 사용 시 원본 영수증을 함께 보관하세요.</div>
        <div class="stamp-box no-print">기록<br>확인</div>
    </div>
</div>
</body>
</html>
