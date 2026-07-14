package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.ChatbotDAO;
import com.moa.model.ChatIntent;

@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String message = req.getParameter("message");
        if (message == null || message.trim().isEmpty()) {
            resp.getWriter().print("{\"matched\":false}");
            return;
        }

        HttpSession session = req.getSession(false);
        Integer memberId = (session != null) ? (Integer) session.getAttribute("memberId") : null;

        try {
            ChatbotDAO dao = new ChatbotDAO();
            ChatIntent intent = dao.findAnswer(message.trim());

            // 매칭 여부와 관계없이 로그는 남겨요. (매칭 실패 로그가 나중에 챗봇을 키우는 재료가 돼요)
            dao.logQuestion(memberId, message.trim(), intent != null ? intent.getIntentId() : null);

            StringBuilder json = new StringBuilder();
            if (intent != null) {
                json.append("{\"matched\":true,");
                json.append("\"answer\":\"").append(escape(intent.getAnswerText())).append("\",");
                json.append("\"link\":").append(intent.getLinkUrl() != null ? "\"" + escape(intent.getLinkUrl()) + "\"" : "null");
                json.append("}");
            } else {
                json.append("{\"matched\":false}");
            }
            resp.getWriter().print(json.toString());
        } catch (SQLException e) {
            resp.getWriter().print("{\"matched\":false,\"error\":true}");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
