package com.leave.approve;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.time.LocalDate;

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
        
        // Only CEO and HOD can access this
        if (!"CEO".equals(role) && !"HOD".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Check if this is a file download/view request
        String download = request.getParameter("download");
        String view = request.getParameter("view");
        if ("true".equals(download) || "true".equals(view)) {
            serveFile(request, response, "true".equals(download));
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
        
        // Check for error messages from doPost
        String error = (String) session.getAttribute("error");
        if (error != null) {
            request.setAttribute("error", error);
            session.removeAttribute("error");
        }
        
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
            
            // Query to get leave details with employee information
            String sql = "SELECT lr.*, e.name as employee_name, e.employee_id, " +
                         "e.position, e.department, e.role as employee_role, " +
                         "lt.name as leave_type, lt.type_id " +
                         "FROM leave_request lr " +
                         "JOIN employee e ON lr.submitted_by = e.employee_id " +
                         "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                         "WHERE lr.request_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Create a map to store leave details
                Map<String, String> leave = new HashMap<String, String>();
                leave.put("requestId", String.valueOf(rs.getInt("request_id")));
                leave.put("employeeName", rs.getString("employee_name"));
                leave.put("employeeId", String.valueOf(rs.getInt("employee_id")));
                leave.put("position", rs.getString("position"));
                leave.put("department", rs.getString("department"));
                leave.put("employeeRole", rs.getString("employee_role"));
                leave.put("leaveType", rs.getString("leave_type"));
                leave.put("typeId", String.valueOf(rs.getInt("type_id")));
                leave.put("startDate", rs.getDate("start_date").toString());
                leave.put("endDate", rs.getDate("end_date").toString());
                leave.put("status", rs.getString("status"));
                leave.put("attachment", rs.getString("attachment"));
                leave.put("reason", rs.getString("reason"));
                leave.put("reasonRejection", rs.getString("reason_rejection"));
                
                // Get current leave balance if approved
                if ("APPROVED".equals(rs.getString("status"))) {
                    int submittedBy = rs.getInt("submitted_by"); // Use submitted_by from leave_request
                    int typeId = rs.getInt("type_id");
                    int currentBalance = getCurrentLeaveBalance(conn, submittedBy, typeId);
                    leave.put("currentBalance", String.valueOf(currentBalance));
                }
                
                // Store leave details in request
                request.setAttribute("leave", leave);
                request.setAttribute("role", role);
                request.setAttribute("userName", name);
                
                // Forward to JSP
                RequestDispatcher dispatcher = request.getRequestDispatcher("approve_leave_details.jsp");
                dispatcher.forward(request, response);
            } else {
                // Leave not found
                session.setAttribute("error", "Leave request not found");
                response.sendRedirect("LeaveListServlet");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect("LeaveListServlet");
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid leave request ID");
            response.sendRedirect("LeaveListServlet");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    // Helper method to get current leave balance
    private int getCurrentLeaveBalance(Connection conn, int employeeId, int typeId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int balance = 0;
        
        try {
            String sql = "SELECT balance FROM employee_leave_balance " +
                        "WHERE employee_id = ? AND type_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, employeeId);
            ps.setInt(2, typeId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                balance = rs.getInt("balance");
            }
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
        }
        
        return balance;
    }
    
    // Method to serve file for download or viewing
    private void serveFile(HttpServletRequest request, HttpServletResponse response, boolean download) 
            throws ServletException, IOException {
        
        String requestIdStr = request.getParameter("id");
        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect("LeaveListServlet");
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        FileInputStream fis = null;
        OutputStream os = null;
        
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
                String attachmentPath = rs.getString("attachment");
                if (attachmentPath != null && !attachmentPath.isEmpty()) {
                    // Extract filename from path
                    String fileName;
                    if (attachmentPath.contains("/")) {
                        fileName = attachmentPath.substring(attachmentPath.lastIndexOf("/") + 1);
                    } else if (attachmentPath.contains("\\")) {
                        fileName = attachmentPath.substring(attachmentPath.lastIndexOf("\\") + 1);
                    } else {
                        fileName = attachmentPath;
                    }
                    
                    // Get file from uploads folder
                    String uploadPath = "C:/leave_uploads/attachments";
                    File file = new File(uploadPath + File.separator + fileName);
                    
                    if (file.exists()) {
                        // Set appropriate content type
                        String contentType = getServletContext().getMimeType(fileName);
                        if (contentType == null) {
                            contentType = "application/octet-stream";
                        }
                        
                        if (download) {
                            // For download
                            response.setContentType("application/octet-stream");
                            response.setHeader("Content-Disposition", 
                                "attachment; filename=\"" + fileName + "\"");
                        } else {
                            // For viewing
                            response.setContentType(contentType);
                            response.setHeader("Content-Disposition", 
                                "inline; filename=\"" + fileName + "\"");
                        }
                        
                        response.setContentLength((int) file.length());
                        
                        fis = new FileInputStream(file);
                        os = response.getOutputStream();
                        
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = fis.read(buffer)) != -1) {
                            os.write(buffer, 0, bytesRead);
                        }
                        
                        fis.close();
                        os.flush();
                        os.close();
                    } else {
                        if (download) {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                        } else {
                            response.sendRedirect("LeaveDetailsServlet?id=" + requestIdStr + "&error=nofile");
                        }
                    }
                } else {
                    response.sendRedirect("LeaveDetailsServlet?id=" + requestIdStr + "&error=nofile");
                }
            } else {
                response.sendRedirect("LeaveDetailsServlet?id=" + requestIdStr + "&error=nofile");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        } catch (FileNotFoundException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error");
        } finally {
            try { if (fis != null) fis.close(); } catch (IOException e) {}
            try { if (os != null) os.close(); } catch (IOException e) {}
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
            
            conn.setAutoCommit(false); // Start transaction
            
            // First, get leave details to calculate days and employee info
            String getLeaveSql = "SELECT submitted_by, type_id, start_date, end_date, status " +
                               "FROM leave_request WHERE request_id = ?";
            PreparedStatement getLeavePs = conn.prepareStatement(getLeaveSql);
            getLeavePs.setInt(1, requestId);
            ResultSet rs = getLeavePs.executeQuery();
            
            int submittedBy = 0;
            int typeId = 0;
            LocalDate startDate = null;
            LocalDate endDate = null;
            String currentStatus = null;
            
            if (rs.next()) {
                submittedBy = rs.getInt("submitted_by");
                typeId = rs.getInt("type_id");
                startDate = rs.getDate("start_date").toLocalDate();
                endDate = rs.getDate("end_date").toLocalDate();
                currentStatus = rs.getString("status");
            }
            rs.close();
            getLeavePs.close();
            
            // Check if already approved/rejected
            if (!"PENDING".equals(currentStatus)) {
                session.setAttribute("error", "This leave request has already been processed");
                response.sendRedirect("LeaveDetailsServlet?id=" + requestId);
                return;
            }
            
            // Calculate leave days
            long leaveDays = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
            
            // Check current balance before approving
            int currentBalance = getCurrentLeaveBalance(conn, submittedBy, typeId);
            
            // Check if balance is sufficient for approval
            if ("APPROVED".equals(status) && currentBalance < leaveDays) {
                // Instead of redirecting to list, set error and redirect back to details page
                session.setAttribute("error", "Cannot approve leave. Employee only has " + 
                                    currentBalance + " days remaining, but requested " + leaveDays + " days.");
                response.sendRedirect("LeaveDetailsServlet?id=" + requestId);
                return;
            }
            
            // Update leave status
            String updateLeaveSql = "UPDATE leave_request SET status = ?, approved_by = ?, " +
                         "reason_rejection = ? WHERE request_id = ?";
            
            ps = conn.prepareStatement(updateLeaveSql);
            ps.setString(1, status);
            ps.setInt(2, approverId);
            
            if ("REJECTED".equals(status)) {
                ps.setString(3, reason != null ? reason : "No reason provided");
            } else {
                ps.setString(3, null); // No rejection reason for approval
            }
            
            ps.setInt(4, requestId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0 && "APPROVED".equals(status)) {
                // Deduct from leave balance
                String updateBalanceSql = "UPDATE employee_leave_balance " +
                                        "SET balance = balance - ? " +
                                        "WHERE employee_id = ? AND type_id = ?";
                
                PreparedStatement balancePs = conn.prepareStatement(updateBalanceSql);
                balancePs.setLong(1, leaveDays);
                balancePs.setInt(2, submittedBy);
                balancePs.setInt(3, typeId);
                
                int balanceUpdated = balancePs.executeUpdate();
                
                if (balanceUpdated == 0) {
                    // If no existing balance record, create one
                    String insertBalanceSql = "INSERT INTO employee_leave_balance (employee_id, type_id, balance) " +
                                            "VALUES (?, ?, ?)";
                    PreparedStatement insertPs = conn.prepareStatement(insertBalanceSql);
                    insertPs.setInt(1, submittedBy);
                    insertPs.setInt(2, typeId);
                    
                    // Try to get default leave allocation from leave_type table
                    String getDefaultBalanceSql = "SELECT default_days FROM leave_type WHERE type_id = ?";
                    PreparedStatement defaultPs = conn.prepareStatement(getDefaultBalanceSql);
                    defaultPs.setInt(1, typeId);
                    ResultSet defaultRs = defaultPs.executeQuery();
                    
                    int defaultBalance = 0;
                    if (defaultRs.next()) {
                        defaultBalance = defaultRs.getInt("default_days");
                    }
                    defaultRs.close();
                    defaultPs.close();
                    
                    // Calculate remaining balance
                    int remainingBalance = Math.max(0, defaultBalance - (int)leaveDays);
                    insertPs.setInt(3, remainingBalance);
                    insertPs.executeUpdate();
                    insertPs.close();
                }
                
                balancePs.close();
            }
            
            conn.commit(); // Commit transaction
            
            if (rowsUpdated > 0) {
                // Success - redirect back to list
                String message = "Leave request #" + requestId + " has been " + status.toLowerCase();
                if ("APPROVED".equals(status)) {
                    // Calculate the new balance to show in message
                    int newBalance = getCurrentLeaveBalance(conn, submittedBy, typeId);
                    message += ". " + leaveDays + " days deducted. Remaining balance: " + newBalance + " days.";
                }
                session.setAttribute("message", message);
                
                // Create notification for the employee
                createNotification(conn, requestId, status, approverId, submittedBy);
                
                // Redirect to list page with success message
                response.sendRedirect("LeaveListServlet");
            } else {
                session.setAttribute("error", "Failed to update leave request");
                response.sendRedirect("LeaveDetailsServlet?id=" + requestId);
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect("LeaveDetailsServlet?id=" + requestId);
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void createNotification(Connection conn, int requestId, String status, int approverId, int requesterId) 
            throws SQLException {
        
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
}