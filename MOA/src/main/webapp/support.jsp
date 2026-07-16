<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, com.moa.dao.InquiryDAO, com.moa.model.Inquiry"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>고객센터</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("memberId") == null) { response.sendRedirect("login.jsp"); return; }
    int memberId = (Integer) session.getAttribute("memberId");
    List<Inquiry> myInquiries = new ArrayList<>();
    String dbError = null;
    try {
        myInquiries = new InquiryDAO().listByMember(memberId);
    } catch (Exception e) {
        dbError = "문의 내역을 불러오지 못했어요. DB에 inquiries 테이블이 있는지 확인해주세요.";
    }
    String currentMenu = "support";

    String[][] faqs = {
        {"영수증 사진만 올리면 매출이 자동으로 등록되나요?", "네, 영수증 AI 스캔에서 사진을 올리면 항목별 금액을 인식해서 표로 보여드리고, 확인 후 '이 매출 저장하기'를 누르면 매출로 등록돼요. 인식이 틀린 부분은 표에서 직접 수정할 수 있어요."},
        {"요금제는 언제든 변경할 수 있나요?", "네, 마이페이지의 '요금제'에서 언제든 업그레이드할 수 있어요. 다운그레이드가 필요하면 문의를 남겨주세요."},
        {"재고관리 안전재고는 어떻게 설정하나요?", "재고관리 페이지에서 품목을 추가할 때 '안전선' 수치를 입력하면, 현재고가 그 아래로 떨어질 때 자동으로 경고와 발주 추천 수량이 표시돼요."},
        {"광고 신청하면 바로 노출되나요?", "아니요, 신청 후 관리자 검토를 거쳐 승인되면 홈페이지 메인에 노출돼요. 보통 영업일 기준 1~2일 내 처리돼요."},
        {"매출 데이터는 엑셀/PDF로 받을 수 있나요?", "네, 매출 통계 페이지에서 엑셀(CSV, 월별 집계 포함)과 PDF(공식 문서 양식) 둘 다 다운로드할 수 있어요."}
    };
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 고객센터 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div style="font-size:19px; font-weight:800; color:#1E1B2E; margin-bottom:16px;"><i class="bi bi-headset"></i> 고객센터</div>

            <button type="button" data-bs-toggle="offcanvas" data-bs-target="#inquirySheet" style="width:100%; background:#8B5CF6; color:#fff; border:none; border-radius:14px; padding:14px; font-weight:700; font-size:14px; margin-bottom:18px;">
                <i class="bi bi-chat-dots"></i> 1:1 문의하기
            </button>

            <% if ("1".equals(request.getParameter("done"))) { %>
                <div class="alert alert-success py-2" style="font-size:12.5px; border-radius:12px;"><i class="bi bi-check-circle"></i> 문의가 접수됐어요!</div>
            <% } %>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">자주 묻는 질문</div>
            <div style="background:#fff; border-radius:16px; padding:6px 4px; margin-bottom:20px;">
                <div class="accordion" id="faqAccordionApp">
                    <% for (int i = 0; i < faqs.length; i++) { %>
                    <div class="accordion-item" style="border:none; background:transparent;">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqApp<%= i %>" style="font-size:13px; font-weight:600; background:transparent; box-shadow:none;">
                                <%= faqs[i][0] %>
                            </button>
                        </h2>
                        <div id="faqApp<%= i %>" class="accordion-collapse collapse" data-bs-parent="#faqAccordionApp">
                            <div class="accordion-body" style="font-size:12.5px; color:#8b87a3; line-height:1.7;"><%= faqs[i][1] %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">내 문의 내역</div>
            <% if (dbError != null) { %>
                <div class="alert alert-warning py-2" style="font-size:12px; border-radius:12px;"><i class="bi bi-exclamation-triangle"></i> <%= dbError %></div>
            <% } else if (myInquiries.isEmpty()) { %>
                <div style="text-align:center; padding:24px 0; color:#8b87a3; font-size:12.5px;">아직 문의 내역이 없어요</div>
            <% } else { for (Inquiry i : myInquiries) { %>
                <div style="background:#fff; border-radius:12px; padding:12px 14px; margin-bottom:8px;">
                    <div class="d-flex justify-content-between">
                        <span style="font-size:11.5px; color:#8b87a3;"><%= i.getCreatedAt() %></span>
                        <span class="badge <%= "PENDING".equals(i.getStatus()) ? "bg-warning" : "bg-success" %>" style="font-size:9.5px;"><%= "PENDING".equals(i.getStatus()) ? "대기중" : "답변완료" %></span>
                    </div>
                    <div style="font-size:12.5px; margin-top:4px; color:#1E1B2E;"><%= i.getContent() %></div>
                    <% if (i.getAdminReply() != null) { %>
                        <div style="background:#F7F6FB; border-radius:8px; padding:8px 10px; margin-top:6px; font-size:11.5px; color:#374151;"><b>답변:</b> <%= i.getAdminReply() %></div>
                    <% } %>
                </div>
            <% } } %>
        </div>

        <div class="offcanvas offcanvas-bottom" tabindex="-1" id="inquirySheet" style="border-radius:20px 20px 0 0;">
            <div class="offcanvas-header">
                <h6 class="offcanvas-title"><i class="bi bi-chat-dots"></i> 1:1 문의</h6>
                <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
            </div>
            <div class="offcanvas-body">
                <form action="InquiryServlet" method="post">
                    <textarea name="content" class="form-control mb-2" rows="5" placeholder="FAQ에 없는 내용은 여기로 문의해주세요" required></textarea>
                    <button type="submit" class="btn-moa w-100 justify-content-center">문의 보내기</button>
                </form>
            </div>
        </div>
        <script>
            if (typeof bootstrap === 'undefined') {
                document.write('<scr' + 'ipt src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></scr' + 'ipt>');
            }
        </script>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 화면 ===================== -->
        <div class="p-4">
        <h4 class="mb-4"><i class="bi bi-headset"></i> 고객센터</h4>

        <div class="row g-3">
            <div class="col-lg-7">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-patch-question"></i> 자주 묻는 질문</h6>
                    <div class="accordion" id="faqAccordion">
                        <% for (int i = 0; i < faqs.length; i++) { %>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq<%= i %>" style="font-size:13.5px; font-weight:600;">
                                    <%= faqs[i][0] %>
                                </button>
                            </h2>
                            <div id="faq<%= i %>" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body" style="font-size:13px; color:var(--text-muted); line-height:1.7;"><%= faqs[i][1] %></div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-chat-dots"></i> 1:1 문의</h6>
                    <% if (dbError != null) { %>
                        <div class="alert alert-warning py-2" style="font-size:12.5px;"><i class="bi bi-exclamation-triangle"></i> <%= dbError %></div>
                    <% } %>
                    <% if ("1".equals(request.getParameter("done"))) { %>
                        <div class="alert alert-success py-2" style="font-size:12.5px;"><i class="bi bi-check-circle"></i> 문의가 접수됐어요!</div>
                    <% } %>
                    <form action="InquiryServlet" method="post">
                        <textarea name="content" class="form-control mb-2" rows="4" placeholder="FAQ에 없는 내용은 여기로 문의해주세요" required></textarea>
                        <button type="submit" class="btn-moa w-100 justify-content-center">문의 보내기</button>
                    </form>
                </div>

                <div class="moa-card">
                    <h6 class="mb-2">내 문의 내역</h6>
                    <% if (myInquiries.isEmpty()) { %>
                        <p class="text-muted text-center py-4 mb-0" style="font-size:13px;">아직 문의 내역이 없어요</p>
                    <% } else { for (Inquiry i : myInquiries) { %>
                        <div style="padding:10px 4px; border-bottom:1px solid var(--border);">
                            <div class="d-flex justify-content-between">
                                <span style="font-size:12px; color:var(--text-muted);"><%= i.getCreatedAt() %></span>
                                <span class="badge <%= "PENDING".equals(i.getStatus()) ? "bg-warning" : "bg-success" %>" style="font-size:10px;"><%= "PENDING".equals(i.getStatus()) ? "대기중" : "답변완료" %></span>
                            </div>
                            <div style="font-size:13px; margin-top:3px;"><%= i.getContent() %></div>
                            <% if (i.getAdminReply() != null) { %>
                                <div class="alert alert-light py-1 px-2 mt-1 mb-0" style="font-size:12px;"><b>답변:</b> <%= i.getAdminReply() %></div>
                            <% } %>
                        </div>
                    <% } } %>
                </div>
            </div>
        </div>
        </div>
    <% } %>
    </main>
</div>
<jsp:include page="chat_widget.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
