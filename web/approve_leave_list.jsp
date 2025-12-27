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
    
    // Get message from session
    String message = (String) userSession.getAttribute("message");
    String error = (String) userSession.getAttribute("error");
    
    // Clear messages after displaying
    if (message != null) userSession.removeAttribute("message");
    if (error != null) userSession.removeAttribute("error");
    
    List<Map<String, String>> leaveRequests = (List<Map<String, String>>) request.getAttribute("leaveRequests");
    String userName = (String) request.getAttribute("userName");
    String name = (String) userSession.getAttribute("name");
    
    // Set page title based on role
    String pageTitle = "CEO".equals(role) ? "CEO" : "HOD";
    String userTitle = "CEO".equals(role) ? "CEO" : "HOD";
    
    // Get profile image
    String profileImage = "uploads/default.png";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Approve Leave</title> <!-- Removed - CEO/HOD -->
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

/* ===== Main Content ===== */
.main {
  flex: 1;
  padding: 20px;
}

/* Header */
.header {
  background: linear-gradient(to right, #bdbdbd, #eeeeee);
  padding: 18px;
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 20px;
  color: #ffffff;
}

/* Search */
.top-bar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 15px;
}

.search {
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid #ccc;
  width: 220px;
  font-size: 13px;
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
  min-width: 600px;
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
    color : #555;
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

/* View Button */
.btn-view {
  padding: 8px 16px;
  border-radius: 6px;
  background: #bdbdbd;
  color: black;
  font-weight: 600;
  text-decoration: none;
  display: inline-block;
}

.btn-view:hover {
  background: #9e9e9e;
}

/* Messages */
.message {
    padding: 10px;
    margin-bottom: 15px;
    border-radius: 4px;
}

.success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

.no-data {
    text-align: center;
    padding: 30px;
    color: #666;
    font-style: italic;
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

  <!-- Main Content -->
  <div class="main">

    <div class="header">Approve/Reject Leave</div> <!-- Removed - CEO/HOD -->

    <% if (message != null) { %>
        <div class="message success"><%= message %></div>
    <% } %>
    
    <% if (error != null) { %>
        <div class="message error"><%= error %></div>
    <% } %>

    <div class="top-bar">
      <input type="text" class="search" placeholder="Search by ID or Leave Type..." id="searchInput" onkeyup="searchTable()">
    </div>

    <div class="card">
      <% if (leaveRequests == null || leaveRequests.isEmpty()) { %>
        <div class="no-data">
          <i class="fas fa-clipboard-check" style="font-size: 48px; margin-bottom: 15px; color: #bdbdbd;"></i>
          <h3>No Leave Requests Found</h3>
          <p>There are no pending leave requests to review.</p>
        </div>
      <% } else { %>
      <table id="leaveTable">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Leave Type</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% for (Map<String, String> leave : leaveRequests) { 
              String status = leave.get("status");
              String statusClass = "status-" + status.toLowerCase();
          %>
          <tr>
            <td>L<%= String.format("%03d", Integer.parseInt(leave.get("requestId"))) %></td>
            <td><%= leave.get("leaveType") %></td>
            <td><%= leave.get("startDate") %></td>
            <td><%= leave.get("endDate") %></td>
            <td class="<%= statusClass %>">
              <%= status %>
            </td>
            <td>
              <a href="LeaveDetailsServlet?id=<%= leave.get("requestId") %>" class="btn-view">View</a>
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
    for (let j = 0; j < tds.length - 1; j++) { // Exclude Action column
      if (tds[j].textContent.toLowerCase().includes(input)) {
        found = true;
        break;
      }
    }
    trs[i].style.display = found ? "" : "none";
  }
}

</script>

</body>
</html> 