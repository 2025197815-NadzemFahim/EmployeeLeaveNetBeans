package com.leave.staff;

import com.leave.model.GenerateRecord;
import java.sql.*;
import java.util.*;

public class Database {

    private String jdbcURL = "jdbc:derby://localhost:1527/LeaveDB";
    private String jdbcUsername = "app";
    private String jdbcPassword = "app";

    private static final String SELECT_ALL =
        "SELECT lr.request_id, lt.name AS leave_type, lr.status, lr.start_date, lr.end_date, e.leave_balance " +
        "FROM leave_request lr " +
        "JOIN leave_type lt ON lr.type_id = lt.type_id " +
        "JOIN employee e ON lr.submitted_by = e.employee_id";

    public List<GenerateRecord> getAllRecords() {
        List<GenerateRecord> records = new ArrayList<>();
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver"); // Load Derby driver
            try (Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
                 PreparedStatement ps = conn.prepareStatement(SELECT_ALL);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    GenerateRecord record = new GenerateRecord();
                    record.setRequestId(rs.getInt("request_id"));
                    record.setLeaveType(rs.getString("leave_type"));
                    record.setStatus(rs.getString("status"));
                    record.setStartDate(rs.getDate("start_date"));
                    record.setEndDate(rs.getDate("end_date"));
                    record.setBalance(rs.getInt("leave_balance"));
                    records.add(record);
                    // Debug
                    System.out.println("Fetched: " + record.getRequestId() + " | " + record.getLeaveType());
                }
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            System.out.println("Derby Driver not found!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return records;
    }
}
