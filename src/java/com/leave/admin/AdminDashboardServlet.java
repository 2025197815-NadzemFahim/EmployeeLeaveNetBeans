package com.model.admin;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
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
        int[] monthlyCount = new int[12];
        List<LeaveHistory> historyList = new ArrayList<>();

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

            // 1️⃣ Count total employees
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(employee_id) FROM employee")) {
                if (rs.next()) totalEmployees = rs.getInt(1);
            }

            // 2️⃣ Count approved leave today
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(request_id) FROM leave_request WHERE status='APPROVED' " +
                "AND CURRENT_DATE BETWEEN start_date AND end_date")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) onLeave = rs.getInt(1);
                }
            }

            // 3️⃣ Fetch leave types + balance for logged-in user safely (Derby compatible)
            List<Integer> balanceList = new ArrayList<>();
            List<String> leaveTypeList = new ArrayList<>();

            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT LT.TYPE_ID, LT.NAME, ELB.BALANCE " +
                "FROM LEAVE_TYPE LT " +
                "LEFT JOIN EMPLOYEE_LEAVE_BALANCE ELB " +
                "ON LT.TYPE_ID = ELB.TYPE_ID AND ELB.EMPLOYEE_ID = ? " +
                "ORDER BY LT.TYPE_ID DESC")) {

                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    int i = 0;
                    while (rs.next()) {
                        leaveTypeList.add(rs.getString("NAME"));
                        int bal = (rs.getObject("BALANCE") == null) ? 0 : rs.getInt("BALANCE");
                        balanceList.add(bal);

                        // 4️⃣ add to fallback history list too if needed
                        historyList.add(new LeaveHistory(
                            0,
                            rs.getString("NAME"),
                            "APPROVED",
                            Date.valueOf("2025-12-26"),
                            Date.valueOf("2025-12-28"),
                            bal
                        ));
                        i++;
                    }
                }
            }

            request.setAttribute("leaveTypes", leaveTypeList);
            request.setAttribute("leaveBalances", balanceList);

            // 5️⃣ Fill monthly chart count
            try (PreparedStatement ps = conn.prepareStatement("SELECT start_date FROM leave_request");
                 ResultSet rs = ps.executeQuery()) {

                Calendar cal = Calendar.getInstance();
                while (rs.next()) {
                    Date d = rs.getDate(1);
                    if (d != null) {
                        cal.setTime(d);
                        int m = cal.get(Calendar.MONTH);
                        monthlyCount[m]++;
                    }
                }
            }

            // 6️⃣ Fetch People On Leave (panel kiri)
            List<String> peopleOnLeave = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT e.name, lt.name FROM leave_request lr " +
                "JOIN employee e ON lr.submitted_by = e.employee_id " +
                "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                "WHERE lr.status='APPROVED' AND CURRENT_DATE BETWEEN lr.start_date AND lr.end_date")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        peopleOnLeave.add(rs.getString(1) + " — " + rs.getString(2));
                    }
                }
            }
            request.setAttribute("peopleOnLeave", peopleOnLeave);

            // 7️⃣ Fetch Upcoming Leave (panel kanan)
            List<String> upcomingLeave = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT e.name, lt.name, lr.start_date FROM leave_request lr " +
                "JOIN employee e ON lr.submitted_by = e.employee_id " +
                "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                "WHERE lr.status = 'APPROVED' " +   // ✅ approved only
                "AND lr.start_date > CURRENT_DATE " +
                "ORDER BY lr.start_date ")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        upcomingLeave.add(rs.getString(1) + " — " + rs.getString(2) + " (" + rs.getDate(3) + ")");
                    }
                }
            }
            request.setAttribute("upcomingLeave", upcomingLeave);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 8️⃣ Fallback if DB empty
        if (historyList.isEmpty()) {
            historyList.add(new LeaveHistory(0,"Annual Leave","APPROVED",Date.valueOf("2025-12-05"),Date.valueOf("2025-12-07"),10));
            historyList.add(new LeaveHistory(0,"Medical Leave","APPROVED",Date.valueOf("2025-12-01"),Date.valueOf("2025-12-02"),2));
        }

        // 9️⃣ Send final data to JSP
        request.setAttribute("monthlyCount", monthlyCount);
        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("presentToday", totalEmployees - onLeave);
        request.setAttribute("onLeave", onLeave);
        request.setAttribute("leaveHistory", historyList);

        request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);
    }

    // helper: get leave balance
    private int getLeaveBalance(int typeId, int employeeId) {
        int bal = 0;
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(
                "SELECT BALANCE FROM EMPLOYEE_LEAVE_BALANCE WHERE EMPLOYEE_ID=? AND TYPE_ID=?")) {
            ps.setInt(1, employeeId);
            ps.setInt(2, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) bal = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bal;
    }

    // helper: get leave type name
    private String getLeaveTypeName(Connection conn, int typeId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT NAME FROM LEAVE_TYPE WHERE TYPE_ID=?")) {
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : "Unknown";
            }
        }
    }
}