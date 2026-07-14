<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.moa.dao.SalesDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>파일 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%
    if (session.getAttribute("name") == null || !"ADMIN".equals(session.getAttribute("memberType"))) { response.sendRedirect("login.jsp?role=ADMIN"); return; }
    List<Object[]> files = new SalesDAO().listAllWithReceiptImages();
    String currentMenu = "files";
%>
<div class="d-flex">
    <%@ include file="admin_sidebar.jsp" %>
    <main class="flex-grow-1 p-4">
        <h4 class="mb-1"><i class="bi bi-folder2-open"></i> 파일 관리</h4>
        <p class="text-muted mb-4" style="font-size:13px;">소상공인들이 영수증 AI 스캔으로 업로드한 원본 이미지를 관리해요.</p>

        <% if ("1".equals(request.getParameter("deleted"))) { %>
            <div class="alert alert-success py-2"><i class="bi bi-check-circle"></i> 이미지가 삭제됐어요.</div>
        <% } %>

        <div class="row g-3 mb-4">
            <div class="col-md-4 col-6"><div class="kpi-card"><div class="kpi-value"><%= files.size() %></div><div class="kpi-label">저장된 영수증 이미지</div></div></div>
        </div>

        <% if (files.isEmpty()) { %>
            <div class="moa-card text-center py-5"><p class="text-muted mb-0">업로드된 영수증 이미지가 없어요.</p></div>
        <% } else { %>
        <div class="row g-3">
            <% for (Object[] f : files) {
                int salesId = (Integer) f[0];
                Object salesDate = f[1];
                int amount = (Integer) f[2];
                String imagePath = (String) f[3];
                String storeName = (String) f[4];
            %>
            <div class="col-md-3 col-6">
                <div class="moa-card p-2">
                    <a href="<%= imagePath %>" target="_blank">
                        <img src="<%= imagePath %>" style="width:100%; height:130px; object-fit:cover; border-radius:8px;" alt="영수증">
                    </a>
                    <div style="font-size:12px; margin-top:8px;">
                        <b><%= storeName %></b><br>
                        <span class="text-muted"><%= salesDate %> · ₩<%= String.format("%,d", amount) %></span>
                    </div>
                    <form action="AdminFileServlet" method="post" class="mt-2" onsubmit="return confirm('이 영수증 이미지를 삭제할까요? (매출 기록은 유지돼요)');">
                        <input type="hidden" name="salesId" value="<%= salesId %>">
                        <input type="hidden" name="imagePath" value="<%= imagePath %>">
                        <button class="btn-moa-outline btn-moa-sm w-100 justify-content-center" style="color:#DC2626;"><i class="bi bi-trash"></i> 삭제</button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </main>
</div>
</body>
</html>
