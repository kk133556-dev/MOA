package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.InquiryDAO;

@WebServlet("/InquiryServlet")
public class InquiryServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("memberId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int memberId = (Integer) session.getAttribute("memberId");
        String content = req.getParameter("content");

        try {
            new InquiryDAO().insert(memberId, content);
            resp.sendRedirect("support.jsp?done=1");
        } catch (SQLException e) {
            resp.sendRedirect("support.jsp?dberror=1");
        }
    }
}
