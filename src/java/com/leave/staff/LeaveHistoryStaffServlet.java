package com.leave.staff;

import com.leave.model.LeaveHistory;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LeaveHistoryStaffServlet")
public class LeaveHistoryStaffServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employeeId = (int) session.getAttribute("employeeId");
        List<LeaveHistory> leaveHistoryList = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // 1️⃣ Fetch user sidebar details
            try (PreparedStatement psUser = conn.prepareStatement(
                    "SELECT name, role, position, leave_balance FROM employee WHERE employee_id = ?")) {
                psUser.setInt(1, employeeId);
                ResultSet rsUser = psUser.executeQuery();

                if (rsUser.next()) {
                    session.setAttribute("name", rsUser.getString("name"));
                    session.setAttribute("role", rsUser.getString("role"));
                    session.setAttribute("position", rsUser.getString("position"));
                    session.setAttribute("leaveBalance", rsUser.getInt("leave_balance"));
                }
            }

            // 2️⃣ Fetch only this user's leave history — USING EXACT DB COLUMN
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT request_id, type_id, status, start_date, end_date, submitted_by FROM leave_request WHERE submitted_by = ? ORDER BY request_id DESC")) {
                stmt.setInt(1, employeeId);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    leaveHistoryList.add(new LeaveHistory(
                            rs.getInt("request_id"),
                            getLeaveTypeName(conn, rs.getInt("type_id")),
                            rs.getString("status"),
                            rs.getDate("start_date"),
                            rs.getDate("end_date"),
                            (int) session.getAttribute("leaveBalance")
                    ));
                }

                // 3️⃣ Debug log print
                System.out.println("Leave records fetched for employee " + employeeId + ": " + leaveHistoryList.size());
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 4️⃣ Send to JSP
        request.setAttribute("leaveHistory", leaveHistoryList);
        request.getRequestDispatcher("/staff/leave_history_staff.jsp").forward(request, response);
    }

    private String getLeaveTypeName(Connection conn, int typeId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM leave_type WHERE type_id = ?")) {
            ps.setInt(1, typeId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getString("name") : "Unknown";
        }
    }
}
