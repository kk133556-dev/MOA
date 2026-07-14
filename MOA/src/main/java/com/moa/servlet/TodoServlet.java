package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.TodoDAO;

@WebServlet("/TodoServlet")
public class TodoServlet extends HttpServlet {
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
            TodoDAO dao = new TodoDAO();
            if ("add".equals(action)) {
                int newId = dao.insert(storeId, req.getParameter("content"));
                resp.getWriter().print("{\"result\":\"ok\",\"todoId\":" + newId + "}");
                return;
            } else if ("toggle".equals(action)) {
                dao.toggleDone(Integer.parseInt(req.getParameter("todoId")));
            } else if ("delete".equals(action)) {
                dao.delete(Integer.parseInt(req.getParameter("todoId")));
            }
            resp.getWriter().print("{\"result\":\"ok\"}");
        } catch (SQLException e) {
            resp.getWriter().print("{\"result\":\"error\"}");
        }
    }
}
