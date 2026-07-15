package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.EmployeeDAO;

@WebServlet("/EmployeeServlet")
public class EmployeeServlet extends HttpServlet {
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
            EmployeeDAO dao = new EmployeeDAO();
            if ("delete".equals(action)) {
                int employeeId = Integer.parseInt(req.getParameter("employeeId"));
                dao.deleteOwnedByStore(employeeId, storeId);
            } else if ("update".equals(action)) {
                int employeeId = Integer.parseInt(req.getParameter("employeeId"));
                dao.updateOwnedByStore(employeeId, storeId, req.getParameter("name"), req.getParameter("role"),
                        req.getParameter("phone"), req.getParameter("address"), req.getParameter("memo"),
                        req.getParameter("guardianName"), req.getParameter("guardianPhone"));
            } else {
                dao.insert(storeId, req.getParameter("name"), req.getParameter("role"),
                        req.getParameter("phone"), req.getParameter("address"), req.getParameter("memo"),
                        req.getParameter("guardianName"), req.getParameter("guardianPhone"));
            }
            resp.sendRedirect("staff.jsp");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
