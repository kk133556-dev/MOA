package com.moa.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/VerifyServlet")
public class VerifyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        session.setAttribute("phoneVerified", true);
        String plan = req.getParameter("plan");
        resp.sendRedirect("checkout.jsp?plan=" + plan);
    }
}
