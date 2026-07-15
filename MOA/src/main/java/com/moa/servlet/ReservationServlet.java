package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.ReservationDAO;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");
        String action = req.getParameter("action");

        try {
            ReservationDAO dao = new ReservationDAO();
            if ("delete".equals(action)) {
                int reservationId = Integer.parseInt(req.getParameter("reservationId"));
                dao.deleteOwnedByStore(reservationId, storeId);
            } else if ("updateStatus".equals(action)) {
                int reservationId = Integer.parseInt(req.getParameter("reservationId"));
                dao.updateStatus(reservationId, storeId, req.getParameter("status"));
            } else {
                int partySize = parseOrOne(req.getParameter("partySize"));
                int prepayment = parseOrZero(req.getParameter("prepayment"));
                dao.insert(storeId, req.getParameter("customerName"), req.getParameter("phone"),
                        req.getParameter("date"), req.getParameter("time"), partySize,
                        req.getParameter("menuOrder"), prepayment, req.getParameter("memo"));
            }
            resp.sendRedirect("reservation.jsp?done=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private int parseOrOne(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 1; }
    }
    private int parseOrZero(String s) {
        if (s == null || s.trim().isEmpty()) return 0;
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }
}
