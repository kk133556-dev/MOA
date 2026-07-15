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
        <div class="container" style="max-width:560px; margin:0;">
            <h4 class="mb-4"><i class="bi bi-camera"></i> 영수증 AI 스캔</h4>

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
                <p style="font-size:12px; color:var(--text-muted);"><i class="bi bi-info-circle"></i> 엑셀처럼 셀을 눌러서 값을 바로 수정할 수 있어요.</p>

                <table class="excel-table mb-3">
                    <thead><tr><th>항목</th><th>수량</th><th>단가</th><th>금액</th></tr></thead>
                    <tbody id="itemBody"></tbody>
                    <tfoot>
                        <tr><td colspan="3">합계 (총 매출)</td><td id="totalCell">0</td></tr>
                        <tr><td colspan="3">카드 매출 (추정)</td><td contenteditable id="cardCell">0</td></tr>
                        <tr><td colspan="3">현금 매출 (추정)</td><td contenteditable id="cashCell">0</td></tr>
                    </tfoot>
                </table>

                <form action="SalesServlet" method="post" id="saveForm">
                    <input type="hidden" name="total" id="fTotal">
                    <input type="hidden" name="card" id="fCard">
                    <input type="hidden" name="cash" id="fCash">
                    <input type="hidden" name="receiptImage" id="fReceiptImage">
                    <div class="d-flex gap-2">
                        <button type="button" id="rescanBtn" class="btn-moa-outline" style="flex:1;"><i class="bi bi-arrow-counterclockwise"></i> 다시 스캔하기</button>
                        <button type="submit" class="btn-moa" style="flex:2; justify-content:center;">이 매출 저장하기</button>
                    </div>
                </form>
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
                    // 서버에서 명확한 에러를 보내주면 빈 결과표 대신 실제 이유를 보여줘요.
                    zone.style.display = 'block';
                    alert('영수증 분석 실패: ' + data.error);
                    return;
                }
                resultCard.style.display = 'block';
                if (!data.items || data.items.length === 0) {
                    alert('영수증에서 품목을 인식하지 못했어요.\n\n[진단용 - 이 내용을 캡처해서 알려주세요]\n' + (data.debugRawText || '(텍스트도 비어있음 - Vision이 아무것도 못 읽었어요)'));
                }
                renderItems(data.items || []);
                document.getElementById('cardCell').textContent = data.cardEstimate != null ? data.cardEstimate : 0;
                document.getElementById('cashCell').textContent = data.cashEstimate != null ? data.cashEstimate : 0;
                document.getElementById('fReceiptImage').value = data.imagePath || '';
                recalc();
            })
            .catch(function (err) {
                scanningBox.style.display = 'none';
                zone.style.display = 'block';
                alert('영수증 분석 요청 자체가 실패했어요 (네트워크/서버 오류). 개발자도구 Network 탭에서 OcrReceiptServlet 응답을 확인해주세요.');
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
    }

    itemBody.addEventListener('input', recalc);

    document.getElementById('rescanBtn').addEventListener('click', function () {
        resultCard.style.display = 'none';
        zone.style.display = 'block';
        itemBody.innerHTML = '';
        document.getElementById('totalCell').textContent = '0';
        document.getElementById('cardCell').textContent = '0';
        document.getElementById('cashCell').textContent = '0';
        document.getElementById('fReceiptImage').value = '';
        fileInput.value = ''; // 같은 파일을 다시 선택해도 change 이벤트가 또 발생하게 초기화
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
