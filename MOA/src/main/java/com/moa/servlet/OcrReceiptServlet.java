package com.moa.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

// ⚠️ Google Cloud Console(https://console.cloud.google.com)에서 Vision API 사용 설정하고
//    발급받은 API 키를 아래에 넣어주세요. WEB-INF/lib에 org.json 라이브러리(json-*.jar)도 추가해야 해요.
@WebServlet("/OcrReceiptServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB 제한
public class OcrReceiptServlet extends HttpServlet {

    // 로컬 Eclipse에서 빠르게 테스트할 땐 아래 문자열에 직접 키를 넣어도 되지만,
    // Railway 등에 배포할 땐 소스코드에 키가 그대로 노출되면 안 되니까 환경변수(GOOGLE_VISION_API_KEY)를
    // 우선적으로 사용해요. Railway Variables에 GOOGLE_VISION_API_KEY를 등록해두면 자동으로 그 값을 써요.
    private static final String GOOGLE_VISION_API_KEY =
        System.getenv("GOOGLE_VISION_API_KEY") != null
            ? System.getenv("GOOGLE_VISION_API_KEY")
            : "여기에_로컬_테스트용_API_키_입력";
    private static final String VISION_URL = "https://vision.googleapis.com/v1/images:annotate?key=" + GOOGLE_VISION_API_KEY;

    // 금액/수량으로 볼 수 있는 "순수 숫자 토큰": 0~3자리 또는 1,000단위 콤마 형식만 인정해요.
    private static final Pattern NUMERIC_TOKEN = Pattern.compile("^[0-9]{1,3}(,[0-9]{3})*$");

    // 영수증에 흔히 나오는 "품목이 아닌 줄"들 - 이 단어가 포함된 줄은 품목으로 안 봐요.
    private static final String[] NON_ITEM_KEYWORDS = {
        "합계", "총액", "총 금액", "받을", "받은", "거스름", "카드", "현금", "테이블", "일시", "날짜",
        "관리자", "처리자", "주문순서", "이용해", "행복", "전화", "사업자", "포인트", "할인", "부가세",
        "봉사료", "품명", "품 명", "단가", "수량", "금액", "영수증", "매장", "테이블번호"
    };

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.getWriter().print("{\"error\":\"로그인이 필요해요\"}");
            return;
        }

        try {
            Part filePart = req.getPart("receiptImage");
            if (filePart == null) {
                resp.getWriter().print("{\"error\":\"이미지가 없어요\"}");
                return;
            }

            String base64Image;
            byte[] fileBytes;
            try (InputStream is = filePart.getInputStream()) {
                fileBytes = is.readAllBytes();
                base64Image = Base64.getEncoder().encodeToString(fileBytes);
            }

            // 영수증 원본 이미지를 서버에 저장해요 - 나중에 매출 기록에서 원본을 다시 확인할 수 있게.
            String savedImagePath = saveReceiptImage(fileBytes, filePart.getSubmittedFileName(), (Integer) session.getAttribute("storeId"));

            String ocrText = callGoogleVision(base64Image);
            List<String[]> items = parseReceiptText(ocrText); // {itemName, qty, price}

            JSONObject result = new JSONObject();
            JSONArray itemsArr = new JSONArray();
            int total = 0;
            for (String[] item : items) {
                JSONObject o = new JSONObject();
                o.put("name", item[0]);
                o.put("qty", item[1]);
                o.put("price", item[2]);
                itemsArr.put(o);
                try { total += Integer.parseInt(item[1]) * Integer.parseInt(item[2]); } catch (NumberFormatException ignore) {}
            }
            result.put("items", itemsArr);
            result.put("cardEstimate", total);
            result.put("cashEstimate", 0);
            result.put("imagePath", savedImagePath); // ai_receipt.jsp가 이 값을 그대로 SalesServlet에 넘겨서 매출기록에 같이 저장해요.
            resp.getWriter().print(result.toString());

        } catch (Exception e) {
            JSONObject err = new JSONObject();
            err.put("error", "OCR 분석 중 오류: " + e.getMessage());
            resp.getWriter().print(err.toString());
        }
    }

    // 웹앱 폴더 아래 uploads/receipts/{storeId}/ 에 원본 이미지를 저장해요.
    // 반환값은 웹에서 바로 <img src="..."> 로 쓸 수 있는 상대 경로예요.
    private String saveReceiptImage(byte[] fileBytes, String originalFileName, Integer storeId) throws IOException {
        String ext = "jpg";
        if (originalFileName != null && originalFileName.contains(".")) {
            ext = originalFileName.substring(originalFileName.lastIndexOf('.') + 1).replaceAll("[^a-zA-Z0-9]", "");
            if (ext.isEmpty()) ext = "jpg";
        }
        String realBase = getServletContext().getRealPath("/uploads/receipts/" + storeId);
        Path dir = Paths.get(realBase);
        Files.createDirectories(dir);

        String fileName = UUID.randomUUID().toString() + "." + ext;
        Path target = dir.resolve(fileName);
        Files.write(target, fileBytes);

        return "uploads/receipts/" + storeId + "/" + fileName;
    }

    private String callGoogleVision(String base64Image) throws IOException, InterruptedException {
        JSONObject imageObj = new JSONObject().put("content", base64Image);
        JSONObject feature = new JSONObject().put("type", "TEXT_DETECTION");
        JSONObject request = new JSONObject()
                .put("image", imageObj)
                .put("features", new JSONArray().put(feature));
        JSONObject body = new JSONObject().put("requests", new JSONArray().put(request));

        HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(15)).build();
        HttpRequest httpReq = HttpRequest.newBuilder()
                .uri(URI.create(VISION_URL))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                .build();
        HttpResponse<String> httpResp = client.send(httpReq, HttpResponse.BodyHandlers.ofString());

        JSONObject json = new JSONObject(httpResp.body());

        // Vision API가 에러를 반환한 경우(키가 잘못됐거나, Vision API가 활성화 안 됐거나 등)
        // 조용히 넘어가지 않고 이유를 그대로 예외로 던져서 화면에 보이게 해요.
        if (json.has("error")) {
            JSONObject err = json.getJSONObject("error");
            throw new IOException("Google Vision 오류: " + err.optString("message", "알 수 없는 오류"));
        }

        JSONArray responses = json.optJSONArray("responses");
        if (responses == null || responses.isEmpty()) return "";
        JSONObject first = responses.getJSONObject(0);

        if (first.has("error")) {
            JSONObject err = first.getJSONObject("error");
            throw new IOException("Google Vision 오류: " + err.optString("message", "알 수 없는 오류"));
        }

        JSONObject fullText = first.optJSONObject("fullTextAnnotation");
        return fullText != null ? fullText.optString("text", "") : "";
    }

    // OCR로 읽은 영수증 텍스트를 "품목 / 수량 / 단가" 라인들로 최대한 잘라내요.
    // 대부분의 한국 영수증은 한 줄에 "품목명  단가  수량  금액" 순으로 나열되니까,
    // 줄 끝에서부터 숫자처럼 보이는 토큰을 최대 3개까지 모아서 [단가, 수량, 금액]으로 봐요.
    // (단가 * 수량 = 금액이 되도록, 화면에서는 단가/수량만 넘기고 금액은 프론트에서 다시 계산해요)
    private List<String[]> parseReceiptText(String text) {
        List<String[]> items = new ArrayList<>();
        if (text == null || text.isEmpty()) return items;

        outer:
        for (String rawLine : text.split("\n")) {
            String line = rawLine.trim();
            if (line.isEmpty()) continue;

            for (String kw : NON_ITEM_KEYWORDS) {
                if (line.contains(kw)) continue outer;
            }
            // 날짜/시간처럼 보이는 줄(2024-02-24, 12:32:25 등)도 품목이 아니라고 보고 건너뛰어요.
            if (line.matches(".*\\d{4}-\\d{2}-\\d{2}.*") || line.matches(".*\\d{1,2}:\\d{2}:\\d{2}.*")) continue;

            String[] tokens = line.split("\\s+");
            if (tokens.length < 2) continue;

            List<String> numericTail = new ArrayList<>();
            int idx = tokens.length - 1;
            while (idx >= 0 && numericTail.size() < 3 && NUMERIC_TOKEN.matcher(tokens[idx]).matches()) {
                numericTail.add(0, tokens[idx].replace(",", ""));
                idx--;
            }
            if (numericTail.isEmpty()) continue; // 숫자 없는 줄(매장명 등)은 품목이 아니라고 보고 건너뜀

            String name = String.join(" ", java.util.Arrays.copyOfRange(tokens, 0, idx + 1)).trim();
            if (name.isEmpty() || name.length() > 30) continue;

            String qty, price;
            if (numericTail.size() >= 3) {
                // [단가, 수량, 금액]
                price = numericTail.get(0);
                qty = numericTail.get(1);
            } else if (numericTail.size() == 2) {
                // 열이 2개뿐이면 [단가, 금액]으로 보고 수량은 1로 가정해요 (완벽하진 않아요).
                price = numericTail.get(0);
                qty = "1";
            } else {
                price = numericTail.get(0);
                qty = "1";
            }

            try { if (Integer.parseInt(qty) > 100 || Integer.parseInt(qty) == 0) qty = "1"; } catch (NumberFormatException e) { qty = "1"; }

            items.add(new String[]{ name, qty, price });
        }
        return items;
    }
}
