package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.MemberDAO;

@WebServlet("/AdminMemberServlet")
public class AdminMemberServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("memberType"))) {
            resp.sendRedirect("login.jsp?role=ADMIN");
            return;
        }
        int memberId = Integer.parseInt(req.getParameter("memberId"));
        String action = req.getParameter("action"); // approve, suspend, reactivate, delete

        try {
            if ("delete".equals(action)) {
                new MemberDAO().deleteMemberCascade(memberId);
                resp.sendRedirect("admin_members.jsp?deleted=1");
                return;
            }
            String status = "approve".equals(action) ? "ACTIVE" : "suspend".equals(action) ? "SUSPENDED" : "ACTIVE";
            new MemberDAO().updateStatus(memberId, status);
            resp.sendRedirect("admin_members.jsp");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
