package com.moa.dao;

import java.sql.*;

import com.moa.db.DBUtil;
import com.moa.model.ChatIntent;

public class ChatbotDAO {

    // 사용자가 입력한 문장(question) 안에 등록된 키워드가 포함돼 있는지 DB에서 찾아요.
    // 여러 개가 걸리면 키워드 길이가 긴 것(더 구체적인 것)을 우선으로 골라요.
    public ChatIntent findAnswer(String question) throws SQLException {
        String sql = "SELECT i.intent_id, i.intent_name, i.answer_text, i.link_url " +
                     "FROM chatbot_keywords k " +
                     "JOIN chatbot_intents i ON k.intent_id = i.intent_id " +
                     "WHERE ? LIKE CONCAT('%', k.keyword, '%') " +
                     "ORDER BY CHAR_LENGTH(k.keyword) DESC LIMIT 1";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, question);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChatIntent intent = new ChatIntent();
                    intent.setIntentId(rs.getInt("intent_id"));
                    intent.setIntentName(rs.getString("intent_name"));
                    intent.setAnswerText(rs.getString("answer_text"));
                    intent.setLinkUrl(rs.getString("link_url"));
                    return intent;
                }
            }
        }
        return null;
    }

    // 질문 로그를 남겨요. matchedIntentId가 null이면 "답 못 찾은 질문"으로 기록돼서
    // 나중에 admin 페이지에서 새 intent를 추가할 때 참고할 수 있어요.
    public void logQuestion(Integer memberId, String question, Integer matchedIntentId) throws SQLException {
        String sql = "INSERT INTO chatbot_logs (member_id, question_text, matched_intent_id) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (memberId != null) ps.setInt(1, memberId); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, question);
            if (matchedIntentId != null) ps.setInt(3, matchedIntentId); else ps.setNull(3, Types.INTEGER);
            ps.executeUpdate();
        }
    }
}
