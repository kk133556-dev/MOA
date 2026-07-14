package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.MemberDAO;
import com.moa.dao.StoreDAO;
import com.moa.model.Member;
import com.moa.model.StoreProfile;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String loginId = req.getParameter("userId");
        String pw1 = req.getParameter("userPw");
        String pw2 = req.getParameter("userPwConfirm");
        String ownerName = req.getParameter("ownerName");
        String storeName = req.getParameter("storeName");
        String address = req.getParameter("address");
        String businessRegNo = req.getParameter("businessRegNo");

        if (!pw1.equals(pw2)) {
            resp.sendRedirect("signup.jsp?error=pwmismatch");
            return;
        }

        try {
            MemberDAO memberDAO = new MemberDAO();
            if (memberDAO.isLoginIdTaken(loginId)) {
                resp.sendRedirect("signup.jsp?error=duplicate");
                return;
            }

            Member m = new Member();
            m.setLoginId(loginId);
            m.setPassword(pw1);
            m.setName(ownerName);
            int newMemberId = memberDAO.insert(m); // insert()에서 자동으로 PENDING 상태로 저장돼요

            StoreProfile store = new StoreProfile();
            store.setMemberId(newMemberId);
            store.setStoreName(storeName);
            store.setAddress(address);
            store.setBusinessRegNo(businessRegNo);
            new StoreDAO().insert(store);

            // 이제 바로 로그인 안 되고, 관리자 승인 후 로그인 가능하다고 안내해요.
            resp.sendRedirect("login.jsp?signup=pending");

        } catch (SQLException e) {
            throw new ServletException("회원가입 처리 중 DB 오류가 발생했어요.", e);
        }
    }
}
