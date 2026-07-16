package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.MemberDAO;
import com.moa.dao.StoreDAO;
import com.moa.model.Member;
import com.moa.model.StoreProfile;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String loginId = req.getParameter("userId");
        String password = req.getParameter("userPw");
        String memberType = req.getParameter("loginType");

        try {
            MemberDAO dao = new MemberDAO();
            Member member = dao.login(loginId, password, memberType);

            if (member == null) {
                if ("ADMIN".equals(memberType)) {
                    resp.sendRedirect("login.jsp?error=1&role=ADMIN");
                } else {
                    resp.sendRedirect("index.jsp?error=1");
                }
                return;
            }

            // 관리자 승인이 아직 안 된 계정이거나, 정지된 계정이면 로그인 자체를 막아요.
            String status = member.getStatus() != null ? member.getStatus() : "ACTIVE";
            if ("PENDING".equals(status)) {
                resp.sendRedirect("index.jsp?pending=1");
                return;
            }
            if ("SUSPENDED".equals(status)) {
                resp.sendRedirect("index.jsp?suspended=1");
                return;
            }

            HttpSession session = req.getSession();
            session.setAttribute("memberId", member.getMemberId());
            session.setAttribute("name", member.getName());
            session.setAttribute("memberType", member.getMemberType());
            session.setAttribute("plan", member.getPlan());

            if ("BUSINESS".equals(member.getMemberType())) {
                StoreProfile store = new StoreDAO().findByMemberId(member.getMemberId());
                if (store != null) {
                    session.setAttribute("storeId", store.getStoreId());
                    session.setAttribute("storeName", store.getStoreName());
                }
            }

            // 안드로이드 앱에서 로그인한 경우, 다음에 앱을 켰을 때 로그인 화면 없이 자동으로 들어오게
            // 30일짜리 기억 토큰을 쿠키로 심어줘요.
            String ua = req.getHeader("User-Agent");
            if (ua != null && ua.contains("MOAApp")) {
                String token = java.util.UUID.randomUUID().toString();
                dao.setRememberToken(member.getMemberId(), token);
                Cookie rememberCookie = new Cookie("moaRT", token);
                rememberCookie.setMaxAge(60 * 60 * 24 * 30); // 30일
                rememberCookie.setPath("/");
                resp.addCookie(rememberCookie);
            }

            resp.sendRedirect("index.jsp?welcome=1");

        } catch (SQLException e) {
            throw new ServletException("로그인 처리 중 DB 오류가 발생했어요.", e);
        }
    }
}
