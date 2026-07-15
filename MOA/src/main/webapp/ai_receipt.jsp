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
        .excel-table { border-collapse: collapse; width: 100%; font-size: 13px; }
        .excel-table th, .excel-table td { border: 1px solid #d1d5db; padding: 8px 10px; }
        .excel-table th { background: #F3F4F6; font-weight: 700; }
        .excel-table td[contenteditable] { background: #FFFBEB; }
        .excel-table tfoot td { font-weight: 800; background: #EEF2FF; }
        .excel-table tfoot td[contenteditable] { background: #FEF9C3; font-weight: 600; }
        .preview-table { width:100%; border-collapse:collapse; font-size:12.5px; }
        .preview-table th, .preview-table td { border:1px solid var(--border); padding:8px 6px; text-align:center; }
        .preview-table th { background:#F3F4F6; font-size:11px; }
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
            <div class="col-lg-6">
                <div class="moa-card mb-3" id="uploadCard">
                    <div id="uploadZone" style="border:2px dashed var(--border); border-radius:12px; padding:40px 20px; text-align:center; cursor:pointer;">
                        <i class="bi bi-cloud-arrow-up" style="font-size:32px; color:var(--primary);"></i>
                        <p class="mt-2 mb-0" style="font-size:13.5px;">영수증 사진을 클릭해서 업로드하세요</p>
                        <input type="file" id="receiptFile" accept="image/*" style="display:none;">
                    </div>
                    <div id="scanningBox" style="display:none; text-align:center; padding:20px;">
                        <div class="spinner-border text-primary"></div>
                        <p class="mt-2" style="font-size:13px;">AI가 영수증을 분석하고 있어요...</p>
                    </div>
                </div>

                <div class="moa-card" id="resultCard" style="display:none;">
                    <p style="font-size:12px; color:var(--text-muted);"><i class="bi bi-info-circle"></i> 엑셀처럼 셀을 눌러서 값을 바로 수정할 수 있어요. 카드/현금은 서로 자동으로 맞춰져요.</p>

                    <table class="excel-table mb-3">
                        <thead><tr><th>항목</th><th>수량</th><th>단가</th><th>금액</th></tr></thead>
                        <tbody id="itemBody"></tbody>
                        <tfoot>
                            <tr><td colspan="3">합계 (총 매출)</td><td id="totalCell">0</td></tr>
                            <tr><td colspan="3">카드 매출</td><td contenteditable id="cardCell">0</td></tr>
                            <tr><td colspan="3">현금 매출</td><td contenteditable id="cashCell">0</td></tr>
                            <tr><td colspan="3">주류매출 <span style="font-weight:400; color:var(--text-muted);">(선택)</span></td><td contenteditable id="liquorCell">0</td></tr>
                            <tr><td colspan="3">수수료 <span style="font-weight:400; color:var(--text-muted);">(선택)</span></td><td contenteditable id="feeCell">0</td></tr>
                            <tr><td colspan="3">기타지출 <span style="font-weight:400; color:var(--text-muted);">(선택, 전기세·광고비 등)</span></td><td contenteditable id="otherCell">0</td></tr>
                        </tfoot>
                    </table>

                    <form action="SalesServlet" method="post" id="saveForm">
                        <input type="hidden" name="total" id="fTotal">
                        <input type="hidden" name="card" id="fCard">
                        <input type="hidden" name="cash" id="fCash">
                        <input type="hidden" name="liquor" id="fLiquor">
                        <input type="hidden" name="fee" id="fFee">
                        <input type="hidden" name="other" id="fOther">
                        <input type="hidden" name="receiptImage" id="fReceiptImage">
                        <div class="d-flex gap-2">
                            <button type="button" id="rescanBtn" class="btn-moa-outline" style="flex:1;"><i class="bi bi-arrow-counterclockwise"></i> 다시 스캔하기</button>
                            <button type="submit" class="btn-moa" style="flex:2; justify-content:center;">이 매출 저장하기</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="moa-card" style="position:sticky; top:20px;">
                    <h6 class="mb-1"><i class="bi bi-table"></i> 저장되면 이렇게 기록돼요</h6>
                    <p style="font-size:11.5px; color:var(--text-muted); margin-bottom:14px;">마이페이지 매출 기록에 실시간으로 미리 어떻게 쌓이는지 보여드려요.</p>
                    <table class="preview-table">
                        <thead><tr><th>날짜</th><th>총매출</th><th>카드</th><th>현금</th><th>주류</th><th>수수료</th><th>기타지출</th></tr></thead>
                        <tbody>
                            <tr>
                                <td id="pvDate">-</td>
                                <td id="pvTotal" style="font-weight:700; color:var(--primary);">0원</td>
                                <td id="pvCard">0원</td>
                                <td id="pvCash">0원</td>
                                <td id="pvLiquor">0원</td>
                                <td id="pvFee">0원</td>
                                <td id="pvOther">0원</td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="text-center mt-3" id="pvEmptyMsg" style="color:var(--text-muted); font-size:12.5px;">
                        <i class="bi bi-arrow-left"></i> 영수증을 업로드하면 여기에 미리보기가 나와요
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    var zone = document.getElementById('uploadZone');
    var fileInput = document.getElementById('receiptFile');
    var scanningBox = document.getElementById('scanningBox');
    var resultCard = document.getElementById('resultCard');
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
                if (data.error) {
                    zone.style.display = 'block';
                    alert('영수증 분석 실패: ' + data.error);
                    return;
                }
                resultCard.style.display = 'block';
                if (!data.items || data.items.length === 0) {
                    alert('영수증에서 품목을 인식하지 못했어요.\n\n[진단용 - 이 내용을 캡처해서 알려주세요]\n' + (data.debugRawText || '(텍스트도 비어있음)'));
                }
                renderItems(data.items || []);
                document.getElementById('cardCell').textContent = data.cardEstimate != null ? data.cardEstimate : 0;
                document.getElementById('cashCell').textContent = data.cashEstimate != null ? data.cashEstimate : 0;
                document.getElementById('fReceiptImage').value = data.imagePath || '';
                document.getElementById('pvDate').textContent = new Date().toISOString().slice(0, 10);
                document.getElementById('pvEmptyMsg').style.display = 'none';
                recalc();
            })
            .catch(function () {
                scanningBox.style.display = 'none';
                zone.style.display = 'block';
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

    var lastEditedPayCell = null; // 'card' 또는 'cash' - 마지막으로 사용자가 직접 건드린 쪽

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
        updatePreview();
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
            // 품목 수정으로 합계가 바뀐 경우엔 카드 비율을 유지한 채로 다시 나눠요.
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

    function updatePreview() {
        document.getElementById('pvTotal').textContent = Number(document.getElementById('totalCell').textContent).toLocaleString() + '원';
        document.getElementById('pvCard').textContent = Number(document.getElementById('cardCell').textContent).toLocaleString() + '원';
        document.getElementById('pvCash').textContent = Number(document.getElementById('cashCell').textContent).toLocaleString() + '원';
        document.getElementById('pvLiquor').textContent = Number(document.getElementById('liquorCell').textContent).toLocaleString() + '원';
        document.getElementById('pvFee').textContent = Number(document.getElementById('feeCell').textContent).toLocaleString() + '원';
        document.getElementById('pvOther').textContent = Number(document.getElementById('otherCell').textContent).toLocaleString() + '원';
    }

    itemBody.addEventListener('input', recalc);

    document.getElementById('cardCell').addEventListener('input', function () { lastEditedPayCell = 'card'; balancePay('card'); updatePreview(); });
    document.getElementById('cashCell').addEventListener('input', function () { lastEditedPayCell = 'cash'; balancePay('cash'); updatePreview(); });
    ['liquorCell', 'feeCell', 'otherCell'].forEach(function (id) {
        document.getElementById(id).addEventListener('input', updatePreview);
    });

    document.getElementById('rescanBtn').addEventListener('click', function () {
        resultCard.style.display = 'none';
        zone.style.display = 'block';
        itemBody.innerHTML = '';
        ['totalCell', 'cardCell', 'cashCell', 'liquorCell', 'feeCell', 'otherCell'].forEach(function (id) {
            document.getElementById(id).textContent = '0';
        });
        document.getElementById('fReceiptImage').value = '';
        document.getElementById('pvEmptyMsg').style.display = 'block';
        fileInput.value = '';
    });

    document.getElementById('saveForm').addEventListener('submit', function () {
        document.getElementById('fTotal').value = document.getElementById('totalCell').textContent;
        document.getElementById('fCard').value = document.getElementById('cardCell').textContent;
        document.getElementById('fCash').value = document.getElementById('cashCell').textContent;
        document.getElementById('fLiquor').value = document.getElementById('liquorCell').textContent;
        document.getElementById('fFee').value = document.getElementById('feeCell').textContent;
        document.getElementById('fOther').value = document.getElementById('otherCell').textContent;
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
