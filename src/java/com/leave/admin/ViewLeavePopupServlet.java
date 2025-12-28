package com.leave.admin;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ViewLeavePopupServlet")
public class ViewLeavePopupServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int requestId = Integer.parseInt(request.getParameter("requestId"));
        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            String sql = "SELECT request_id, type_id, start_date, end_date, reason, attachment " +
                         "FROM leave_request WHERE request_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int typeId = rs.getInt("type_id");

                // Get leave type name
                String leaveType = "";
                try (PreparedStatement pst = conn.prepareStatement("SELECT name FROM leave_type WHERE type_id=?")) {
                    pst.setInt(1, typeId);
                    ResultSet rst = pst.executeQuery();
                    leaveType = rst.next() ? rst.getString("name") : "Unknown";
                }

                // Clean filename
                String dbPath = rs.getString("attachment");
                String fileName = "";
                if (dbPath != null && dbPath.contains("/")) {
                    fileName = dbPath.substring(dbPath.lastIndexOf("/") + 1);
                } else {
                    fileName = dbPath;
                }

                // Check file existence
                File file = new File("C:/leave_uploads/attachments/" + fileName);

                // Print popup content
                response.getWriter().println(
                    "<div class='popup-data'>" +
                    "<p><b>Request ID:</b> " + rs.getInt("request_id") + "</p>" +
                    "<p><b>Leave Type:</b> " + leaveType + "</p>" +
                    "<p><b>Start Date:</b> " + rs.getDate("start_date") + "</p>" +
                    "<p><b>End Date:</b> " + rs.getDate("end_date") + "</p>" +
                    "<p><b>Reason:</b> " + rs.getString("reason") + "</p>"
                );

                if (file.exists()) {
                    response.getWriter().println(
                        "<p><b>Attachment:</b> " +
                        "<a href='" + request.getContextPath() + "/DownloadAttachmentServlet?file=" + fileName + "' target='_blank'>Download File</a>" +
                        "</p>"
                    );
                } else {
                    response.getWriter().println(
                        "<p style='color:red'><b>No attachment found.</b></p>"
                    );
                }

                response.getWriter().println("</div>");

            } else {
                response.getWriter().println("<p>No record found.</p>");
            }

        } catch (SQLException e) {
            response.getWriter().println("<p style='color:red'>Database error occurred.</p>");
        }
    }
}
