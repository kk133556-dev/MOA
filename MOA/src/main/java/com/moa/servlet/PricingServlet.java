package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.MemberDAO;
import com.moa.dao.PaymentDAO;

@WebServlet("/PricingServlet")
public class PricingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("memberId") == null || session.getAttribute("phoneVerified") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int memberId = (Integer) session.getAttribute("memberId");
        Integer storeId = (Integer) session.getAttribute("storeId");
        String plan = req.getParameter("plan");
        int amount = "STANDARD".equals(plan) ? 29000 : "PRO".equals(plan) ? 59000 : 0;

        try {
            new MemberDAO().updatePlan(memberId, plan);
            if (storeId != null) new PaymentDAO().insert(storeId, plan, amount);
            session.setAttribute("plan", plan);
            resp.sendRedirect("dashboard.jsp?planUpdated=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
