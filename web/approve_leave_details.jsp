<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    HttpSession userSession = request.getSession();
    if (userSession.getAttribute("employeeId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) userSession.getAttribute("role");
    if (!"CEO".equals(role) && !"HOD".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Map<String, String> leave = (Map<String, String>) request.getAttribute("leave");
    String userName = (String) request.getAttribute("userName");
    String name = (String) userSession.getAttribute("name");
    Integer employeeId = (Integer) userSession.getAttribute("employeeId");
    
    if (leave == null) {
        response.sendRedirect("LeaveListServlet");
        return;
    }
    
    // Set page title based on role
    String pageTitle = "CEO".equals(role) ? "CEO" : "HOD";
    String userTitle = "CEO".equals(role) ? "CEO" : "HOD";
    
    String status = leave.get("status");
    String attachment = leave.get("attachment");
    boolean hasAttachment = attachment != null && !attachment.isEmpty();
    
    // Determine color based on leave type - FIXED: Replaced switch with if-else
    String leaveType = leave.get("leaveType");
    String leaveColor = "#6aff00"; // Default color
    
    if (leaveType != null) {
        String lowerType = leaveType.toLowerCase();
        if ("annual leave".equals(lowerType)) {
            leaveColor = "#FF9800"; // Orange
        } else if ("medical leave".equals(lowerType)) {
            leaveColor = "#2196F3"; // Blue
        } else if ("emergency leave".equals(lowerType)) {
            leaveColor = "#F44336"; // Red
        } else if ("maternity leave".equals(lowerType)) {
            leaveColor = "#9C27B0"; // Purple
        }
    }
    
    // Get profile image
    String profileImage = "uploads/default.png";
    // We'll get this from session or database, but for now use default
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Leave Details</title> <!-- Removed - CEO/HOD -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
          box-sizing: border-box;
          font-family: 'Poppins', sans-serif;
        }

        body {
          margin: 0;
          display: flex;
          min-height: 100vh;
          background: #f2f2f2;
        }

        .wrapper {
          display: flex;
          min-height: 100vh;
          width: 100%;
        }

        .sidebar {
          width: 260px;
          background: #e0e0e0;
          padding: 15px;
          transition: width 0.3s ease;
        }

        .sidebar.closed {
          width: 60px;
        }

        .brand {
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-weight: bold;
          margin-bottom: 20px;
        }

        .sidebar.closed .brand span:first-child {
          display: none;
        }

        .profile {
          text-align: center;
          margin-bottom: 25px;
          transition: opacity 0.3s ease;
        }

        .sidebar.closed .profile {
          opacity: 0;
          pointer-events: none;
        }

        .profile img {
          width: 70px;
          height: 70px;
          border-radius: 50%;
          object-fit: cover;
          background: #ccc;
          margin-bottom: 10px;
        }

        .profile h4 {
          margin: 5px 0 0;
          font-size: 14px;
        }

        .profile p {
          margin: 0;
          font-size: 12px;
          color: #555;
        }

        .menu a {
          display: flex;
          align-items: center;
          padding: 12px;
          margin-bottom: 6px;
          text-decoration: none;
          color: #000;
          border-radius: 6px;
          font-size: 14px;
          gap: 12px;
        }

        .menu a i {
          width: 20px;
          text-align: center;
          font-size: 16px;
        }

        .menu a:hover {
          background: #cfcfcf;
        }

        .menu a.active {
          background: #bdbdbd;
          font-weight: bold;
        }

        .sidebar.closed .menu a {
          justify-content: center;
          padding-left: 0;
          padding-right: 0;
          font-size: 0;
          gap: 0;
        }

        .sidebar.closed .menu a i {
          font-size: 18px;
          width: auto;
        }

        .main {
          flex: 1;
          padding: 20px;
        }

        .header {
          background: linear-gradient(to right, #bdbdbd, #eeeeee);
          padding: 18px;
          font-size: 32px;
          font-weight: bold;
          margin-bottom: 20px;
        }

        .content {
          padding: 40px;
        }

        .card {
          max-width: 850px;
          margin: auto;
          background: #fff;
          padding: 35px;
          border-radius: 12px;
          box-shadow: 0 6px 25px rgba(0,0,0,0.2);
        }

        .form {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 22px;
        }

        .row {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .label {
          width: 140px;
          font-weight: 600;
          font-size: 14px;
        }

        input, textarea {
          flex: 1;
          padding: 6px 8px;
          font-size: 13px;
          border: 1px solid #aaa;
          background-color: #f9f9f9;
          color: #333;
        }

        textarea {
          height: 80px;
          resize: none;
        }

        .leave-color {
          width: 18px;
          height: 18px;
          background: <%= leaveColor %>;
          border: 1px solid #555;
          border-radius: 3px;
        }

        .attachment {
          background: #666;
          color: #fff;
          padding: 8px 16px;
          font-size: 13px;
          cursor: pointer;
          display: inline-flex;
          align-items: center;
          gap: 8px;
          text-decoration: none;
          border-radius: 4px;
        }

        .attachment:hover {
          background: #555;
        }

        .buttons {
          display: flex;
          justify-content: flex-end;
          gap: 12px;
          margin-top: 25px;
        }

        .btn {
          padding: 8px 22px;
          border: none;
          color: #fff;
          font-weight: 600;
          cursor: pointer;
        }

        .back { background: #555; }
        .reject { background: #e53935; }
        .approve { background: #2ecc71; }

        input:read-only, textarea:read-only {
          background-color: #f5f5f5;
          cursor: default;
        }

        .rejection-section {
            grid-column: 1/3;
            margin-top: 10px;
        }

        .rejection-reason {
            margin-top: 5px;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-pending-badge {
            background-color: #ffab00;
            color: #fff;
        }
        
        .status-approved-badge {
            background-color: #00c853;
            color: #fff;
        }
        
        .status-rejected-badge {
            background-color: #ff1744;
            color: #fff;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
        }
        
        .modal-content {
            background-color: #fff;
            margin: 10% auto;
            padding: 20px;
            border-radius: 8px;
            width: 400px;
        }
        
        .modal-header {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .modal-textarea {
            width: 100%;
            height: 100px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: none;
        }
        
        /* File attachment section - UPDATED */
        .file-attachment {
            grid-column: 1/3;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .attachment-container {
            display: flex;
            align-items: center;
        }
        
        .download-btn {
            background: #2196F3;
            color: white;
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
        }
        
        .download-btn:hover {
            background: #1976D2;
        }
        
        .no-attachment {
            background-color: #f5f5f5;
            color: #666;
            padding: 8px 16px;
            border: 1px dashed #999;
            border-radius: 4px;
            font-style: italic;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .no-attachment i {
            color: #999;
        }
        
        .leave-type-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .leave-type-label {
            font-weight: 600;
            color: #333;
        }
        
        /* Menu group for HOD */
        .menu-group .menu-parent {
            background: #d0d0d0;
            font-weight: 600;
        }
        
        .menu-group .menu-parent::after {
            content: "▼";
            font-size: 10px;
            margin-left: auto;
            margin-right: 10px;
            transition: transform 0.2s ease;
        }
        
        .menu-group .menu-parent.open::after {
            transform: rotate(180deg);
        }
        
        .menu-group .submenu {
            margin-left: 32px;
            display: none;
            flex-direction: column;
        }
        
        .menu-group .submenu.open {
            display: flex;
        }
        
        .sidebar.closed .menu-group .menu-parent {
            justify-content: center;
            padding: 12px 0;
            font-size: 0;
            gap: 0;
        }
        
        .sidebar.closed .menu-group .menu-parent::after {
            display: none;
        }
        
        .sidebar.closed .menu-group .submenu {
            margin-left: 0;
            align-items: center;
        }
        
        .sidebar.closed .menu-group .submenu a {
            justify-content: center;
            padding: 10px 0;
            gap: 0;
        }
    </style>
</head>
<body>

<div class="wrapper">
  <div class="sidebar" id="sidebar">
    <div class="brand">
      <span>TERLAJAK LARIS</span>
      <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
    </div>

    <div class="profile">
      <img src="<%= request.getContextPath() %>/profile-image?path=<%= profileImage %>"
           onerror="this.src='<%= request.getContextPath() %>/images/default_profile.png'">
      <h4><%= name != null ? name : userName %></h4>
      <p><%= userTitle %></p>
    </div>

    <div class="menu">
      <% if ("CEO".equals(role)) { %>
        <!-- CEO Sidebar Menu -->
        <a href="#"><i class="fas fa-th-large"></i>Dashboard</a>
        <a href="<%= request.getContextPath() %>/ViewProfileCEOServlet"><i class="fas fa-user"></i>Profile</a>
        <a class="active" href="LeaveListServlet"><i class="fas fa-clipboard-list"></i>Requests</a>
        <a href="#"><i class="fas fa-bell"></i>Notifications</a>
        <a href="#" onclick="logout()"><i class="fas fa-sign-out-alt"></i>Logout</a>
      <% } else if ("HOD".equals(role)) { %>
        <!-- HOD Sidebar Menu -->
        <a href="dashboard_hod.jsp"><i class="fas fa-th-large"></i>Dashboard</a>
        <a href="<%= request.getContextPath() %>/ViewProfileHODServlet"><i class="fas fa-user"></i>Profile</a>
        <a href="<%= request.getContextPath() %>/hod/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
        <a class="active" href="LeaveListServlet"><i class="fas fa-clipboard-list"></i>Requests</a>
        <a href="<%= request.getContextPath() %>/LeaveHistoryHodServlet"><i class="fas fa-history"></i>Leave History</a>
        <a href="#"><i class="fas fa-bell"></i>Notifications</a>
        <a href="login.jsp"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
      <% } %>
    </div>
  </div>

  <div class="main">
    <div class="header" style="color: #ffffff;">Leave Request Details</div> <!-- Removed - CEO/HOD -->

    <div class="content">
      <div class="card">
        <div class="form">
          <div class="row">
            <div class="label">Employee Name</div>
            <input value="<%= leave.get("employeeName") %>" readonly>
          </div>
          <div class="row">
            <div class="label">Employee ID</div>
            <input value="E<%= String.format("%05d", Integer.parseInt(leave.get("employeeId"))) %>" readonly>
          </div>
          <div class="row">
            <div class="label">Position</div>
            <input value="<%= leave.get("position") %>" readonly>
          </div>
          <div class="row">
            <div class="label">Department</div>
            <input value="<%= leave.get("department") != null ? leave.get("department") : "N/A" %>" readonly>
          </div>
          <div class="row">
            <div class="label">Request ID</div>
            <input value="L<%= String.format("%03d", Integer.parseInt(leave.get("requestId"))) %>" readonly>
          </div>
          <div class="row">
            <div class="label">Start Date</div>
            <input value="<%= leave.get("startDate") %>" readonly>
          </div>
          <div class="row">
            <div class="label">Leave Type</div>
            <div class="leave-type-info">
              <div class="leave-color" style="background: <%= leaveColor %>"></div>
              <input value="<%= leave.get("leaveType") %>" readonly>
            </div>
          </div>
          <div class="row">
            <div class="label">End Date</div>
            <input value="<%= leave.get("endDate") %>" readonly>
          </div>
          <div class="row">
            <div class="label">Status</div>
            <%
                String statusClass = "";
                if ("PENDING".equals(status)) {
                    statusClass = "status-pending-badge";
                } else if ("APPROVED".equals(status)) {
                    statusClass = "status-approved-badge";
                } else if ("REJECTED".equals(status)) {
                    statusClass = "status-rejected-badge";
                }
            %>
            <span class="status-badge <%= statusClass %>"><%= status %></span>
          </div>
          
          <!-- File Attachment Section - UPDATED: Always visible -->
          <div class="file-attachment">
            <div class="label">Attachment</div>
            <div class="attachment-container">
              <% if (hasAttachment) { %>
                  <a href="LeaveDetailsServlet?download=true&id=<%= leave.get("requestId") %>" class="download-btn">
                    <i class="fas fa-download"></i>
                    Download <%= attachment %>
                  </a>
              <% } else { %>
                  <div class="no-attachment">
                    <i class="fas fa-paperclip"></i> No attachment provided
                  </div>
              <% } %>
            </div>
          </div>
          
          <div class="row" style="grid-column:1/3">
            <div class="label">Reason for Leave</div>
            <textarea readonly><%= leave.get("reason") != null ? leave.get("reason") : "" %></textarea>
          </div>
          
          <% if ("REJECTED".equals(status) && leave.get("reasonRejection") != null && !leave.get("reasonRejection").isEmpty()) { %>
          <div class="row rejection-section">
            <div class="label">Rejection Reason</div>
            <div class="rejection-reason">
              <textarea readonly><%= leave.get("reasonRejection") %></textarea>
            </div>
          </div>
          <% } %>
        </div>

        <div class="buttons">
          <button class="btn back" onclick="window.location.href='LeaveListServlet'">Back to List</button>
          <% if ("PENDING".equals(status)) { %>
            <button class="btn reject" onclick="openRejectModal()">Reject</button>
            <button class="btn approve" onclick="approveLeave()">Approve</button>
          <% } %>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Rejection Modal -->
<div id="rejectModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">Reject Leave Request</div>
    <div class="modal-body">
      <textarea id="rejectionReason" class="modal-textarea" 
                placeholder="Enter reason for rejection..." required></textarea>
    </div>
    <div class="modal-footer">
      <button class="btn back" onclick="closeModal()">Cancel</button>
      <button class="btn reject" onclick="submitRejection()">Submit Rejection</button>
    </div>
  </div>
</div>

<script>
function toggleSidebar() {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.toggle('closed');
}

function openRejectModal() {
  document.getElementById('rejectModal').style.display = 'block';
}

function closeModal() {
  document.getElementById('rejectModal').style.display = 'none';
  document.getElementById('rejectionReason').value = '';
}

function submitRejection() {
  const reason = document.getElementById('rejectionReason').value;
  if (!reason.trim()) {
    alert('Please enter a reason for rejection');
    return;
  }
  
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = 'LeaveDetailsServlet';
  
  const requestId = document.createElement('input');
  requestId.type = 'hidden';
  requestId.name = 'requestId';
  requestId.value = '<%= leave.get("requestId") %>';
  
  const action = document.createElement('input');
  action.type = 'hidden';
  action.name = 'action';
  action.value = 'reject';
  
  const reasonInput = document.createElement('input');
  reasonInput.type = 'hidden';
  reasonInput.name = 'reason';
  reasonInput.value = reason;
  
  form.appendChild(requestId);
  form.appendChild(action);
  form.appendChild(reasonInput);
  
  document.body.appendChild(form);
  form.submit();
}

function approveLeave() {
  if (confirm('Are you sure you want to approve this leave request?')) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'LeaveDetailsServlet';
    
    const requestId = document.createElement('input');
    requestId.type = 'hidden';
    requestId.name = 'requestId';
    requestId.value = '<%= leave.get("requestId") %>';
    
    const action = document.createElement('input');
    action.type = 'hidden';
    action.name = 'action';
    action.value = 'approve';
    
    form.appendChild(requestId);
    form.appendChild(action);
    
    document.body.appendChild(form);
    form.submit();
  }
}

// Close modal when clicking outside
window.onclick = function(event) {
  const modal = document.getElementById('rejectModal');
  if (event.target == modal) {
    closeModal();
  }
}

</script>

</body>
</html>