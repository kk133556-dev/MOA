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
        String action = req.getParameter("action"); // null 또는 "apply" = 신청, "delete" = 삭제

        try {
            if ("delete".equals(action)) {
                int adId = Integer.parseInt(req.getParameter("adId"));
                new AdDAO().deleteOwnedByStore(adId, storeId);
                resp.sendRedirect("ads_apply.jsp?deleted=1");
                return;
            }
            new AdDAO().insert(storeId, req.getParameter("bannerText"));
            resp.sendRedirect("ads_apply.jsp?done=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
