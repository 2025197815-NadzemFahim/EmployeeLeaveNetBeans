package com.leave.admin;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "EmployeeInformationServlet", urlPatterns = {"/EmployeeInformationServlet"})
public class EmployeeInformationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder();
        json.append("[");

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB",
                "app",
                "app"
            );

            Statement stmt = conn.createStatement();

            String sql =
                "SELECT e.employee_id, e.name, e.position, e.department, " +
                "CASE " +
                " WHEN EXISTS ( " +
                "   SELECT 1 FROM leave_request lr " +
                "   WHERE lr.submitted_by = e.employee_id " +
                "     AND lr.status = 'APPROVED' " +
                "     AND CURRENT_DATE BETWEEN lr.start_date AND lr.end_date " +
                " ) THEN 'On Leave' " +
                " ELSE 'Available' " +
                "END AS status " +
                "FROM employee e " +
                "ORDER BY e.employee_id";

            ResultSet rs = stmt.executeQuery(sql);

            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

                json.append("{")
                    .append("\"id\":").append(rs.getInt("employee_id")).append(",")
                    .append("\"name\":\"").append(rs.getString("name").replace("\"", "\\\"")).append("\",")
                    .append("\"position\":\"").append(rs.getString("position")).append("\",")
                    .append("\"department\":\"").append(rs.getString("department")).append("\",")
                    .append("\"status\":\"").append(rs.getString("status")).append("\"")
                    .append("}");
            }

            rs.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("]");
        out.print(json.toString());
        out.flush();
    }
}
