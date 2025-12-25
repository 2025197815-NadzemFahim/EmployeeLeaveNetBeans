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

            // Fetch user details for sidebar
            String userSql = "SELECT name, role, position, leave_balance FROM employee WHERE employee_id = ?";
            try (PreparedStatement psUser = conn.prepareStatement(userSql);
                 ResultSet rsUser = runQuery(psUser, employeeId)) {

                if (rsUser.next()) {
                    session.setAttribute("name", rsUser.getString("name"));
                    session.setAttribute("role", rsUser.getString("role"));
                    session.setAttribute("position", rsUser.getString("position"));
                    session.setAttribute("leaveBalance", rsUser.getInt("leave_balance"));
                }
            }

            // Fetch only this user's leave history
            String leaveSql = "SELECT request_id, type_id, status, start_date, end_date FROM leave_request WHERE submitted_by = ?";
            try (PreparedStatement stmt = conn.prepareStatement(leaveSql)) {
                stmt.setInt(1, employeeId);
                try (ResultSet rs = stmt.executeQuery()) {

                    Integer leaveBalance = (Integer) session.getAttribute("leaveBalance");
                    if (leaveBalance == null) leaveBalance = 0;

                    while (rs.next()) {
                        leaveHistoryList.add(new LeaveHistory(
                                rs.getInt("request_id"),
                                getLeaveTypeName(conn, rs.getInt("type_id")),
                                rs.getString("status"),
                                rs.getDate("start_date"),
                                rs.getDate("end_date"),
                                leaveBalance
                        ));
                    }

                    System.out.println("Leave records fetched for ADMIN " + employeeId + ": " + leaveHistoryList.size());
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("leaveHistory", leaveHistoryList);
        request.getRequestDispatcher("/admin/leave_history_admin.jsp").forward(request, response);
    }

    private ResultSet runQuery(PreparedStatement ps, int id) throws SQLException {
        ps.setInt(1, id);
        return ps.executeQuery();
    }

    private String getLeaveTypeName(Connection conn, int typeId) throws SQLException {
        String sql = "SELECT name FROM leave_type WHERE type_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("name") : "Unknown";
            }
        }
    }
}
