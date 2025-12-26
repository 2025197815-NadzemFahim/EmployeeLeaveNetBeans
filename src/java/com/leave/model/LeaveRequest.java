/* * To change this license header, choose License Headers in Project Properties. 
* To change this template file, choose Tools | Templates 
* and open the template in the editor. 
*/ 
package com.leave.model; 
/** 
 * 
 * 
 * @author suweg */
import java.sql.Date;

public class LeaveRequest {

    private int requestId;
    private Date startDate;
    private Date endDate;
    private String reason;
    private String status;
    private int submittedBy;
    private Integer approvedBy;
    private int typeId;
    private String attachment;
    private String reasonRejection;
    private String leaveType;   
    private String staffName;   

    public LeaveRequest() {}


    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getSubmittedBy() { return submittedBy; }
    public void setSubmittedBy(int submittedBy) { this.submittedBy = submittedBy; }

    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }

    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }

    public String getAttachment() { return attachment; }
    public void setAttachment(String attachment) { this.attachment = attachment; }

    public String getReasonRejection() { return reasonRejection; }
    public void setReasonRejection(String reasonRejection) {
        this.reasonRejection = reasonRejection;
    }

    public String getLeaveType() { return leaveType; }
    public void setLeaveType(String leaveType) { this.leaveType = leaveType; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }
}
