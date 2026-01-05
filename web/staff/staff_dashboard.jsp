<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>

<%
    /* ================= SESSION CHECK ================= */
    Integer employeeId = (Integer) session.getAttribute("employeeId");
    if (employeeId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    /* ================= SESSION DATA ================= */
    String empName = (String) session.getAttribute("name");
    String empRole = (String) session.getAttribute("role");
    String empDept = (String) session.getAttribute("department");
    String profileImage = (String) session.getAttribute("profile_image");

    /* ================= DATA FROM SERVLET ================= */
    String statusToday = (String) request.getAttribute("statusToday");
    Map leaveBalanceByType = (Map) request.getAttribute("leaveBalanceByType");
    String pendingInfo = (String) request.getAttribute("pendingInfo");
    List absentToday = (List) request.getAttribute("absentToday");
    List upcomingLeave = (List) request.getAttribute("upcomingLeave");
    Map calendarLeaves = (Map) request.getAttribute("calendarLeaves");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Staff Dashboard</title>

<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">

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

/* ===== MAIN ===== */
.main {
  flex: 1;
  padding: 18px;
}

.header {
  background: linear-gradient(to right, #bdbdbd, #eeeeee);
  padding: 14px;
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 14px;
}

/* ========= CARD ========= */
.card {
  background:#fff;
  border-radius:16px;
  padding:16px;
  border:1px solid #eef0f4;
  box-shadow:0 4px 12px rgba(0,0,0,.04);
}

/* ========= GRID ========= */
.dashboard-grid{
  display:grid;
  grid-template-columns:3fr 1.5fr;
  grid-template-areas:
    "myleave calendar"
    "pending calendar"
    "absent upcoming";
  gap:12px;
}
.my-leave{grid-area:myleave;}
.pending{grid-area:pending;}
.absent{grid-area:absent;}
.upcoming{grid-area:upcoming;}
.calendar{grid-area:calendar;}

/* ========= MY LEAVE ========= */
.leave-cards{
  display:grid;
  grid-template-columns:repeat(4,1fr);
  gap:10px;
}
.leave-box{
  padding:14px;
  border-radius:12px;
  text-align:center;
}
.leave-box h2{margin:0;font-size:20px;}
.leave-box p{margin:4px 0 0;font-size:12px;}
.annual{background:#f3f7ff;}
.medical{background:#fff4eb;}
.casual{background:#eef9f8;}
.unpaid{background:#eef7ef;}

/* ========= TABLE ========= */
table{width:100%;border-collapse:collapse;}
th,td{padding:10px;text-align:center;font-size:13px;}
th{color:#6b7280;border-bottom:1px solid #eef0f4;}
td{border-bottom:1px solid #f1f3f7;}
.status{padding:4px 10px;border-radius:999px;font-size:11px;font-weight:600;}
.pending-tag{background:#fff3cd;color:#856404;}

/* ========= INFO ========= */
.badge{
  display:inline-block;
  background:#fee2e2;
  color:#b91c1c;
  padding:4px 10px;
  border-radius:999px;
  font-size:12px;
  font-weight:600;
}
.no-data{
  background:#f8fafc;
  padding:10px;
  border-radius:10px;
  font-size:13px;
  color:#6b7280;
}

/* ========= CALENDAR ========= */
.calendar-header{
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:8px;
}
.calendar-grid{
  display:grid;
  grid-template-columns:repeat(7,1fr);
  gap:4px;
}
.day-name{text-align:center;font-size:11px;font-weight:600;}
.date{
  background:#eeeeee;
  border-radius:6px;
  padding:4px;
  font-size:11px;
  min-height:54px;
}
.date.today{background:#c8e6c9;}
.leave-text{
  font-size:10px;
  font-weight:600;
  color:#b71c1c;
}
</style>
</head>

<body>
<div class="wrapper">
     <!-- Sidebar -->
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
                </div>

                <div class="profile">
                    <img src="<%= request.getContextPath()%>/profile-image?path=<%= request.getAttribute("profileImg")%>"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
                    <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Staff User"%></h4>
                    <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : session.getAttribute("role")%></p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/DashboardStaffServlet" class="active"><i class="fas fa-th-large"></i>Dashboard</a>
                    <a href="<%= request.getContextPath()%>/ViewProfileServlet"><i class="fas fa-user"></i>Profile</a>
                    <a  href="<%= request.getContextPath()%>/staff/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
                    <a href="<%= request.getContextPath()%>/LeaveHistoryStaffServlet" ><i class="fas fa-history"></i>Leave History</a>
                    <a href="<%= request.getContextPath()%>/NotificationServlet"><i class="fas fa-bell"></i>Notifications</a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>


<!-- ================= MAIN ================= -->
<div class="main">


<div class="dashboard-grid">

<!-- ================= MY LEAVE ================= -->
    <div class="card my-leave">
        <h3>My Leave</h3>
        <div class="leave-cards">
            <%
            if(leaveBalanceByType!=null){
              for(Object o:leaveBalanceByType.entrySet()){
                Map.Entry e=(Map.Entry)o;
            %>
            <div class="leave-box annual">
                <h2><%=e.getValue()%></h2>
                <p><%=e.getKey()%></p>
            </div>
        <%}}%>
        </div>
    </div>

<!-- ================= CALENDAR ================= -->
    <div class="card calendar">
        <div class="calendar-header">
            <button onclick="changeMonth(-1)">◀</button>
            <strong id="monthYear"></strong>
            <button onclick="changeMonth(1)">▶</button>
        </div>
        <div class="calendar-grid" id="calendar"></div>
    </div>

<!-- ================= PENDING ================= -->
    <div class="card pending">
        <h3>Pending Apply Leave</h3>
        <%= pendingInfo!=null ? pendingInfo : "<div class='no-data'>No pending leave</div>" %>
    </div>

<!-- ================= ABSENT ================= -->
    <div class="card absent">
        <h3>Absent Today</h3>
            <%
            if(absentToday!=null && !absentToday.isEmpty()){
            for(Object o:absentToday){
            %>
            <div><%=o%></div>
                <%}}else{%>
             <div class="no-data">No absent today</div>
            <%}%>
    </div>

<!-- ================= UPCOMING ================= -->
    <div class="card upcoming">
        <h3>Upcoming Leave</h3>
            <%
                if(upcomingLeave!=null && !upcomingLeave.isEmpty()){
                    for(Object o:upcomingLeave){
            %>
                <div><%=o%></div>
                <%}}else{%>
                <div class="no-data">No upcoming leave</div>
                <%}%>
    </div>

</div>
</div>
</div>

<script>
/* ========= CALENDAR ========= */
var calendarData = {
<%
    if (calendarLeaves != null) {
        Iterator it = calendarLeaves.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
%>
    "<%= e.getKey() %>": [
<%
            List l = (List) e.getValue();
            for (int i = 0; i < l.size(); i++) {
%>
        "<%= l.get(i) %>"<%= (i < l.size() - 1) ? "," : "" %>
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

    var year  = currentDate.getFullYear();
    var month = currentDate.getMonth();

    monthYear.innerText = currentDate.toLocaleString("default", {
        month: "long",
        year: "numeric"
    });

    /* ===== DAY HEADER ===== */
    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].forEach(function (day) {
        var el = document.createElement("div");
        el.className = "day-name";
        el.innerText = day;
        calendar.appendChild(el);
    });

    /* ===== EMPTY SLOT BEFORE FIRST DAY ===== */
    var firstDay = new Date(year, month, 1).getDay() || 7;
    for (var i = 1; i < firstDay; i++) {
        calendar.appendChild(document.createElement("div"));
    }

    /* ===== DATES ===== */
    var totalDays = new Date(year, month + 1, 0).getDate();

    for (var d = 1; d <= totalDays; d++) {
        var box = document.createElement("div");
        box.className = "date";
        box.innerHTML = "<strong>" + d + "</strong>";

        var key =
            year + "-" +
            String(month + 1).padStart(2, "0") + "-" +
            String(d).padStart(2, "0");

        /* ===== LEAVE INFO ===== */
        if (calendarData[key]) {
            calendarData[key].forEach(function (text) {
                var leave = document.createElement("div");
                leave.className = "leave-text";
                leave.innerText = text;
                box.appendChild(leave);
            });
        }

        calendar.appendChild(box);
    }
}

function changeMonth(step) {
    currentDate.setMonth(currentDate.getMonth() + step);
    renderCalendar();
}

/* ===== INIT ===== */
renderCalendar();
</script>


</body>
</html>
