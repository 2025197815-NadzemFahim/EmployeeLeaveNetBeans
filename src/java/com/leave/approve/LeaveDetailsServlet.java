package com.leave.approve;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet("/LeaveDetailsServlet")
public class LeaveDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if user is logged in
        if (session.getAttribute("employeeId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        
        // Only CEO, HOD, and HOD HR can access this
        if (!"CEO".equals(role) && !"HOD".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Check if this is a file download request
        String download = request.getParameter("download");
        if ("true".equals(download)) {
            downloadFile(request, response);
            return;
        }
        
        // Get leave ID from request
        String requestIdStr = request.getParameter("id");
        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect("LeaveListServlet");
            return;
        }
        
        int requestId = Integer.parseInt(requestIdStr);
        String name = (String) session.getAttribute("name");
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Connect to database
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB",
                "app",
                "app"
            );
            
            // Updated query to include ALL employee details for the details page
            String sql = "SELECT lr.*, e.name as employee_name, e.employee_id, " +
                         "e.position, e.department, e.role as employee_role, " +
                         "lt.name as leave_type " +
                         "FROM leave_request lr " +
                         "JOIN employee e ON lr.submitted_by = e.employee_id " +
                         "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                         "WHERE lr.request_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Create a map to store leave details - FIXED: Java 1.5 compatible
                Map<String, String> leave = new HashMap<String, String>();
                leave.put("requestId", String.valueOf(rs.getInt("request_id")));
                leave.put("employeeName", rs.getString("employee_name"));
                leave.put("employeeId", String.valueOf(rs.getInt("employee_id")));
                leave.put("position", rs.getString("position"));
                leave.put("department", rs.getString("department"));
                leave.put("employeeRole", rs.getString("employee_role"));
                leave.put("leaveType", rs.getString("leave_type"));
                leave.put("startDate", rs.getDate("start_date").toString());
                leave.put("endDate", rs.getDate("end_date").toString());
                leave.put("status", rs.getString("status"));
                leave.put("attachment", rs.getString("attachment"));
                leave.put("reason", rs.getString("reason"));
                leave.put("reasonRejection", rs.getString("reason_rejection"));
                
                // Store leave details in request
                request.setAttribute("leave", leave);
                request.setAttribute("role", role);
                request.setAttribute("userName", name);
                
                // Forward to unified JSP
                RequestDispatcher dispatcher = request.getRequestDispatcher("approve_leave_details.jsp");
                dispatcher.forward(request, response);
            } else {
                // Leave not found
                request.setAttribute("error", "Leave request not found");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid leave request ID");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    // Method to handle file download
    private void downloadFile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String requestIdStr = request.getParameter("id");
        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect("LeaveListServlet");
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB",
                "app",
                "app"
            );
            
            String sql = "SELECT attachment FROM leave_request WHERE request_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(requestIdStr));
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String fileName = rs.getString("attachment");
                if (fileName != null && !fileName.isEmpty()) {
                    // Set response headers for file download
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition", 
                        "attachment; filename=\"" + fileName + "\"");
                    
                    // Read file from uploads folder
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File file = new File(uploadPath + File.separator + fileName);
                    
                    if (file.exists()) {
                        FileInputStream fis = new FileInputStream(file);
                        OutputStream os = response.getOutputStream();
                        
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = fis.read(buffer)) != -1) {
                            os.write(buffer, 0, bytesRead);
                        }
                        
                        fis.close();
                        os.flush();
                        os.close();
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                    }
                } else {
                    response.sendRedirect("LeaveDetailsServlet?id=" + requestIdStr + "&error=nofile");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if user is logged in
        if (session.getAttribute("employeeId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        int approverId = (Integer) session.getAttribute("employeeId");
        
        // Get parameters
        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");
        String reason = request.getParameter("reason");
        
        if (!"CEO".equals(role) && !"HOD".equals(role) || 
            action == null || requestIdStr == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int requestId = Integer.parseInt(requestIdStr);
        String status = "approve".equals(action) ? "APPROVED" : "REJECTED";
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            // Connect to database
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB",
                "app",
                "app"
            );
            
            // Update leave status
            String sql = "UPDATE leave_request SET status = ?, approved_by = ?, " +
                         "reason_rejection = ? WHERE request_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, approverId);
            ps.setString(3, reason);
            ps.setInt(4, requestId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
                // Success - redirect back to list
                session.setAttribute("message", "Leave request has been " + status.toLowerCase());
                
                // Optional: Create notification
                createNotification(conn, requestId, status, approverId);
            } else {
                session.setAttribute("error", "Failed to update leave request");
            }
            
            response.sendRedirect("LeaveListServlet");
            
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect("LeaveListServlet");
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void createNotification(Connection conn, int requestId, String status, int approverId) 
            throws SQLException {
        
        // Get the requester's ID
        String getRequesterSql = "SELECT submitted_by FROM leave_request WHERE request_id = ?";
        PreparedStatement ps1 = conn.prepareStatement(getRequesterSql);
        ps1.setInt(1, requestId);
        ResultSet rs = ps1.executeQuery();
        
        if (rs.next()) {
            int requesterId = rs.getInt("submitted_by");
            
            // Get approver name
            String getApproverSql = "SELECT name FROM employee WHERE employee_id = ?";
            PreparedStatement ps2 = conn.prepareStatement(getApproverSql);
            ps2.setInt(1, approverId);
            ResultSet rs2 = ps2.executeQuery();
            
            String approverName = "Approver";
            if (rs2.next()) {
                approverName = rs2.getString("name");
            }
            
            // Create notification message
            String message = "Your leave request #" + requestId + " has been " + 
                           status.toLowerCase() + " by " + approverName;
            
            // Insert notification
            String insertNotifSql = "INSERT INTO notification (receiver_id, message, timestamp) " +
                                   "VALUES (?, ?, CURRENT_TIMESTAMP)";
            PreparedStatement ps3 = conn.prepareStatement(insertNotifSql);
            ps3.setInt(1, requesterId);
            ps3.setString(2, message);
            ps3.executeUpdate();
            
            rs2.close();
            ps2.close();
            ps3.close();
        }
        
        rs.close();
        ps1.close();
    }
}