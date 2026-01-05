package com.leave.staff;

import com.leave.model.GenerateRecord;
import java.sql.*;
import java.util.ArrayList;
import java.util.*;

public class Database {

    private static final String URL = "jdbc:derby://localhost:1527/leaveDB";
    private static final String USER = "app";
    private static final String PASS = "app";

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public List<GenerateRecord> getAllRecords() {

        List<GenerateRecord> list = new ArrayList<>();

        String sql =
            "SELECT lr.request_id, lt.name AS leave_type, lr.status, " +
            "       lr.start_date, lr.end_date, elb.balance " +
            "FROM leave_request lr " +
            "JOIN leave_type lt ON lr.type_id = lt.type_id " +
            "LEFT JOIN employee_leave_balance elb " +
            "     ON elb.employee_id = lr.submitted_by " +
            "    AND elb.type_id = lr.type_id " +
            "ORDER BY lr.request_id DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                GenerateRecord r = new GenerateRecord();
                r.setRequestId(rs.getInt("request_id"));
                r.setLeaveType(rs.getString("leave_type"));
                r.setStatus(rs.getString("status"));
                r.setStartDate(rs.getDate("start_date"));
                r.setEndDate(rs.getDate("end_date"));
                r.setBalance(rs.getInt("balance"));

                list.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<String> getLeaveTypes() {
    List<String> list = new ArrayList<>();
    String sql = "SELECT name FROM leave_type ORDER BY name";

    try (Connection con = getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            list.add(rs.getString("name"));
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}



}
