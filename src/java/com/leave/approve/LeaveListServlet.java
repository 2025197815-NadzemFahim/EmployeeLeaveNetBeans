package com.leave.approve;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet("/LeaveListServlet")
public class LeaveListServlet extends HttpServlet {
    
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
        int userId = (Integer) session.getAttribute("employeeId");
        String name = (String) session.getAttribute("name");
        
        // Only CEO, HOD, and HOD HR can access this
        if (!"CEO".equals(role) && !"HOD".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
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
            
            // Build query based on role - SIMPLIFIED
            String sql;
            if ("CEO".equals(role)) {
                // CEO can see HOD requests - simplified
                sql = "SELECT lr.request_id, lr.start_date, lr.end_date, " +
                      "lr.status, lt.name as leave_type " +
                      "FROM leave_request lr " +
                      "JOIN employee e ON lr.submitted_by = e.employee_id " +
                      "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                      "WHERE e.role = 'HOD' " +
                      "ORDER BY lr.start_date DESC";
                ps = conn.prepareStatement(sql);
            } else if ("HOD".equals(role)) {
                // Check if this HOD is HOD HR (handles admin requests)
                String checkHODTypeSql = "SELECT department FROM employee WHERE employee_id = ?";
                PreparedStatement checkPs = conn.prepareStatement(checkHODTypeSql);
                checkPs.setInt(1, userId);
                ResultSet checkRs = checkPs.executeQuery();
                
                String department = "";
                if (checkRs.next()) {
                    department = checkRs.getString("department");
                }
                checkRs.close();
                checkPs.close();
                
                if ("HR".equalsIgnoreCase(department)) {
                    // HOD HR sees ADMIN requests - simplified
                    sql = "SELECT lr.request_id, lr.start_date, lr.end_date, " +
                          "lr.status, lt.name as leave_type " +
                          "FROM leave_request lr " +
                          "JOIN employee e ON lr.submitted_by = e.employee_id " +
                          "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                          "WHERE e.role = 'ADMIN' " +
                          "ORDER BY lr.start_date DESC";
                } else {
                    // Regular HOD sees STAFF requests from their department - simplified
                    sql = "SELECT lr.request_id, lr.start_date, lr.end_date, " +
                          "lr.status, lt.name as leave_type " +
                          "FROM leave_request lr " +
                          "JOIN employee e ON lr.submitted_by = e.employee_id " +
                          "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                          "WHERE e.role = 'STAFF' " +
                          "AND e.department = ? " +
                          "ORDER BY lr.start_date DESC";
                }
                ps = conn.prepareStatement(sql);
                if (!"HR".equalsIgnoreCase(department)) {
                    ps.setString(1, department);
                }
            } else {
                response.sendRedirect("login.jsp");
                return;
            }
            
            rs = ps.executeQuery();
            
            // Create a list of maps to store the data - FIXED: Java 1.5 compatible generics
            List<Map<String, String>> leaveRequests = new ArrayList<Map<String, String>>();
            
            while (rs.next()) {
                Map<String, String> leave = new HashMap<String, String>();
                leave.put("requestId", String.valueOf(rs.getInt("request_id")));
                leave.put("leaveType", rs.getString("leave_type"));
                leave.put("startDate", rs.getDate("start_date").toString());
                leave.put("endDate", rs.getDate("end_date").toString());
                leave.put("status", rs.getString("status"));
                leaveRequests.add(leave);
            }
            
            
            // ================= USER PROFILE =================
PreparedStatement psProfile = conn.prepareStatement(
    "SELECT name, position, profile_image FROM employee WHERE employee_id = ?"
);
psProfile.setInt(1, userId);

ResultSet rsProfile = psProfile.executeQuery();

String position = null;
String profileImage = null;

if (rsProfile.next()) {
    position = rsProfile.getString("position");
    profileImage = rsProfile.getString("profile_image");
}

// cleanup
rsProfile.close();
psProfile.close();

            request.setAttribute("leaveRequests", leaveRequests);
request.setAttribute("name", name);
request.setAttribute("position", position);
request.setAttribute("profileImage", profileImage);

            
            // Forward to unified JSP
            RequestDispatcher dispatcher = request.getRequestDispatcher("approve_leave_list.jsp");
            dispatcher.forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}