package com.model.admin;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.leave.model.LeaveHistory;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {

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

        int totalEmployees = 0;
        int onLeave = 0;
        int pending = 0;
        int adminBalance = 0;
        int[] monthlyCount = new int[12];

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // Fetch logged-in admin details for sidebar
            String sqlUser = "SELECT name, role, position, leave_balance FROM employee WHERE employee_id = ?";
            try (PreparedStatement psUser = conn.prepareStatement(sqlUser)) {
                psUser.setInt(1, employeeId);
                try (ResultSet rsUser = psUser.executeQuery()) {
                    if (rsUser.next()) {
                        session.setAttribute("name", rsUser.getString("name"));
                        session.setAttribute("role", rsUser.getString("role"));
                        session.setAttribute("position", rsUser.getString("position"));
                        adminBalance = rsUser.getInt("leave_balance");
                        session.setAttribute("leaveBalance", adminBalance);
                    }
                }
            }

            // Total employees count
            try (PreparedStatement psTotal = conn.prepareStatement("SELECT COUNT(employee_id) FROM employee");
                 ResultSet rsTotal = psTotal.executeQuery()) {
                if (rsTotal.next()) totalEmployees = rsTotal.getInt(1);
            }

            // Active leave today (approved leave currently happening)
            String sqlOnLeave = "SELECT COUNT(request_id) FROM leave_request WHERE status = 'APPROVED' AND start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE";
            try (PreparedStatement psLeave = conn.prepareStatement(sqlOnLeave);
                 ResultSet rsLeave = psLeave.executeQuery()) {
                if (rsLeave.next()) onLeave = rsLeave.getInt(1);
            }

            // Pending approvals count
            try (PreparedStatement psPending = conn.prepareStatement("SELECT COUNT(request_id) FROM leave_request WHERE status = 'PENDING'");
                 ResultSet rsPending = psPending.executeQuery()) {
                if (rsPending.next()) pending = rsPending.getInt(1);
            }

            // Chart data: Jan–Dec total employees applied leave
            String sqlChart = "SELECT MONTH(start_date) AS m, COUNT(DISTINCT submitted_by) AS total FROM leave_request GROUP BY MONTH(start_date) ORDER BY m";
            try (PreparedStatement psChart = conn.prepareStatement(sqlChart);
                 ResultSet rsChart = psChart.executeQuery()) {
                while (rsChart.next()) {
                    int m = rsChart.getInt("m");
                    monthlyCount[m - 1] = rsChart.getInt("total");
                }
            }

            // Optional: show 3 latest leave requests in approval list
            String sqlHistory = "SELECT request_id, type_id, status, start_date, end_date, submitted_by FROM leave_request ORDER BY request_id DESC FETCH FIRST 3 ROWS ONLY";
            try (PreparedStatement psHistory = conn.prepareStatement(sqlHistory);
                 ResultSet rs = psHistory.executeQuery()) {
                List<LeaveHistory> latestList = new ArrayList<>();
                while (rs.next()) {
                    latestList.add(new LeaveHistory(
                            rs.getInt("request_id"),
                            getLeaveTypeName(conn, rs.getInt("type_id")),
                            rs.getString("status"),
                            rs.getDate("start_date"),
                            rs.getDate("end_date"),
                            adminBalance
                    ));
                }
                request.setAttribute("latestLeaves", latestList);
            }

            System.out.println("ADMIN DASHBOARD FETCHED → totalEmployees:" + totalEmployees + " | onLeave:" + onLeave + " | pending:" + pending);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Send all data to JSP
        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("presentToday", totalEmployees - onLeave); // simple assumption
        request.setAttribute("onLeave", onLeave);
        request.setAttribute("pending", pending);
        request.setAttribute("leaveBalance", adminBalance);
        request.setAttribute("monthlyCount", monthlyCount);

        request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);
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
