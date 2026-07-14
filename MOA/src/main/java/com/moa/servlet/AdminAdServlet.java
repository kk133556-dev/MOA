package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.AdDAO;

@WebServlet("/AdminAdServlet")
public class AdminAdServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("memberType"))) {
            resp.sendRedirect("login.jsp?role=ADMIN");
            return;
        }
        int adId = Integer.parseInt(req.getParameter("adId"));
        String action = req.getParameter("action"); // approve, reject, delete
        try {
            AdDAO dao = new AdDAO();
            if ("approve".equals(action)) {
                dao.approveWithDateRange(adId, req.getParameter("startDate"), req.getParameter("endDate"));
            } else if ("delete".equals(action)) {
                dao.delete(adId);
            } else {
                dao.updateStatus(adId, "REJECTED");
            }
            resp.sendRedirect("admin_ads.jsp");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
