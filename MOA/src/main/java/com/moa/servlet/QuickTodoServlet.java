package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.QuickTodoDAO;

@WebServlet("/QuickTodoServlet")
public class QuickTodoServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.getWriter().print("{\"result\":\"error\"}");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");
        String action = req.getParameter("action");

        try {
            QuickTodoDAO dao = new QuickTodoDAO();
            if ("add".equals(action)) {
                String label = req.getParameter("label");
                if (label == null || label.trim().isEmpty()) {
                    resp.getWriter().print("{\"result\":\"error\"}");
                    return;
                }
                int newId = dao.insert(storeId, label.trim());
                resp.getWriter().print("{\"result\":\"ok\",\"quickId\":" + newId + "}");
                return;
            } else if ("delete".equals(action)) {
                dao.delete(Integer.parseInt(req.getParameter("quickId")));
            }
            resp.getWriter().print("{\"result\":\"ok\"}");
        } catch (SQLException e) {
            resp.getWriter().print("{\"result\":\"error\"}");
        }
    }
}
