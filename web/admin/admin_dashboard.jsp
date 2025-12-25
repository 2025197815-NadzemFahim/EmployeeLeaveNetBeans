<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.leave.model.LeaveHistory" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard</title>

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
  background: #e0e0e0;
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
/* ===== Main Content ===== */
.main {
  flex: 1;
  padding: 25px 30px;
}

.main-content {
  max-width: 1200px;
  margin: auto;
}

.header {
  background: linear-gradient(to right, #bdbdbd, #eeeeee);
  padding: 18px;
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 20px;
}

/* ===== Dashboard Cards ===== */
.cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  margin-bottom: 20px;
}

.card-item {
  background: white;
  padding: 18px;
  border-radius: 8px;
  text-align: center;
  font-weight: 600;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.05);
  color: #333;
}

.card-item h3 {
  margin: 8px 0 0;
  font-size: 24px;
  font-weight: 700;
  color: #000;
}

/* ===== Leave Chart Section ===== */
.chart-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.04);
}

/* ===== Approval List Section ===== */
.approval-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.04);
}

.approval-section h4 {
  margin-top: 0;
  margin-bottom: 15px;
  font-size: 18px;
  font-weight: 700;
  color: #222;
}

.approval-list {
  width: 100%;
  border-left: 4px solid #9e9e9e;
  padding: 10px 15px;
  margin-bottom: 10px;
  background: #fafafa;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

/* ===== Responsive ===== */
@media (max-width: 900px) {
  .cards { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .wrapper { flex-direction: column; }
  .sidebar { width: 100%; }
  .sidebar.closed { width: 100%; }
  .header { font-size: 22px; text-align: center; }
  .cards { grid-template-columns: 1fr; }
}
</style>

</head>
<body>
    
    <div class="wrapper">

  <!-- ===== Sidebar ===== -->
  <div class="sidebar" id="sidebar">
    <div class="brand">
      <span>TERLAJAK LARIS</span>
      <span class="toggle-btn">☰</span>
    </div>

    <div class="profile">
      <img src="https://i.imgur.com/7k12EPD.png">
      <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Admin User" %></h4>
      <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : session.getAttribute("role") %></p>
    </div>

   <div class="menu">
      <a href="#" class="active"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
      <a href="#"><i class="fas fa-users"></i><span>Employees</span></a>
      <a href="#"><i class="fas fa-file-lines"></i><span>Policies</span></a>
      <a href="#"><i class="fas fa-clipboard"></i><span>Reports</span></a>
      <a href="#"><i class="fas fa-bell"></i><span>Requests</span></a>

      <!-- Personal dropdown -->
      <div class="menu-group">
        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
        <div class="submenu">
          <a href="#"><i class="fas fa-id-badge"></i><span>Profile</span></a>
          <a href="#"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
          <a href="#"><i class="fas fa-history"></i><span>Leave History</span></a>
          <a href="#"><i class="fas fa-folder-open"></i><span>Generate Record</span></a>
        </div>
      </div>

      <a href="#"><i class="fas fa-bell"></i><span>Notifications</span></a>
      <a href="#"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
    </div>
  </div>

<div class="main">
  <div class="main-content">

    <div class="header">Dashboard Overview</div>

    <div class="cards">
      <div class="card-item"><i class="fas fa-users"></i> Total Employees <h3><%= request.getAttribute("totalEmployees") %></h3></div>
      <div class="card-item"><i class="fas fa-calendar-day"></i> Present Today <h3><%= request.getAttribute("presentToday") %></h3></div>
      <div class="card-item"><i class="fas fa-plane"></i> On Leave <h3><%= request.getAttribute("onLeave") %></h3></div>
      <div class="card-item"><i class="fas fa-clock"></i> Pending Approvals <h3><%= request.getAttribute("pending") %></h3></div>
    </div>

    <div class="chart-section">
      <canvas id="leaveChart"></canvas>
    </div>

    <div class="approval-section">
      <h4>Leave Requests for Approval</h4>
      <%
          List<LeaveHistory> latest = (List<LeaveHistory>) request.getAttribute("latestLeaves");
          if (latest != null) {
              for (LeaveHistory lh : latest) {
      %>
          <div class="approval-list">L<%= lh.getRequestId() %> – <%= lh.getLeaveType() %> (<%= lh.getStartDate() %> → <%= lh.getEndDate() %>) – <%= lh.getStatus() %></div>
      <% 
              }
          }
      %>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<%
  int[] c = (int[]) request.getAttribute("monthlyCount");
  String dataPoints = "0,0,0,0,0,0,0,0,0,0,0,0";
  if (c != null) {
      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < 12; i++) {
          sb.append(c[i]);
          if (i < 11) sb.append(",");
      }
      dataPoints = sb.toString();
  }
%>

<script>
const ctx = document.getElementById('leaveChart').getContext('2d');
new Chart(ctx, {
  type: 'line',
  data: {
    labels: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
    datasets: [{
      data: [<%= dataPoints %>],
      fill: false,
      tension: 0.3
    }]
  },
  options: {
    responsive: true,
    plugins: { legend: { display: false } },
    scales: { y: { beginAtZero: true } }
  }
});
</script>

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
</script>

</body>
</html>
