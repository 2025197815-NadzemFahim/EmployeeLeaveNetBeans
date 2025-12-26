package com.leave.staff;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DashboardStaffServlet")
public class DashboardStaffServlet extends HttpServlet {

    private static final String JDBC_URL =
        "jdbc:derby://localhost:1527/LeaveDB";
    private static final String JDBC_USER = "app";
    private static final String JDBC_PASS = "app";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer employeeId =
            (Integer) request.getSession().getAttribute("employeeId");

        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Connection conn = null;

        try {
            conn = DriverManager.getConnection(
                JDBC_URL, JDBC_USER, JDBC_PASS
            );

            /* ================= STATUS TODAY ================= */
            String statusToday = "Present";
            java.sql.Date today =
                new java.sql.Date(System.currentTimeMillis());

            PreparedStatement psStatus = conn.prepareStatement(
                "SELECT COUNT(*) FROM leave_request " +
                "WHERE submitted_by=? AND status='APPROVED' " +
                "AND ? BETWEEN start_date AND end_date"
            );
            psStatus.setInt(1, employeeId);
            psStatus.setDate(2, today);

            ResultSet rsStatus = psStatus.executeQuery();
            if (rsStatus.next() && rsStatus.getInt(1) > 0) {
                statusToday = "On Leave";
            }

            /* ================= LEAVE BALANCE BY TYPE ================= */
            Map leaveBalanceByType = new HashMap();

            PreparedStatement psBalanceType = conn.prepareStatement(
                "SELECT lt.name, elb.balance " +
                "FROM employee_leave_balance elb " +
                "JOIN leave_type lt ON elb.type_id = lt.type_id " +
                "WHERE elb.employee_id = ?"
            );

            psBalanceType.setInt(1, employeeId);
            ResultSet rsBalanceType = psBalanceType.executeQuery();

            while (rsBalanceType.next()) {
                leaveBalanceByType.put(
                    rsBalanceType.getString("name"),
                    rsBalanceType.getInt("balance")
                );
            }


            /* ================= PENDING LEAVE ================= */
            String pendingInfo = null;
            PreparedStatement psPending = conn.prepareStatement(
                "SELECT lr.start_date, lr.end_date, lt.name " +
                "FROM leave_request lr " +
                "JOIN leave_type lt ON lr.type_id=lt.type_id " +
                "WHERE lr.submitted_by=? AND lr.status='PENDING' " +
                "ORDER BY lr.start_date FETCH FIRST 1 ROW ONLY"
            );
            psPending.setInt(1, employeeId);
            ResultSet rsPending = psPending.executeQuery();

            if (rsPending.next()) {
                java.text.SimpleDateFormat sdf =
                    new java.text.SimpleDateFormat("dd MMM yyyy");

                pendingInfo =
                    sdf.format(rsPending.getDate("start_date")) +
                    " – " +
                    sdf.format(rsPending.getDate("end_date")) +
                    "<br><span style='color:#b71c1c;'>" +
                    rsPending.getString("name") +
                    "</span>";
            }

            /* ================= ABSENT TODAY ================= */
            List absentToday = new ArrayList();
            PreparedStatement psAbsent = conn.prepareStatement(
                "SELECT e.name, lt.name AS leave_name " +
                "FROM leave_request lr " +
                "JOIN employee e ON lr.submitted_by=e.employee_id " +
                "JOIN leave_type lt ON lr.type_id=lt.type_id " +
                "WHERE lr.status='APPROVED' " +
                "AND CURRENT_DATE BETWEEN lr.start_date AND lr.end_date"
            );
            ResultSet rsAbsent = psAbsent.executeQuery();
            while (rsAbsent.next()) {
                absentToday.add(
                    rsAbsent.getString("name") + " – " +
                    rsAbsent.getString("leave_name")
                );
            }

            /* ================= UPCOMING LEAVE ================= */
            List upcomingLeave = new ArrayList();
            PreparedStatement psUpcoming = conn.prepareStatement(
                "SELECT e.name, lr.start_date, lt.name AS leave_name " +
                "FROM leave_request lr " +
                "JOIN employee e ON lr.submitted_by=e.employee_id " +
                "JOIN leave_type lt ON lr.type_id=lt.type_id " +
                "WHERE lr.status='APPROVED' " +
                "AND lr.start_date > CURRENT_DATE " +
                "ORDER BY lr.start_date FETCH FIRST 5 ROWS ONLY"
            );
            ResultSet rsUpcoming = psUpcoming.executeQuery();
            while (rsUpcoming.next()) {
                upcomingLeave.add(
                    rsUpcoming.getDate("start_date") + " – " +
                    rsUpcoming.getString("name") +
                    " (" + rsUpcoming.getString("leave_name") + ")"
                );
            }

            /* ================= CALENDAR LEAVES ================= */
            Map calendarLeaves = new HashMap();

            PreparedStatement psCalendar = conn.prepareStatement(
                "SELECT lr.start_date, lr.end_date, e.name, lt.name AS leave_type " +
                "FROM leave_request lr " +
                "JOIN employee e ON lr.submitted_by=e.employee_id " +
                "JOIN leave_type lt ON lr.type_id=lt.type_id " +
                "WHERE lr.status='APPROVED'"
            );

            ResultSet rsCalendar = psCalendar.executeQuery();

            while (rsCalendar.next()) {
                java.sql.Date start = rsCalendar.getDate("start_date");
                java.sql.Date end   = rsCalendar.getDate("end_date");

                String info =
                    rsCalendar.getString("name") + " – " +
                    rsCalendar.getString("leave_type");

                Calendar cal = Calendar.getInstance();
                cal.setTime(start);

                Calendar endCal = Calendar.getInstance();
                endCal.setTime(end);

                while (!cal.after(endCal)) {
                    String key =
                        cal.get(Calendar.YEAR) + "-" +
                        String.format("%02d", cal.get(Calendar.MONTH)+1) + "-" +
                        String.format("%02d", cal.get(Calendar.DAY_OF_MONTH));

                    if (!calendarLeaves.containsKey(key)) {
                        calendarLeaves.put(key, new ArrayList());
                    }

                    ((List) calendarLeaves.get(key)).add(info);
                    cal.add(Calendar.DATE, 1);
                }
            }

            /* ================= PASS TO JSP ================= */
            request.setAttribute("statusToday", statusToday);
            request.setAttribute("leaveBalanceByType", leaveBalanceByType);
            request.setAttribute("pendingInfo", pendingInfo);
            request.setAttribute("absentToday", absentToday);
            request.setAttribute("upcomingLeave", upcomingLeave);
            request.setAttribute("calendarLeaves", calendarLeaves);

            request.getRequestDispatcher("/staff/staff_dashboard.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException ignore) {}
        }
    }
}
