package com.moa.servlet;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONObject;

// 카카오가 로그인 처리를 끝내고 이 주소로 돌려보내줘요 (인가 코드를 들고).
// 그 코드를 액세스 토큰으로 바꾸고, 그 토큰으로 "정말 로그인된 카카오 사용자가 맞는지" 확인해요.
// 실제로 카카오 서버와 통신하는 진짜 인증이라, 아무 코드나 넣는다고 통과되지 않아요.
@WebServlet("/KakaoAuthServlet")
public class KakaoAuthServlet extends HttpServlet {

    private static final String KAKAO_REST_API_KEY =
        System.getenv("KAKAO_REST_API_KEY") != null
            ? System.getenv("KAKAO_REST_API_KEY")
            : "여기에_카카오_REST_API_키_입력";

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String errorParam = req.getParameter("error");
        HttpSession session = req.getSession(false);
        String plan = session != null ? (String) session.getAttribute("kakaoVerifyPlan") : null;

        if (errorParam != null || code == null) {
            // 사용자가 카카오 로그인 화면에서 취소했거나 실패한 경우
            resp.sendRedirect("verify.jsp?plan=" + (plan != null ? plan : "") + "&kakaoFail=1");
            return;
        }

        try {
            String redirectUri = req.getScheme() + "://" + req.getServerName()
                    + (req.getServerPort() != 80 && req.getServerPort() != 443 ? ":" + req.getServerPort() : "")
                    + req.getContextPath() + "/KakaoAuthServlet";

            // 1) 인가 코드 -> 액세스 토큰 교환
            String tokenBody = "grant_type=authorization_code"
                    + "&client_id=" + KAKAO_REST_API_KEY
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                    + "&code=" + code;

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
            HttpRequest tokenReq = HttpRequest.newBuilder()
                    .uri(URI.create("https://kauth.kakao.com/oauth/token"))
                    .header("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
                    .POST(HttpRequest.BodyPublishers.ofString(tokenBody))
                    .build();
            HttpResponse<String> tokenResp = client.send(tokenReq, HttpResponse.BodyHandlers.ofString());
            JSONObject tokenJson = new JSONObject(tokenResp.body());

            if (!tokenJson.has("access_token")) {
                resp.sendRedirect("verify.jsp?plan=" + (plan != null ? plan : "") + "&kakaoFail=1");
                return;
            }
            String accessToken = tokenJson.getString("access_token");

            // 2) 액세스 토큰으로 실제 카카오 사용자 정보 조회 (여기가 성공해야 "진짜 로그인된 사람"인 게 확인돼요)
            HttpRequest meReq = HttpRequest.newBuilder()
                    .uri(URI.create("https://kapi.kakao.com/v2/user/me"))
                    .header("Authorization", "Bearer " + accessToken)
                    .GET()
                    .build();
            HttpResponse<String> meResp = client.send(meReq, HttpResponse.BodyHandlers.ofString());
            JSONObject meJson = new JSONObject(meResp.body());

            if (!meJson.has("id")) {
                resp.sendRedirect("verify.jsp?plan=" + (plan != null ? plan : "") + "&kakaoFail=1");
                return;
            }

            // 카카오 인증 성공 - 기존 휴대폰 인증과 동일하게 "본인확인 완료" 처리하고 결제 단계로 넘어가요.
            if (session == null) session = req.getSession();
            session.setAttribute("phoneVerified", true);
            session.setAttribute("verifiedVia", "카카오톡");
            resp.sendRedirect("checkout.jsp?plan=" + (plan != null ? plan : ""));

        } catch (Exception e) {
            resp.sendRedirect("verify.jsp?plan=" + (plan != null ? plan : "") + "&kakaoFail=1");
        }
    }
}
