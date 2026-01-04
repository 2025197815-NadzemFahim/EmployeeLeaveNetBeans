package com.leave.admin;

import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/updateEmployeeServlet")
public class UpdateEmployeeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int empId = Integer.parseInt(req.getParameter("employeeId"));

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB","app","app")) {

            conn.setAutoCommit(false);

            /* ===== UPDATE EMPLOYEE ===== */
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE employee SET name=?, email=?, department=?, position=?, role=?, " +
                "date_of_birth=?, admission_date=?, address=? WHERE employee_id=?"
            );


            ps.setString(1, req.getParameter("name"));
            ps.setString(2, req.getParameter("email"));
            ps.setString(3, req.getParameter("department"));
            ps.setString(4, req.getParameter("position"));
            ps.setString(5, req.getParameter("role"));   // role

            String dob = req.getParameter("dob");
            String admission = req.getParameter("admissionDate");

            ps.setDate(6, (dob == null || dob.isEmpty()) ? null : Date.valueOf(dob));
            ps.setDate(7, (admission == null || admission.isEmpty()) ? null : Date.valueOf(admission));

            ps.setString(8, req.getParameter("address"));
            ps.setInt(9, empId);

            ps.executeUpdate();
            ps.close();

            /* ===== UPDATE LEAVES (DYNAMIC) ===== */
            Enumeration<String> params = req.getParameterNames();

            while (params.hasMoreElements()) {
                String param = params.nextElement();

                if (param.startsWith("leave_")) {
                    int typeId = Integer.parseInt(param.substring(6));
                    String value = req.getParameter(param);

                    if (value == null || value.isEmpty()) {
                        value = "0";
                    }

                    PreparedStatement psLeave = conn.prepareStatement(
                        "UPDATE employee_leave_balance SET balance=? " +
                        "WHERE employee_id=? AND type_id=?"
                    );
                    psLeave.setInt(1, Integer.parseInt(value));
                    psLeave.setInt(2, empId);
                    psLeave.setInt(3, typeId);
                    psLeave.executeUpdate();
                    psLeave.close();
                }
            }

            conn.commit();

            res.sendRedirect(
                req.getContextPath() + "/admin/employeeUpdatePage.jsp?id=" + empId
            );


        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}