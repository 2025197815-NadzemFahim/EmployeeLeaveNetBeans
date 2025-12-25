<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.leave.model.LeaveHistory" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Leave History - Staff</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
/* ===== Your Provided CSS ===== */
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

.card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  min-width: 650px;
}

th, td {
  padding: 14px;
  text-align: center;
}

th {
  color: black;
  font-weight: 600;
}

td {
  color: #555;
  font-weight: 600;
}

tbody tr:nth-child(odd) {
  background: #f2f2f2;
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
</style>
</head>

<body>

<div class="wrapper">

  <!-- ===== Sidebar UI ===== -->
  <div class="sidebar" id="sidebar">
    <div class="brand">
      <span>TERLAJAK LARIS</span>
      <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
    </div>

    <div class="profile">
      <img src="https://i.imgur.com/7k12EPD.png">
      <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Staff User" %></h4>
      <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : session.getAttribute("role") %></p>
    </div>

    <div class="menu">
      <a href="dashboard.jsp"><i class="fas fa-th-large"></i>Dashboard</a>
      <a href="profile.jsp"><i class="fas fa-user"></i>Profile</a>
      <a href="apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
      <a class="active"><i class="fas fa-history"></i>Leave History</a>
      <a href="notifications.jsp"><i class="fas fa-bell"></i>Notifications</a>
      <a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
    </div>
  </div>

  <!-- ===== Main Content ===== -->
  <div class="main">
    <div class="header">Leave History Record</div>

    <div class="top-bar">
      <input type="text" class="search" placeholder="Search leave..." id="searchInput" onkeyup="searchTable()">
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
          <tr>
            <td colspan="6">No leave history found.</td>
          </tr>
<%
    }
%>

        </tbody>
      </table>
    </div>

  </div>

</div>

<script>
function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('closed');
}

function searchTable() {
  const input = document.getElementById("searchInput").value.toLowerCase();
  const table = document.getElementById("leaveTable");
  const trs = table.getElementsByTagName("tr");

  for (let i = 1; i < trs.length; i++) {
    const row = trs[i].textContent.toLowerCase();
    trs[i].style.display = row.includes(input) ? "" : "none";
  }
}
</script>

</body>
</html>
