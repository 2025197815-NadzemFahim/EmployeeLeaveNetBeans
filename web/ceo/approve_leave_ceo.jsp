<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is CEO
    HttpSession userSession = request.getSession(false);
    if (userSession == null || !"CEO".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    List<Map<String, String>> leaveRequests = new ArrayList<>();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        conn = DriverManager.getConnection(
            "jdbc:derby://localhost:1527/LeaveDB", "app", "app");

        // Get leave requests that need CEO approval (PENDING_CEO) and all others for view
        String query = "SELECT lr.request_id, e.name, e.department, e.position, " +
                      "lt.name AS leave_type, lr.start_date, lr.end_date, " +
                      "lr.status, lr.submitted_date, e.employee_id, " +
                      "hod.name AS hod_name, lr.hod_approved_date " +
                      "FROM leave_request lr " +
                      "JOIN employee e ON lr.submitted_by = e.employee_id " +
                      "JOIN leave_type lt ON lr.type_id = lt.type_id " +
                      "JOIN employee hod ON lr.approved_by = hod.employee_id " +
                      "WHERE lr.status IN ('PENDING_CEO', 'APPROVED', 'REJECTED') " +
                      "AND (e.department IN ('Management', 'Executive') OR lr.status = 'PENDING_CEO') " +
                      "ORDER BY CASE WHEN lr.status = 'PENDING_CEO' THEN 0 ELSE 1 END, " +
                      "lr.submitted_date DESC";

        ps = conn.prepareStatement(query);
        rs = ps.executeQuery();

        SimpleDateFormat displayFormat = new SimpleDateFormat("dd-MM-yyyy");
        SimpleDateFormat timestampFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");

        while (rs.next()) {
            Map<String, String> leaveRequestMap = new HashMap<>();
            leaveRequestMap.put("requestId", "L" + String.format("%04d", rs.getInt("request_id")));
            leaveRequestMap.put("employeeName", rs.getString("name"));
            leaveRequestMap.put("employeeId", rs.getString("employee_id"));
            leaveRequestMap.put("department", rs.getString("department"));
            leaveRequestMap.put("position", rs.getString("position"));
            leaveRequestMap.put("leaveType", rs.getString("leave_type"));
            leaveRequestMap.put("startDate", displayFormat.format(rs.getDate("start_date")));
            leaveRequestMap.put("endDate", displayFormat.format(rs.getDate("end_date")));
            leaveRequestMap.put("status", rs.getString("status"));
            leaveRequestMap.put("submittedDate", timestampFormat.format(rs.getTimestamp("submitted_date")));
            leaveRequestMap.put("hodName", rs.getString("hod_name"));

            java.util.Date hodApprovedDate = rs.getTimestamp("hod_approved_date");
            if (hodApprovedDate != null) {
                leaveRequestMap.put("hodApprovedDate", timestampFormat.format(hodApprovedDate));
            } else {
                leaveRequestMap.put("hodApprovedDate", "N/A");
            }

            leaveRequests.add(leaveRequestMap);
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
<title>Approve / Reject Leave - CEO</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* ===== Use your CSS from previous code ===== */
* { box-sizing: border-box; font-family: "Segoe UI", sans-serif; }
body { margin: 0; background: #f2f2f2; }
.wrapper { display: flex; min-height: 100vh; }
.sidebar { width: 260px; background: #e0e0e0; padding: 15px; transition: width 0.3s ease; }
.sidebar.closed { width: 60px; }
.brand { display: flex; justify-content: space-between; align-items: center; font-weight: bold; margin-bottom: 20px; }
.sidebar.closed .brand span:first-child { display: none; }
.profile { text-align: center; margin-bottom: 25px; transition: opacity 0.3s ease; }
.sidebar.closed .profile { opacity: 0; pointer-events: none; }
.profile img { width: 70px; height: 70px; border-radius: 50%; object-fit: cover; background: #ccc; margin-bottom: 10px; }
.profile h4 { margin: 5px 0 0; font-size: 14px; }
.profile p { margin: 0; font-size: 12px; color: #555; }
.menu a { display: flex; align-items: center; padding: 12px; margin-bottom: 6px; text-decoration: none; color: #000; border-radius: 6px; font-size: 14px; gap: 12px; }
.menu a i { width: 20px; text-align: center; font-size: 16px; }
.menu a:hover { background: #cfcfcf; }
.menu a.active { background: #bdbdbd; font-weight: bold; }
.sidebar.closed .menu a { justify-content: center; padding-left: 0; padding-right: 0; font-size: 0; gap: 0; }
.sidebar.closed .menu a i { font-size: 18px; width: auto; }
.main { flex: 1; padding: 20px; }
.header { background: linear-gradient(to right, #2196F3, #64B5F6); padding: 18px; font-size: 32px; font-weight: bold; margin-bottom: 20px; color: #ffffff; }
.top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px; }
.search { padding: 8px 12px; border-radius: 6px; border: 1px solid #ccc; width: 250px; font-size: 13px; }
.filter-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
.filter-btn { padding: 6px 12px; border-radius: 6px; border: 1px solid #ccc; background: white; cursor: pointer; font-size: 13px; }
.filter-btn.active { background: #2196F3; color: white; border-color: #1976D2; }
.filter-btn:hover { background: #e3f2fd; }
.card { background: white; padding: 20px; border-radius: 8px; overflow-x: auto; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
table { width: 100%; border-collapse: collapse; min-width: 900px; }
th, td { padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0; }
th { color: black; font-weight: 600; background: #f5f5f5; position: sticky; top: 0; }
td { color: #555; font-weight: 500; }
tbody tr:hover { background: #f8f9fa; }
.status-approved { color: #00c853; font-weight: bold; }
.status-rejected { color: #ff1744; font-weight: bold; }
.status-pending { color: #ffab00; font-weight: bold; }
.status-pending-ceo { color: #2196F3; font-weight: bold; background: #e3f2fd; padding: 4px 8px; border-radius: 4px; }
.btn-view { padding: 6px 14px; border-radius: 6px; background: #2196F3; color: white; font-weight: 600; text-decoration: none; display: inline-block; border: none; cursor: pointer; font-size: 13px; transition: background 0.3s; }
.btn-view:hover { background: #1976D2; }
.priority-badge { display: inline-block; padding: 2px 8px; background: #ff5722; color: white; border-radius: 12px; font-size: 11px; font-weight: bold; margin-left: 5px; }
.no-data { text-align: center; padding: 50px; color: #666; font-style: italic; }
.no-data i { font-size: 48px; margin-bottom: 15px; color: #bdbdbd; }
.message { padding: 12px 15px; margin-bottom: 15px; border-radius: 6px; font-weight: 500; }
.message.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
.message.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
.stats-summary { display: flex; gap: 15px; margin-bottom: 20px; flex-wrap: wrap; }
.stat-box { flex: 1; min-width: 150px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); text-align: center; }
.stat-box.pending { border-top: 4px solid #ffab00; }
.stat-box.approved { border-top: 4px solid #00c853; }
.stat-box.rejected { border-top: 4px solid #ff1744; }
.stat-box.total { border-top: 4px solid #2196F3; }
.stat-number { font-size: 28px; font-weight: bold; margin: 10px 0; }
.stat-label { font-size: 14px; color: #666; }
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
      <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "AHMAD BADRUL BIN SAIFUL" %></h4>
      <p>CEO</p>
    </div>

    <div class="menu">
      <a href="dashboard_ceo.jsp"><i class="fas fa-th-large"></i>Dashboard</a>
      <a href="profile_ceo.jsp"><i class="fas fa-user"></i>Profile</a>
      <a class="active" href="approve_leave_ceo.jsp"><i class="fas fa-clipboard-list"></i>Requests</a>
      <a href="notifications_ceo.jsp"><i class="fas fa-bell"></i>Notifications</a>
      <a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
    </div>
  </div>

  <div class="main">
    <div class="header">Approve/Reject Leave - CEO</div>

    <% if (request.getParameter("success") != null) { %>
    <div class="message success">
      <i class="fas fa-check-circle"></i> Leave request has been processed successfully!
    </div>
    <% } %>

    <% if (request.getParameter("error") != null) { %>
    <div class="message error">
      <i class="fas fa-exclamation-circle"></i> Error: <%= request.getParameter("error") %>
    </div>
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
    <div class="message error">
      <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <%
        int pendingCount = 0;
        int approvedCount = 0;
        int rejectedCount = 0;
        for (Map<String, String> leaveRequestMap : leaveRequests) {
            String status = leaveRequestMap.get("status");
            if ("PENDING_CEO".equals(status)) pendingCount++;
            else if ("APPROVED".equals(status)) approvedCount++;
            else if ("REJECTED".equals(status)) rejectedCount++;
        }
    %>

    <div class="stats-summary">
      <div class="stat-box total">
        <div class="stat-number"><%= leaveRequests.size() %></div>
        <div class="stat-label">Total Requests</div>
      </div>
      <div class="stat-box pending">
        <div class="stat-number"><%= pendingCount %></div>
        <div class="stat-label">Pending CEO Approval</div>
      </div>
      <div class="stat-box approved">
        <div class="stat-number"><%= approvedCount %></div>
        <div class="stat-label">Approved</div>
      </div>
      <div class="stat-box rejected">
        <div class="stat-number"><%= rejectedCount %></div>
        <div class="stat-label">Rejected</div>
      </div>
    </div>

    <div class="top-bar">
      <div class="filter-buttons">
        <button class="filter-btn active" onclick="filterTable('all')">All Requests</button>
        <button class="filter-btn" onclick="filterTable('PENDING_CEO')">
          Pending CEO <span class="priority-badge"><%= pendingCount %></span>
        </button>
        <button class="filter-btn" onclick="filterTable('APPROVED')">Approved</button>
        <button class="filter-btn" onclick="filterTable('REJECTED')">Rejected</button>
        <button class="filter-btn" onclick="filterTable('Management')">Management Dept</button>
        <button class="filter-btn" onclick="filterTable('Executive')">Executive Dept</button>
      </div>
      <input type="text" class="search" placeholder="Search requests..." id="searchInput" onkeyup="searchTable()">
    </div>

    <div class="card">
      <% if (leaveRequests.isEmpty()) { %>
      <div class="no-data">
        <i class="fas fa-clipboard-check"></i>
        <h3>No Leave Requests Found</h3>
        <p>There are no leave requests requiring your attention.</p>
      </div>
      <% } else { %>
      <table id="leaveTable">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Employee</th>
            <th>Department</th>
            <th>Leave Type</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>HOD Approved</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% for (Map<String, String> leaveRequestMap : leaveRequests) {
              String status = leaveRequestMap.get("status");
              String statusClass = "status-" + status.toLowerCase();
              if ("PENDING_CEO".equals(status)) {
                  statusClass = "status-pending-ceo";
              }
          %>
          <tr data-status="<%= status %>" data-department="<%= leaveRequestMap.get("department") %>">
            <td><strong><%= leaveRequestMap.get("requestId") %></strong></td>
            <td>
              <div><strong><%= leaveRequestMap.get("employeeName") %></strong></div>
              <div style="font-size: 12px; color: #777;"><%= leaveRequestMap.get("position") %></div>
            </td>
            <td><%= leaveRequestMap.get("department") %></td>
            <td><%= leaveRequestMap.get("leaveType") %></td>
            <td><%= leaveRequestMap.get("startDate") %></td>
            <td><%= leaveRequestMap.get("endDate") %></td>
            <td>
              <div><%= leaveRequestMap.get("hodName") %></div>
              <div style="font-size: 11px; color: #666;"><%= leaveRequestMap.get("hodApprovedDate") %></div>
            </td>
            <td class="<%= statusClass %>">
              <%= "PENDING_CEO".equals(status) ? "Pending CEO" : status %>
            </td>
            <td>
              <a href="approve_leave_details_ceo.jsp?requestId=<%= leaveRequestMap.get("requestId").substring(1) %>" class="btn-view">
                <i class="fas fa-eye"></i> View
              </a>
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

function searchTable() {
  const input = document.getElementById("searchInput").value.toLowerCase();
  const table = document.getElementById("leaveTable");
  if (!table) return;
  
  const trs = table.tBodies[0].getElementsByTagName("tr");
  for (let i = 0; i < trs.length; i++) {
    let found = false;
    const tds = trs[i].getElementsByTagName("td");
    for (let j = 0; j < tds.length - 1; j++) {
      if (tds[j].textContent.toLowerCase().includes(input)) {
        found = true;
        break;
      }
    }
    trs[i].style.display = found ? "" : "none";
  }
}

function filterTable(filter) {
  const table = document.getElementById("leaveTable");
  if (!table) return;
  
  const trs = table.tBodies[0].getElementsByTagName("tr");
  const filterButtons = document.querySelectorAll('.filter-btn');
  filterButtons.forEach(btn => {
    btn.classList.remove('active');
    const btnText = btn.textContent.replace(/\s*\d+/, '').trim();
    if ((filter === 'all' && btnText === 'All Requests') ||
        (filter === 'PENDING_CEO' && btnText === 'Pending CEO') ||
        (filter === 'APPROVED' && btnText === 'Approved') ||
        (filter === 'REJECTED' && btnText === 'Rejected') ||
        (filter === 'Management' && btnText === 'Management Dept') ||
        (filter === 'Executive' && btnText === 'Executive Dept')) {
      btn.classList.add('active');
    }
  });
  
  for (let i = 0; i < trs.length; i++) {
    const rowStatus = trs[i].getAttribute('data-status');
    const rowDept = trs[i].getAttribute('data-department');
    let showRow = false;
    if (filter === 'all') showRow = true;
    else if (filter === rowStatus) showRow = true;
    else if (filter === rowDept) showRow = true;
    trs[i].style.display = showRow ? "" : "none";
  }
}

setTimeout(() => { window.location.reload(); }, 45000);

document.addEventListener('DOMContentLoaded', function() {
  const rows = document.querySelectorAll('#leaveTable tbody tr');
  rows.forEach(row => {
    const status = row.getAttribute('data-status');
    if (status === 'PENDING_CEO') {
      row.style.animation = 'pulse 2s infinite';
    }
  });
});

const style = document.createElement('style');
style.textContent = `
  @keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(33, 150, 243, 0.4); }
    70% { box-shadow: 0 0 0 5px rgba(33, 150, 243, 0); }
    100% { box-shadow: 0 0 0 0 rgba(33, 150, 243, 0); }
  }
`;
document.head.appendChild(style);
</script>

</body>
</html>
