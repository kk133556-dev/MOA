<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>AI 비서 - MOA</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        html, body { height:100%; margin:0; overflow:hidden; }
        body { display:flex; flex-direction:column; background:#F7F6FB; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Malgun Gothic", sans-serif; }

        .ai-header {
            flex-shrink:0; background:linear-gradient(135deg,#1E1B2E,#332D52);
            padding:22px 20px 20px; color:#fff; position:relative; overflow:hidden;
        }
        .ai-header::after {
            content:''; position:absolute; right:-30px; top:-30px; width:140px; height:140px; border-radius:50%;
            background:radial-gradient(circle, rgba(139,92,246,0.35), transparent 70%);
        }
        .ai-header-row { display:flex; align-items:center; gap:12px; position:relative; z-index:1; }
        .ai-avatar {
            width:46px; height:46px; border-radius:14px; flex-shrink:0;
            background:linear-gradient(135deg,#8B5CF6,#6366F1); display:flex; align-items:center; justify-content:center;
            font-size:21px; box-shadow:0 6px 16px rgba(139,92,246,0.4);
        }
        .ai-title { font-size:17px; font-weight:800; margin:0; }
        .ai-subtitle { font-size:11.5px; color:#a39fc0; margin-top:2px; display:flex; align-items:center; gap:5px; }
        .ai-status-dot { width:6px; height:6px; border-radius:50%; background:#34D399; display:inline-block; box-shadow:0 0 0 2px rgba(52,211,153,0.25); }

        .ai-body { flex:1; overflow-y:auto; padding:18px 16px; display:flex; flex-direction:column; gap:10px; -webkit-overflow-scrolling:touch; }
        .ai-bubble { max-width:82%; padding:10px 14px; border-radius:16px; font-size:13.5px; line-height:1.5; }
        .ai-bubble.bot { background:#fff; border:1px solid #ECEAF4; align-self:flex-start; border-bottom-left-radius:4px; box-shadow:0 1px 2px rgba(0,0,0,0.03); }
        .ai-bubble.user { background:linear-gradient(135deg,#8B5CF6,#6366F1); color:#fff; align-self:flex-end; border-bottom-right-radius:4px; }
        .ai-bubble a { color:inherit; font-weight:700; text-decoration:underline; }
        .ai-bubble.bot a { color:#8B5CF6; }

        .ai-quick-wrap { flex-shrink:0; padding:0 16px 10px; }
        .ai-quick-label { font-size:11px; color:#9b97ad; margin-bottom:7px; font-weight:600; }
        .ai-quick { display:flex; gap:7px; overflow-x:auto; padding-bottom:2px; }
        .ai-quick span {
            flex-shrink:0; font-size:12px; font-weight:600; background:#fff; border:1px solid #ECEAF4; color:#332D52;
            padding:8px 14px; border-radius:20px; cursor:pointer; white-space:nowrap; transition:all .15s ease;
        }
        .ai-quick span:active { transform:scale(0.96); background:#F3F0FF; border-color:#8B5CF6; }

        .ai-input-bar { flex-shrink:0; display:flex; gap:8px; align-items:center; padding:12px 14px; background:#fff; border-top:1px solid #ECEAF4; }
        .ai-input-bar input {
            flex:1; border:1px solid #ECEAF4; background:#F7F6FB; border-radius:22px; padding:11px 16px; font-size:13.5px; outline:none;
        }
        .ai-input-bar input:focus { border-color:#8B5CF6; background:#fff; }
        .ai-send-btn {
            width:42px; height:42px; border-radius:50%; flex-shrink:0; border:none; color:#fff; font-size:16px;
            background:linear-gradient(135deg,#8B5CF6,#6366F1); display:flex; align-items:center; justify-content:center;
            box-shadow:0 4px 10px rgba(139,92,246,0.35);
        }
        .ai-send-btn:active { transform:scale(0.94); }

        .typing-dots { display:inline-block; letter-spacing:2px; }
    </style>
</head>
<body>

<div class="ai-header">
    <div class="ai-header-row">
        <div class="ai-avatar"><i class="bi bi-stars"></i></div>
        <div>
            <p class="ai-title">MOA AI 비서</p>
            <div class="ai-subtitle"><span class="ai-status-dot"></span> 언제든 물어보세요</div>
        </div>
    </div>
</div>

<div class="ai-body" id="aiBody">
    <div class="ai-bubble bot">안녕하세요! 저는 MOA AI 비서예요 🙂<br>매출등록, 영수증스캔, 요금제, 발주, 재고, 다이어리 뭐든 편하게 물어보세요.</div>
</div>

<div class="ai-quick-wrap">
    <div class="ai-quick-label">이런 것도 물어볼 수 있어요</div>
    <div class="ai-quick" id="aiQuick">
        <span data-link="mypage.jsp">마이페이지</span>
        <span data-link="pricing.jsp">요금제</span>
        <span data-link="ai_receipt.jsp">영수증 스캔</span>
        <span data-link="inventory.jsp">재고관리</span>
        <span data-link="reservation.jsp">예약관리</span>
        <span data-link="support.jsp">1:1 문의</span>
    </div>
</div>

<div class="ai-input-bar">
    <input type="text" id="aiInput" placeholder="메시지를 입력하세요" autocomplete="off">
    <button class="ai-send-btn" id="aiSend"><i class="bi bi-send-fill"></i></button>
</div>

<script>
(function () {
    var body = document.getElementById('aiBody');
    var input = document.getElementById('aiInput');
    var send = document.getElementById('aiSend');

    function addBubble(html, who) {
        var b = document.createElement('div');
        b.className = 'ai-bubble ' + who;
        b.innerHTML = html;
        body.appendChild(b);
        body.scrollTop = body.scrollHeight;
        return b;
    }

    function showTyping() {
        var b = addBubble('<span class="typing-dots">···</span>', 'bot');
        b.id = 'aiTypingBubble';
        return b;
    }
    function removeTyping() {
        var t = document.getElementById('aiTypingBubble');
        if (t) t.remove();
    }

    function askServer(text) {
        var params = new URLSearchParams();
        params.append('message', text);
        return fetch('ChatbotServlet', { method: 'POST', body: params })
            .then(function (r) { return r.json(); })
            .catch(function () { return { matched: false, error: true }; });
    }

    function handleSend() {
        var text = input.value.trim();
        if (!text) return;
        addBubble(text.replace(/</g, '&lt;'), 'user');
        input.value = '';
        showTyping();
        askServer(text).then(function (data) {
            removeTyping();
            if (data.matched) {
                var html = data.answer;
                if (data.link) html += ' <a href="' + data.link + '">바로가기 →</a>';
                addBubble(html, 'bot');
            } else {
                addBubble('음, 정확히는 모르겠어요 🤔 아래 중에 궁금하신 게 있을까요?', 'bot');
                addBubble('<a href="support.jsp">→ 1:1 문의로 직접 물어보기</a>', 'bot');
            }
        });
    }

    send.addEventListener('click', handleSend);
    input.addEventListener('keydown', function (e) { if (e.key === 'Enter') handleSend(); });

    document.querySelectorAll('.ai-quick span').forEach(function (el) {
        el.addEventListener('click', function () {
            addBubble('이동할게요! <a href="' + el.getAttribute('data-link') + '">바로가기 →</a>', 'bot');
        });
    });
})();
</script>
</body>
</html>
