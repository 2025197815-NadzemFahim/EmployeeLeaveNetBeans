<%@page import="java.sql.*, java.util.*, javax.servlet.http.*"%>
<%@page import="com.leave.model.LeaveHistory"%>
<%@page import="java.util.Arrays"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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

/* ===== Sidebar (KEKAL — untouched logic) ===== */
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

/* ===== Main Content (KEKAL logic) ===== */
.main {
  flex: 1;
  padding: 20px;
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

/* ===== Leave Cards Section (UPDATED — 4 per row, DB fetch ready) ===== */
.leave-container {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  justify-content: start;
  margin-top: 25px;
}

.leave-card {
  width: 23%;
  min-width: 200px;
  background: white;
  border-radius: 12px;
  padding: 9px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  position: relative;
  font-size: 14px;
}

.leave-card h3 {
  margin-top: 0;
  font-size: 18px;
}

.circle-indicator {
  width: 15px;
  height: 15px;
  border-radius: 50%;
  position: absolute;
  top: 15px;
  right: 15px;
}

/* ===== Chart Section (untouched) ===== */
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

/* ===== Leave Panels (untouched) ===== */
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

/* ===== Calendar (untouched) ===== */
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

/*--- live clock ---*/
.card {
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
  text-align: center;
  font-weight: 600;
}

/* ===== Responsive (untouched) ===== */
@media (max-width: 900px) {
  .leave-grid { grid-template-columns: repeat(2, 1fr); }
  .chart-grid { grid-template-columns: 1fr; }
}

@media (max-width: 600px) {
  .leave-grid { grid-template-columns: 1fr; }
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

  <!-- ===== Sidebar (KEKAL) ===== -->
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
      <a href="<%= request.getContextPath()%>/AdminDashboardServlet" class="active"><i class="fas fa-th-large"></i><span>Dashboard</span></a>    
      <a href="employees.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
      <a href="policies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
      <a href="<%= request.getContextPath()%>/GenerateRecord"><i class="fas fa-th-large"></i>Reports</a>

      <div class="menu-group">
        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
        <div class="submenu">
          <a href="<%= request.getContextPath()%>/ViewProfileAdminServlet"><i class="fas fa-id-badge"></i><span>Profile</span></a>
          <a href="<%= request.getContextPath()%>/admin/apply_leave.jsp"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
          <a href="<%= request.getContextPath()%>/LeaveHistoryAdminServlet"><i class="fas fa-history"></i><span>Leave History</span></a>
        </div>
      </div>

      <a href="<%= request.getContextPath()%>/NotificationAdminServlet"><i class="fas fa-bell"></i><span>Notifications</span></a>
      <a href="login.jsp"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
    </div>
  </div>

  <!-- ===== Main Content ===== -->
  <div class="main">
  <div class="main-content">

    <div class="header">Admin Dashboard</div>

    <!-- Live Clock -->
    <div class="card" style="font-size:20px;font-weight:bold;margin-bottom:15px;text-align:center;">
      <i class="fas fa-clock"></i>
      <span id="liveClock"></span>
    </div>
  

  <!-- People On Leave & Upcoming Leave (kekal) -->
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
        <p><b>Weekly Leave</b></p>
        <canvas id="weeklyChart"></canvas>
      </div>
      <div class="chart-box">
        <p><b>Monthly Leave</b></p>
        <canvas id="monthlyChart"></canvas>
      </div>
  </div>
  
  
  <!-- Leave Type Cards + Balance -->
  
  <div class="leave-container">
  <%
      // safe read session int
      Integer tmp = (Integer) session.getAttribute("employeeId");
      int loggedInId = (tmp == null) ? 0 : tmp;

      List<String> colors = Arrays.asList("#4CAF50","#2196F3","#FF9800","#E91E63");

      Connection con = null;
      PreparedStatement ps = null;
      ResultSet rs = null;

      try {
          con = DriverManager.getConnection("jdbc:derby://localhost:1527/LeaveDB","app","app");
          ps = con.prepareStatement(
              "SELECT LT.TYPE_ID, LT.NAME, ELB.BALANCE " +
              "FROM LEAVE_TYPE LT " +
              "LEFT JOIN EMPLOYEE_LEAVE_BALANCE ELB " +
              "ON LT.TYPE_ID = ELB.TYPE_ID AND ELB.EMPLOYEE_ID = ? " +
              "ORDER BY LT.TYPE_ID DESC"
          );
          ps.setInt(1, loggedInId);
          rs = ps.executeQuery();

          int i = 0;
          while (rs.next()) {
              String leaveName = rs.getString("NAME");
              int balance = rs.getObject("BALANCE") == null ? 0 : rs.getInt("BALANCE");
              String color = colors.get(i % 4);
  %>
  
          <div class="leave-card">
              <div class="circle-indicator" style="background:<%=color%>"></div>
              <h3><%=leaveName%></h3>
              <p><b>Balance: <%=balance%> days</b></p>
          </div>
  <%
              i++;
          }

      } catch (Exception e) {
          out.println("<p>⚠ Error fetching leave types from database.</p>");
      } finally {
          if (rs != null) rs.close();
          if (ps != null) ps.close();
          if (con != null) con.close();
      }
  %>
  </div>

  

  </div> <!-- end main content -->

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <%
  int[] monthly = (int[]) request.getAttribute("monthlyCount");
  if (monthly == null) {
      monthly = new int[12];
  }
%>



  <script>
  // Live Clock
function updateClock() {
  const now = new Date();
  document.getElementById("liveClock").innerText =
    now.toLocaleDateString() + " " + now.toLocaleTimeString();
}
setInterval(updateClock, 1000);
updateClock();

  // weekly chart
  new Chart(document.getElementById('weeklyChart').getContext('2d'), {
    type: 'bar',
    data: {
      labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
      datasets: [{ data: [2,3,1,4,2,0,1] }]
    },
    options: { responsive:true, plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
  });

  // monthly chart
  new Chart(document.getElementById('monthlyChart').getContext('2d'), {
    type: 'line',
    data: {
      labels:['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
      datasets:[{ data: <%= Arrays.toString(monthly) %> }]
    },
    options:{ responsive:true, plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
  });
  </script>

  <script>
  // sidebar toggle
  document.querySelector(".toggle-btn").addEventListener("click", () => {
    document.getElementById("sidebar").classList.toggle("closed");
  });

  // personal dropdown
  document.querySelectorAll(".menu-group").forEach(group => {
    const parent = group.querySelector(".menu-parent");
    const submenu = group.querySelector(".submenu");
    parent.addEventListener("click", () => {
      parent.classList.toggle("open");
      submenu.classList.toggle("open");
    });
  });
  </script>

  </div>
  </div>

</body>
</html>
