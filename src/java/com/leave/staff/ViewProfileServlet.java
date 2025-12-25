package com.leave.staff;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.util.HashMap;
import java.util.Map;


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

            // ===== EMPLOYEE INFO =====
            PreparedStatement psEmp = conn.prepareStatement(
                    "SELECT * FROM employee WHERE employee_id=?"
            );
            psEmp.setInt(1, employeeId);
            ResultSet emp = psEmp.executeQuery();

            if (!emp.next()) {
                response.sendRedirect("login.jsp");
                return;
            }

            request.setAttribute("emp", emp);

            // ===== LEAVE INFO (AUTO GROW) =====
            PreparedStatement psLeave = conn.prepareStatement(
                    "SELECT lt.name, lp.max_days " +
                    "FROM leave_type lt " +
                    "JOIN leave_policy lp ON lt.type_id = lp.type_id " +
                    "WHERE lp.status='ACTIVE'"
            );
            ResultSet leaveInfo = psLeave.executeQuery();

            request.setAttribute("leaveInfo", leaveInfo);

            request.getRequestDispatcher("staff/profile.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
