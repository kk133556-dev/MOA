package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.SalesDAO;

@WebServlet("/SalesDeleteServlet")
public class SalesDeleteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");
        String action = req.getParameter("action"); // "deleteSelected" 또는 "deleteAll"

        try {
            SalesDAO dao = new SalesDAO();
            if ("deleteAll".equals(action)) {
                dao.deleteAllForStore(storeId);
            } else {
                String[] idParams = req.getParameterValues("salesId");
                List<Integer> ids = new ArrayList<>();
                if (idParams != null) {
                    for (String s : idParams) {
                        try { ids.add(Integer.parseInt(s)); } catch (NumberFormatException ignore) {}
                    }
                }
                dao.deleteByIdsForStore(ids, storeId);
            }
            resp.sendRedirect("mypage.jsp?salesDeleted=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
