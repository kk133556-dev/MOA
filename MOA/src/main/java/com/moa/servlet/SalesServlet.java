package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.moa.dao.SalesDAO;

@WebServlet("/SalesServlet")
public class SalesServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 로그인 안 한 사람이 이 주소로 직접 요청 보내는 걸 막는 안전장치예요.
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");

        int total = Integer.parseInt(req.getParameter("total"));
        int card = Integer.parseInt(req.getParameter("card"));
        int cash = Integer.parseInt(req.getParameter("cash"));
        String receiptImage = req.getParameter("receiptImage");
        if (receiptImage != null && receiptImage.isEmpty()) receiptImage = null;

        // 세 항목은 선택 입력이라 안 보내면 0으로 처리해요.
        int liquor = parseOrZero(req.getParameter("liquor"));
        int fee = parseOrZero(req.getParameter("fee"));
        int other = parseOrZero(req.getParameter("other"));

        try {
            new SalesDAO().insert(storeId, total, card, cash, receiptImage, liquor, fee, other);
            resp.sendRedirect("mypage.jsp");
        } catch (SQLException e) {
            throw new ServletException("매출 저장 중 DB 오류가 발생했어요.", e);
        }
    }

    private int parseOrZero(String s) {
        if (s == null || s.trim().isEmpty()) return 0;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return 0; }
    }
}
