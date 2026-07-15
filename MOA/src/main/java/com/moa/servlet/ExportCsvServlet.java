package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.moa.dao.SalesDAO;
import com.moa.model.SalesRecord;

// 예전엔 이름 그대로 CSV(글자만 있는 파일)를 만들었는데, 이제는 진짜 엑셀(.xlsx) 파일을
// SUM 함수랑 서식까지 넣어서 만들어줘요. 버튼/링크(ExportCsvServlet)는 그대로 두고 내용만 바꿨어요.
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

        try {
            SalesDAO dao = new SalesDAO();
            List<Object[]> monthly = dao.monthlyByStore(storeId, 12);
            List<SalesRecord> detail = dao.listByStore(storeId);

            try (XSSFWorkbook workbook = new XSSFWorkbook()) {
                CellStyle headerStyle = headerStyle(workbook);
                CellStyle moneyStyle = moneyStyle(workbook);
                CellStyle totalStyle = totalStyle(workbook);
                CellStyle titleStyle = titleStyle(workbook);

                buildMonthlySheet(workbook, monthly, storeName, headerStyle, moneyStyle, totalStyle, titleStyle);
                buildDetailSheet(workbook, detail, headerStyle, moneyStyle, totalStyle, titleStyle);

                // 수식이 캐시된 옛날 값 대신 파일을 열자마자 바로 다시 계산되게 해요.
                workbook.setForceFormulaRecalculation(true);

                resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                resp.setHeader("Content-Disposition", "attachment; filename=\"moa_sales_report.xlsx\"");
                workbook.write(resp.getOutputStream());
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void buildMonthlySheet(XSSFWorkbook wb, List<Object[]> monthly, String storeName,
                                    CellStyle headerStyle, CellStyle moneyStyle, CellStyle totalStyle, CellStyle titleStyle) {
        Sheet sheet = wb.createSheet("월별 요약");

        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("MOA 매출 리포트 - " + (storeName != null ? storeName : "") + " (월별 요약)");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

        String[] headers = {"월", "총매출", "카드매출", "현금매출", "주류매출", "수수료", "기타지출"};
        Row headerRow = sheet.createRow(2);
        for (int i = 0; i < headers.length; i++) {
            Cell c = headerRow.createCell(i);
            c.setCellValue(headers[i]);
            c.setCellStyle(headerStyle);
        }

        int startRow = 3;
        int r = startRow;
        for (Object[] row : monthly) {
            Row dataRow = sheet.createRow(r);
            dataRow.createCell(0).setCellValue((String) row[0]);
            int excelRowNum = r + 1; // POI는 0-index, 엑셀 수식은 1-index라서 변환
            for (int col = 1; col <= 6; col++) {
                Cell c = dataRow.createCell(col);
                if (col == 1) {
                    // 총매출 = 카드매출(C) + 현금매출(D) - 엑셀에서 직접 수정해도 자동으로 재계산돼요.
                    c.setCellFormula("C" + excelRowNum + "+D" + excelRowNum);
                } else {
                    c.setCellValue((Integer) row[col]);
                }
                c.setCellStyle(moneyStyle);
            }
            r++;
        }
        int endRow = r - 1;

        Row totalRow = sheet.createRow(r);
        Cell totalLabel = totalRow.createCell(0);
        totalLabel.setCellValue("합계");
        totalLabel.setCellStyle(totalStyle);

        for (int col = 1; col <= 6; col++) {
            char colLetter = (char) ('A' + col);
            Cell c = totalRow.createCell(col);
            if (monthly.isEmpty()) {
                c.setCellValue(0);
            } else {
                c.setCellFormula("SUM(" + colLetter + (startRow + 1) + ":" + colLetter + (endRow + 1) + ")");
            }
            c.setCellStyle(totalStyle);
        }

        sheet.setColumnWidth(0, 12 * 256);
        for (int i = 1; i <= 6; i++) sheet.setColumnWidth(i, 13 * 256);
        sheet.createFreezePane(0, 3);
    }

    private void buildDetailSheet(XSSFWorkbook wb, List<SalesRecord> detail,
                                   CellStyle headerStyle, CellStyle moneyStyle, CellStyle totalStyle, CellStyle titleStyle) {
        Sheet sheet = wb.createSheet("일별 상세");

        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("일별 상세 매출 내역");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

        String[] headers = {"날짜", "총매출", "카드매출", "현금매출", "주류매출", "수수료", "기타지출"};
        Row headerRow = sheet.createRow(2);
        for (int i = 0; i < headers.length; i++) {
            Cell c = headerRow.createCell(i);
            c.setCellValue(headers[i]);
            c.setCellStyle(headerStyle);
        }

        int startRow = 3;
        int r = startRow;
        for (SalesRecord rec : detail) {
            Row dataRow = sheet.createRow(r);
            dataRow.createCell(0).setCellValue(rec.getSalesDate().toString());
            int[] values = { rec.getTotalAmount(), rec.getCardAmount(), rec.getCashAmount(),
                              rec.getLiquorAmount(), rec.getFeeAmount(), rec.getOtherExpense() };
            int excelRowNum = r + 1;
            for (int col = 1; col <= 6; col++) {
                Cell c = dataRow.createCell(col);
                if (col == 1) {
                    // 총매출 = 카드매출(C) + 현금매출(D)
                    c.setCellFormula("C" + excelRowNum + "+D" + excelRowNum);
                } else {
                    c.setCellValue(values[col - 1]);
                }
                c.setCellStyle(moneyStyle);
            }
            r++;
        }
        int endRow = r - 1;

        Row totalRow = sheet.createRow(r);
        Cell totalLabel = totalRow.createCell(0);
        totalLabel.setCellValue("합계");
        totalLabel.setCellStyle(totalStyle);

        for (int col = 1; col <= 6; col++) {
            char colLetter = (char) ('A' + col);
            Cell c = totalRow.createCell(col);
            if (detail.isEmpty()) {
                c.setCellValue(0);
            } else {
                c.setCellFormula("SUM(" + colLetter + (startRow + 1) + ":" + colLetter + (endRow + 1) + ")");
            }
            c.setCellStyle(totalStyle);
        }

        sheet.setColumnWidth(0, 12 * 256);
        for (int i = 1; i <= 6; i++) sheet.setColumnWidth(i, 13 * 256);
        sheet.createFreezePane(0, 3);
    }

    private CellStyle titleStyle(XSSFWorkbook wb) {
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 13);
        CellStyle style = wb.createCellStyle();
        style.setFont(font);
        return style;
    }

    private CellStyle headerStyle(XSSFWorkbook wb) {
        Font font = wb.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        CellStyle style = wb.createCellStyle();
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        return style;
    }

    private CellStyle moneyStyle(XSSFWorkbook wb) {
        CellStyle style = wb.createCellStyle();
        DataFormat format = wb.createDataFormat();
        style.setDataFormat(format.getFormat("#,##0\"원\""));
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle totalStyle(XSSFWorkbook wb) {
        Font font = wb.createFont();
        font.setBold(true);
        CellStyle style = wb.createCellStyle();
        style.setFont(font);
        DataFormat format = wb.createDataFormat();
        style.setDataFormat(format.getFormat("#,##0\"원\""));
        style.setFillForegroundColor(IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.DOUBLE);
        return style;
    }
}
