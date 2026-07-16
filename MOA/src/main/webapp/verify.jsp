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
        .rrn-input { text-align:center; letter-spacing:1px; }
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
                    <div class="verify-provider" data-provider="PASS" data-mode="push" data-color="#FF5D3B">
                        <div class="icon-badge" style="background:#FF5D3B;"><i class="bi bi-patch-check-fill"></i></div>
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
                    <div class="verify-provider" data-provider="네이버" data-mode="push" data-color="#03C75A">
                        <div class="icon-badge" style="background:#03C75A; font-weight:800; font-size:20px;">N</div>
                        <span class="label">네이버</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="통신사PASS" data-mode="push" data-color="#6D5BD0">
                        <div class="icon-badge" style="background:#6D5BD0;"><i class="bi bi-broadcast"></i></div>
                        <span class="label">통신사PASS</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="국민인증서" data-mode="push" data-color="#FFBC00">
                        <div class="icon-badge" style="background:#FFBC00; color:#3C2E00;"><i class="bi bi-bank"></i></div>
                        <span class="label">국민인증서</span>
                    </div>
                </div>
                <div class="col-4">
                    <div class="verify-provider" data-provider="휴대폰 인증" data-mode="sms" data-color="#4F46E5">
                        <div class="icon-badge" style="background:var(--primary);"><i class="bi bi-telephone-fill"></i></div>
                        <span class="label">휴대폰 인증</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- STEP 1.5: 본인정보 입력 (이름/생년월일/통신사/휴대폰번호 - 실제 PASS/통신사 인증 폼 방식) -->
    <div id="stepInfo" style="display:none;">
        <div class="moa-card">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-arrow-left" id="backBtnInfo" style="cursor:pointer; font-size:16px;"></i>
                <span id="providerLabelInfo" style="font-size:13px; font-weight:700;"></span>
            </div>
            <p style="font-size:11.5px; color:var(--text-muted); margin-bottom:16px;">본인 확인을 위해 아래 정보를 정확히 입력해주세요</p>

            <div class="mb-2">
                <label class="form-label" style="font-size:12px;">이름</label>
                <input type="text" id="infoName" class="form-control" placeholder="홍길동">
            </div>
            <div class="mb-2">
                <label class="form-label" style="font-size:12px;">생년월일 (6자리)</label>
                <input type="text" id="infoBirth" class="form-control rrn-input" placeholder="예) 990101" maxlength="6" inputmode="numeric">
            </div>
            <div class="mb-2">
                <label class="form-label" style="font-size:12px;">통신사</label>
                <select id="infoCarrier" class="form-control">
                    <option value="SKT">SKT</option>
                    <option value="KT">KT</option>
                    <option value="LGU+">LG U+</option>
                    <option value="SKT 알뜰폰">SKT 알뜰폰</option>
                    <option value="KT 알뜰폰">KT 알뜰폰</option>
                    <option value="LGU+ 알뜰폰">LG U+ 알뜰폰</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label" style="font-size:12px;">휴대폰 번호</label>
                <input type="tel" id="infoPhone" class="form-control" placeholder="010-0000-0000">
            </div>

            <div style="background:#F9FAFB; border-radius:8px; padding:10px 12px; margin-bottom:16px;">
                <label style="font-size:12px; display:flex; align-items:center; gap:6px; margin-bottom:6px; font-weight:600;">
                    <input type="checkbox" id="agreeAll"> 전체 동의
                </label>
                <label style="font-size:11.5px; display:flex; align-items:center; gap:6px; margin-bottom:4px; color:var(--text-muted);">
                    <input type="checkbox" class="agreeItem" required> 개인정보 수집·이용 동의 (필수)
                </label>
                <label style="font-size:11.5px; display:flex; align-items:center; gap:6px; color:var(--text-muted);">
                    <input type="checkbox" class="agreeItem" required> 고유식별정보 처리 동의 (필수)
                </label>
            </div>

            <button type="button" id="infoNextBtn" class="btn-moa w-100 justify-content-center">
                <i class="bi bi-shield-check"></i> 인증 요청
            </button>
        </div>
    </div>

    <!-- STEP 2: 휴대폰 인증번호 확인 (데모) -->
    <div id="step2" style="display:none;">
        <div class="moa-card">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-arrow-left" id="backBtn" style="cursor:pointer; font-size:16px;"></i>
                <span id="providerLabel" style="font-size:13px; font-weight:700;"></span>
            </div>
            <p style="font-size:12px; color:var(--text-muted); margin-bottom:10px;">입력하신 번호로 인증번호를 보냈어요</p>
            <div id="codeBox">
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

    <!-- STEP 3: 앱 푸시 인증 대기 (PASS/네이버/통신사PASS/국민인증서 - 실제 앱들처럼 문자 대신 푸시 승인 방식) -->
    <div id="step3" style="display:none;">
        <div class="moa-card text-center">
            <div class="d-flex align-items-center gap-2 mb-4">
                <i class="bi bi-arrow-left" id="backBtn3" style="cursor:pointer; font-size:16px;"></i>
                <span id="providerLabel3" style="font-size:13px; font-weight:700;"></span>
            </div>
            <div id="pushIcon" style="width:64px; height:64px; border-radius:16px; margin:0 auto 18px; display:flex; align-items:center; justify-content:center; font-size:28px; color:#fff;"></div>
            <p style="font-size:14px; font-weight:600; margin-bottom:6px;" id="pushTitle">인증 요청을 보냈어요</p>
            <p style="font-size:12.5px; color:var(--text-muted); margin-bottom:20px;" id="pushDesc">앱에서 인증 요청을 확인하고 승인해주세요</p>
            <div class="spinner-border text-primary mb-3" style="width:2rem; height:2rem;"></div>
            <p style="font-size:12px; color:var(--text-muted);">남은 시간 <b id="pushTimer">03:00</b></p>

            <button type="button" id="pushSimulateBtn" class="btn-moa w-100 justify-content-center mt-3">
                <i class="bi bi-phone-vibrate"></i> (데모) 앱에서 승인 완료
            </button>
        </div>
    </div>
