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
import java.util.Arrays;

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

        // --- Array untuk 4 leave types per user ---
        int[] leaveBalances = new int[4];
        String[] leaveTypes = {"Maternity", "Annual", "Emergency", "Medical"};

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // 1️⃣ Count total employees
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(employee_id) FROM employee")) {
                if (rs.next()) totalEmployees = rs.getInt(1);
            }

            // 2️⃣ Count on leave today (APPROVED sahaja)
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(request_id) FROM leave_request WHERE status='APPROVED' " +
                "AND CURRENT_DATE BETWEEN start_date AND end_date")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) onLeave = rs.getInt(1);
                }
            }

            // 3️⃣ Query leave balance per user untuk 4 leave types
            for (int i = 0; i < leaveTypes.length; i++) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT balance FROM employee_leave_balance WHERE employee_id=? AND type_id=?")) {

                    ps.setInt(1, employeeId);
                    ps.setInt(2, i + 1); // type_id = 1..4
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) leaveBalances[i] = rs.getInt(1);
                        else leaveBalances[i] = 0;
                    }
                }
            }

            // 4️⃣ Build leave history list
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT request_id, type_id, status, start_date, end_date FROM leave_request ORDER BY request_id DESC")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int typeId = rs.getInt("type_id");
                        historyList.add(new LeaveHistory(
                            rs.getInt("request_id"),
                            getLeaveTypeName(conn, typeId),
                            rs.getString("status"),
                            rs.getDate("start_date"),
                            rs.getDate("end_date"),
                            getLeaveBalance(typeId, employeeId)
                        ));
                    }
                }
            }

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
                "WHERE lr.start_date > CURRENT_DATE ORDER BY lr.start_date FETCH FIRST 5 ROWS ONLY")) {
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

        // fallback kalau DB kosong (UI preview)
        if (historyList.isEmpty()) {
            historyList.add(new LeaveHistory(1,"Annual","APPROVED",Date.valueOf("2025-12-02"),Date.valueOf("2025-12-05"),5));
            historyList.add(new LeaveHistory(2,"Medical","APPROVED",Date.valueOf("2025-12-10"),Date.valueOf("2025-12-12"),2));
        }

        // hantar leave balance ke JSP untuk circle
        request.setAttribute("leaveBalanceList", leaveBalances);

        // hantar chart dan summary cards
        request.setAttribute("monthlyCount", monthlyCount);
        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("presentToday", totalEmployees - onLeave);
        request.setAttribute("onLeave", onLeave);
        request.setAttribute("leaveHistory", historyList);

        request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);
    }

    // helper: leave balance per user
    private int getLeaveBalance(int typeId, int employeeId) {
        int bal = 0;
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(
                "SELECT balance FROM employee_leave_balance WHERE employee_id=? AND type_id=?")) {
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

    // helper: leave type name
    private String getLeaveTypeName(Connection conn, int typeId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM leave_type WHERE type_id=?")) {
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : "Unknown";
            }
        }
    }

    // query SUM balance untuk 4 types (jika perlu)
    private int[] getAllLeaveBalances() {
        int[] balances = new int[4];
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             Statement s = conn.createStatement();
             ResultSet rs = s.executeQuery(
                "SELECT type_id, SUM(balance) FROM employee_leave_balance GROUP BY type_id ORDER BY type_id")) {
            int i = 0;
            while (rs.next() && i < 4) {
                balances[i++] = rs.getInt(2);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return balances;
    }

    

}
