package com.leave.hod;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ApproveLeaveHODServlet")
public class ApproveLeaveHODServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"HOD".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        String requestId = request.getParameter("requestId");
        String status = request.getParameter("status");
        String rejectReason = request.getParameter("rejectReason");
        int hodId = (int) session.getAttribute("employeeId");
        
        if (requestId == null || status == null) {
            response.sendRedirect("hod/approve_leave_hod.jsp?error=invalid");
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement psCheck = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app");
            
            // Check if HOD is authorized to approve this request
            String checkQuery = "SELECT lr.request_id, e.department " +
                               "FROM leave_request lr " +
                               "JOIN employee e ON lr.submitted_by = e.employee_id " +
                               "WHERE lr.request_id = ? AND lr.approved_by = ? AND lr.status = 'PENDING'";
            
            psCheck = conn.prepareStatement(checkQuery);
            psCheck.setString(1, requestId);
            psCheck.setInt(2, hodId);
            rs = psCheck.executeQuery();
            
            if (!rs.next()) {
                response.sendRedirect("hod/approve_leave_hod.jsp?error=unauthorized");
                return;
            }
            
            String department = rs.getString("department");
            
            if ("APPROVED".equals(status)) {
                // Check if department requires CEO approval
                boolean needsCEOApproval = department.equals("Management") || 
                                          department.equals("Executive");
                
                if (needsCEOApproval) {
                    // Get CEO ID
                    String ceoQuery = "SELECT employee_id FROM employee WHERE role = 'CEO' LIMIT 1";
                    PreparedStatement psCEO = conn.prepareStatement(ceoQuery);
                    ResultSet rsCEO = psCEO.executeQuery();
                    int ceoId = 0;
                    if (rsCEO.next()) {
                        ceoId = rsCEO.getInt("employee_id");
                    }
                    rsCEO.close();
                    psCEO.close();
                    
                    // Update for CEO approval
                    String updateQuery = "UPDATE leave_request SET " +
                                        "status = 'PENDING_CEO', " +
                                        "hod_approved_date = CURRENT_TIMESTAMP, " +
                                        "approved_by = ? " +
                                        "WHERE request_id = ?";
                    
                    ps = conn.prepareStatement(updateQuery);
                    ps.setInt(1, ceoId);
                    ps.setString(2, requestId);
                } else {
                    // Direct approval - update employee leave balance
                    String updateQuery = "UPDATE leave_request SET " +
                                        "status = 'APPROVED', " +
                                        "hod_approved_date = CURRENT_TIMESTAMP " +
                                        "WHERE request_id = ?";
                    
                    ps = conn.prepareStatement(updateQuery);
                    ps.setString(1, requestId);
                    
                    // Calculate and update leave balance
                    updateLeaveBalance(conn, requestId);
                }
            } else if ("REJECTED".equals(status)) {
                String updateQuery = "UPDATE leave_request SET " +
                                    "status = 'REJECTED', " +
                                    "reject_reason = ?, " +
                                    "hod_approved_date = CURRENT_TIMESTAMP " +
                                    "WHERE request_id = ?";
                
                ps = conn.prepareStatement(updateQuery);
                ps.setString(1, rejectReason);
                ps.setString(2, requestId);
            }
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
                // Send notification to staff
                sendNotification(conn, requestId, status);
                response.sendRedirect("hod/approve_leave_hod.jsp?success=1");
            } else {
                response.sendRedirect("hod/approve_leave_hod.jsp?error=update");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("hod/approve_leave_hod.jsp?error=db");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void updateLeaveBalance(Connection conn, String requestId) throws SQLException {
        // Get leave details
        String query = "SELECT lr.submitted_by, lr.start_date, lr.end_date, lt.deduct_from_balance " +
                      "FROM leave_request lr " +
                      "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                      "WHERE lr.request_id = ?";
        
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1, requestId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            int employeeId = rs.getInt("submitted_by");
            Date startDate = rs.getDate("start_date");
            Date endDate = rs.getDate("end_date");
            boolean deductFromBalance = rs.getBoolean("deduct_from_balance");
            
            if (deductFromBalance) {
                // Calculate days
                long diff = endDate.getTime() - startDate.getTime();
                int daysUsed = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
                
                // Update balance
                String updateBalance = "UPDATE employee SET leave_balance = leave_balance - ? " +
                                      "WHERE employee_id = ?";
                PreparedStatement psUpdate = conn.prepareStatement(updateBalance);
                psUpdate.setInt(1, daysUsed);
                psUpdate.setInt(2, employeeId);
                psUpdate.executeUpdate();
                psUpdate.close();
            }
        }
        
        rs.close();
        ps.close();
    }
    
    private void sendNotification(Connection conn, String requestId, String status) throws SQLException {
        String query = "INSERT INTO notifications (employee_id, message, created_at, is_read) " +
                      "SELECT submitted_by, " +
                      "'Your leave request ' || request_id || ' has been " + status.toLowerCase() + " by HOD.', " +
                      "CURRENT_TIMESTAMP, false " +
                      "FROM leave_request WHERE request_id = ?";
        
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1, requestId);
        ps.executeUpdate();
        ps.close();
    }
}