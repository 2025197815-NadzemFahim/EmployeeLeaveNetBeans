package com.leave.model;

/**
 * View model for Leave Type + Leave Policy (joined).
 * Keeps the UI simple: one row per leave type.
 */
public class LeavePolicyView {

    private int typeId;
    private String typeName;
    private String description;
    private Integer policyId;   // can be null if no policy yet
    private Integer maxDays;    // can be null if no policy yet
    private String status;      // can be null

    public LeavePolicyView() {}

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getPolicyId() {
        return policyId;
    }

    public void setPolicyId(Integer policyId) {
        this.policyId = policyId;
    }

    public Integer getMaxDays() {
        return maxDays;
    }

    public void setMaxDays(Integer maxDays) {
        this.maxDays = maxDays;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
