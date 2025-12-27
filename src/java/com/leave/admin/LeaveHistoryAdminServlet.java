package com.leave.admin;

import com.leave.model.LeaveHistory;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LeaveHistoryAdminServlet")
public class LeaveHistoryAdminServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:derby://localhost:1527/LeaveDB";
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

            // Fetch user details
            try (PreparedStatement psUser = conn.prepareStatement(
                    "SELECT name, role, position, profile_image FROM employee WHERE employee_id = ?")) {
                psUser.setInt(1, employeeId);
                ResultSet rsUser = psUser.executeQuery();

                if (rsUser.next()) {
                    session.setAttribute("name", rsUser.getString("name"));
                    session.setAttribute("role", rsUser.getString("role"));
                    session.setAttribute("position", rsUser.getString("position"));

                    String profileImg = rsUser.getString("profile_image");
                    if (profileImg == null || profileImg.isEmpty()) {
                        profileImg = "default.jpg";
                    }
                    session.setAttribute("profileImg", profileImg);
                    request.setAttribute("profileImg", profileImg);
                }
            }

            // Fetch leave history
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT request_id, type_id, status, start_date, end_date " +
                    "FROM leave_request WHERE submitted_by = ? ORDER BY request_id DESC")) {
                stmt.setInt(1, employeeId);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int typeId = rs.getInt("type_id");
                    int leaveBalance = getLeaveBalance(employeeId, typeId);

                    leaveHistoryList.add(new LeaveHistory(
                            rs.getInt("request_id"),
                            getLeaveTypeName(conn, typeId),
                            rs.getString("status"),
                            rs.getDate("start_date"),
                            rs.getDate("end_date"),
                            leaveBalance
                    ));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("leaveHistory", leaveHistoryList);
        request.getRequestDispatcher("/admin/leave_history_admin.jsp").forward(request, response);
    }

    private int getLeaveBalance(int employeeId, int typeId) {
        int balance = 0;
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT balance FROM employee_leave_balance WHERE employee_id = ? AND type_id = ?")) {

            ps.setInt(1, employeeId);
            ps.setInt(2, typeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                balance = rs.getInt("balance");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return balance;
    }

    private String getLeaveTypeName(Connection conn, int typeId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM leave_type WHERE type_id = ?")) {
            ps.setInt(1, typeId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getString("name") : "Unknown";
        }
    }
}