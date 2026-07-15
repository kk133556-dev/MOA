package com.moa.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.moa.dao.SalesDAO;
import com.moa.model.SalesRecord;

// 예전엔 이름 그대로 CSV(글자만 있는 파일)를 만들었는데, 이제는 진짜 엑셀(.xlsx) 파일을
// SUM 함수랑 서식까지 넣어서 만들어줘요. 버튼/링크(ExportCsvServlet)는 그대로 두고 내용만 바꿨어요.
@WebServlet("/ExportCsvServlet")
public class ExportCsvServlet extends HttpServlet {

    private static final int LAST_COL = 6; // A=월/날짜, B~G = 총매출~기타지출

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
            int grandTotal = dao.sumByStore(storeId);

            try (XSSFWorkbook workbook = new XSSFWorkbook()) {
                Styles s = new Styles(workbook);

                buildMonthlySheet(workbook, s, monthly, storeName, grandTotal);
                buildDetailSheet(workbook, s, detail, storeName);

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

    // ============================================================
    // 시트 1: 월별 요약
    // ============================================================
    private void buildMonthlySheet(XSSFWorkbook wb, Styles s, List<Object[]> monthly, String storeName, int grandTotal) {
        Sheet sheet = wb.createSheet("월별 요약");
        setupColumns(sheet);

        int r = buildDocHeader(sheet, s, "월별 매출 요약", storeName, grandTotal, monthly.size());

        String[] headers = {"월", "총매출", "카드매출", "현금매출", "주류매출", "수수료", "기타지출"};
        r = writeHeaderRow(sheet, s, r, headers);

        int startRow = r;
        boolean stripe = false;
        for (Object[] row : monthly) {
            Row dataRow = sheet.createRow(r);
            writeLabelCell(dataRow, s, stripe, (String) row[0]);
            int excelRowNum = r + 1;
            for (int col = 1; col <= LAST_COL; col++) {
                Cell c = dataRow.createCell(col);
                if (col == 1) {
                    c.setCellFormula("C" + excelRowNum + "+D" + excelRowNum); // 총매출 = 카드+현금
                } else {
                    c.setCellValue((Integer) row[col]);
                }
                c.setCellStyle(stripe ? s.moneyAlt : s.money);
            }
            stripe = !stripe;
            r++;
        }
        int endRow = r - 1;
        writeTotalRow(sheet, s, r, "합계", startRow, endRow, monthly.isEmpty());
        r++;

        sheet.createFreezePane(0, startRow);
        addFooterNote(sheet, s, r + 1, "※ 총매출 칸은 카드매출+현금매출 수식입니다. 값을 고치면 합계가 자동으로 재계산돼요.");
    }

    // ============================================================
    // 시트 2: 일별 상세
    // ============================================================
    private void buildDetailSheet(XSSFWorkbook wb, Styles s, List<SalesRecord> detail, String storeName) {
        Sheet sheet = wb.createSheet("일별 상세");
        setupColumns(sheet);

        int total = 0;
        for (SalesRecord rec : detail) total += rec.getTotalAmount();
        int r = buildDocHeader(sheet, s, "일별 상세 매출 내역", storeName, total, detail.size());

        String[] headers = {"날짜", "총매출", "카드매출", "현금매출", "주류매출", "수수료", "기타지출"};
        r = writeHeaderRow(sheet, s, r, headers);

        int startRow = r;
        boolean stripe = false;
        for (SalesRecord rec : detail) {
            Row dataRow = sheet.createRow(r);
            writeLabelCell(dataRow, s, stripe, rec.getSalesDate().toString());
            int[] values = { rec.getTotalAmount(), rec.getCardAmount(), rec.getCashAmount(),
                              rec.getLiquorAmount(), rec.getFeeAmount(), rec.getOtherExpense() };
            int excelRowNum = r + 1;
            for (int col = 1; col <= LAST_COL; col++) {
                Cell c = dataRow.createCell(col);
                if (col == 1) {
                    c.setCellFormula("C" + excelRowNum + "+D" + excelRowNum);
                } else {
                    c.setCellValue(values[col - 1]);
                }
                c.setCellStyle(stripe ? s.moneyAlt : s.money);
            }
            stripe = !stripe;
            r++;
        }
        int endRow = r - 1;
        writeTotalRow(sheet, s, r, "합계", startRow, endRow, detail.isEmpty());
        r++;

        sheet.createFreezePane(0, startRow);
        addFooterNote(sheet, s, r + 1, "MOA 소상공인 매출 관리 플랫폼에서 자동 생성된 리포트입니다.");
    }

    // ============================================================
    // 공통 조립 헬퍼
    // ============================================================

    // 표지 영역(제목/매장명/생성일/요약 KPI)을 쓰고, 다음에 이어서 쓸 행 번호(0-index)를 돌려줘요.
    private int buildDocHeader(Sheet sheet, Styles s, String title, String storeName, int totalAmount, int rowCount) {
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("MOA 매출 리포트");
        titleCell.setCellStyle(s.brandTitle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, LAST_COL));
        titleRow.setHeightInPoints(26);

        Row subRow = sheet.createRow(1);
        Cell subCell = subRow.createCell(0);
        subCell.setCellValue(title + (storeName != null ? "  ·  " + storeName : ""));
        subCell.setCellStyle(s.subTitle);
        sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, LAST_COL));

        Row metaRow = sheet.createRow(2);
        Cell metaCell = metaRow.createCell(0);
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일"));
        metaCell.setCellValue("생성일: " + today + "   |   집계 건수: " + rowCount + "건   |   누적 총매출: " + String.format("%,d", totalAmount) + "원");
        metaCell.setCellStyle(s.meta);
        sheet.addMergedRegion(new CellRangeAddress(2, 2, 0, LAST_COL));

        sheet.createRow(3); // 여백 한 줄
        return 4; // 다음(헤더) 행 시작 위치
    }

    private int writeHeaderRow(Sheet sheet, Styles s, int rowIdx, String[] headers) {
        Row headerRow = sheet.createRow(rowIdx);
        headerRow.setHeightInPoints(20);
        for (int i = 0; i < headers.length; i++) {
            Cell c = headerRow.createCell(i);
            c.setCellValue(headers[i]);
            c.setCellStyle(s.header);
        }
        return rowIdx + 1;
    }

    private void writeLabelCell(Row row, Styles s, boolean stripe, String value) {
        Cell c = row.createCell(0);
        c.setCellValue(value);
        c.setCellStyle(stripe ? s.labelAlt : s.label);
    }

    private void writeTotalRow(Sheet sheet, Styles s, int rowIdx, String label, int startRow, int endRow, boolean empty) {
        Row totalRow = sheet.createRow(rowIdx);
        totalRow.setHeightInPoints(20);
        Cell totalLabel = totalRow.createCell(0);
        totalLabel.setCellValue(label);
        totalLabel.setCellStyle(s.total);

        for (int col = 1; col <= LAST_COL; col++) {
            char colLetter = (char) ('A' + col);
            Cell c = totalRow.createCell(col);
            if (empty) {
                c.setCellValue(0);
            } else {
                c.setCellFormula("SUM(" + colLetter + (startRow + 1) + ":" + colLetter + (endRow + 1) + ")");
            }
            c.setCellStyle(s.total);
        }
    }

    private void addFooterNote(Sheet sheet, Styles s, int rowIdx, String text) {
        Row noteRow = sheet.createRow(rowIdx);
        Cell c = noteRow.createCell(0);
        c.setCellValue(text);
        c.setCellStyle(s.note);
        sheet.addMergedRegion(new CellRangeAddress(rowIdx, rowIdx, 0, LAST_COL));
    }

    private void setupColumns(Sheet sheet) {
        sheet.setColumnWidth(0, 13 * 256);
        for (int i = 1; i <= LAST_COL; i++) sheet.setColumnWidth(i, 14 * 256);
    }

    // ============================================================
    // 스타일 묶음 - 한 번만 만들어서 재사용해요 (엑셀 스타일은 워크북당 개수 제한이 있어서 이렇게 하는 게 정석이에요)
    // ============================================================
    private static class Styles {
        CellStyle brandTitle, subTitle, meta, header, money, label, total, note;
        XSSFCellStyle moneyAlt, labelAlt;

        Styles(XSSFWorkbook wb) {
            DataFormat fmt = wb.createDataFormat();
            short moneyFmt = fmt.getFormat("#,##0\"원\"");

            Font brandFont = wb.createFont();
            brandFont.setBold(true);
            brandFont.setFontHeightInPoints((short) 16);
            brandFont.setColor(IndexedColors.WHITE.getIndex());
            brandTitle = wb.createCellStyle();
            brandTitle.setFont(brandFont);
            brandTitle.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
            brandTitle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            brandTitle.setVerticalAlignment(VerticalAlignment.CENTER);
            brandTitle.setAlignment(HorizontalAlignment.LEFT);
            brandTitle.setBorderLeft(BorderStyle.THIN); brandTitle.setBorderRight(BorderStyle.THIN);

            Font subFont = wb.createFont();
            subFont.setBold(true);
            subFont.setFontHeightInPoints((short) 12);
            subTitle = wb.createCellStyle();
            subTitle.setFont(subFont);
            subTitle.setBorderLeft(BorderStyle.THIN); subTitle.setBorderRight(BorderStyle.THIN);

            Font metaFont = wb.createFont();
            metaFont.setFontHeightInPoints((short) 10);
            metaFont.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
            meta = wb.createCellStyle();
            meta.setFont(metaFont);
            meta.setBorderLeft(BorderStyle.THIN); meta.setBorderRight(BorderStyle.THIN);
            meta.setBorderBottom(BorderStyle.MEDIUM);
            meta.setBottomBorderColor(IndexedColors.INDIGO.getIndex());

            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            header = wb.createCellStyle();
            header.setFont(headerFont);
            header.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
            header.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            header.setAlignment(HorizontalAlignment.CENTER);
            header.setVerticalAlignment(VerticalAlignment.CENTER);
            setAllBorders(header, BorderStyle.THIN);

            money = wb.createCellStyle();
            money.setDataFormat(moneyFmt);
            money.setAlignment(HorizontalAlignment.RIGHT);
            setAllBorders(money, BorderStyle.THIN);

            moneyAlt = wb.createCellStyle();
            moneyAlt.cloneStyleFrom(money);
            moneyAlt.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            moneyAlt.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            label = wb.createCellStyle();
            label.setAlignment(HorizontalAlignment.CENTER);
            setAllBorders(label, BorderStyle.THIN);

            labelAlt = wb.createCellStyle();
            labelAlt.cloneStyleFrom(label);
            labelAlt.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            labelAlt.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            Font totalFont = wb.createFont();
            totalFont.setBold(true);
            total = wb.createCellStyle();
            total.setFont(totalFont);
            total.setDataFormat(moneyFmt);
            total.setAlignment(HorizontalAlignment.RIGHT);
            total.setFillForegroundColor(IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex());
            total.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            total.setBorderTop(BorderStyle.MEDIUM);
            total.setBorderBottom(BorderStyle.DOUBLE);
            total.setBorderLeft(BorderStyle.THIN);
            total.setBorderRight(BorderStyle.THIN);

            Font noteFont = wb.createFont();
            noteFont.setItalic(true);
            noteFont.setFontHeightInPoints((short) 9);
            noteFont.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
            note = wb.createCellStyle();
            note.setFont(noteFont);
        }

        private void setAllBorders(CellStyle style, BorderStyle b) {
            style.setBorderTop(b); style.setBorderBottom(b); style.setBorderLeft(b); style.setBorderRight(b);
        }
    }
}
