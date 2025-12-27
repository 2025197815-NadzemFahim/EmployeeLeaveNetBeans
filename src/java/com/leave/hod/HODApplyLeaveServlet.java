package com.leave.hod;

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

@WebServlet("/HODApplyLeaveServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class HODApplyLeaveServlet extends HttpServlet {

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

        /* ===== DATE VALIDATION ===== */
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        LocalDate today = LocalDate.now();

        if (start.isBefore(today)) {
            response.sendRedirect("hod/apply_leave.jsp?dateError=past");
            return;
        }
        if (end.isBefore(start)) {
            response.sendRedirect("hod/apply_leave.jsp?dateError=range");
            return;
        }

        long leaveDays = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1;

        /* ===== HANDLE ATTACHMENT ===== */
        Part filePart = request.getPart("attachment");
        String filePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = System.currentTimeMillis() + "_"
                    + java.nio.file.Paths.get(filePart.getSubmittedFileName())
                            .getFileName().toString();

            String uploadDirPath = "C:/leave_uploads/attachments";
            File uploadDir = new File(uploadDirPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            File file = new File(uploadDir, fileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, file.toPath(),
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }

            filePath = "attachments/" + fileName;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app")) {

            /* ===== ENSURE ROLE IS HOD ===== */
            String role = "";
            PreparedStatement psRole = conn.prepareStatement(
                "SELECT role FROM employee WHERE employee_id=?"
            );
            psRole.setInt(1, employeeId);
            ResultSet rsRole = psRole.executeQuery();

            if (rsRole.next()) {
                role = rsRole.getString("role");
            }

            if (!"HOD".equals(role)) {
                response.sendRedirect("login.jsp");
                return;
            }

            /* ===== CHECK LEAVE BALANCE ===== */
            PreparedStatement psBalance = conn.prepareStatement(
                "SELECT balance FROM employee_leave_balance " +
                "WHERE employee_id=? AND type_id=?"
            );
            psBalance.setInt(1, employeeId);
            psBalance.setInt(2, typeId);
            ResultSet rsBalance = psBalance.executeQuery();

            if (!rsBalance.next()) {
                response.sendRedirect("hod/apply_leave.jsp?error=nobalance");
                return;
            }

            int balance = rsBalance.getInt("balance");

            if (leaveDays > balance) {
                response.sendRedirect("hod/apply_leave.jsp?error=insufficient");
                return;
            }

            /* ===== GET CEO (APPROVER) ===== */
            int ceoId = 0;
            PreparedStatement psCeo = conn.prepareStatement(
                "SELECT employee_id FROM employee WHERE role='CEO'"
            );
            ResultSet rsCeo = psCeo.executeQuery();
            if (rsCeo.next()) {
                ceoId = rsCeo.getInt("employee_id");
            }

            if (ceoId == 0) {
                response.sendRedirect("hod/apply_leave.jsp?error=no_ceo");
                return;
            }

            /* ===== INSERT LEAVE REQUEST ===== */
            PreparedStatement psInsert = conn.prepareStatement(
                "INSERT INTO leave_request " +
                "(start_date, end_date, reason, status, submitted_by, approved_by, type_id, attachment) " +
                "VALUES (?, ?, ?, 'PENDING', ?, ?, ?, ?)"
            );

            psInsert.setDate(1, Date.valueOf(startDate));
            psInsert.setDate(2, Date.valueOf(endDate));
            psInsert.setString(3, reason);
            psInsert.setInt(4, employeeId); // submitted_by (HOD)
            psInsert.setInt(5, ceoId);      // approved_by (CEO)
            psInsert.setInt(6, typeId);
            psInsert.setString(7, filePath);

            psInsert.executeUpdate();

            response.sendRedirect("hod/apply_leave.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("hod/apply_leave.jsp?error=server");
        }
    }
}
