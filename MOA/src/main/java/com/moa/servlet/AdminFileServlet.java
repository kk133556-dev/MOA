package com.moa.servlet;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.SalesDAO;

@WebServlet("/AdminFileServlet")
public class AdminFileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("memberType"))) {
            resp.sendRedirect("login.jsp?role=ADMIN");
            return;
        }
        int salesId = Integer.parseInt(req.getParameter("salesId"));
        String imagePath = req.getParameter("imagePath"); // 예: uploads/receipts/3/xxx.jpg

        try {
            new SalesDAO().clearReceiptImage(salesId);

            // 실제 디스크 파일도 지워요. 실패해도(이미 없거나 등) 전체 흐름은 막지 않아요.
            if (imagePath != null && !imagePath.isEmpty()) {
                String realPath = getServletContext().getRealPath("/" + imagePath);
                if (realPath != null) {
                    File f = new File(realPath);
                    if (f.exists()) f.delete();
                }
            }
            resp.sendRedirect("admin_files.jsp?deleted=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
