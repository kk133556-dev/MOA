package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.InquiryDAO;

@WebServlet("/AdminReplyServlet")
public class AdminReplyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("memberType"))) {
            resp.sendRedirect("login.jsp?role=ADMIN");
            return;
        }
        int inquiryId = Integer.parseInt(req.getParameter("inquiryId"));
        try {
            new InquiryDAO().reply(inquiryId, req.getParameter("replyText"));
            resp.sendRedirect("admin_inquiries.jsp");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
