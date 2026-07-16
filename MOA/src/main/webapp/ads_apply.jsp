<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.AdDAO, com.moa.model.Ad, com.moa.dao.QuickAdTemplateDAO, com.moa.model.QuickAdTemplate"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>광고 신청</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .tpl-chip { font-size:11.5px; background:#F3F4F6; border:1px solid var(--border); padding:6px 10px; border-radius:14px; cursor:pointer; display:inline-flex; align-items:center; gap:4px; }
        .tpl-chip:hover { background:var(--primary); color:#fff; border-color:var(--primary); }
        .tpl-chip .tpl-del { font-size:13px; opacity:0.6; }
        .tpl-chip .tpl-del:hover { opacity:1; color:#DC2626; }
        .tpl-add-new { font-size:11.5px; background:#fff; border:1.5px dashed var(--border); padding:6px 10px; border-radius:14px; cursor:pointer; color:var(--primary); font-weight:600; }
        .tpl-add-new:hover { border-color:var(--primary); background:rgba(79,70,229,0.05); }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    int storeId = (Integer) session.getAttribute("storeId");
    List<Ad> myAds = new AdDAO().listByStore(storeId);
    List<QuickAdTemplate> quickTemplates = new QuickAdTemplateDAO().listByStore(storeId);
    String currentMenu = "ads";
    int approved=0, pending=0, rejected=0;
    for (Ad a : myAds) {
        if ("APPROVED".equals(a.getStatus())) approved++;
        else if ("PENDING".equals(a.getStatus())) pending++;
        else rejected++;
    }
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 광고신청 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div style="font-size:19px; font-weight:800; color:#1E1B2E; margin-bottom:16px;"><i class="bi bi-megaphone"></i> 메인 배너 광고</div>

            <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:8px; margin-bottom:16px;">
                <div style="background:#fff; border-radius:14px; padding:12px 8px; text-align:center;">
                    <div style="font-size:10px; color:#8b87a3; margin-bottom:4px;">전체</div>
                    <div style="font-size:15px; font-weight:800; color:#1E1B2E;"><%= myAds.size() %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:12px 8px; text-align:center;">
                    <div style="font-size:10px; color:#8b87a3; margin-bottom:4px;">노출중</div>
                    <div style="font-size:15px; font-weight:800; color:#16A34A;"><%= approved %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:12px 8px; text-align:center;">
                    <div style="font-size:10px; color:#8b87a3; margin-bottom:4px;">대기</div>
                    <div style="font-size:15px; font-weight:800; color:#F59E0B;"><%= pending %></div>
                </div>
                <div style="background:#fff; border-radius:14px; padding:12px 8px; text-align:center;">
                    <div style="font-size:10px; color:#8b87a3; margin-bottom:4px;">반려</div>
                    <div style="font-size:15px; font-weight:800; color:#9CA3AF;"><%= rejected %></div>
                </div>
            </div>

            <% if ("1".equals(request.getParameter("done"))) { %>
                <div class="alert alert-success py-2" style="font-size:12.5px; border-radius:12px;"><i class="bi bi-check-circle"></i> 신청됐어요! 관리자 승인 후 노출돼요.</div>
            <% } %>
            <% if ("1".equals(request.getParameter("deleted"))) { %>
                <div class="alert alert-success py-2" style="font-size:12.5px; border-radius:12px;"><i class="bi bi-check-circle"></i> 삭제됐어요.</div>
            <% } %>

            <button type="button" data-bs-toggle="offcanvas" data-bs-target="#adAddSheet" style="width:100%; background:#8B5CF6; color:#fff; border:none; border-radius:14px; padding:14px; font-weight:700; font-size:14px; margin-bottom:18px;">
                <i class="bi bi-plus-circle"></i> 새 광고 신청
            </button>

            <div style="font-size:13px; font-weight:700; margin-bottom:10px; color:#1E1B2E;">내 광고 신청 내역</div>
            <% if (myAds.isEmpty()) { %>
                <div style="text-align:center; padding:30px 0; color:#8b87a3; font-size:12.5px;">아직 신청한 광고가 없어요</div>
            <% } else { for (Ad a : myAds) {
                String badgeClass = "APPROVED".equals(a.getStatus()) ? "bg-success" : "PENDING".equals(a.getStatus()) ? "bg-warning" : "bg-secondary";
                String badgeText = "APPROVED".equals(a.getStatus()) ? "노출중" : "PENDING".equals(a.getStatus()) ? "승인대기" : "반려됨";
            %>
                <div style="background:#fff; border-radius:12px; padding:13px 14px; margin-bottom:8px;">
                    <div class="d-flex justify-content-between align-items-start">
                        <span style="font-size:13px; color:#1E1B2E; flex:1; padding-right:8px;"><%= a.getBannerText() %></span>
                        <span class="badge <%= badgeClass %>" style="font-size:10px; flex-shrink:0;"><%= badgeText %></span>
                    </div>
                    <% if ("APPROVED".equals(a.getStatus())) { %>
                        <div style="font-size:11px; color:#8b87a3; margin-top:5px;">
                            노출기간: <%= a.getStartDate() != null ? a.getStartDate() : "제한없음" %> ~ <%= a.getEndDate() != null ? a.getEndDate() : "무기한" %>
                        </div>
                    <% } %>
                    <form action="AdApplyServlet" method="post" onsubmit="return confirm('이 광고 신청을 삭제할까요?');" style="margin-top:8px;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="adId" value="<%= a.getAdId() %>">
                        <button type="submit" class="btn-moa-outline btn-moa-sm" style="color:#DC2626;"><i class="bi bi-trash"></i> 삭제</button>
                    </form>
                </div>
            <% } } %>

            <div style="background:#fff; border-radius:16px; padding:16px; margin-top:14px;">
                <div style="font-size:13px; font-weight:700; margin-bottom:8px; color:#1E1B2E;"><i class="bi bi-clipboard-check"></i> 광고 가이드라인</div>
                <ul style="font-size:12px; color:#8b87a3; line-height:1.8; padding-left:16px; margin-bottom:0;">
                    <li>배너 문구는 60자 이내로 간결하게 작성해주세요.</li>
                    <li>과장·허위 광고는 반려될 수 있어요.</li>
                    <li>승인은 영업일 기준 1~2일 내 처리돼요.</li>
                    <li>노출 기간은 관리자가 승인 시 설정해요.</li>
                </ul>
            </div>
        </div>

        <div class="offcanvas offcanvas-bottom" tabindex="-1" id="adAddSheet" style="border-radius:20px 20px 0 0; max-height:88vh;">
            <div class="offcanvas-header">
                <h6 class="offcanvas-title"><i class="bi bi-plus-circle"></i> 새 광고 신청</h6>
                <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
            </div>
            <div class="offcanvas-body">
                <form action="AdApplyServlet" method="post" id="adForm">
                    <label class="form-label" style="font-size:12px;">배너 문구</label>
                    <input type="text" name="bannerText" id="bannerInput" class="form-control mb-1" placeholder="예: OO식당 - 신규 오픈 이벤트!" required maxlength="60">
                    <div class="text-end mb-3" style="font-size:11px; color:var(--text-muted);"><span id="charCount">0</span> / 60자</div>

                    <label class="form-label" style="font-size:12px;">빠른 문구 템플릿 (눌러서 채우기, x로 삭제)</label>
                    <div class="d-flex flex-wrap gap-2 mb-3" id="tplList">
                        <% for (QuickAdTemplate q : quickTemplates) { %>
                        <span class="tpl-chip" data-id="<%= q.getQuickId() %>" data-tpl="<%= q.getTemplate() %>">
                            <%= q.getLabel() %> <i class="bi bi-x tpl-del" data-id="<%= q.getQuickId() %>"></i>
                        </span>
                        <% } %>
                        <span class="tpl-add-new" id="tplAddNewBtn"><i class="bi bi-plus"></i> 새 템플릿</span>
                    </div>

                    <button type="submit" class="btn-moa w-100 justify-content-center">신청하기</button>
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
        <h4 class="mb-4"><i class="bi bi-megaphone"></i> 메인 배너 광고 신청</h4>

        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value"><%= myAds.size() %></div><div class="kpi-label">전체 신청</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#16A34A;"><%= approved %></div><div class="kpi-label">노출중</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#F59E0B;"><%= pending %></div><div class="kpi-label">승인 대기</div></div></div>
            <div class="col-md-3 col-6"><div class="kpi-card"><div class="kpi-value" style="color:#9CA3AF;"><%= rejected %></div><div class="kpi-label">반려</div></div></div>
        </div>

        <div class="row g-3">
            <div class="col-lg-6">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-plus-circle"></i> 새 광고 신청</h6>
                    <% if ("1".equals(request.getParameter("done"))) { %>
                        <div class="alert alert-success py-2"><i class="bi bi-check-circle"></i> 신청됐어요! 관리자 승인 후 노출 기간에 맞춰 홈페이지에 노출돼요.</div>
                    <% } %>
                    <form action="AdApplyServlet" method="post" id="adFormWeb">
                        <label class="form-label" style="font-size:12px;">배너 문구</label>
                        <input type="text" name="bannerText" id="bannerInputWeb" class="form-control mb-1" placeholder="예: OO식당 - 신규 오픈 이벤트!" required maxlength="60">
                        <div class="text-end mb-3" style="font-size:11px; color:var(--text-muted);"><span id="charCountWeb">0</span> / 60자</div>

                        <label class="form-label" style="font-size:12px;">빠른 문구 템플릿 (눌러서 채우기, x로 삭제)</label>
                        <div class="d-flex flex-wrap gap-2 mb-3" id="tplListWeb">
                            <% for (QuickAdTemplate q : quickTemplates) { %>
                            <span class="tpl-chip" data-id="<%= q.getQuickId() %>" data-tpl="<%= q.getTemplate() %>">
                                <%= q.getLabel() %> <i class="bi bi-x tpl-del" data-id="<%= q.getQuickId() %>"></i>
                            </span>
                            <% } %>
                            <span class="tpl-add-new" id="tplAddNewBtnWeb"><i class="bi bi-plus"></i> 새 템플릿</span>
                        </div>

                        <button type="submit" class="btn-moa w-100 justify-content-center">신청하기</button>
                    </form>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="moa-card mb-3">
                    <h6 class="mb-3"><i class="bi bi-clock-history"></i> 내 광고 신청 내역</h6>
                    <% if ("1".equals(request.getParameter("deleted"))) { %>
                        <div class="alert alert-success py-2" style="font-size:12.5px;"><i class="bi bi-check-circle"></i> 삭제됐어요.</div>
                    <% } %>
                    <% if (myAds.isEmpty()) { %>
                        <p class="text-muted text-center py-4 mb-0">아직 신청한 광고가 없어요</p>
                    <% } else { for (Ad a : myAds) {
                        String badgeClass = "APPROVED".equals(a.getStatus()) ? "bg-success" : "PENDING".equals(a.getStatus()) ? "bg-warning" : "bg-secondary";
                        String badgeText = "APPROVED".equals(a.getStatus()) ? "노출중" : "PENDING".equals(a.getStatus()) ? "승인대기" : "반려됨";
                    %>
                        <div style="padding:11px 4px; border-bottom:1px solid var(--border);">
                            <div class="d-flex justify-content-between align-items-center">
                                <span style="font-size:13px;"><%= a.getBannerText() %></span>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge <%= badgeClass %>" style="font-size:10.5px;"><%= badgeText %></span>
                                    <form action="AdApplyServlet" method="post" onsubmit="return confirm('이 광고 신청을 삭제할까요?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="adId" value="<%= a.getAdId() %>">
                                        <button type="submit" class="btn-moa-outline btn-moa-sm" style="padding:2px 8px; color:#DC2626;"><i class="bi bi-trash"></i></button>
                                    </form>
                                </div>
                            </div>
                            <% if ("APPROVED".equals(a.getStatus())) { %>
                                <div style="font-size:11px; color:var(--text-muted); margin-top:3px;">
                                    노출기간: <%= a.getStartDate() != null ? a.getStartDate() : "제한없음" %> ~ <%= a.getEndDate() != null ? a.getEndDate() : "무기한" %>
                                </div>
                            <% } %>
                        </div>
                    <% } } %>
                </div>

                <div class="moa-card">
                    <h6 class="mb-2"><i class="bi bi-clipboard-check"></i> 광고 가이드라인</h6>
                    <ul style="font-size:12.5px; color:var(--text-muted); line-height:1.9; padding-left:18px; margin-bottom:0;">
                        <li>배너 문구는 60자 이내로 간결하게 작성해주세요.</li>
                        <li>과장·허위 광고는 반려될 수 있어요.</li>
                        <li>승인은 영업일 기준 1~2일 내 처리돼요.</li>
                        <li>노출 기간은 관리자가 승인 시 설정해요 (기본: 무기한).</li>
                        <li>동시에 여러 개 신청도 가능해요.</li>
                    </ul>
                </div>
            </div>
        </div>
        </div>
    <% } %>
    </main>
</div>

<script>
    var isAppPage = <%= isApp %>;
    var suf = isAppPage ? '' : 'Web';
    var bannerInput = document.getElementById('bannerInput' + suf);
    var charCount = document.getElementById('charCount' + suf);

    function syncCount() { charCount.textContent = bannerInput.value.length; }
    bannerInput.addEventListener('input', syncCount);

    var tplList = document.getElementById('tplList' + suf);

    function bindTplChip(chip) {
        chip.addEventListener('click', function (e) {
            if (e.target.classList.contains('tpl-del')) return;
            bannerInput.value = chip.dataset.tpl;
            syncCount();
        });
        chip.querySelector('.tpl-del').addEventListener('click', function (e) {
            e.stopPropagation();
            var params = new URLSearchParams();
            params.append('action', 'delete');
            params.append('quickId', chip.dataset.id);
            fetch('QuickAdTemplateServlet', { method: 'POST', body: params }).then(function () { chip.remove(); });
        });
    }
    tplList.querySelectorAll('.tpl-chip').forEach(bindTplChip);

    document.getElementById('tplAddNewBtn' + suf).addEventListener('click', function () {
        var label = prompt('템플릿 버튼에 표시할 짧은 이름 (예: 여름 특가)');
        if (!label || !label.trim()) return;
        var template = prompt('실제로 입력창에 채워질 문구를 입력하세요');
        if (!template || !template.trim()) return;
        var params = new URLSearchParams();
        params.append('action', 'add');
        params.append('label', label.trim());
        params.append('template', template.trim());
        fetch('QuickAdTemplateServlet', { method: 'POST', body: params })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var chip = document.createElement('span');
                chip.className = 'tpl-chip';
                chip.dataset.id = data.quickId;
                chip.dataset.tpl = template.trim();
                chip.innerHTML = label.trim().replace(/</g, '&lt;') + ' <i class="bi bi-x tpl-del" data-id="' + data.quickId + '"></i>';
                tplList.insertBefore(chip, document.getElementById('tplAddNewBtn' + suf));
                bindTplChip(chip);
            });
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
