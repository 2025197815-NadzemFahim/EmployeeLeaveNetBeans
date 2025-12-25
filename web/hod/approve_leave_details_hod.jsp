<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // Check if user is logged in and is HOD
    HttpSession userSession = request.getSession(false);
    if (userSession == null || !"HOD".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String requestId = request.getParameter("requestId");
    if (requestId == null || requestId.isEmpty()) {
        response.sendRedirect("approve_leave_hod.jsp");
        return;
    }
    
    // Database connection
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    String name = "", employeeId = "", position = "", leaveType = "", 
           startDate = "", endDate = "", reason = "", attachment = "", 
           status = "", leaveId = "";
    int typeId = 0;
    
    try {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        conn = DriverManager.getConnection(
            "jdbc:derby://localhost:1527/LeaveDB", "app", "app");
        
        String query = "SELECT lr.request_id, e.name, e.employee_id, e.position, " +
                      "lt.name AS leave_type, lr.start_date, lr.end_date, " +
                      "lr.reason, lr.attachment, lr.status, lt.type_id " +
                      "FROM leave_request lr " +
                      "JOIN employee e ON lr.submitted_by = e.employee_id " +
                      "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                      "WHERE lr.request_id = ? AND lr.approved_by = ?";
        
        ps = conn.prepareStatement(query);
        ps.setString(1, requestId);
        ps.setInt(2, (int)userSession.getAttribute("employeeId"));
        rs = ps.executeQuery();
        
        if (rs.next()) {
            leaveId = rs.getString("request_id");
            name = rs.getString("name");
            employeeId = rs.getString("employee_id");
            position = rs.getString("position");
            leaveType = rs.getString("leave_type");
            startDate = rs.getString("start_date");
            endDate = rs.getString("end_date");
            reason = rs.getString("reason");
            attachment = rs.getString("attachment");
            status = rs.getString("status");
            typeId = rs.getInt("type_id");
        } else {
            response.sendRedirect("approve_leave_hod.jsp?error=notfound");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("approve_leave_hod.jsp?error=db");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Leave Details - HOD</title>
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
            color: #ffffff;
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
            background: #6aff00;
            border: 1px solid #555;
        }
        .attachment {
            background: #666;
            color: #fff;
            padding: 6px 14px;
            font-size: 13px;
            cursor: pointer;
            display: inline-block;
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
            text-decoration: none;
            display: inline-block;
        }
        .back { background: #555; }
        .reject { background: #e53935; }
        .approve { background: #2ecc71; }
        .status-pending { color: #ffab00; font-weight: bold; }
        .status-approved { color: #00c853; font-weight: bold; }
        .status-rejected { color: #ff1744; font-weight: bold; }
        
        /* Hide approve/reject buttons if already processed */
        .processed .reject, .processed .approve {
            display: none;
        }
        
        input:read-only, textarea:read-only {
            background-color: #f5f5f5;
            cursor: default;
        }
        
        /* Modal for comments */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .modal-content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            margin: 100px auto;
        }
        .modal-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="wrapper">
        <!-- Sidebar (same as your HTML) -->
        <div class="sidebar" id="sidebar">
            <div class="brand">
                <span>TERLAJAK LARIS</span>
                <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
            </div>
            <div class="profile">
                <img src="https://i.imgur.com/7k12EPD.png">
                <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "HOD USER" %></h4>
                <p>HOD <%= session.getAttribute("department") != null ? session.getAttribute("department") : "" %></p>
            </div>
            <div class="menu">
                <a><i class="fas fa-th-large"></i>Dashboard</a>
                <a><i class="fas fa-user"></i>Profile</a>
                <a class="active"><i class="fas fa-clipboard-list"></i>Requests</a>
                <a><i class="fas fa-bell"></i>Notifications</a>
                <a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
            </div>
        </div>

        <div class="main">
            <div class="header">Approve/Reject Leave</div>
            
            <div class="content">
                <div class="card <%= !"PENDING".equals(status) ? "processed" : "" %>" id="leaveCard">
                    <div class="form">
                        <div class="row"><div class="label">Name</div><input value="<%= name %>" readonly></div>
                        <div class="row"><div class="label">Employee ID</div><input value="<%= employeeId %>" readonly></div>
                        <div class="row"><div class="label">Position</div><input value="<%= position %>" readonly></div>
                        <div class="row"><div class="label">Leave ID</div><input value="<%= leaveId %>" readonly></div>
                        <div class="row">
                            <div class="label">Start Date</div>
                            <input value="<%= startDate %>" readonly>
                        </div>
                        <div class="row">
                            <div class="label">Leave Type</div>
                            <div class="leave-color"></div>
                            <input value="<%= leaveType %>" readonly>
                        </div>
                        <div class="row">
                            <div class="label">End Date</div>
                            <input value="<%= endDate %>" readonly>
                        </div>
                        <div class="row">
                            <div class="label">Current Status</div>
                            <span class="status-<%= status.toLowerCase() %>"><%= status %></span>
                        </div>
                        <div class="row" style="grid-column:1/3">
                            <div class="label">Reason for Leave</div>
                            <textarea readonly><%= reason != null ? reason : "" %></textarea>
                        </div>
                        <% if (attachment != null && !attachment.isEmpty()) { %>
                        <div class="row">
                            <div class="label">Attachment</div>
                            <a href="../download?file=<%= attachment %>" class="attachment" target="_blank">
                                View Attachment
                            </a>
                        </div>
                        <% } %>
                    </div>

                    <div class="buttons">
                        <a href="approve_leave_hod.jsp" class="btn back">Back</a>
                        <% if ("PENDING".equals(status)) { %>
                        <button class="btn reject" onclick="showRejectModal()">Reject</button>
                        <button class="btn approve" onclick="showApproveModal()">Approve</button>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Reject Modal -->
    <div id="rejectModal" class="modal">
        <div class="modal-content">
            <h3>Reject Leave Request</h3>
            <p>Please provide a reason for rejection:</p>
            <textarea id="rejectReason" placeholder="Enter rejection reason..." style="width:100%; height:100px;"></textarea>
            <div class="modal-buttons">
                <button onclick="hideModal('rejectModal')" class="btn back">Cancel</button>
                <button onclick="submitDecision('REJECTED')" class="btn reject">Confirm Reject</button>
            </div>
        </div>
    </div>

    <!-- Approve Modal -->
    <div id="approveModal" class="modal">
        <div class="modal-content">
            <h3>Approve Leave Request</h3>
            <p>Are you sure you want to approve this leave request?</p>
            <div class="modal-buttons">
                <button onclick="hideModal('approveModal')" class="btn back">Cancel</button>
                <button onclick="submitDecision('APPROVED')" class="btn approve">Confirm Approve</button>
            </div>
        </div>
    </div>

    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('closed');
        }
        
        function showRejectModal() {
            document.getElementById('rejectModal').style.display = 'block';
        }
        
        function showApproveModal() {
            document.getElementById('approveModal').style.display = 'block';
        }
        
        function hideModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        function submitDecision(status) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '../ApproveLeaveHODServlet';
            
            const requestIdInput = document.createElement('input');
            requestIdInput.type = 'hidden';
            requestIdInput.name = 'requestId';
            requestIdInput.value = '<%= requestId %>';
            form.appendChild(requestIdInput);
            
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = status;
            form.appendChild(statusInput);
            
            if (status === 'REJECTED') {
                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'rejectReason';
                reasonInput.value = document.getElementById('rejectReason').value;
                form.appendChild(reasonInput);
            }
            
            document.body.appendChild(form);
            form.submit();
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
    </script>
</body>
</html>