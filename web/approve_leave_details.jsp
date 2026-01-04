<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
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
    Integer employeeId = (Integer) userSession.getAttribute("employeeId");
    String name = (String) request.getAttribute("name");
String position = (String) request.getAttribute("position");
String profileImage = (String) request.getAttribute("profileImage");

if (profileImage == null || profileImage.trim().isEmpty()) {
    profileImage = "default.png";
}
    
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
    
    // Get current leave balance if approved
    int currentBalance = 0;
    if ("APPROVED".equals(status)) {
        int submittedBy = Integer.parseInt(leave.get("employeeId"));
        int typeId = Integer.parseInt(leave.get("typeId"));
        currentBalance = getCurrentLeaveBalance(submittedBy, typeId);
    }
    
    // Get error message from request
    String error = (String) request.getAttribute("error");
    boolean hasError = error != null && !error.isEmpty();
    
  
%>
<%!
    // Helper method to get current leave balance
    private int getCurrentLeaveBalance(int employeeId, int typeId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int balance = 0;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB",
                "app",
                "app"
            );
            
            String sql = "SELECT balance FROM employee_leave_balance " +
                        "WHERE employee_id = ? AND type_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, employeeId);
            ps.setInt(2, typeId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                balance = rs.getInt("balance");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        
        return balance;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Leave Details</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
         * {
                box-sizing: border-box;
                font-family: "Poppins", sans-serif;
            }

            body {
                margin: 0;
                background: #f5f7fb;
            }

            .wrapper {
                display: flex;
                min-height: 100vh;
            }
            /* ===== SIDEBAR ===== */
            .sidebar {
                width: 260px;
                background: #0f172a; /* UPDATED */
                padding: 15px;
                transition: width 0.3s ease;
            }

            .sidebar.closed {
                width: 60px;
            }

            /* ===== BRAND ===== */
            .brand {
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-weight: bold;
                margin-bottom: 20px;
                color: #ffffff; /* UPDATED */
            }

            .sidebar.closed .brand span:first-child {
                display: none;
            }

            /* ===== PROFILE ===== */
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
                background: #333;
                margin-bottom: 10px;
            }

            .profile h4 {
                margin: 5px 0 0;
                font-size: 14px;
                color: #ffffff; /* UPDATED */
            }

            .profile p {
                margin: 0;
                font-size: 12px;
                color: #aaaaaa; /* UPDATED */
            }

            /* ===== MENU ===== */
            .menu a {
                display: flex;
                align-items: center;
                padding: 12px;
                margin-bottom: 6px;
                text-decoration: none;
                color: #dcdcdc; /* UPDATED */
                border-radius: 6px;
                font-size: 14px;
                gap: 12px;
                transition: background 0.2s ease, color 0.2s ease; /* BONUS */
            }

            .menu a i {
                width: 20px;
                text-align: center;
                font-size: 16px;
            }

            /* ===== HOVER ===== */
            .menu a:hover {
                background: #2c2c2c; /* UPDATED */
            }

            /* ===== ACTIVE ===== */
            .menu a.active {
                background: #ffffff;
                color: #0f172a;   /* dark navy text */
                font-weight: bold;
            }

            /* ===== COLLAPSED MODE ===== */
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
          background: linear-gradient(to right, #0f172a, #94a3b8);
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
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
            min-width: 100px;
            text-align: center;
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
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background-color: #fff;
            padding: 0;
            border-radius: 8px;
            width: 400px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        .modal-header {
            background: linear-gradient(to right, #ff9800, #ffab00);
            color: white;
            padding: 15px 20px;
            font-size: 18px;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .modal-body {
            padding: 20px;
            text-align: center;
            color: #333;
            font-size: 14px;
            line-height: 1.5;
        }
        
        .modal-footer {
            padding: 15px 20px;
            display: flex;
            justify-content: center;
            background-color: #f5f5f5;
            border-top: 1px solid #ddd;
        }
        
        .modal-btn {
            padding: 8px 30px;
            border: none;
            border-radius: 4px;
            font-weight: 600;
            cursor: pointer;
            font-size: 14px;
        }
        
        .modal-btn-ok {
            background-color: #ff9800;
            color: white;
        }
        
        .modal-btn-ok:hover {
            background-color: #f57c00;
        }
        
        .modal-textarea {
            width: 100%;
            height: 100px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: none;
            font-size: 14px;
        }
        
        /* File attachment section */
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
        
        /* Error message */
        .error-message {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background-color: #ffebee;
            color: #c62828;
            padding: 15px 20px;
            text-align: center;
            font-weight: 600;
            z-index: 999;
            display: none;
        }
        
        .error-message.show {
            display: block;
            animation: slideDown 0.3s ease;
        }
        
        @keyframes slideDown {
            from { transform: translateY(-100%); }
            to { transform: translateY(0); }
        }
    </style>
</head>
<body>

<% if (hasError) { %>
    <!-- Error Message Banner -->
    <div class="error-message show">
        <i class="fas fa-exclamation-triangle"></i> <%= error %>
    </div>
<% } %>

<div class="wrapper">
  <div class="sidebar" id="sidebar">
    <div class="brand">
      <span>TERLAJAK LARIS</span>
      <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
    </div>

    <div class="profile">
    <img src="<%= request.getContextPath() %>/profile-image?path=<%= profileImage %>"
         onerror="this.src='<%= request.getContextPath() %>/images/default_profile.png'">

    <h4><%= name != null ? name : "User" %></h4>
    <p><%= position != null ? position : "-" %></p>
</div>


    <div class="menu">
      <% if ("CEO".equals(role)) { %>
        <!-- CEO Sidebar Menu -->
        <a href="<%= request.getContextPath() %>/CEODashboardServlet"><i class="fas fa-th-large"></i>Dashboard</a>
        <a href="<%= request.getContextPath() %>/ViewProfileCEOServlet"><i class="fas fa-user"></i>Profile</a>
        <a class="active" href="<%= request.getContextPath() %>/LeaveListServlet"><i class="fas fa-clipboard-list"></i>Requests</a>
        <a href="<%= request.getContextPath() %>/NotificationCeoServlet"><i class="fas fa-bell"></i>Notifications</a>
        <a href="login.jsp" onclick="logout()"><i class="fas fa-sign-out-alt"></i>Logout</a>
      <% } else if ("HOD".equals(role)) { %>
        <!-- HOD Sidebar Menu -->
        <a href="<%= request.getContextPath() %>/HODDashboardServlet"><i class="fas fa-th-large"></i>Dashboard</a>
        <a href="<%= request.getContextPath() %>/ViewProfileHODServlet"><i class="fas fa-user"></i>Profile</a>
        <a href="<%= request.getContextPath() %>/HODApplyLeaveServlet"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
        <a class="active" href="<%= request.getContextPath() %>/LeaveListServlet"><i class="fas fa-clipboard-list"></i>Requests</a>
        <a href="<%= request.getContextPath() %>/LeaveHistoryHodServlet"><i class="fas fa-history"></i>Leave History</a>
        <a href="<%= request.getContextPath() %>/NotificationHodServlet"><i class="fas fa-bell"></i>Notifications</a>
        <a href="login.jsp"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
      <% } %>
    </div>
  </div>

  <div class="main">
    <div class="header" style="color: #ffffff;">Leave Request Details</div>

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
            <input value="<%= leave.get("leaveType") %>" readonly>
          </div>
          <div class="row">
            <div class="label">End Date</div>
            <input value="<%= leave.get("endDate") %>" readonly>
          </div>
          <div class="row">
            <div class="label">Status</div>
            <%
                String statusClass = "";
                String statusText = status;
                String statusColor = "";
                
                if ("PENDING".equals(status)) {
                    statusClass = "status-pending-badge";
                    statusColor = "#ffab00"; // Orange
                    statusText = "PENDING";
                } else if ("APPROVED".equals(status)) {
                    statusClass = "status-approved-badge";
                    statusColor = "#00c853"; // Green
                    statusText = "APPROVED";
                } else if ("REJECTED".equals(status)) {
                    statusClass = "status-rejected-badge";
                    statusColor = "#ff1744"; // Red
                    statusText = "REJECTED";
                }
            %>
            <span class="status-badge <%= statusClass %>" 
                  style="background-color: <%= statusColor %>; color: white;">
                <%= statusText %>
            </span>
          </div>
          
          <!-- File Attachment Section -->
          <div class="file-attachment">
            <div class="label">Attachment</div>
            <div class="attachment-container">
              <% if (hasAttachment) { 
                  // Extract filename from path
                  String fileName = attachment;
                  if (attachment.contains("/")) {
                      fileName = attachment.substring(attachment.lastIndexOf("/") + 1);
                  }
              %>
                  <a href="LeaveDetailsServlet?download=true&id=<%= leave.get("requestId") %>" class="download-btn">
                    <i class="fas fa-download"></i>
                    Download <%= fileName %>
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

<!-- Error Modal -->
<div id="errorModal" class="modal" style="display: <%= hasError ? "flex" : "none" %>;">
  <div class="modal-content">
    <div class="modal-header">
      <span>Leave Approval Error</span>
    </div>
    <div class="modal-body">
      <% if (hasError) { %>
        <%= error %>
      <% } else { %>
        An error occurred while processing your request.
      <% } %>
    </div>
    <div class="modal-footer">
      <button class="modal-btn modal-btn-ok" onclick="closeErrorModal()">OK</button>
    </div>
  </div>
</div>

<!-- Rejection Modal -->
<div id="rejectModal" class="modal">
  <div class="modal-content">
    <div class="modal-header" style="background: linear-gradient(to right, #e53935, #ef5350);">
      <span>Reject Leave Request</span>
    </div>
    <div class="modal-body">
      <textarea id="rejectionReason" class="modal-textarea" 
                placeholder="Enter reason for rejection..." required></textarea>
    </div>
    <div class="modal-footer">
      <button class="modal-btn" onclick="closeRejectModal()" style="background: #ddd; color: #333;">Cancel</button>
      <button class="modal-btn" onclick="submitRejection()" style="background: #e53935; color: white;">Submit Rejection</button>
    </div>
  </div>
</div>

<script>
function toggleSidebar() {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.toggle('closed');
}

// Error Modal functions
function showErrorModal(message) {
  const modal = document.getElementById('errorModal');
  const modalBody = modal.querySelector('.modal-body');
  modalBody.textContent = message;
  modal.style.display = 'flex';
}

function closeErrorModal() {
  document.getElementById('errorModal').style.display = 'none';
}

// Rejection Modal functions
function openRejectModal() {
  document.getElementById('rejectModal').style.display = 'flex';
}

function closeRejectModal() {
  document.getElementById('rejectModal').style.display = 'none';
  document.getElementById('rejectionReason').value = '';
}

function submitRejection() {
  const reason = document.getElementById('rejectionReason').value;
  if (!reason.trim()) {
    alert('Please enter a reason for rejection');
    return;
  }
  
  if (confirm('Are you sure you want to reject this leave request?')) {
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
}

function approveLeave() {
  if (confirm('Are you sure you want to approve this leave request?\n\nThis will deduct the leave days from the employee\'s balance.')) {
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
  const errorModal = document.getElementById('errorModal');
  const rejectModal = document.getElementById('rejectModal');
  
  if (event.target == errorModal) {
    closeErrorModal();
  }
  if (event.target == rejectModal) {
    closeRejectModal();
  }
}

function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '<%= request.getContextPath() %>/LogoutServlet';
    }
}

// Auto-hide error banner after 5 seconds
if (<%= hasError %>) {
    setTimeout(() => {
        const errorBanner = document.querySelector('.error-message');
        if (errorBanner) {
            errorBanner.classList.remove('show');
            setTimeout(() => {
                errorBanner.style.display = 'none';
            }, 300);
        }
    }, 5000);
}
</script>

</body>
</html>