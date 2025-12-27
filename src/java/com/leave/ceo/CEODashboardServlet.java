package com.leave.ceo;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CEODashboardServlet")
public class CEODashboardServlet extends HttpServlet {

    private static final String DB_URL
            = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer ceoId = (Integer) session.getAttribute("employeeId");

        // ✅ CEO must be logged in
        if (ceoId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            /* ================= CEO PROFILE INFO ================= */
            PreparedStatement psProfile = conn.prepareStatement(
                    "SELECT name, position, profile_image FROM employee WHERE employee_id=?"
            );
            psProfile.setInt(1, ceoId);
            ResultSet rsProfile = psProfile.executeQuery();

            if (rsProfile.next()) {
                session.setAttribute("empName", rsProfile.getString("name"));
                session.setAttribute("empPost", rsProfile.getString("position"));
                session.setAttribute("profileImage", rsProfile.getString("profile_image"));
            }

            /* ================= HOD LEAVE REQUESTS (PENDING ONLY) ================= */
            PreparedStatement psRequests = conn.prepareStatement(
                    "SELECT lr.request_id, e.name AS hod_name, lt.name AS leave_type, "
                    + "lr.start_date, lr.end_date, lr.status "
                    + "FROM leave_request lr "
                    + "JOIN employee e ON lr.submitted_by = e.employee_id "
                    + "JOIN leave_type lt ON lr.type_id = lt.type_id "
                    + "WHERE e.role = 'HOD' "
                    + "AND lr.status = 'PENDING' "
                    + "ORDER BY lr.request_id DESC "
                    + "FETCH FIRST 4 ROWS ONLY"
            );

            ResultSet rsReq = psRequests.executeQuery();
            List<Map<String, Object>> leaveRequests = new ArrayList<>();

            while (rsReq.next()) {
                Map<String, Object> r = new HashMap<>();
                r.put("id", rsReq.getInt("request_id"));
                r.put("staff", rsReq.getString("hod_name"));
                r.put("type", rsReq.getString("leave_type"));
                r.put("start", rsReq.getDate("start_date"));
                r.put("end", rsReq.getDate("end_date"));
                r.put("status", rsReq.getString("status"));
                leaveRequests.add(r);
            }
            request.setAttribute("leaveRequests", leaveRequests);

            /* ================= STAFF ON LEAVE TODAY (ALL DEPARTMENTS) ================= */
            java.sql.Date today = java.sql.Date.valueOf(LocalDate.now());

            PreparedStatement psToday = conn.prepareStatement(
                    "SELECT e.name, lt.name AS leave_type "
                    + "FROM leave_request lr "
                    + "JOIN employee e ON lr.submitted_by = e.employee_id "
                    + "JOIN leave_type lt ON lr.type_id = lt.type_id "
                    + "WHERE lr.start_date <= ? AND lr.end_date >= ? "
                    + "AND lr.status = 'APPROVED' "
                    + "AND e.role = 'HOD'"
            );

            psToday.setDate(1, today);
            psToday.setDate(2, today);

            ResultSet rsToday = psToday.executeQuery();
            List<Map<String, String>> todayLeave = new ArrayList<>();

            while (rsToday.next()) {
                Map<String, String> t = new HashMap<>();
                t.put("name", rsToday.getString("name"));
                t.put("type", rsToday.getString("leave_type"));
                todayLeave.add(t);
            }
            request.setAttribute("todayLeave", todayLeave);

            /* ================= TEAM SUMMARY (ALL DEPARTMENTS) ================= */
            request.setAttribute("pendingCount",
                    simpleCount(conn,
                            "SELECT COUNT(*) "
                            + "FROM leave_request lr "
                            + "JOIN employee e ON lr.submitted_by = e.employee_id "
                            + "WHERE lr.status='PENDING' AND e.role='HOD'")
            );

            request.setAttribute("approvedCount",
                    simpleCount(conn,
                            "SELECT COUNT(*) "
                            + "FROM leave_request lr "
                            + "JOIN employee e ON lr.submitted_by = e.employee_id "
                            + "WHERE lr.status='APPROVED' AND e.role='HOD'")
            );

            request.setAttribute("rejectedCount",
                    simpleCount(conn,
                            "SELECT COUNT(*) "
                            + "FROM leave_request lr "
                            + "JOIN employee e ON lr.submitted_by = e.employee_id "
                            + "WHERE lr.status='REJECTED' AND e.role='HOD'")
            );

            request.setAttribute("currentlyOnLeave", todayLeave.size());
            
            /* ================= WORKFORCE OVERVIEW ================= */
request.setAttribute("staffCount",
        simpleCount(conn, "SELECT COUNT(*) FROM employee WHERE role='STAFF'"));

request.setAttribute("hodCount",
        simpleCount(conn, "SELECT COUNT(*) FROM employee WHERE role='HOD'"));

request.setAttribute("adminCount",
        simpleCount(conn, "SELECT COUNT(*) FROM employee WHERE role='ADMIN'"));

request.setAttribute("ceoCount",
        simpleCount(conn, "SELECT COUNT(*) FROM employee WHERE role='CEO'"));

/* ================= STAFF DISTRIBUTION BY DEPARTMENT ================= */
PreparedStatement psDeptChart = conn.prepareStatement(
        "SELECT department, COUNT(*) AS total " +
        "FROM employee GROUP BY department"
);

ResultSet rsDeptChart = psDeptChart.executeQuery();
List<Map<String, Object>> deptChart = new ArrayList<>();

while (rsDeptChart.next()) {
    Map<String, Object> d = new HashMap<>();
    d.put("department", rsDeptChart.getString("department"));
    d.put("total", rsDeptChart.getInt("total"));
    deptChart.add(d);
}

request.setAttribute("deptChart", deptChart);


            request.getRequestDispatcher("ceo/ceo_dashboard.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    /* ================= HELPER ================= */
    private int simpleCount(Connection conn, String sql)
            throws SQLException {

        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        rs.next();
        return rs.getInt(1);
    }
}
