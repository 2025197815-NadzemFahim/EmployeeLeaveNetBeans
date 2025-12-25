/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.leave.staff;

/**
 *
 * @author suweg
 */
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.MultipartConfig;

@WebServlet("/ApplyLeaveServlet")
public class ApplyLeaveServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employeeId = (int) session.getAttribute("employeeId");

        String typeIdStr = request.getParameter("typeId");
        if (typeIdStr == null || typeIdStr.isEmpty()) {
            response.sendRedirect("apply_leave.jsp?error=type");
            return;
        }

        int typeId = Integer.parseInt(typeIdStr);

        Date startDate = Date.valueOf(request.getParameter("startDate"));
        Date endDate = Date.valueOf(request.getParameter("endDate"));
        String reason = request.getParameter("reason");

        long diff = endDate.getTime() - startDate.getTime();
        int daysRequested = (int) (diff / (1000 * 60 * 60 * 24)) + 1;

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app")) {

            PreparedStatement ps1 = conn.prepareStatement(
                "SELECT leave_balance FROM employee WHERE employee_id=?"
            );
            ps1.setInt(1, employeeId);
            ResultSet rs = ps1.executeQuery();

            int balance = 0;
            if (rs.next()) balance = rs.getInt("leave_balance");

            if (daysRequested > balance) {
                response.sendRedirect("apply_leave.jsp?error=balance");
                return;
            }

            PreparedStatement ps2 = conn.prepareStatement(
                "INSERT INTO leave_request (start_date, end_date, reason, status, submitted_by, type_id) "
              + "VALUES (?, ?, ?, 'PENDING', ?, ?)"
            );

            ps2.setDate(1, startDate);
            ps2.setDate(2, endDate);
            ps2.setString(3, reason);
            ps2.setInt(4, employeeId);
            ps2.setInt(5, typeId);

            ps2.executeUpdate();

            response.sendRedirect("LeaveHistoryServlet");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("apply_leave.jsp?error=db");
        }
    }
}

