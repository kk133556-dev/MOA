package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.InventoryDAO;

@WebServlet("/InventoryServlet")
public class InventoryServlet extends HttpServlet {
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
            InventoryDAO dao = new InventoryDAO();
            if ("add".equals(action)) {
                dao.insert(storeId, req.getParameter("itemName"),
                        Double.parseDouble(req.getParameter("qty")),
                        Double.parseDouble(req.getParameter("safetyQty")),
                        req.getParameter("unit"));
            } else if ("delete".equals(action)) {
                dao.delete(Integer.parseInt(req.getParameter("itemId")));
            }
            resp.sendRedirect("inventory.jsp");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
