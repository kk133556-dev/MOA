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

    // 금액/수량으로 볼 수 있는 "순수 숫자 토큰": 0~3자리 또는 1,000단위 콤마 형식, 할인 표시용 음수도 인정해요.
    private static final Pattern NUMERIC_TOKEN = Pattern.compile("^-?[0-9]{1,3}(,[0-9]{3})*$");

    // "3개", "2병", "3인분", "500ml" 처럼 숫자 뒤에 단위가 붙은 수량 표기도 수량으로 인식해요.
    // 괄호 안 숫자만 뽑아서 숫자 토큰으로 취급해요 (단위 글자는 버려요).
    // "3개", "2병", "3인분", "500g" 처럼 숫자 뒤에 단위가 붙은 수량 표기도 수량으로 인식해요.
    // ml/L은 일부러 뺐어요 - "360ml"처럼 거의 항상 상품명 안의 "용량 표시"라서, 수량으로 오인하면
    // 오히려 더 틀려요(예: "신참이슬병360ml"의 360을 수량으로 착각). kg/g은 정육점처럼 무게 단위로
    // 실제 "수량" 역할을 하는 경우가 많아서 남겨뒀어요.
    private static final Pattern QTY_WITH_UNIT = Pattern.compile(
        "^([0-9]{1,3})(개|병|캔|잔|봉|팩|세트|장|줄|판|모|알|인분|인|수|그릇|접시|공기|박스|근|통|ea|EA|kg|Kg|KG|g|G)$");

    // 영수증에 흔히 나오는 "품목이 아닌 줄"들 - 이 단어가 포함된 줄은 품목으로 안 봐요.
    // OCR이 한글 자모 사이를 띄어 인식하는 경우가 많아서("부 가 세" 등), 비교 전에 공백은 제거해요.
    private static final String[] NON_ITEM_KEYWORDS = {
        "합계", "총구매액", "총액", "총금액", "받을", "받은", "거스름", "카드", "현금", "테이블", "일시", "날짜",
        "관리자", "처리자", "주문순서", "이용해", "행복", "전화", "사업자", "포인트", "할인율", "부가세", "과세물품",
        "면세물품", "봉사료", "품명", "단가", "수량", "금액", "영수증", "매장", "테이블번호", "공병매출", "구매액",
        "결제금액", "결제", "확인번호", "승인번호", "자진발급", "소득공제", "hometax", "등록을", "해주시기",
        "교환", "환불", "방침", "지참", "구매점포", "제외", "pos-", "no:", "담당"
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
            if (items.isEmpty()) {
                // 품목을 하나도 못 찾았으면, Vision이 실제로 뭘 읽었는지 화면에서 바로 볼 수 있게
                // 원문 텍스트 앞부분을 같이 보내줘요. (원인 파악용 - 파싱 정확도 잡히면 나중에 빼도 돼요)
                result.put("debugRawText", ocrText.length() > 800 ? ocrText.substring(0, 800) + "..." : ocrText);
            }
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
        // DOCUMENT_TEXT_DETECTION을 쓰면 글자 하나하나(symbol) 단위로 좌표랑 "여기서 띄어썼다"는
        // 정보(detectedBreak)까지 받을 수 있어요. 이게 TEXT_DETECTION의 "단어" 단위보다 훨씬 정교해요.
        JSONObject feature = new JSONObject().put("type", "DOCUMENT_TEXT_DETECTION");
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

        JSONObject fullTextAnnotation = first.optJSONObject("fullTextAnnotation");
        if (fullTextAnnotation == null) return "";

        List<WordBox> tokens = extractTokensFromSymbols(fullTextAnnotation);
        if (!tokens.isEmpty()) {
            return rebuildLinesFromTokens(tokens);
        }

        // 심볼 단위 추출이 실패하면(드묾) 그냥 Vision이 준 원문 텍스트라도 사용해요.
        return fullTextAnnotation.optString("text", "");
    }

    private static class WordBox {
        String text;
        double xLeft;
        double yCenter;
        double height;
    }

    // pages -> blocks -> paragraphs -> words -> symbols 순으로 내려가면서 글자를 하나씩 읽어요.
    // 각 글자(symbol)마다 "이 글자 다음에 띄어쓰기/줄바꿈이 있었는지"(detectedBreak) 정보가 있는데,
    // 이걸 기준으로 "진짜 단어 경계"를 다시 판단해요. Vision의 자체 단어 판단보다 이게 더 정확해요.
    private List<WordBox> extractTokensFromSymbols(JSONObject fullTextAnnotation) {
        List<WordBox> tokens = new ArrayList<>();
        JSONArray pages = fullTextAnnotation.optJSONArray("pages");
        if (pages == null) return tokens;

        StringBuilder curText = new StringBuilder();
        double curMinX = Double.MAX_VALUE, curMinY = Double.MAX_VALUE, curMaxY = -Double.MAX_VALUE;
        boolean hasCur = false;

        for (int p = 0; p < pages.length(); p++) {
            JSONArray blocks = pages.getJSONObject(p).optJSONArray("blocks");
            if (blocks == null) continue;
            for (int b = 0; b < blocks.length(); b++) {
                JSONArray paragraphs = blocks.getJSONObject(b).optJSONArray("paragraphs");
                if (paragraphs == null) continue;
                for (int pa = 0; pa < paragraphs.length(); pa++) {
                    JSONArray words = paragraphs.getJSONObject(pa).optJSONArray("words");
                    if (words == null) continue;
                    for (int w = 0; w < words.length(); w++) {
                        JSONArray symbols = words.getJSONObject(w).optJSONArray("symbols");
                        if (symbols == null) continue;
                        for (int s = 0; s < symbols.length(); s++) {
                            JSONObject sym = symbols.getJSONObject(s);
                            String ch = sym.optString("text", "");
                            JSONObject boundingBox = sym.optJSONObject("boundingBox");
                            double[] box = boxMinMaxY(boundingBox);

                            curText.append(ch);
                            if (box != null) {
                                curMinX = Math.min(curMinX, box[0]);
                                curMinY = Math.min(curMinY, box[1]);
                                curMaxY = Math.max(curMaxY, box[2]);
                                hasCur = true;
                            }

                            String breakType = "";
                            JSONObject property = sym.optJSONObject("property");
                            if (property != null) {
                                JSONObject detectedBreak = property.optJSONObject("detectedBreak");
                                if (detectedBreak != null) {
                                    breakType = detectedBreak.optString("type", "");
                                }
                            }
                            boolean isBreak = breakType.equals("SPACE") || breakType.equals("SURE_SPACE")
                                    || breakType.equals("EOL_SURE_SPACE") || breakType.equals("LINE_BREAK")
                                    || breakType.equals("HYPHEN");

                            if (isBreak && hasCur) {
                                WordBox tb = new WordBox();
                                tb.text = curText.toString();
                                tb.xLeft = curMinX;
                                tb.yCenter = (curMinY + curMaxY) / 2.0;
                                tb.height = Math.max(1, curMaxY - curMinY);
                                tokens.add(tb);
                                curText.setLength(0);
                                curMinX = Double.MAX_VALUE; curMinY = Double.MAX_VALUE; curMaxY = -Double.MAX_VALUE;
                                hasCur = false;
                            }
                        }
                    }
                    // 단어 하나가 끝났는데 위에서 break 표시가 안 됐으면, 그래도 단어 경계로 봐요.
                    if (hasCur) {
                        WordBox tb = new WordBox();
                        tb.text = curText.toString();
                        tb.xLeft = curMinX;
                        tb.yCenter = (curMinY + curMaxY) / 2.0;
                        tb.height = Math.max(1, curMaxY - curMinY);
                        tokens.add(tb);
                        curText.setLength(0);
                        curMinX = Double.MAX_VALUE; curMinY = Double.MAX_VALUE; curMaxY = -Double.MAX_VALUE;
                        hasCur = false;
                    }
                }
            }
        }
        return tokens;
    }

    private double[] boxMinMaxY(JSONObject boundingBox) {
        if (boundingBox == null) return null;
        JSONArray vertices = boundingBox.optJSONArray("vertices");
        if (vertices == null || vertices.length() == 0) return null;
        double minX = Double.MAX_VALUE, minY = Double.MAX_VALUE, maxY = -Double.MAX_VALUE;
        for (int v = 0; v < vertices.length(); v++) {
            JSONObject pt = vertices.getJSONObject(v);
            double x = pt.optDouble("x", 0);
            double y = pt.optDouble("y", 0);
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
        }
        return new double[]{ minX, minY, maxY };
    }

    // y좌표(세로 위치)가 비슷한 토큰들끼리 한 줄로 묶은 다음, 그 줄 안에서는 x좌표(가로 위치) 순으로 정렬해요.
    private String rebuildLinesFromTokens(List<WordBox> words) {
        words.sort((a, b) -> Double.compare(a.yCenter, b.yCenter));

        List<List<WordBox>> lines = new ArrayList<>();
        List<WordBox> currentLine = new ArrayList<>();
        double lineRefY = -1, lineRefHeight = 20;
        for (WordBox w : words) {
            if (currentLine.isEmpty() || Math.abs(w.yCenter - lineRefY) <= lineRefHeight * 0.6) {
                currentLine.add(w);
                // 줄의 기준 y/높이는 지금까지 넣은 단어들의 평균으로 계속 갱신해요.
                double sumY = 0, sumH = 0;
                for (WordBox cw : currentLine) { sumY += cw.yCenter; sumH += cw.height; }
                lineRefY = sumY / currentLine.size();
                lineRefHeight = sumH / currentLine.size();
            } else {
                lines.add(currentLine);
                currentLine = new ArrayList<>();
                currentLine.add(w);
                lineRefY = w.yCenter;
                lineRefHeight = w.height;
            }
        }
        if (!currentLine.isEmpty()) lines.add(currentLine);

        StringBuilder sb = new StringBuilder();
        for (List<WordBox> line : lines) {
            line.sort((a, b) -> Double.compare(a.xLeft, b.xLeft));
            for (int i = 0; i < line.size(); i++) {
                if (i > 0) sb.append(' ');
                sb.append(line.get(i).text);
            }
            sb.append('\n');
        }
        return sb.toString();
    }

    // OCR로 읽은 영수증 텍스트를 "품목 / 수량 / 단가" 라인들로 최대한 잘라내요.
    // 영수증 형식이 두 가지예요: "품목명 단가 수량 금액"(4열) 또는 "품목명 수량 금액"(3열, 단가 생략).
    // 어느 쪽이든 화면에서는 수량/단가를 넘기고, 금액은 프론트에서 수량×단가로 다시 계산해요.
    private List<String[]> parseReceiptText(String text) {
        List<String[]> items = new ArrayList<>();
        if (text == null || text.isEmpty()) return items;

        outer:
        for (String rawLine : text.split("\n")) {
            String line = rawLine.trim();
            if (line.isEmpty()) continue;

            // OCR이 한글 자모 사이를 띄어 인식하는 경우가 있어서("부 가 세" 등), 공백 없앤 버전으로도 비교해요.
            String normalized = line.replaceAll("\\s+", "");
            for (String kw : NON_ITEM_KEYWORDS) {
                if (normalized.contains(kw.replaceAll("\\s+", ""))) continue outer;
            }
            // 날짜/시간처럼 보이는 줄(2024-02-24, 12:32:25 등)도 품목이 아니라고 보고 건너뛰어요.
            if (line.matches(".*\\d{4}-\\d{2}-\\d{2}.*") || line.matches(".*\\d{1,2}:\\d{2}:\\d{2}.*")) continue;

            String[] tokens = line.split("\\s+");
            if (tokens.length < 2) continue;

            List<String> numericTail = new ArrayList<>();
            int idx = tokens.length - 1;
            while (idx >= 0 && numericTail.size() < 3) {
                String tok = tokens[idx];
                if (NUMERIC_TOKEN.matcher(tok).matches()) {
                    numericTail.add(0, tok.replace(",", ""));
                    idx--;
                } else {
                    Matcher unitMatch = QTY_WITH_UNIT.matcher(tok);
                    if (unitMatch.matches()) {
                        numericTail.add(0, unitMatch.group(1)); // 단위 글자는 버리고 숫자만
                        idx--;
                    } else {
                        break;
                    }
                }
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
                // 열이 2개면 대부분 [수량, 금액] 형식이에요 (단가 생략). 단가는 금액÷수량으로 역산해요.
                int qtyVal, amountVal;
                try {
                    qtyVal = Integer.parseInt(numericTail.get(0));
                    amountVal = Integer.parseInt(numericTail.get(1));
                } catch (NumberFormatException e) {
                    qtyVal = 1; amountVal = Integer.parseInt(numericTail.get(1).replaceAll("[^0-9-]", "0"));
                }
                // 두 숫자가 똑같으면(예: "100 100") 품목코드 끝자리 숫자가 수량 자리로 잘못 끼어든
                // 경우가 많아요 - 그럴 땐 수량 1개에 단가가 그 값이라고 보는 게 훨씬 자연스러워요.
                if (qtyVal == amountVal) {
                    qty = "1";
                    price = String.valueOf(amountVal);
                } else {
                    if (qtyVal <= 0 || qtyVal > 30) { qtyVal = 1; } // 한 줄 수량이 30개 넘는 건 비정상으로 보고 보정
                    qty = String.valueOf(qtyVal);
                    price = String.valueOf(qtyVal == 0 ? amountVal : amountVal / qtyVal);
                }
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
