package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.WorkScheduleDAO;

@WebServlet("/WorkScheduleServlet")
public class WorkScheduleServlet extends HttpServlet {
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
            WorkScheduleDAO dao = new WorkScheduleDAO();
            if ("delete".equals(action)) {
                int scheduleId = Integer.parseInt(req.getParameter("scheduleId"));
                dao.deleteOwnedByStore(scheduleId, storeId);
                resp.getWriter().print("{\"result\":\"ok\"}");
            } else {
                int employeeId = Integer.parseInt(req.getParameter("employeeId"));
                int newId = dao.insert(storeId, employeeId, req.getParameter("workDate"),
                        req.getParameter("shiftStart"), req.getParameter("shiftEnd"), req.getParameter("memo"));
                resp.getWriter().print("{\"result\":\"ok\",\"scheduleId\":" + newId + "}");
            }
        } catch (SQLException e) {
            resp.getWriter().print("{\"result\":\"error\"}");
        }
    }
}
