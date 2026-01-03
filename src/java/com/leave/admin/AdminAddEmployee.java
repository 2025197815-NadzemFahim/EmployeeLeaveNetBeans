package com.leave.admin;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Date;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminAddEmployee", urlPatterns = {"/AdminAddEmployee"})
public class AdminAddEmployee extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String dob = request.getParameter("DoB");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String department = request.getParameter("department");
        String position = request.getParameter("position");
        String admissionDate = request.getParameter("admissionDate");
        String address = request.getParameter("address");

        // 2️⃣ Convert String → SQL Date
        Date sqlDob = (dob != null && !dob.isEmpty()) ? Date.valueOf(dob) : null;
        Date sqlAdmissionDate = (admissionDate != null && !admissionDate.isEmpty())
                ? Date.valueOf(admissionDate)
                : null;

        // 3️⃣ SQL INSERT
        String sql = "INSERT INTO employee "
                   + "(name, email, password, department, role, date_of_birth, address, admission_date, position) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        // 4️⃣ JDBC
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");

            try (Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/LeaveDB","nadzem","oracle");
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password); // later you can hash it
                ps.setString(4, department);
                ps.setString(5, role);
                ps.setDate(6, sqlDob);
                ps.setString(7, address);
                ps.setDate(8, sqlAdmissionDate);
                ps.setString(9, position);

                ps.executeUpdate();
            }

            // 5️⃣ Redirect after success
            // SUCCESS
            response.sendRedirect(request.getContextPath() + "/admin/addEmployeeInformation.jsp?status=success");


        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            // ERROR
            response.sendRedirect(request.getContextPath() + "/admin/addEmployeeInformation.jsp?status=error");

        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin Add Employee Servlet";
    }
}