package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.AdDAO;

@WebServlet("/AdApplyServlet")
public class AdApplyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");
        try {
            new AdDAO().insert(storeId, req.getParameter("bannerText"));
            resp.sendRedirect("ads_apply.jsp?done=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
