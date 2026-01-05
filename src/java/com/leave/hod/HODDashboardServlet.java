/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.leave.hod;

/**
 *
 * @author suweg
 */
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/HODDashboardServlet")
public class HODDashboardServlet extends HttpServlet {

    private static final String DB_URL
            = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer hodId = (Integer) session.getAttribute("employeeId");

        // ✅ ONLY check employeeId
        if (hodId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            /* ================= GET DEPARTMENT FROM DB ================= */
            String department = null;

            PreparedStatement psDept = conn.prepareStatement(
                    "SELECT department FROM employee WHERE employee_id=?"
            );
            psDept.setInt(1, hodId);
            ResultSet rsDept = psDept.executeQuery();

            if (rsDept.next()) {
                department = rsDept.getString("department");
                // optional cache
                session.setAttribute("department", department);
            } else {
                response.sendRedirect("login.jsp");
                return;
            }
            /* ================= PROFILE INFO ================= */
            PreparedStatement psProfile = conn.prepareStatement(
                    "SELECT name, position, profile_image FROM employee WHERE employee_id=?"
            );
            psProfile.setInt(1, hodId);

            ResultSet rsProfile = psProfile.executeQuery();
            if (rsProfile.next()) {
                session.setAttribute("empName", rsProfile.getString("name"));
                session.setAttribute("empPost", rsProfile.getString("position"));
                session.setAttribute("profileImage", rsProfile.getString("profile_image"));
            }


            /* ================= MY LEAVE (AUTO) ================= */
            PreparedStatement psMyLeave = conn.prepareStatement(
                    "SELECT lt.name AS leave_name, "
                    + "       elb.balance, "
                    + "       lp.max_days "
                    + "FROM employee_leave_balance elb "
                    + "JOIN leave_type lt ON elb.type_id = lt.type_id "
                    + "JOIN leave_policy lp ON elb.type_id = lp.type_id "
                    + "WHERE elb.employee_id = ? "
                    + "AND lp.status = 'Active'"
            );

            psMyLeave.setInt(1, hodId);

            ResultSet rsMyLeave = psMyLeave.executeQuery();
            List<Map<String, Object>> myLeaveList = new ArrayList<>();

            while (rsMyLeave.next()) {
                Map<String, Object> leave = new HashMap<>();
                leave.put("name", rsMyLeave.getString("leave_name"));
                leave.put("balance", rsMyLeave.getInt("balance"));
                leave.put("max", rsMyLeave.getInt("max_days"));
                myLeaveList.add(leave);
            }
            request.setAttribute("myLeaveList", myLeaveList);

            /* ================= DEPARTMENT LEAVE REQUESTS ================= */
            PreparedStatement psRequests = conn.prepareStatement(
                    "SELECT lr.request_id, e.name AS staff_name, lt.name AS leave_type, "
                    + "lr.start_date, lr.end_date, lr.status "
                    + "FROM leave_request lr "
                    + "JOIN employee e ON lr.submitted_by = e.employee_id "
                    + "JOIN leave_type lt ON lr.type_id = lt.type_id "
                    + "WHERE e.department = ? "
                    + "AND lr.status = 'PENDING' "
                    + "ORDER BY lr.request_id DESC "
                    + "FETCH FIRST 4 ROWS ONLY"
            );
            psRequests.setString(1, department);

            ResultSet rsReq = psRequests.executeQuery();
            List<Map<String, Object>> leaveRequests = new ArrayList<>();

            while (rsReq.next()) {
                Map<String, Object> r = new HashMap<>();
                r.put("id", rsReq.getInt("request_id"));
                r.put("staff", rsReq.getString("staff_name"));
                r.put("type", rsReq.getString("leave_type"));
                r.put("start", rsReq.getDate("start_date"));
                r.put("end", rsReq.getDate("end_date"));
                r.put("status", rsReq.getString("status"));
                leaveRequests.add(r);
            }
            request.setAttribute("leaveRequests", leaveRequests);

            /* ================= STAFF ON LEAVE TODAY ================= */
            java.sql.Date today = java.sql.Date.valueOf(LocalDate.now());

            PreparedStatement psToday = conn.prepareStatement(
                    "SELECT e.name, lt.name AS leave_type "
                    + "FROM leave_request lr "
                    + "JOIN employee e ON lr.submitted_by = e.employee_id "
                    + "JOIN leave_type lt ON lr.type_id = lt.type_id "
                    + "WHERE e.department = ? "
                    + "AND lr.start_date <= ? AND lr.end_date >= ? "
                    + "AND lr.status = 'APPROVED'"
            );
            psToday.setString(1, department);
            psToday.setDate(2, today);
            psToday.setDate(3, today);

            ResultSet rsToday = psToday.executeQuery();
            List<Map<String, String>> todayLeave = new ArrayList<>();

            while (rsToday.next()) {
                Map<String, String> t = new HashMap<>();
                t.put("name", rsToday.getString("name"));
                t.put("type", rsToday.getString("leave_type"));
                todayLeave.add(t);
            }
            request.setAttribute("todayLeave", todayLeave);

            /* ================= RIGHT PANEL ================= */
            request.setAttribute("pendingCount",
                    count(conn, department, "PENDING"));
            request.setAttribute("approvedCount",
                    count(conn, department, "APPROVED"));
            request.setAttribute("rejectedCount",
                    count(conn, department, "REJECTED"));

            request.setAttribute("totalStaff",
                    simpleCount(conn,
                            "SELECT COUNT(*) FROM employee WHERE department=?",
                            department));

            request.setAttribute("currentlyOnLeave", todayLeave.size());

            request.getRequestDispatcher("hod/hod_dashboard.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private int count(Connection conn, String dept, String status)
            throws SQLException {

        PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM leave_request lr "
                + "JOIN employee e ON lr.submitted_by=e.employee_id "
                + "WHERE lr.status=? AND e.department=?"
        );
        ps.setString(1, status);
        ps.setString(2, dept);

        ResultSet rs = ps.executeQuery();
        rs.next();
        return rs.getInt(1);
    }

    private int simpleCount(Connection conn, String sql, String dept)
            throws SQLException {

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, dept);
        ResultSet rs = ps.executeQuery();
        rs.next();
        return rs.getInt(1);
    }
}
