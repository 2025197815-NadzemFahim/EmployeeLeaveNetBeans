<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.leave.model.LeaveHistory, java.util.Arrays" %>

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

/* ===== Sidebar (kekal) ===== */
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

.menu a:hover, .menu-parent:hover {
  background: #cfcfcf;
}

.menu a.active {
  background: #bdbdbd;
  font-weight: bold;
}

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

/* ===== Main Content (kekal logic) ===== */
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
}

/* ===== Leave Types Circle ===== */
.leave-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.card {
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
  text-align: center;
  font-weight: 600;
}

.circle {
  width: 90px;
  height: 90px;
  border-radius: 50%;
  border: 8px solid #e5e5e5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  margin: 0 auto 8px auto;
  position: relative;
}

.circle span {
  position: absolute;
}

/* Warna circle ikut leave type */
.circle-annual svg path {
  stroke: MediumSeaGreen;
}

.circle-medical svg path {
  stroke: Tomato;
}

.circle-emergency svg path {
  stroke: DodgerBlue;
}

.circle-maternity svg path {
  stroke: Orchid;
}

/* ===== Leave Circle Colors ===== */
.circle-annual { border-color: MediumSeaGreen; }
.circle-medical { border-color: Tomato; }
.circle-emergency { border-color: DodgerBlue; }
.circle-maternity { border-color: Orchid; }

.circle-annual span { color: MediumSeaGreen; }
.circle-medical span { color: Tomato; }
.circle-emergency span { color: DodgerBlue; }
.circle-maternity span { color: Orchid; }

/* Optional hover glow */
.circle:hover {
  transform: scale(1.05);
  transition: 0.2s ease;
}




/* ===== Chart Section ===== */
.chart-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 20px;
}

.chart-box {
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
}

.chart-placeholder {
  height: 120px;
  border: 2px dashed #ccc;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  color: #777;
  margin-top: 8px;
}

/* ===== Leave Panels ===== */
.leave-panel {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-top: 20px;
}

.panel-box {
  flex: 1;
  min-width: 260px;
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
}

.approval-list {
  width: 100%;
  border-left-width: 4px;
  border-left-style: solid;
  padding: 10px 15px;
  margin-bottom: 10px;
  background: #fafafa;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
}

/* ===== Calendar ===== */
.calendar-box {
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
  margin-top: 24px;
}

.calendar-box input {
  padding: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
  margin-top: 8px;
  width: fit-content;
}

/* ===== Responsive Leave Section ===== */
@media (max-width: 900px) {
  .leave-grid { grid-template-columns: repeat(2, 1fr); }
  .chart-grid { grid-template-columns: 1fr; }
}

@media (max-width: 600px) {
  .leave-grid { grid-template-columns: 1fr; }
}

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
      <a href="dashboard.jsp" class="active"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
      <a href="employees.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
      <a href="policies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
      <a href="reports.jsp"><i class="fas fa-clipboard"></i><span>Reports</span></a>

      <div class="menu-group">
        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
        <div class="submenu">
          <a href="profile.jsp"><i class="fas fa-id-badge"></i><span>Profile</span></a>
          <a href="apply_leave.jsp"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
          <a href="leave_history_staff.jsp"><i class="fas fa-history"></i><span>Leave History</span></a>
        </div>
      </div>

      <a href="notifications.jsp"><i class="fas fa-bell"></i><span>Notifications</span></a>
      <a href="LogoutServlet"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
    </div>
  </div>
    
<div class="main">
  <div class="main-content">

    <div class="header">Admin Dashboard</div>

    <!-- Live Clock -->
    <div class="card" style="font-size:20px;font-weight:bold;margin-bottom:15px;text-align:center;">
      <i class="fas fa-clock"></i>
      <span id="liveClock"></span>
    </div>

    <!-- Leave Types Circles (fetch dari DB) -->
    <div class="leave-grid">
      <%
        int[] balances = (int[]) request.getAttribute("leaveBalanceList");
        String[] types = {"Maternity","Annual","Emergency","Medical"};

        if (balances != null) {
            for (int i = 0; i < types.length; i++) {
                String c = "";
                if ("Annual".equals(types[i])) {
                    c = "circle-annual";
                } else if ("Medical".equals(types[i])) {
                    c = "circle-medical";
                } else if ("Emergency".equals(types[i])) {
                    c = "circle-emergency";
                } else if ("Maternity".equals(types[i])) {
                    c = "circle-maternity";
                }
      %>
        <div class="card">
          <div class="circle <%= c %>">
            <span><%= balances[i] %></span>
          </div>
          <p><%= types[i] %></p>
          <small><%= balances[i] %> days left</small>
        </div>
      <%
            }
        } else {
      %>
        <div>No leave balance data.</div>
      <% } %>
    </div>

    <!-- People On Leave & Upcoming Leave -->
    <div class="leave-panel">
      <div class="panel-box">
        <h4>People On Leave</h4>
        <%
          List<String> on = (List<String>) request.getAttribute("peopleOnLeave");
          if (on != null && !on.isEmpty()) {
              for (String x : on) {
        %>
            <div class="approval-list"><%= x %></div>
        <%
              }
          } else {
        %>
            <div>No one is on leave today.</div>
        <% } %>

      </div>

      <div class="panel-box">
        <h4>Upcoming Leave</h4>
        <%
          List<String> up = (List<String>) request.getAttribute("upcomingLeave");
          if (up != null && !up.isEmpty()) {
              for (String x : up) {
        %>
            <div class="approval-list"><%= x %></div>
        <%
              }
          } else {
        %>
            <div>No upcoming leave records.</div>
        <% } %>

      </div>
    </div>

    <!-- Charts -->
    <div class="chart-grid">
      <div class="chart-box">
        <p><b>Weekly Leave Pattern</b></p>
        <canvas id="weeklyChart"></canvas>
      </div>
      <div class="chart-box">
        <p><b>Monthly Leave Pattern</b></p>
        <canvas id="monthlyChart"></canvas>
      </div>
    </div>

    <!-- Calendar -->
    <div class="calendar-box">
      <h4>Leave Calendar</h4>
      <input type="month">
      <div class="chart-placeholder">Calendar view here</div>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const monthly = <%= request.getAttribute("monthlyCount") != null 
    ? Arrays.toString((int[])request.getAttribute("monthlyCount")) 
    : "[0,0,0,0,0,0,0,0,0,0,0,0]" %>;

// Live Clock
function updateClock() {
  const now = new Date();
  document.getElementById("liveClock").innerText =
    now.toLocaleDateString() + " " + now.toLocaleTimeString();
}
setInterval(updateClock, 1000);
updateClock();

// Weekly Bar Chart
new Chart(document.getElementById('weeklyChart').getContext('2d'), {
  type: 'bar',
  data: {
    labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
    datasets: [{ data: [2,3,1,4,2,0,1] }]
  },
  options: { responsive:true, plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
});

// Monthly Line Chart
new Chart(document.getElementById('monthlyChart').getContext('2d'), {
  type: 'line',
  data: {
    labels:['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
    datasets:[{ data: monthly }]
  },
  options:{ responsive:true, plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
});
</script>





<script>
// Sidebar Toggle
document.querySelector(".toggle-btn").addEventListener("click", () => {
  document.getElementById("sidebar").classList.toggle("closed");
});

// Personal Dropdown
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
