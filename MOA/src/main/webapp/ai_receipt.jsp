<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>영수증 AI 스캔</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .excel-table { border-collapse: collapse; width: 100%; font-size: 13px; background: #fff; }
        .excel-table th, .excel-table td { border: 1px solid var(--border); padding: 9px 12px; }
        .excel-table th { background: #F9FAFB; font-weight: 700; font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.3px; }
        .excel-table td[contenteditable] { cursor: text; transition: background 0.15s ease; }
        .excel-table td[contenteditable]:hover { background: #F9FAFB; }
        .excel-table td[contenteditable]:focus { background: #EEF2FF; outline: 1.5px solid var(--primary); outline-offset: -1.5px; }
        .excel-table tfoot td { font-weight: 700; background: #FAFAFC; }
        .excel-table tfoot td[contenteditable]:hover { background: #F3F4F6; }
        .excel-table tfoot td[contenteditable]:focus { background: #EEF2FF; }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    String currentMenu = "receipt";
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-4"><i class="bi bi-camera"></i> 영수증 AI 스캔</h4>

        <div class="row g-3">
            <div class="col-lg-5">
                <div class="moa-card" id="uploadCard">
                    <div id="uploadZone" style="border:2px dashed var(--border); border-radius:12px; padding:50px 20px; text-align:center; cursor:pointer;">
                        <i class="bi bi-cloud-arrow-up" style="font-size:36px; color:var(--primary);"></i>
                        <p class="mt-2 mb-0" style="font-size:13.5px;">영수증 사진을 클릭해서 업로드하세요</p>
                        <input type="file" id="receiptFile" accept="image/*" style="display:none;">
                    </div>
                    <div id="scanningBox" style="display:none; text-align:center; padding:30px 20px;">
                        <div class="spinner-border text-primary"></div>
                        <p class="mt-2" style="font-size:13px;">AI가 영수증을 분석하고 있어요...</p>
                    </div>
                    <button type="button" id="rescanBtn" class="btn-moa-outline w-100 justify-content-center mt-3" style="display:none;">
                        <i class="bi bi-arrow-counterclockwise"></i> 다른 영수증 다시 스캔하기
                    </button>
                </div>
            </div>

            <div class="col-lg-7">
                <div class="moa-card" id="resultCard" style="display:none;">
                    <p style="font-size:12px; color:var(--text-muted);"><i class="bi bi-info-circle"></i> 엑셀처럼 셀을 눌러서 값을 바로 수정할 수 있어요. 카드/현금은 서로 자동으로 맞춰져요.</p>

                    <table class="excel-table mb-3">
                        <thead><tr><th>항목</th><th>수량</th><th>단가</th><th>금액</th></tr></thead>
                        <tbody id="itemBody"></tbody>
                        <tfoot>
                            <tr><td colspan="3">합계 (총 매출)</td><td id="totalCell">0</td></tr>
                            <tr><td colspan="3">카드 매출</td><td contenteditable id="cardCell">0</td></tr>
                            <tr><td colspan="3">현금 매출</td><td contenteditable id="cashCell">0</td></tr>
                        </tfoot>
                    </table>

                    <form action="SalesServlet" method="post" id="saveForm">
                        <input type="hidden" name="total" id="fTotal">
                        <input type="hidden" name="card" id="fCard">
                        <input type="hidden" name="cash" id="fCash">
                        <input type="hidden" name="receiptImage" id="fReceiptImage">
                        <button type="submit" class="btn-moa w-100 justify-content-center">이 매출 저장하기</button>
                    </form>
                </div>
                <div class="moa-card text-center py-5" id="emptyMsg" style="color:var(--text-muted);">
                    <i class="bi bi-arrow-left" style="font-size:20px;"></i>
                    <p class="mt-2 mb-0" style="font-size:13px;">왼쪽에서 영수증을 업로드하면 여기에 분석 결과가 나와요</p>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    var zone = document.getElementById('uploadZone');
    var fileInput = document.getElementById('receiptFile');
    var scanningBox = document.getElementById('scanningBox');
    var rescanBtn = document.getElementById('rescanBtn');
    var resultCard = document.getElementById('resultCard');
    var emptyMsg = document.getElementById('emptyMsg');
    var itemBody = document.getElementById('itemBody');

    zone.addEventListener('click', function () { fileInput.click(); });

    fileInput.addEventListener('change', function () {
        if (!fileInput.files[0]) return;
        zone.style.display = 'none';
        scanningBox.style.display = 'block';

        var formData = new FormData();
        formData.append('receiptImage', fileInput.files[0]);

        fetch('OcrReceiptServlet', { method: 'POST', body: formData })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                scanningBox.style.display = 'none';
                rescanBtn.style.display = 'block';
                if (data.error) {
                    zone.style.display = 'block';
                    rescanBtn.style.display = 'none';
                    alert('영수증 분석 실패: ' + data.error);
                    return;
                }
                emptyMsg.style.display = 'none';
                resultCard.style.display = 'block';
                if (!data.items || data.items.length === 0) {
                    alert('영수증에서 품목을 인식하지 못했어요.\n\n[진단용 - 이 내용을 캡처해서 알려주세요]\n' + (data.debugRawText || '(텍스트도 비어있음)'));
                }
                renderItems(data.items || []);
                document.getElementById('cardCell').textContent = data.cardEstimate != null ? data.cardEstimate : 0;
                document.getElementById('cashCell').textContent = data.cashEstimate != null ? data.cashEstimate : 0;
                document.getElementById('fReceiptImage').value = data.imagePath || '';
                recalc();
            })
            .catch(function () {
                scanningBox.style.display = 'none';
                zone.style.display = 'block';
                rescanBtn.style.display = 'none';
                alert('영수증 분석 요청 자체가 실패했어요 (네트워크/서버 오류).');
            });
    });

    function renderItems(items) {
        itemBody.innerHTML = '';
        items.forEach(function (item) {
            var tr = document.createElement('tr');
            tr.innerHTML =
                '<td contenteditable>' + item.name + '</td>' +
                '<td contenteditable class="qty">' + item.qty + '</td>' +
                '<td contenteditable class="price">' + item.price + '</td>' +
                '<td class="amount">' + (item.qty * item.price) + '</td>';
            itemBody.appendChild(tr);
        });
    }

    var lastEditedPayCell = null;

    function recalc() {
        var total = 0;
        document.querySelectorAll('#itemBody tr').forEach(function (tr) {
            var qty = parseFloat(tr.querySelector('.qty').textContent) || 0;
            var price = parseFloat(tr.querySelector('.price').textContent) || 0;
            var amount = qty * price;
            tr.querySelector('.amount').textContent = amount;
            total += amount;
        });
        document.getElementById('totalCell').textContent = total;
        balancePay(lastEditedPayCell);
    }

    // 카드/현금 중 하나를 고치면, 합계에 맞게 나머지 하나가 자동으로 계산돼요.
    function balancePay(editedSide) {
        var total = parseFloat(document.getElementById('totalCell').textContent) || 0;
        var cardEl = document.getElementById('cardCell');
        var cashEl = document.getElementById('cashCell');
        var card = parseFloat(cardEl.textContent) || 0;
        var cash = parseFloat(cashEl.textContent) || 0;

        if (editedSide === 'card') {
            cash = Math.max(0, total - card);
            cashEl.textContent = cash;
        } else if (editedSide === 'cash') {
            card = Math.max(0, total - cash);
            cardEl.textContent = card;
        } else {
            var sum = card + cash;
            if (sum > 0) {
                cardEl.textContent = Math.round(total * (card / sum));
                cashEl.textContent = total - Math.round(total * (card / sum));
            } else {
                cardEl.textContent = total;
                cashEl.textContent = 0;
            }
        }
    }

    itemBody.addEventListener('input', recalc);
    document.getElementById('cardCell').addEventListener('input', function () { lastEditedPayCell = 'card'; balancePay('card'); });
    document.getElementById('cashCell').addEventListener('input', function () { lastEditedPayCell = 'cash'; balancePay('cash'); });

    rescanBtn.addEventListener('click', function () {
        resultCard.style.display = 'none';
        emptyMsg.style.display = 'block';
        zone.style.display = 'block';
        rescanBtn.style.display = 'none';
        itemBody.innerHTML = '';
        document.getElementById('totalCell').textContent = '0';
        document.getElementById('cardCell').textContent = '0';
        document.getElementById('cashCell').textContent = '0';
        document.getElementById('fReceiptImage').value = '';
        fileInput.value = '';
    });

    document.getElementById('saveForm').addEventListener('submit', function () {
        document.getElementById('fTotal').value = document.getElementById('totalCell').textContent;
        document.getElementById('fCard').value = document.getElementById('cardCell').textContent;
        document.getElementById('fCash').value = document.getElementById('cashCell').textContent;
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
