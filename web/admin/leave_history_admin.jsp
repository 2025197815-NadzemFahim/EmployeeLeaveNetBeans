<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.leave.model.LeaveHistory" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Leave History - Admin</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
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

.menu a, .menu-parent {
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

/* Dropdown parent */
.menu-group .menu-parent {
  background: #d0d0d0;
  font-weight: 600;
}

/* Arrow indicator (fix, kekal di kanan & tak duplicate) */
.menu-group .menu-parent::after {
  content: "▼";
  font-size: 10px;
  margin-left: auto;
  margin-right: 10px;
  transition: transform 0.2s ease;
}

/* Rotate arrow bila buka */
.menu-group .menu-parent.open::after {
  transform: rotate(180deg);
}

/* Submenu */
.menu-group .submenu {
  margin-left: 32px;
  display: none;
  flex-direction: column;
}

.menu-group .submenu.open {
  display: flex;
}

.menu a:hover, .menu-parent:hover {
  background: #cfcfcf;
}

.menu a.active {
  background: #bdbdbd;
  font-weight: bold;
}

/* Collapse mode → icon center */
.sidebar.closed .menu a,
.sidebar.closed .menu-parent {
  justify-content: center;
  padding: 12px 0;
  font-size: 0;
  gap: 0;
}

.sidebar.closed .menu a i,
.sidebar.closed .menu-parent i {
  font-size: 18px;
  width: auto;
}

.sidebar.closed .menu a span,
.sidebar.closed .menu-parent span {
  display: none;
}

.sidebar.closed .menu-parent::after {
  display: none;
}

.sidebar.closed .submenu {
  margin-left: 0;
  align-items: center;
}

.sidebar.closed .submenu a {
  justify-content: center;
  padding: 10px 0;
  gap: 0;
}

.sidebar.closed .submenu a i {
  font-size: 16px;
}

/* Main content */
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

/* Search bar */
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
  min-width: 650px; /* forces horizontal scroll on small screens */
}

th, td {
  padding: 14px;
  text-align: center;
}

th {
  color: black;
  font-weight: 600;
}

td{
    color : #555;
    font-weight: 600;
}

tbody tr:nth-child(odd) {
  background: #f2f2f2;
}

.status-approved { color: #00c853; font-weight: bold; }
.status-rejected { color: #ff1744; font-weight: bold; }
.status-pending { color: #ffab00; font-weight: bold; }

/* Responsive */
@media (max-width: 768px) {
  .wrapper { flex-direction: column; }
  .sidebar { width: 100%; }
  .sidebar.closed { width: 100%; }
  .header { font-size: 22px; text-align: center; }
  .top-bar { justify-content: center; }
  .search { width: 100%; max-width: 300px; }
}



</style>

</head>
<body>

<div class="wrapper">

  <!-- ===== Sidebar UI ===== -->
  <div class="sidebar" id="sidebar">
    <div class="brand">
      <span>TERLAJAK LARIS</span>
      <span class="toggle-btn">☰</span>
    </div>

    <div class="profile">
      <img src="<%= request.getContextPath() %>/profile-image?path=<%= request.getAttribute("profileImg") %>"
           onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
      <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Staff User" %></h4>
      <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : session.getAttribute("role") %></p>
    </div>

    <div class="menu">
      <a href="dashboard_admin.jsp"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
      <a href="employees.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
      <a href="policies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
      <a href="reports.jsp"><i class="fas fa-clipboard"></i><span>Reports</span></a>
    

      <div class="menu-group">
        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
        <div class="submenu">
          <a href="profile_admin.jsp"><i class="fas fa-id-badge"></i><span>Profile</span></a>
          <a href="apply_leave_admin.jsp"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
          <a href="leaveHistory_admin.jsp" class="active"><i class="fas fa-history"></i><span>Leave History</span></a>
          <a href="generate_record.jsp"><i class="fas fa-folder-open"></i><span>Generate Record</span></a>
        </div>
      </div>

      <a href="notifications_admin.jsp"><i class="fas fa-bell"></i><span>Notifications</span></a>
      <a href="../LogoutServlet"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
    </div>
  </div>

   <!-- Main Content -->
  <div class="main">
    <div class="header">Leave History Record</div>

    <div class="top-bar">
      <input type="text" class="search" placeholder="Search leave..." onkeyup="searchTable()" id="searchInput">
    </div>

    <div class="card">
      <table id="leaveTable">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Leave Type</th>
            <th>Status</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Balance</th>
          </tr>
        </thead>
        <tbody>

<%
    List<LeaveHistory> leaveHistory = (List<LeaveHistory>) request.getAttribute("leaveHistory");
    if (leaveHistory != null && !leaveHistory.isEmpty()) {
        for (LeaveHistory lh : leaveHistory) {
            String statusClass = "";
            if ("APPROVED".equalsIgnoreCase(lh.getStatus())) statusClass = "status-approved";
            else if ("REJECTED".equalsIgnoreCase(lh.getStatus())) statusClass = "status-rejected";
            else statusClass = "status-pending";
%>
          <tr>
            <td><%= lh.getRequestId() %></td>
            <td><%= lh.getLeaveType() %></td>
            <td class="<%= statusClass %>"><%= lh.getStatus() %></td>
            <td><%= lh.getStartDate() %></td>
            <td><%= lh.getEndDate() %></td>
            <td><%= lh.getLeaveBalance() %></td>
          </tr>
<%
        }
    } else {
%>
          <tr><td colspan="6">No leave history found.</td></tr>
<%
    }
%>

        </tbody>
      </table>
    </div>

  </div>

</div>

<script>
/* Sidebar open/close */
document.querySelector(".toggle-btn").addEventListener("click", function() {
  document.getElementById("sidebar").classList.toggle("closed");
});

/* Dropdown Personal open/close */
document.querySelectorAll(".menu-group").forEach(group => {
  const parent = group.querySelector(".menu-parent");
  const submenu = group.querySelector(".submenu");

  parent.addEventListener("click", () => {
    parent.classList.toggle("open");
    submenu.classList.toggle("open");
  });
});

/* Search realtime (fix sebab ID dah wujud) */
document.getElementById("searchInput").addEventListener("keyup", function() {
  let filter = this.value.toLowerCase();
  let rows = document.querySelectorAll("#leaveTable tbody tr");

  rows.forEach(row => {
    let text = row.innerText.toLowerCase();
    row.style.display = text.includes(filter) ? "" : "none";
  });
});
</script>

</body>
</html>