</div>

<script>
    var step1 = document.getElementById('step1');
    var stepInfo = document.getElementById('stepInfo');
    var step2 = document.getElementById('step2');
    var step3 = document.getElementById('step3');
    var providerLabelInfo = document.getElementById('providerLabelInfo');
    var providerLabel = document.getElementById('providerLabel');
    var providerLabel3 = document.getElementById('providerLabel3');
    var pushIcon = document.getElementById('pushIcon');
    var pushTitle = document.getElementById('pushTitle');
    var pushDesc = document.getElementById('pushDesc');
    var pushTimerEl = document.getElementById('pushTimer');
    var pushTimerInterval = null;
    var selectedProviderEl = null;

    // STEP1: 인증수단 선택 -> STEP1.5(본인정보 입력)로
    document.querySelectorAll('.verify-provider').forEach(function (el) {
        el.addEventListener('click', function () {
            document.querySelectorAll('.verify-provider').forEach(function (p) { p.classList.remove('selected'); });
            el.classList.add('selected');
            selectedProviderEl = el;

            providerLabelInfo.textContent = el.dataset.provider + ' 본인 확인';
            step1.style.display = 'none';
            stepInfo.style.display = 'block';
        });
    });

    document.getElementById('backBtnInfo').addEventListener('click', function () {
        stepInfo.style.display = 'none';
        step1.style.display = 'block';
    });

    // 전체동의 체크박스
    document.getElementById('agreeAll').addEventListener('change', function () {
        var checked = this.checked;
        document.querySelectorAll('.agreeItem').forEach(function (c) { c.checked = checked; });
    });

    // STEP1.5: 본인정보 입력 완료 -> 인증수단별로 STEP2(문자) 또는 STEP3(앱푸시)
    document.getElementById('infoNextBtn').addEventListener('click', function () {
        var name = document.getElementById('infoName').value.trim();
        var birth = document.getElementById('infoBirth').value.trim();
        var phone = document.getElementById('infoPhone').value.trim();
        var agreedAll = Array.from(document.querySelectorAll('.agreeItem')).every(function (c) { return c.checked; });

        if (!name) { alert('이름을 입력해주세요'); return; }
        if (!/^[0-9]{6}$/.test(birth)) { alert('생년월일 6자리를 정확히 입력해주세요 (예: 990101)'); return; }
        if (!phone) { alert('휴대폰 번호를 입력해주세요'); return; }
        if (!agreedAll) { alert('필수 항목에 동의해주세요'); return; }

        var el = selectedProviderEl;
        var mode = el.dataset.mode;
        stepInfo.style.display = 'none';

        if (mode === 'push') {
            providerLabel3.textContent = el.dataset.provider + ' 인증';
            pushIcon.style.background = el.dataset.color;
            pushIcon.innerHTML = el.querySelector('.icon-badge').innerHTML;
            pushIcon.style.fontWeight = '800';
            pushIcon.style.fontSize = '26px';
            pushTitle.textContent = el.dataset.provider + ' 앱으로 인증 요청을 보냈어요';
            pushDesc.textContent = name + '님, ' + el.dataset.provider + ' 앱을 열어 알림을 확인하고 승인해주세요';
            step3.style.display = 'block';
            startPushTimer();
        } else {
            providerLabel.textContent = el.dataset.provider + '로 인증하기';
            step2.style.display = 'block';
            sendSmsCode(phone);
        }
    });

    function startPushTimer() {
        var remaining = 180;
        clearInterval(pushTimerInterval);
        pushTimerInterval = setInterval(function () {
            remaining--;
            var m = String(Math.floor(remaining / 60)).padStart(2, '0');
            var s = String(remaining % 60).padStart(2, '0');
            pushTimerEl.textContent = m + ':' + s;
            if (remaining <= 0) clearInterval(pushTimerInterval);
        }, 1000);
    }

    document.getElementById('pushSimulateBtn').addEventListener('click', function () {
        clearInterval(pushTimerInterval);
        document.getElementById('verifyForm').submit();
    });

    document.getElementById('backBtn3').addEventListener('click', function () {
        clearInterval(pushTimerInterval);
        step3.style.display = 'none';
        stepInfo.style.display = 'block';
    });

    document.getElementById('backBtn').addEventListener('click', function () {
        step2.style.display = 'none';
        stepInfo.style.display = 'block';
        document.getElementById('code').value = '';
    });

    var demoCode = null;
    function sendSmsCode(phone) {
        demoCode = String(Math.floor(100000 + Math.random() * 900000));
        document.getElementById('msg').textContent = phone + '로 인증번호를 보냈어요. (데모: ' + demoCode + ')';
    }
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
