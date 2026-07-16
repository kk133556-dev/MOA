<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<button class="chat-fab" id="chatFab"><i class="bi bi-chat-dots-fill"></i></button>
<div class="chat-panel" id="chatPanel">
    <div class="chat-panel-header">
        <span>MOA 챗봇</span>
        <span id="chatClose" style="cursor:pointer;"><i class="bi bi-x-lg"></i></span>
    </div>
    <div class="chat-panel-body" id="chatBody">
        <div class="chat-bubble bot">안녕하세요! 저는 MOA 챗봇이에요 🙂<br>매출등록, 영수증스캔, 요금제, 발주, 재고, 다이어리 뭐든 물어보세요.</div>
    </div>
    <div class="chat-quick">
        <span data-link="mypage.jsp">마이페이지</span>
        <span data-link="pricing.jsp">요금제</span>
        <span data-link="ai_receipt.jsp">영수증 스캔</span>
        <span data-link="inventory.jsp">재고관리</span>
    </div>
    <div class="chat-input-row">
        <input type="text" id="chatInput" placeholder="메시지를 입력하세요">
        <button id="chatSend"><i class="bi bi-send-fill"></i></button>
    </div>
</div>

<script>
(function () {
    var fab = document.getElementById('chatFab');
    var panel = document.getElementById('chatPanel');
    var close = document.getElementById('chatClose');
    var body = document.getElementById('chatBody');
    var input = document.getElementById('chatInput');
    var send = document.getElementById('chatSend');

    var saved = localStorage.getItem('moaChatPos');
    var isAppUA = navigator.userAgent.indexOf('MOAApp') > -1;
    if (isAppUA) {
        // 앱에서는 하단탭바 위, 항상 같은 자리에 고정해요. (드래그로 저장된 예전 PC 위치를 쓰면 화면마다 위치가 들쭉날쭉해 보여서)
        fab.style.right = '16px';
        fab.style.bottom = '90px';
    } else if (saved) {
        var pos = JSON.parse(saved);
        fab.style.right = pos.right + 'px';
        fab.style.bottom = pos.bottom + 'px';
    }
    var dragging = false, moved = false, startX, startY, startRight, startBottom;
    fab.addEventListener('mousedown', function (e) {
        if (isAppUA) return; // 앱에서는 위치 고정, 드래그 비활성화
        dragging = true; moved = false;
        startX = e.clientX; startY = e.clientY;
        var rect = fab.getBoundingClientRect();
        startRight = window.innerWidth - rect.right;
        startBottom = window.innerHeight - rect.bottom;
    });
    document.addEventListener('mousemove', function (e) {
        if (!dragging) return;
        var dx = startX - e.clientX, dy = startY - e.clientY;
        if (Math.abs(dx) > 5 || Math.abs(dy) > 5) moved = true;
        if (!moved) return;
        fab.style.right = Math.max(8, startRight + dx) + 'px';
        fab.style.bottom = Math.max(8, startBottom + dy) + 'px';
    });
    document.addEventListener('mouseup', function () {
        if (dragging && moved) localStorage.setItem('moaChatPos', JSON.stringify({ right: parseInt(fab.style.right), bottom: parseInt(fab.style.bottom) }));
        dragging = false;
    });
    fab.addEventListener('click', function (e) { if (moved) { e.stopPropagation(); return; } panel.classList.toggle('open'); });
    close.addEventListener('click', function () { panel.classList.remove('open'); });

    document.querySelectorAll('.chat-quick span').forEach(function (el) {
        el.addEventListener('click', function () { addBubble('이동할게요! <a href="' + el.getAttribute('data-link') + '">바로가기 →</a>', 'bot'); });
    });

    function addBubble(html, who) {
        var b = document.createElement('div');
        b.className = 'chat-bubble ' + who;
        b.innerHTML = html;
        body.appendChild(b);
        body.scrollTop = body.scrollHeight;
        return b;
    }

    function showTyping() {
        var b = addBubble('<span class="typing-dots">···</span>', 'bot');
        b.id = 'typingBubble';
        return b;
    }
    function removeTyping() {
        var t = document.getElementById('typingBubble');
        if (t) t.remove();
    }

    // DB(chatbot_intents/chatbot_keywords)에서 답을 찾아요. 더 이상 JS에 답이 하드코딩되어 있지 않아요.
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
        addBubble(text, 'user');
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
                addBubble('<span style="cursor:pointer; color:#4F46E5;" onclick="location.href=\'support.jsp\'">→ 1:1 문의로 직접 물어보기</span>', 'bot');
            }
        });
    }
    send.addEventListener('click', handleSend);
    input.addEventListener('keydown', function (e) { if (e.key === 'Enter') handleSend(); });
})();
</script>
