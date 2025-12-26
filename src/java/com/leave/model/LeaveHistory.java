package com.leave.model;

import java.util.Date;

public class LeaveHistory {
    private int requestId;
    private String leaveType;
    private String status;
    private Date startDate;
    private Date endDate;
    private int leaveBalance;

    public LeaveHistory(int requestId, String leaveType, String status, Date startDate, Date endDate, int leaveBalance) {
        this.requestId = requestId;
        this.leaveType = leaveType;
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
        this.leaveBalance = leaveBalance;
        
        
    }

    public LeaveHistory() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public LeaveHistory(int aInt, String string, String string0, String string1, java.sql.Date date, java.sql.Date date0, int i) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public String getLeaveType() {
        return leaveType;
    }

    public void setLeaveType(String leaveType) {
        this.leaveType = leaveType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public int getLeaveBalance() {
        return leaveBalance;
    }

    public void setLeaveBalance(int leaveBalance) {
        this.leaveBalance = leaveBalance;
    }

    public void setEmployeeName(String string) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}
    
