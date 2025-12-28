package com.leave.admin;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.sql.*;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminApplyLeaveServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class AdminApplyLeaveServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        String role = (String) session.getAttribute("role");

        if (employeeId == null || !"ADMIN".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String reason = request.getParameter("reason");
        int typeId = Integer.parseInt(request.getParameter("typeId"));

        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        LocalDate today = LocalDate.now();

        if (start.isBefore(today)) {
            response.sendRedirect("admin/apply_leave.jsp?dateError=past");
            return;
        }
        if (end.isBefore(start)) {
            response.sendRedirect("admin/apply_leave.jsp?dateError=range");
            return;
        }

        long leaveDays = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1;

        Part filePart = request.getPart("attachment");
        String filePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = System.currentTimeMillis() + "_"
                    + java.nio.file.Paths.get(filePart.getSubmittedFileName())
                            .getFileName().toString();

            File uploadDir = new File("C:/leave_uploads/attachments");
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

            conn.setAutoCommit(false); // ✅ ADDED

            /* ===== CHECK LEAVE BALANCE ===== */
            PreparedStatement psBalance = conn.prepareStatement(
                "SELECT balance FROM employee_leave_balance WHERE employee_id=? AND type_id=?"
            );
            psBalance.setInt(1, employeeId);
            psBalance.setInt(2, typeId);
            ResultSet rsBalance = psBalance.executeQuery();

            if (!rsBalance.next()) {
                response.sendRedirect("admin/apply_leave.jsp?error=nobalance");
                return;
            }

            int balance = rsBalance.getInt("balance");
            rsBalance.close();
            psBalance.close();

            if (leaveDays > balance) {
                response.sendRedirect("admin/apply_leave.jsp?error=insufficient");
                return;
            }

            /* ===== GET ADMIN DEPARTMENT ===== */
            String department = "";
            PreparedStatement psDept = conn.prepareStatement(
                "SELECT department FROM employee WHERE employee_id=?"
            );
            psDept.setInt(1, employeeId);
            ResultSet rsDept = psDept.executeQuery();
            if (rsDept.next()) department = rsDept.getString("department");
            rsDept.close();
            psDept.close();

            /* ===== FIND HOD HR ===== */
            int hodId = 0;
            PreparedStatement psHod = conn.prepareStatement(
                "SELECT employee_id FROM employee WHERE role='HOD' AND department=?"
            );
            psHod.setString(1, department);
            ResultSet rsHod = psHod.executeQuery();
            if (rsHod.next()) hodId = rsHod.getInt("employee_id");
            rsHod.close();
            psHod.close();

            if (hodId == 0) {
                response.sendRedirect("admin/apply_leave.jsp?error=nohod");
                return;
            }

            /* ===== INSERT LEAVE REQUEST ===== */
            PreparedStatement psInsert = conn.prepareStatement(
                "INSERT INTO leave_request "
              + "(start_date, end_date, reason, status, submitted_by, approved_by, type_id, attachment) "
              + "VALUES (?, ?, ?, 'PENDING', ?, ?, ?, ?)"
            );

            psInsert.setDate(1, Date.valueOf(startDate));
            psInsert.setDate(2, Date.valueOf(endDate));
            psInsert.setString(3, reason);
            psInsert.setInt(4, employeeId); // ADMIN
            psInsert.setInt(5, hodId);      // HOD HR
            psInsert.setInt(6, typeId);
            psInsert.setString(7, filePath);
            psInsert.executeUpdate();
            psInsert.close();

            // ✅ ADDED: get applicant name
            String applicantName = "";
            PreparedStatement psName = conn.prepareStatement(
                "SELECT name FROM employee WHERE employee_id=?"
            );
            psName.setInt(1, employeeId);
            ResultSet rsName = psName.executeQuery();
            if (rsName.next()) applicantName = rsName.getString("name");
            rsName.close();
            psName.close();

            // ✅ ADDED: notify HOD HR
            notifyApprover(conn, hodId, applicantName, start, end);

            conn.commit(); // ✅ ADDED
            response.sendRedirect("admin/apply_leave.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/apply_leave.jsp?error=server");
        }
    }

    // ❗ NEW METHOD ADDED (does not affect existing logic)
    private void notifyApprover(Connection conn, int approverId,
            String applicantName, LocalDate start, LocalDate end)
            throws SQLException {

        String msg = "New leave request from " + applicantName
                + " (" + start + " to " + end + ")";

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO notification (receiver_id, message, timestamp, is_read) "
          + "VALUES (?, ?, CURRENT_TIMESTAMP, FALSE)"
        );
        ps.setInt(1, approverId);
        ps.setString(2, msg);
        ps.executeUpdate();
        ps.close();
    }
}
