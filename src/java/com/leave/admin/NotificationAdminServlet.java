/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.leave.admin;

/**
 *
 * @author suweg
 */
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/NotificationAdminServlet")
public class NotificationAdminServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employeeId = (Integer) session.getAttribute("employeeId");

        List<Map<String, Object>> notifications = new ArrayList<>();

        int approvedCount = 0;
        int rejectedCount = 0;
        int unreadCount = 0;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            String sql = "SELECT * FROM notification "
                       + "WHERE receiver_id = ? "
                       + "ORDER BY timestamp DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, employeeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> noti = new HashMap<>();

                String message = rs.getString("message");
                boolean isRead = rs.getBoolean("is_read");

                noti.put("id", rs.getInt("notification_id"));
                noti.put("message", message);
                noti.put("time", rs.getTimestamp("timestamp"));
                noti.put("isRead", isRead);

                // Status detection from message
                if (message.toUpperCase().contains("APPROVED")) {
                    noti.put("status", "approved");
                    approvedCount++;
                } else if (message.toUpperCase().contains("REJECTED")) {
                    noti.put("status", "rejected");
                    rejectedCount++;
                } else {
                    noti.put("status", "info");
                }

                if (!isRead) {
                    unreadCount++;
                }

                notifications.add(noti);
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.setAttribute("notifications", notifications);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("unreadCount", unreadCount);

        RequestDispatcher rd = request.getRequestDispatcher("admin/notification.jsp");
        rd.forward(request, response);
    }
}

