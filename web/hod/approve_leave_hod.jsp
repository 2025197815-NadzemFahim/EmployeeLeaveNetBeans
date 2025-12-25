<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is HOD
    HttpSession userSession = request.getSession(false);
    if (userSession == null || !"HOD".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    int hodId = (int) userSession.getAttribute("employeeId");
    String department = (String) userSession.getAttribute("department");
    
    List<Map<String, String>> leaveRequests = new ArrayList<>();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        conn = DriverManager.getConnection(
            "jdbc:derby://localhost:1527/LeaveDB", "app", "app");
        
        // Get leave requests for staff in HOD's department
        String query = "SELECT lr.request_id, e.name, lt.name AS leave_type, " +
                      "lr.start_date, lr.end_date, lr.status, lr.submitted_date, " +
                      "e.employee_id " +
                      "FROM leave_request lr " +
                      "JOIN employee e ON lr.submitted_by = e.employee_id " +
                      "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                      "WHERE e.department = ? AND lr.approved_by = ? " +
                      "AND lr.status IN ('PENDING', 'APPROVED', 'REJECTED') " +
                      "ORDER BY lr.submitted_date DESC";
        
        ps = conn.prepareStatement(query);
        ps.setString(1, department);
        ps.setInt(2, hodId);
        rs = ps.executeQuery();
        
        SimpleDateFormat displayFormat = new SimpleDateFormat("dd-MM-yyyy");
        
        while (rs.next()) {
            Map<String, String> request = new HashMap<>();
            request.put("requestId", "L" + String.format("%04d", rs.getInt("request_id")));
            request.put("employeeName", rs.getString("name"));
            request.put("employeeId", rs.getString("employee_id"));
            request.put("leaveType", rs.getString("leave_type"));
            request.put("startDate", displayFormat.format(rs.getDate("start_date")));
            request.put("endDate", displayFormat.format(rs.getDate("end_date")));
            request.put("status", rs.getString("status"));
            request.put("submittedDate", rs.getTimestamp("submitted_date").toString());
            
            leaveRequests.add(request);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Database error: " + e.getMessage());
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
<title>Approve / Reject Leave - HOD</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
/* ===== Use your provided CSS ===== */
* {
  box-sizing: border-box;
  font-family: "Segoe UI", sans-serif;
}

body {
  margin: 0;
  background: #f2f2f2;
}

.wrapper {
  display: flex;
  min-height: 100vh;
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

/* ===== Main Content ===== */
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

/* Search */
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.search {
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid #ccc;
  width: 220px;
  font-size: 13px;
}

.filter-buttons {
  display: flex;
  gap: 10px;
}

.filter-btn {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid #ccc;
  background: white;
  cursor: pointer;
  font-size: 13px;
}

.filter-btn.active {
  background: #bdbdbd;
  font-weight: bold;
}

.filter-btn:hover {
  background: #e0e0e0;
}

/* Card */
.card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  overflow-x: auto;
}

/* Table */
table {
  width: 100%;
  border-collapse: collapse;
  min-width: 750px; /* Adjusted for additional column */
}

th, td {
  padding: 14px;
  text-align: center;
}

th {
  color: black;
  font-weight: 600;
  background: #f5f5f5;
}

td {
  color: #555;
  font-weight: 600;
}

tbody tr:nth-child(odd) {
  background: #f9f9f9;
}

tbody tr:hover {
  background: #f0f0f0;
}

.status-approved {
  color: #00c853;
  font-weight: bold;
}

.status-rejected {
  color: #ff1744;
  font-weight: bold;
}

.status-pending {
  color: #ffab00;
  font-weight: bold;
}

.status-pending-ceo {
  color: #2196F3;
  font-weight: bold;
}

/* View Button */
.btn-view {
  padding: 8px 16px;
  border-radius: 6px;
  background: #bdbdbd;
  color: black;
  font-weight: 600;
  text-decoration: none;
  display: inline-block;
  border: none;
  cursor: pointer;
  font-size: 13px;
}

.btn-view:hover {
  background: #9e9e9e;
}

/* Message when no data */
.no-data {
  text-align: center;
  padding: 40px;
  color: #666;
  font-style: italic;
}

/* Success/Error messages */
.message {
  padding: 10px 15px;
  margin-bottom: 15px;
  border-radius: 6px;
  font-weight: 500;
}

.message.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.message.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
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
      <img src="https://i.imgur.com/7k12EPD.png">
      <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "AMIRUL AIMAN BIN LEO" %></h4>
      <p>HOD <%= department != null ? department : "IT" %></p>
    </div>

    <div class="menu">
      <a href="dashboard_hod.jsp"><i class="fas fa-th-large"></i>Dashboard</a>
      <a href="profile_hod.jsp"><i class="fas fa-user"></i>Profile</a>
      <a class="active" href="approve_leave_hod.jsp"><i class="fas fa-clipboard-list"></i>Requests</a>
      <a href="notifications_hod.jsp"><i class="fas fa-bell"></i>Notifications</a>
      <a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
    </div>
  </div>

  <!-- Main Content -->
  <div class="main">

    <div class="header" style="color: #ffffff;">Approve/Reject Leave - HOD</div>

    <!-- Success/Error Messages -->
    <% if (request.getParameter("success") != null) { %>
    <div class="message success">
      Leave request has been processed successfully!
    </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
    <div class="message error">
      Error: <%= request.getParameter("error") %>
    </div>
    <% } %>
    
    <% if (request.getAttribute("error") != null) { %>
    <div class="message error">
      <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <div class="top-bar">
      <div class="filter-buttons">
        <button class="filter-btn active" onclick="filterTable('all')">All</button>
        <button class="filter-btn" onclick="filterTable('PENDING')">Pending</button>
        <button class="filter-btn" onclick="filterTable('APPROVED')">Approved</button>
        <button class="filter-btn" onclick="filterTable('REJECTED')">Rejected</button>
      </div>
      <input type="text" class="search" placeholder="Search by ID, Name, or Type" id="searchInput" onkeyup="searchTable()">
    </div>

    <div class="card">
      <% if (leaveRequests.isEmpty()) { %>
      <div class="no-data">
        <i class="fas fa-clipboard-check" style="font-size: 48px; margin-bottom: 15px; color: #bdbdbd;"></i>
        <h3>No Leave Requests Found</h3>
        <p>There are no pending leave requests from staff in your department.</p>
      </div>
      <% } else { %>
      <table id="leaveTable">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Employee Name</th>
            <th>Leave Type</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% for (Map<String, String> request : leaveRequests) { 
            String statusClass = "status-" + request.get("status").toLowerCase();
            if ("PENDING_CEO".equals(request.get("status"))) {
                statusClass = "status-pending-ceo";
            }
          %>
          <tr data-status="<%= request.get("status") %>">
            <td><%= request.get("requestId") %></td>
            <td><%= request.get("employeeName") %></td>
            <td><%= request.get("leaveType") %></td>
            <td><%= request.get("startDate") %></td>
            <td><%= request.get("endDate") %></td>
            <td class="<%= statusClass %>">
              <% 
                String statusDisplay = request.get("status");
                if ("PENDING_CEO".equals(statusDisplay)) {
                    statusDisplay = "Pending CEO";
                }
              %>
              <%= statusDisplay %>
            </td>
            <td>
              <% 
                String requestId = request.get("requestId").substring(1); // Remove "L" prefix
              %>
              <a href="approve_leave_details_hod.jsp?requestId=<%= requestId %>" class="btn-view">View</a>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } %>
    </div>

  </div>

</div>

<script>
function toggleSidebar() {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.toggle('closed');
}

/* Search table */
function searchTable() {
  const input = document.getElementById("searchInput").value.toLowerCase();
  const table = document.getElementById("leaveTable");
  if (!table) return;
  
  const trs = table.tBodies[0].getElementsByTagName("tr");

  for (let i = 0; i < trs.length; i++) {
    let found = false;
    const tds = trs[i].getElementsByTagName("td");
    for (let j = 0; j < tds.length - 1; j++) { // exclude Action column
      if (tds[j].textContent.toLowerCase().includes(input)) {
        found = true;
        break;
      }
    }
    trs[i].style.display = found ? "" : "none";
  }
}

/* Filter table by status */
function filterTable(status) {
  const table = document.getElementById("leaveTable");
  if (!table) return;
  
  const trs = table.tBodies[0].getElementsByTagName("tr");
  const filterButtons = document.querySelectorAll('.filter-btn');
  
  // Update active button
  filterButtons.forEach(btn => {
    btn.classList.remove('active');
    if (btn.textContent === (status === 'all' ? 'All' : 
        status === 'PENDING' ? 'Pending' :
        status === 'APPROVED' ? 'Approved' : 'Rejected')) {
      btn.classList.add('active');
    }
  });
  
  // Show/hide rows based on status
  for (let i = 0; i < trs.length; i++) {
    const rowStatus = trs[i].getAttribute('data-status');
    if (status === 'all' || rowStatus === status) {
      trs[i].style.display = "";
    } else {
      trs[i].style.display = "none";
    }
  }
}

// Auto-refresh every 30 seconds to check for new requests
setTimeout(() => {
  window.location.reload();
}, 30000);
</script>

</body>
</html>