<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.leave.model.LeaveRequest" %>

<%
    /* ===== SESSION CHECK ===== */
    Integer employeeId = (Integer) session.getAttribute("employeeId");
    if (employeeId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    /* ===== DATA FROM SERVLET ===== */
    String empName = (String) session.getAttribute("name");
    String empRole = (String) session.getAttribute("role");
    String empDept = (String) session.getAttribute("department");
    String profileImage = (String) session.getAttribute("profile_image");

    List<LeaveRequest> leaveList =
        (List<LeaveRequest>) request.getAttribute("leaves");

    Integer leaveBalance =
        (Integer) request.getAttribute("leaveBalance");

    String pendingInfo =
        (String) request.getAttribute("pendingInfo");

    List<String> absentTodayList =
        (List<String>) request.getAttribute("absentToday");

    List<String> upcomingLeaveList =
        (List<String>) request.getAttribute("upcomingLeave");

  
%>

<%
    Map calendarLeaves =
        (Map) request.getAttribute("calendarLeaves");
%>

<%
    Map leaveBalanceByType =
        (Map) request.getAttribute("leaveBalanceByType");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Staff Dashboard</title>
<link rel="stylesheet"
 href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">


<style>
* { box-sizing: border-box; font-family: "Segoe UI", sans-serif; }
body { margin: 0; background: #f2f2f2; overflow: auto; }

.wrapper { display: flex; height: 100vh; }

* {
  box-sizing: border-box;
  font-family: "Poppins", sans-serif;
}

.sidebar {
  width: 260px;
  background: #e0e0e0;
  padding: 15px;
  transition: width 0.3s ease;
  overflow: auto;
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

.card {
  background: #fff;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
  text-align: center;
  font-weight: 600;
}

/* ===== MAIN ===== */
.main {
  flex: 1;
  padding: 18px;
  display: flex;
  flex-direction: column;
  overflow-x: hidden;   
  overflow-y: auto;  
}

.header {
  background: linear-gradient(to right, #bdbdbd, #eeeeee);
  padding: 14px;
  font-size: 26px;
  font-weight: bold;
  margin-bottom: 12px;
}

/* ===== STATUS CARDS ===== 
.cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 12px;
}
.card {
  background: white;
  padding: 14px;
  border-radius: 8px;
  text-align: center;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.05);
}
.card h3 { margin: 6px 0 0; font-size: 22px; }*/

/* ===== Dashboard Cards ===== */
.cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 12px;
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

/* ===== INFO ROW ===== */
.info-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 12px;
}
.section {
  background: white;
  padding: 14px;
  border-radius: 8px;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.05);
}
.section h4 { margin: 0 0 10px; font-size: 16px; }

/* ===== CALENDAR ===== */
.calendar {
  background: white;
  padding: 14px;
  border-radius: 8px;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.05);
  flex: 1;
  width: 100%;       
  min-width: 0;       
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  margin-bottom: 10px;
}

.calendar-header button {
  background: #d0d0d0;
  border: none;
  padding: 6px 10px;
  border-radius: 6px;
  cursor: pointer;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 6px;
}

.day-name {
  text-align: center;
  font-weight: 700;
  font-size: 13px;
  color: #555;
}

.date {
  background: #eeeeee;
  border-radius: 6px;
  padding: 6px;
  height: 72px;
  font-size: 12px;
}

.date strong { font-size: 13px; }

.date.today { background: #c8e6c9; }

.leave-text {
  margin-top: 4px;
  font-size: 11px;
  font-weight: 600;
  color: #b71c1c;
}
</style>
</head>

<body>
<div class="wrapper">

<!-- ================= SIDEBAR ================= -->
<div class="sidebar" id="sidebar">
    <div class="brand">
        <span>TERLAJAK LARIS</span>
        <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
    </div>

    <div class="profile">
        <img src="<%= profileImage != null ? profileImage : "https://i.imgur.com/7k12EPD.png" %>">
        <h4><%= empName %></h4>
        <p><%= empRole %> <%= empDept != null ? empDept : "" %></p>
    </div>

    <div class="menu">
        <a href="<%= request.getContextPath()%>/DashboardStaffServlet" class="active"><i class="fas fa-th-large"></i>Dashboard</a>
        <a  href="<%= request.getContextPath()%>/ViewProfileServlet"><i class="fas fa-user"></i>Profile</a>
        <a href="<%= request.getContextPath()%>/staff/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
        <a href="<%= request.getContextPath()%>/LeaveHistoryStaffServlet"><i class="fas fa-history"></i>Leave History</a>
        <a href="<%= request.getContextPath()%>/NotificationServlet"><i class="fas fa-bell"></i>Notifications</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">
            <i class="fas fa-sign-out-alt"></i>Logout
        </a>
    </div>
</div>

<!-- ================= MAIN ================= -->
<div class="main">

<div class="header">Staff Dashboard</div>
 <!-- Live Clock -->
    <div class="card" style="font-size:20px;font-weight:bold;margin-bottom:15px;text-align:center;">
      <i class="fas fa-clock"></i>
      <span id="liveClock"></span>
    </div>

<!-- STATUS CARDS -->
<div class="cards">
    <div class="card-item">
        <i class="fas fa-calendar-day"></i><br>
        Status Today
        <h3><%= request.getAttribute("statusToday") %></h3>
    </div>

    <div class="card-item">
        <i class="fas fa-users"></i><br>
        Leave Balance
        <h3 style="font-size:14px; text-align:left;">
        <%
            if (leaveBalanceByType != null && !leaveBalanceByType.isEmpty()) {
                Iterator it = leaveBalanceByType.entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry e = (Map.Entry) it.next();
        %>
            <div>
                <strong><%= e.getKey() %></strong> :
                <%= e.getValue() %> days
            </div>
        <%
                }
            } else {
        %>
            0 days
        <%
            }
        %>
        </h3>
    </div>

    <div class="card-item">
        <i class="fas fa-clock"></i><br>
        Pending Apply Leave
        <h3 style="font-size:14px;">
            <%= pendingInfo != null ? pendingInfo : "No pending leave" %>
        </h3>
    </div>
</div>

<!-- INFO ROW -->
<div class="info-row">
    <div class="section">
        <h4>Absent Today</h4>
        <% if (absentTodayList != null && !absentTodayList.isEmpty()) {
               for (String s : absentTodayList) { %>
            <p><%= s %></p>
        <% } } else { %>
            <p>No absent today</p>
        <% } %>
    </div>

   <div class="section">
    <h4>Upcoming Leave</h4>

    <%
        if (upcomingLeaveList != null && !upcomingLeaveList.isEmpty()) {
            for (String s : upcomingLeaveList) {
    %>
                <p><%= s %></p>
    <%
            }
        } else {
    %>
            <p>No upcoming leave</p>
    <%
        }
    %>
</div>

</div>

<!-- CALENDAR -->
<div class="calendar">
    <div class="calendar-header">
        <button onclick="changeMonth(-1)">◀</button>
        <div id="monthYear"></div>
        <button onclick="changeMonth(1)">▶</button>
    </div>
    <div class="calendar-grid" id="calendar"></div>
</div>

</div> 
</div> 

<script>
    // Live Clock
function updateClock() {
  const now = new Date();
  document.getElementById("liveClock").innerText =
    now.toLocaleDateString() + " " + now.toLocaleTimeString();
}
setInterval(updateClock, 1000);
updateClock();

function toggleSidebar() {
  document.getElementById("sidebar").classList.toggle("closed");
}

var calendar = document.getElementById("calendar");
var monthYear = document.getElementById("monthYear");

/* ===== LEAVE DATA FROM SERVER ===== */
var leaveData = {
<%
    if (calendarLeaves != null) {
        Iterator it = calendarLeaves.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String date = (String) entry.getKey();
            List list = (List) entry.getValue();
%>
"<%= date %>": [
<%
            for (int i = 0; i < list.size(); i++) {
%>
"<%= list.get(i) %>"<%= (i < list.size()-1) ? "," : "" %>
<%
            }
%>
]<%= it.hasNext() ? "," : "" %>
<%
        }
    }
%>
};

