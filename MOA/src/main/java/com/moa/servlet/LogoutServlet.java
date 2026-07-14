package com.moa.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 로그인할 때 만들었던 session을 통째로 없애는 거예요.
        // 이러면 session.getAttribute("name")도 다시 null이 돼서, dashboard.jsp가 로그인 화면으로 돌려보내요.
        HttpSession session = req.getSession(false); // false: 없으면 새로 만들지 말고 그냥 null 받기
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect("login.jsp");
    }
}
