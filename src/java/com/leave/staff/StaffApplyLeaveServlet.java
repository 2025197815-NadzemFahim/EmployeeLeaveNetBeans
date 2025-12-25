package com.leave.staff;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.time.LocalDate;

@WebServlet("/StaffApplyLeaveServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class StaffApplyLeaveServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        if (employeeId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String reason = request.getParameter("reason");
        int typeId = Integer.parseInt(request.getParameter("typeId"));

        /* ===== DATE VALIDATION (INSERT HERE) ===== */
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        LocalDate today = LocalDate.now();

// ❌ Start date in the past
        if (start.isBefore(today)) {
            response.sendRedirect("staff/apply_leave.jsp?dateError=past");
            return;
        }

// ❌ End date before start date
        if (end.isBefore(start)) {
            response.sendRedirect("staff/apply_leave.jsp?dateError=range");
            return;
        }
        /* ===== END DATE VALIDATION ===== */

/* ===== HANDLE ATTACHMENT (EXTERNAL FOLDER) ===== */
Part filePart = request.getPart("attachment");
String filePath = null;

if (filePart != null && filePart.getSize() > 0) {

    // ✔ Safe filename
    String fileName = System.currentTimeMillis() + "_"
            + java.nio.file.Paths
                .get(filePart.getSubmittedFileName())
                .getFileName()
                .toString();

    // ✔ External upload directory (CREATE THIS MANUALLY)
    String uploadDirPath = "C:/leave_uploads/attachments";

    File uploadDir = new File(uploadDirPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();   // backup safety
    }

    File file = new File(uploadDir, fileName);

    try (InputStream input = filePart.getInputStream()) {
        Files.copy(
            input,
            file.toPath(),
            java.nio.file.StandardCopyOption.REPLACE_EXISTING
        );
    }

    // ✔ Store RELATIVE path in DB (important)
    filePath = "attachments/" + fileName;
}



        try {
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/LeaveDB", "app", "app"
            );

            /* ===== GET STAFF DEPARTMENT ===== */
            String department = "";
            PreparedStatement psDept
                    = conn.prepareStatement(
                            "SELECT department FROM employee WHERE employee_id=?"
                    );
            psDept.setInt(1, employeeId);
            ResultSet rsDept = psDept.executeQuery();
            if (rsDept.next()) {
                department = rsDept.getString("department");
            }

            /* ===== GET HOD ===== */
            int hodId = 0;
            PreparedStatement psHod
                    = conn.prepareStatement(
                            "SELECT employee_id FROM employee WHERE role='HOD' AND department=?"
                    );
            psHod.setString(1, department);
            ResultSet rsHod = psHod.executeQuery();
            if (rsHod.next()) {
                hodId = rsHod.getInt("employee_id");
            }

            /* ===== INSERT LEAVE REQUEST ===== */
            PreparedStatement psInsert
                    = conn.prepareStatement(
                            "INSERT INTO leave_request "
                            + "(start_date, end_date, reason, status, submitted_by, approved_by, type_id, attachment) "
                            + "VALUES (?, ?, ?, 'PENDING', ?, ?, ?, ?)"
                    );

            psInsert.setDate(1, Date.valueOf(startDate));
            psInsert.setDate(2, Date.valueOf(endDate));
            psInsert.setString(3, reason);
            psInsert.setInt(4, employeeId);
            psInsert.setInt(5, hodId);
            psInsert.setInt(6, typeId);
            psInsert.setString(7, filePath);

            psInsert.executeUpdate();
            conn.close();

            // stay on page + popup
            response.sendRedirect("staff/apply_leave.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff/apply_leave.jsp");
        }
    }
}
