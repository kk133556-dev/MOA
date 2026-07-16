<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
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
        .excel-table-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; }
    </style>
</head>
<body>
<%
    if (session.getAttribute("storeId") == null) { response.sendRedirect("login.jsp"); return; }
    String currentMenu = "receipt";
%>
<div class="d-flex">
    <%@ include file="mypage_sidebar.jsp" %>
    <main class="flex-grow-1<%= isApp ? "" : " p-4" %>">
    <% if (isApp) { %>
        <!-- ===================== 앱 전용 영수증 스캔 화면 ===================== -->
        <div style="padding:18px 16px 24px; background:#F7F6FB; min-height:100vh;">
            <div style="font-size:19px; font-weight:800; color:#1E1B2E; margin-bottom:16px;"><i class="bi bi-camera"></i> 영수증 AI 스캔</div>

            <div style="background:#fff; border-radius:16px; padding:16px;" id="uploadCard">
                <div id="uploadZone" style="border:2px dashed #DDD8EE; border-radius:14px; padding:40px 16px; text-align:center; cursor:pointer; background:#FAFAFF;">
                    <i class="bi bi-cloud-arrow-up" style="font-size:32px; color:#8B5CF6;"></i>
                    <p class="mt-2 mb-0" style="font-size:13px; color:#1E1B2E;">영수증 사진을 눌러서 업로드하세요</p>
                    <p style="font-size:11px; color:#8b87a3; margin-top:4px;">카메라로 바로 찍거나 갤러리에서 선택할 수 있어요</p>
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

            <div style="background:#fff; border-radius:16px; padding:16px; margin-top:14px; display:none;" id="resultCard">
                <p style="font-size:11.5px; color:#8b87a3;"><i class="bi bi-info-circle"></i> 셀을 눌러서 값을 바로 수정할 수 있어요. 카드/현금은 서로 자동으로 맞춰져요.</p>

                <div class="excel-table-scroll">
                    <table class="excel-table mb-2">
                        <thead><tr><th>항목</th><th style="width:56px;">수량</th><th style="width:70px;">단가</th><th style="width:80px;">금액</th><th style="width:30px;"></th></tr></thead>
                        <tbody id="itemBody"></tbody>
                        <tfoot>
                            <tr><td colspan="3">합계 (총 매출)</td><td id="totalCell">0</td><td></td></tr>
                            <tr><td colspan="3">카드 매출</td><td contenteditable id="cardCell">0</td><td></td></tr>
                            <tr><td colspan="3">현금 매출</td><td contenteditable id="cashCell">0</td><td></td></tr>
                        </tfoot>
                    </table>
                </div>
                <button type="button" id="addItemBtn" class="btn-moa-outline btn-moa-sm mb-3 mt-2"><i class="bi bi-plus-lg"></i> 품목 추가</button>

                <form action="SalesServlet" method="post" id="saveForm">
                    <input type="hidden" name="total" id="fTotal">
                    <input type="hidden" name="card" id="fCard">
                    <input type="hidden" name="cash" id="fCash">
                    <input type="hidden" name="receiptImage" id="fReceiptImage">
                    <button type="submit" class="btn-moa w-100 justify-content-center">이 매출 저장하기</button>
                </form>
            </div>
            <div style="background:#fff; border-radius:16px; padding:30px 16px; margin-top:14px; text-align:center; color:#8b87a3;" id="emptyMsg">
                <i class="bi bi-arrow-up" style="font-size:18px;"></i>
                <p class="mt-2 mb-0" style="font-size:12.5px;">위에서 영수증을 업로드하면 여기에 분석 결과가 나와요</p>
            </div>
        </div>
    <% } else { %>
        <!-- ===================== 기존 PC/웹 화면 ===================== -->
        <div class="p-4">
        <h4 class="mb-4"><i class="bi bi-camera"></i> 영수증 AI 스캔</h4>

        <div class="row g-3">
            <div class="col-lg-5">
                <div class="moa-card">
                    <div id="uploadZoneWeb" style="border:2px dashed var(--border); border-radius:12px; padding:50px 20px; text-align:center; cursor:pointer;">
                        <i class="bi bi-cloud-arrow-up" style="font-size:36px; color:var(--primary);"></i>
                        <p class="mt-2 mb-0" style="font-size:13.5px;">영수증 사진을 클릭해서 업로드하세요</p>
                        <input type="file" id="receiptFileWeb" accept="image/*" style="display:none;">
                    </div>
                    <div id="scanningBoxWeb" style="display:none; text-align:center; padding:30px 20px;">
                        <div class="spinner-border text-primary"></div>
                        <p class="mt-2" style="font-size:13px;">AI가 영수증을 분석하고 있어요...</p>
                    </div>
                    <button type="button" id="rescanBtnWeb" class="btn-moa-outline w-100 justify-content-center mt-3" style="display:none;">
                        <i class="bi bi-arrow-counterclockwise"></i> 다른 영수증 다시 스캔하기
                    </button>
                </div>
            </div>

            <div class="col-lg-7">
                <div class="moa-card" id="resultCardWeb" style="display:none;">
                    <p style="font-size:12px; color:var(--text-muted);"><i class="bi bi-info-circle"></i> 엑셀처럼 셀을 눌러서 값을 바로 수정할 수 있어요. 잘못 잡힌 줄은 지우고, 빠진 품목은 추가하세요. 카드/현금은 서로 자동으로 맞춰져요.</p>

                    <table class="excel-table mb-2">
                        <thead><tr><th>항목</th><th style="width:70px;">수량</th><th style="width:90px;">단가</th><th style="width:100px;">금액</th><th style="width:36px;"></th></tr></thead>
                        <tbody id="itemBodyWeb"></tbody>
                        <tfoot>
                            <tr><td colspan="3">합계 (총 매출)</td><td id="totalCellWeb">0</td><td></td></tr>
                            <tr><td colspan="3">카드 매출</td><td contenteditable id="cardCellWeb">0</td><td></td></tr>
                            <tr><td colspan="3">현금 매출</td><td contenteditable id="cashCellWeb">0</td><td></td></tr>
                        </tfoot>
                    </table>
                    <button type="button" id="addItemBtnWeb" class="btn-moa-outline btn-moa-sm mb-3"><i class="bi bi-plus-lg"></i> 품목 추가</button>

                    <form action="SalesServlet" method="post" id="saveFormWeb">
                        <input type="hidden" name="total" id="fTotalWeb">
                        <input type="hidden" name="card" id="fCardWeb">
                        <input type="hidden" name="cash" id="fCashWeb">
                        <input type="hidden" name="receiptImage" id="fReceiptImageWeb">
                        <button type="submit" class="btn-moa w-100 justify-content-center">이 매출 저장하기</button>
                    </form>
                </div>
                <div class="moa-card text-center py-5" id="emptyMsgWeb" style="color:var(--text-muted);">
                    <i class="bi bi-arrow-left" style="font-size:20px;"></i>
                    <p class="mt-2 mb-0" style="font-size:13px;">왼쪽에서 영수증을 업로드하면 여기에 분석 결과가 나와요</p>
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
    var zone = document.getElementById('uploadZone' + suf);
    var fileInput = document.getElementById('receiptFile' + suf);
    var scanningBox = document.getElementById('scanningBox' + suf);
    var rescanBtn = document.getElementById('rescanBtn' + suf);
    var resultCard = document.getElementById('resultCard' + suf);
    var emptyMsg = document.getElementById('emptyMsg' + suf);
    var itemBody = document.getElementById('itemBody' + suf);
    var totalCell = document.getElementById('totalCell' + suf);
    var cardCell = document.getElementById('cardCell' + suf);
    var cashCell = document.getElementById('cashCell' + suf);
    var fReceiptImage = document.getElementById('fReceiptImage' + suf);

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
                cardCell.textContent = data.cardEstimate != null ? data.cardEstimate : 0;
                cashCell.textContent = data.cashEstimate != null ? data.cashEstimate : 0;
                fReceiptImage.value = data.imagePath || '';
                recalc();
            })
            .catch(function () {
                scanningBox.style.display = 'none';
                zone.style.display = 'block';
                rescanBtn.style.display = 'none';
                alert('영수증 분석 요청 자체가 실패했어요 (네트워크/서버 오류).');
            });
    });

    function makeRow(name, qty, price) {
        var tr = document.createElement('tr');
        tr.innerHTML =
            '<td contenteditable>' + name + '</td>' +
            '<td contenteditable class="qty">' + qty + '</td>' +
            '<td contenteditable class="price">' + price + '</td>' +
            '<td class="amount">' + (qty * price) + '</td>' +
            '<td class="text-center"><i class="bi bi-trash rowDelBtn" style="cursor:pointer; color:#DC2626;"></i></td>';
        return tr;
    }

    function renderItems(items) {
        itemBody.innerHTML = '';
        items.forEach(function (item) {
            itemBody.appendChild(makeRow(item.name, item.qty, item.price));
        });
    }

    document.getElementById('addItemBtn' + suf).addEventListener('click', function () {
        itemBody.appendChild(makeRow('새 품목', 1, 0));
        recalc();
    });

    itemBody.addEventListener('click', function (e) {
        if (e.target.classList.contains('rowDelBtn')) {
            e.target.closest('tr').remove();
            recalc();
        }
    });

    var lastEditedPayCell = null;

    function recalc() {
        var total = 0;
        itemBody.querySelectorAll('tr').forEach(function (tr) {
            var qty = parseFloat(tr.querySelector('.qty').textContent) || 0;
            var price = parseFloat(tr.querySelector('.price').textContent) || 0;
            var amount = qty * price;
            tr.querySelector('.amount').textContent = amount;
            total += amount;
        });
        totalCell.textContent = total;
        balancePay(lastEditedPayCell);
    }

    function balancePay(editedSide) {
        var total = parseFloat(totalCell.textContent) || 0;
        var card = parseFloat(cardCell.textContent) || 0;
        var cash = parseFloat(cashCell.textContent) || 0;

        if (editedSide === 'card') {
            cash = Math.max(0, total - card);
            cashCell.textContent = cash;
        } else if (editedSide === 'cash') {
            card = Math.max(0, total - cash);
            cardCell.textContent = card;
        } else {
            var sum = card + cash;
            if (sum > 0) {
                cardCell.textContent = Math.round(total * (card / sum));
                cashCell.textContent = total - Math.round(total * (card / sum));
            } else {
                cardCell.textContent = total;
                cashCell.textContent = 0;
            }
        }
    }

    itemBody.addEventListener('input', recalc);
    cardCell.addEventListener('input', function () { lastEditedPayCell = 'card'; balancePay('card'); });
    cashCell.addEventListener('input', function () { lastEditedPayCell = 'cash'; balancePay('cash'); });

    rescanBtn.addEventListener('click', function () {
        resultCard.style.display = 'none';
        emptyMsg.style.display = 'block';
        zone.style.display = 'block';
        rescanBtn.style.display = 'none';
        itemBody.innerHTML = '';
        totalCell.textContent = '0';
        cardCell.textContent = '0';
        cashCell.textContent = '0';
        fReceiptImage.value = '';
        fileInput.value = '';
    });

    document.getElementById('saveForm' + suf).addEventListener('submit', function () {
        document.getElementById('fTotal' + suf).value = totalCell.textContent;
        document.getElementById('fCard' + suf).value = cardCell.textContent;
        document.getElementById('fCash' + suf).value = cashCell.textContent;
    });
</script>
<jsp:include page="chat_widget.jsp" />
</body>
</html>
