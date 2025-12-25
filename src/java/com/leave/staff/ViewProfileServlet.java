package com.leave.staff;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


@WebServlet("/ViewProfileServlet")
public class ViewProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        if (employeeId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app")) {

            /* ================= EMPLOYEE INFO ================= */
            PreparedStatement psEmp = conn.prepareStatement(
                "SELECT * FROM employee WHERE employee_id = ?"
            );
            psEmp.setInt(1, employeeId);
            ResultSet rsEmp = psEmp.executeQuery();

            if (!rsEmp.next()) {
                response.sendRedirect("login.jsp");
                return;
            }

            Map<String, Object> emp = new HashMap<>();
            emp.put("employee_id", rsEmp.getInt("employee_id"));
            emp.put("name", rsEmp.getString("name"));
            emp.put("email", rsEmp.getString("email"));
            emp.put("department", rsEmp.getString("department"));
            emp.put("role", rsEmp.getString("role"));
            emp.put("position", rsEmp.getString("position"));
            emp.put("profile_image", rsEmp.getString("profile_image"));
            emp.put("date_of_birth", rsEmp.getDate("date_of_birth"));
            emp.put("address", rsEmp.getString("address"));
            emp.put("admission_date", rsEmp.getDate("admission_date"));

            request.setAttribute("emp", emp);

            /* ================= LEAVE BALANCE INFO ================= */
            PreparedStatement psLeave = conn.prepareStatement(
                "SELECT lt.name, elb.balance, lp.max_days " +
                "FROM employee_leave_balance elb " +
                "JOIN leave_type lt ON elb.type_id = lt.type_id " +
                "JOIN leave_policy lp ON lp.type_id = lt.type_id " +
                "WHERE elb.employee_id = ?"
            );
            psLeave.setInt(1, employeeId);
            ResultSet rsLeave = psLeave.executeQuery();

            List<Map<String, Object>> leaveInfo = new ArrayList<>();

            while (rsLeave.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rsLeave.getString("name"));
                row.put("balance", rsLeave.getInt("balance"));
                row.put("max_days", rsLeave.getInt("max_days"));
                leaveInfo.add(row);
            }

            request.setAttribute("leaveInfo", leaveInfo);

            request.getRequestDispatcher("staff/profile.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }
}