var currentDate = new Date();

function renderCalendar() {
  calendar.innerHTML = "";

  var year = currentDate.getFullYear();
  var month = currentDate.getMonth();

  monthYear.innerHTML =
    currentDate.toLocaleString("default", { month: "long" }) +
    " " + year;

  var days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
  for (var i=0;i<days.length;i++){
    var d=document.createElement("div");
    d.className="day-name";
    d.innerHTML=days[i];
    calendar.appendChild(d);
  }

  var firstDay = new Date(year, month, 1).getDay() || 7;
  for (var i=1;i<firstDay;i++){
    calendar.appendChild(document.createElement("div"));
  }

  var totalDays = new Date(year, month+1, 0).getDate();

  for (var d=1; d<=totalDays; d++){
    var box=document.createElement("div");
    box.className="date";
    box.innerHTML="<strong>"+d+"</strong>";

    var key =
      year+"-"+(month+1<10?"0":"")+(month+1)+"-"+(d<10?"0":"")+d;

    var today=new Date();
    if (d===today.getDate() &&
        month===today.getMonth() &&
        year===today.getFullYear()){
      box.className+=" today";
    }

    if (leaveData[key]){
      for (var i=0;i<leaveData[key].length;i++){
        var l=document.createElement("div");
        l.className="leave-text";
        l.innerHTML=leaveData[key][i];
        box.appendChild(l);
      }
    }

    calendar.appendChild(box);
  }
}

function changeMonth(step){
  currentDate.setMonth(currentDate.getMonth()+step);
  renderCalendar();
}

renderCalendar();
</script>




</body>
</html>
