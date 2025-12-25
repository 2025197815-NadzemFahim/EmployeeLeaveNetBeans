package com.leave.ceo;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ApproveLeaveCEOServlet")
public class ApproveLeaveCEOServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"CEO".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        String requestId = request.getParameter("requestId");
        String status = request.getParameter("status");
        String rejectReason = request.getParameter("rejectReason");
        
        if (requestId == null || status == null) {
            response.sendRedirect("ceo/approve_leave_ceo.jsp?error=invalid");
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app");
            
            if ("APPROVED".equals(status)) {
                String updateQuery = "UPDATE leave_request SET " +
                                    "status = 'APPROVED', " +
                                    "ceo_approved_date = CURRENT_TIMESTAMP, " +
                                    "reject_reason = NULL " +
                                    "WHERE request_id = ? AND status = 'PENDING_CEO'";
                
                ps = conn.prepareStatement(updateQuery);
                ps.setString(1, requestId);
                
                int rowsUpdated = ps.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // Update leave balance
                    updateLeaveBalance(conn, requestId);
                    // Send notification
                    sendNotification(conn, requestId, "APPROVED");
                    response.sendRedirect("ceo/approve_leave_ceo.jsp?success=1");
                } else {
                    response.sendRedirect("ceo/approve_leave_ceo.jsp?error=update");
                }
                
            } else if ("REJECTED".equals(status)) {
                String updateQuery = "UPDATE leave_request SET " +
                                    "status = 'REJECTED', " +
                                    "ceo_approved_date = CURRENT_TIMESTAMP, " +
                                    "reject_reason = ? " +
                                    "WHERE request_id = ? AND status = 'PENDING_CEO'";
                
                ps = conn.prepareStatement(updateQuery);
                ps.setString(1, rejectReason);
                ps.setString(2, requestId);
                
                int rowsUpdated = ps.executeUpdate();
                
                if (rowsUpdated > 0) {
                    sendNotification(conn, requestId, "REJECTED");
                    response.sendRedirect("ceo/approve_leave_ceo.jsp?success=1");
                } else {
                    response.sendRedirect("ceo/approve_leave_ceo.jsp?error=update");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ceo/approve_leave_ceo.jsp?error=db");
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void updateLeaveBalance(Connection conn, String requestId) throws SQLException {
        // Same as HOD servlet
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
                long diff = endDate.getTime() - startDate.getTime();
                int daysUsed = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
                
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
        // Notify both staff and HOD
        String query = "INSERT INTO notifications (employee_id, message, created_at, is_read) " +
                      "SELECT submitted_by, " +
                      "'Your leave request ' || request_id || ' has been " + status.toLowerCase() + " by CEO.', " +
                      "CURRENT_TIMESTAMP, false " +
                      "FROM leave_request WHERE request_id = ? " +
                      "UNION ALL " +
                      "SELECT approved_by, " +
                      "'Leave request ' || request_id || ' you approved has been " + status.toLowerCase() + " by CEO.', " +
                      "CURRENT_TIMESTAMP, false " +
                      "FROM leave_request WHERE request_id = ?";
        
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1, requestId);
        ps.setString(2, requestId);
        ps.executeUpdate();
        ps.close();
    }
}