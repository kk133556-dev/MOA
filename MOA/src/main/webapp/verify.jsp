<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>본인 확인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .verify-provider {
            display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px;
            border:1.5px solid var(--border); border-radius:12px; padding:16px 8px; cursor:pointer;
            transition: all .15s ease; background:#fff;
        }
        .verify-provider:hover, .verify-provider.selected { border-color:var(--primary); background:rgba(79,70,229,0.05); }
        .verify-provider .icon-badge { width:40px; height:40px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:18px; color:#fff; }
        .verify-provider .label { font-size:12px; font-weight:600; color:#374151; }
    </style>
</head>
<body>
<%
    if (session.getAttribute("memberId") == null) { response.sendRedirect("login.jsp"); return; }
    String plan = request.getParameter("plan");
%>
<div class="container py-5" style="max-width:460px;">
    <h4 class="text-center mb-1">본인 확인</h4>
    <p class="text-center text-muted mb-4" style="font-size:13px;">결제 전, 본인 확인이 필요해요</p>

    <!-- STEP 1: 인증 수단 선택 -->
    <div id="step1">
        <% if ("1".equals(request.getParameter("kakaoFail"))) { %>
            <div class="alert alert-danger py-2" style="font-size:12.5px;"><i class="bi bi-exclamation-circle"></i> 카카오 인증에 실패했어요. 다시 시도해주세요.</div>
        <% } %>
        <div class="moa-card">
            <h6 class="mb-3" style="font-size:13.5px;"><i class="bi bi-shield-check"></i> 인증 수단을 선택하세요</h6>
            <div class="row g-2">
                <div class="col-4">
                    <div class="verify-provider" data-provider="PASS">
                        <div class="icon-badge" style="background:#FF5D3B;"><i class="bi bi-phone"></i></div>
                        <span class="label">PASS</span>
                    </div>
                </div>
                <div class="col-4">
                    <a href="KakaoLoginServlet?plan=<%= plan %>" class="verify-provider" style="text-decoration:none;">
                        <div class="icon-badge" style="background:#FEE500; color:#3C1E1E;"><i class="bi bi-chat-fill"></i></div>
                        <span class="label">카카오톡</span>
                    </a>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="네이버">
                        <div class="icon-badge" style="background:#03C75A;"><i class="bi bi-n"></i></div>
                        <span class="label">네이버</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="통신사PASS">
                        <div class="icon-badge" style="background:#6D5BD0;"><i class="bi bi-broadcast"></i></div>
                        <span class="label">통신사PASS</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="국민인증서">
                        <div class="icon-badge" style="background:#FFBC00; color:#3C2E00;"><i class="bi bi-bank"></i></div>
                        <span class="label">국민인증서</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="휴대폰 인증">
                        <div class="icon-badge" style="background:var(--primary);"><i class="bi bi-telephone-fill"></i></div>
                        <span class="label">휴대폰 인증</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- STEP 2: 휴대폰 인증번호 확인 (데모) -->
    <div id="step2" style="display:none;">
        <div class="moa-card">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-arrow-left" id="backBtn" style="cursor:pointer; font-size:16px;"></i>
                <span id="providerLabel" style="font-size:13px; font-weight:700;"></span>
            </div>
            <div class="mb-2">
                <label class="form-label">휴대폰 번호</label>
                <div class="d-flex gap-2">
                    <input type="tel" id="phone" class="form-control" placeholder="010-0000-0000">
                    <button type="button" id="sendBtn" class="btn-moa-outline">인증번호 받기</button>
                </div>
            </div>
            <div id="codeBox" style="display:none;">
                <div class="d-flex gap-2 mb-2">
                    <input type="text" id="code" class="form-control" placeholder="인증번호 6자리" maxlength="6">
                    <button type="button" id="confirmBtn" class="btn-moa">확인</button>
                </div>
                <div id="msg" style="font-size:12px; color:#6b7280;"></div>
            </div>

            <form id="verifyForm" action="VerifyServlet" method="post" style="display:none;">
                <input type="hidden" name="plan" value="<%= plan %>">
            </form>
        </div>
    </div>
</div>

<script>
    var step1 = document.getElementById('step1');
    var step2 = document.getElementById('step2');
    var providerLabel = document.getElementById('providerLabel');

    document.querySelectorAll('.verify-provider').forEach(function (el) {
        el.addEventListener('click', function () {
            document.querySelectorAll('.verify-provider').forEach(function (p) { p.classList.remove('selected'); });
            el.classList.add('selected');
            providerLabel.textContent = el.dataset.provider + '로 인증하기';
            step1.style.display = 'none';
            step2.style.display = 'block';
        });
    });

    document.getElementById('backBtn').addEventListener('click', function () {
        step2.style.display = 'none';
        step1.style.display = 'block';
        document.getElementById('codeBox').style.display = 'none';
        document.getElementById('phone').value = '';
    });

    var demoCode = null;
    document.getElementById('sendBtn').addEventListener('click', function () {
        var phone = document.getElementById('phone').value.trim();
        if (!phone) { alert('휴대폰 번호를 입력해주세요'); return; }
        demoCode = String(Math.floor(100000 + Math.random() * 900000));
        document.getElementById('codeBox').style.display = 'block';
        document.getElementById('msg').textContent = '인증번호를 보냈어요. (데모: ' + demoCode + ')';
    });
    document.getElementById('confirmBtn').addEventListener('click', function () {
        var input = document.getElementById('code').value.trim();
        if (input === demoCode) {
            document.getElementById('verifyForm').submit();
        } else {
            document.getElementById('msg').innerHTML = '<span style="color:#dc3545;">인증번호가 일치하지 않아요</span>';
        }
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
