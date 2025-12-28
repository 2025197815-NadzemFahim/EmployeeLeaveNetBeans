/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.leave.admin;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author nurna
 */
@WebServlet("/DeleteLeaveServlet")
public class DeleteLeaveServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM leave_request WHERE request_id=?");
            ps.setInt(1, requestId);
            ps.executeUpdate();
            response.getWriter().println("Leave request deleted successfully.");

        } catch (SQLException e) {
            response.getWriter().println("Error deleting leave request.");
        }
    }
}
