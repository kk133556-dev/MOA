package com.moa.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

// 카카오 로그인으로 본인 확인을 시작해요. 실제로 카카오 계정에 로그인한 사람만
// 다음 단계(결제)로 넘어갈 수 있게 하는, 진짜로 동작하는 카카오 OAuth 연동이에요.
// (요금제 결제 전 "카카오톡으로 인증하기" 버튼을 누르면 여기로 와요)
@WebServlet("/KakaoLoginServlet")
public class KakaoLoginServlet extends HttpServlet {

    // developers.kakao.com 에서 앱 만들고 발급받은 REST API 키를 Railway Variables에
    // KAKAO_REST_API_KEY 로 등록해두면 자동으로 그 값을 써요.
    private static final String KAKAO_REST_API_KEY =
        System.getenv("KAKAO_REST_API_KEY") != null
            ? System.getenv("KAKAO_REST_API_KEY")
            : "여기에_카카오_REST_API_키_입력";

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) == null || req.getSession().getAttribute("memberId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String plan = req.getParameter("plan");
        req.getSession().setAttribute("kakaoVerifyPlan", plan);

        // Kakao Developers 콘솔의 "카카오 로그인 > Redirect URI"에 정확히 이 주소가 등록돼 있어야 해요:
        // https://<배포주소>/KakaoAuthServlet
        String redirectUri = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() != 80 && req.getServerPort() != 443 ? ":" + req.getServerPort() : "")
                + req.getContextPath() + "/KakaoAuthServlet";

        String authorizeUrl = "https://kauth.kakao.com/oauth/authorize"
                + "?client_id=" + KAKAO_REST_API_KEY
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&state=" + URLEncoder.encode(plan != null ? plan : "", StandardCharsets.UTF_8);

        resp.sendRedirect(authorizeUrl);
    }
}
