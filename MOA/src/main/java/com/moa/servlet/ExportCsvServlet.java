package com.moa.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.moa.dao.SalesDAO;
import com.moa.model.SalesRecord;

@WebServlet("/ExportCsvServlet")
public class ExportCsvServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("storeId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        int storeId = (Integer) session.getAttribute("storeId");
        String storeName = (String) session.getAttribute("storeName");

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"moa_sales_report.csv\"");

        try (PrintWriter writer = resp.getWriter()) {
            // 엑셀에서 한글이 안 깨지도록 BOM을 앞에 붙여줘요. (OutputStream이 아니라 Writer로만 써야
            // 응답이 깨지지 않아요 - 같은 응답에서 OutputStream/Writer를 같이 쓰면 안 돼요)
            writer.write('\uFEFF');
            SalesDAO dao = new SalesDAO();

            // 1) 문서 정보
            writer.println("MOA 매출 리포트");
            writer.println("매장명," + (storeName != null ? storeName : ""));
            writer.println();

            // 2) 월별 집계 요약 (한눈에 보기용) - 엑셀에서 이 부분만 봐도 전체 흐름이 보여요.
            writer.println("=== 월별 집계 요약 ===");
            writer.println("월,총매출,카드매출,현금매출");
            List<Object[]> monthly = dao.monthlyByStore(storeId, 12);
            int sumTotal = 0, sumCard = 0, sumCash = 0;
            for (Object[] row : monthly) {
                writer.println(row[0] + "," + row[1] + "," + row[2] + "," + row[3]);
                sumTotal += (Integer) row[1];
                sumCard += (Integer) row[2];
                sumCash += (Integer) row[3];
            }
            writer.println("합계," + sumTotal + "," + sumCard + "," + sumCash);
            writer.println();

            // 3) 일별 상세 내역 (기존 기능 유지)
            writer.println("=== 일별 상세 내역 ===");
            writer.println("날짜,총매출,카드매출,현금매출");
            List<SalesRecord> list = dao.listByStore(storeId);
            for (SalesRecord r : list) {
                writer.println(r.getSalesDate() + "," + r.getTotalAmount() + "," + r.getCardAmount() + "," + r.getCashAmount());
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
