<%-- 
    Document   : hod_dashboard
    Created on : Dec 27, 2025, 11:31:40 AM
    Author     : suweg
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>HOD Leave Dashboard</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

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
            /* ===== MAIN CONTENT ===== */
            /* ===== MAIN CONTENT ===== */
            .main {
                flex: 1;
                padding: 25px;
            }

            .content-wrapper {
                display: grid;
                grid-template-columns: 3fr 1.2fr;
                gap: 20px;
            }

            .content-left,
            .content-right {
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            /* Card */
            .card {
                background: #fff;
                border-radius: 14px;
                padding: 22px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.04);
            }

            .section-title {
                margin-bottom: 16px;
                font-size: 18px;
                font-weight: 600;
            }

            /* Leave cards */
            .leave-cards {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 16px;
            }

            .leave-box {
                padding: 20px;
                border-radius: 18px;
                text-align: center;
            }

            .leave-box h2 {
                margin: 0;
                font-size: 24px;
            }

            .leave-box span {
                font-size: 13px;
                color: #666;
            }

            .leave-box p {
                margin-top: 6px;
                font-size: 13px;
            }

            .leave-box:nth-child(1) { background: #f3f7ff; }
            .leave-box:nth-child(2) { background: #fff4eb; }
            .leave-box:nth-child(3) { background: #eef9f8; }
            .leave-box:nth-child(4) { background: #eef7ef; }


            /* Table */
            table {
                width: 100%;
                border-collapse: collapse;
            }

            th, td {
                padding: 14px;
                border-bottom: 1px solid #eee;
                font-size: 13px;
            }

            th {
                text-align: center;
                color: #666;
                font-weight: 500;
            }

            td {
                text-align: center;
            }

            td.days,
            td.status-col {
                text-align: center;
            }

            /* Status */
            .status {
                padding: 6px 14px;
                border-radius: 20px;
                font-size: 12px;
            }

            .pending { background: #fff3cd; color: #856404; }
            .approved { background: #d4edda; color: #155724; }
            .rejected { background: #f8d7da; color: #721c24; }

            

            /* Staff on leave */
            .leave-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .leave-list li {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 0;
                border-bottom: 1px solid #eee;
            }

            .leave-list li:last-child {
                border-bottom: none;
            }

            .badge {
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
            }

            .ongoing {
                background: #e6f4ea;
                color: #1e7e34;
            }

            /* Summary boxes */
            .summary-box {
                background: #f8faff;
                padding: 16px;
                border-radius: 12px;
                margin-bottom: 12px;
            }

            .summary-box h3 {
                margin: 0;
                font-size: 22px;
            }

            .summary-box span {
                font-size: 12px;
                color: #666;
            }

            /* Responsive */
            @media (max-width: 1024px) {
                .content-wrapper {
                    grid-template-columns: 1fr;
                }

                .leave-cards {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 480px) {
                .leave-cards {
                    grid-template-columns: 1fr;
                }
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
                    <img src="<%= request.getContextPath()%>/profile-image?path=${profileImage}"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">

                    <h4>${empName}</h4>
                    <p>${empPost}</p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/HODDashboardServlet" class="active"><i class="fas fa-th-large"></i>Dashboard</a>
      <a  href="<%= request.getContextPath()%>/ViewProfileHODServlet"><i class="fas fa-user"></i>Profile</a>
      <a href="<%= request.getContextPath()%>/hod/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
      <a href="<%= request.getContextPath()%>/LeaveListServlet"><i class="fas fa-bell"></i>Requests</a>
      <a href="<%= request.getContextPath()%>/LeaveHistoryHodServlet"><i class="fas fa-history"></i>Leave History</a>
      <a href="<%= request.getContextPath()%>/NotificationHodServlet"><i class="fas fa-bell"></i>Notifications</a>
      <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>

            <!-- ===== MAIN CONTENT ===== -->
            <div class="main">
                <div class="content-wrapper">

                    <!-- ===== LEFT CONTENT ===== -->
                    <div class="content-left">

                        <!-- My Leave -->
                        <div class="card">
                            <h3 class="section-title">My Leave</h3>

                            <div class="leave-cards">
                                <c:forEach var="l" items="${myLeaveList}">
                                    <div class="leave-box">
                                        <h2>
                                            ${l.balance}
                                            <span>/ ${l.max}</span>
                                        </h2>
                                        <p>${l.name} Leave</p>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty myLeaveList}">
                                    <p>No leave balance available</p>
                                </c:if>
                            </div>
                        </div>

                        <!-- Leave Requests -->
                        <div class="card">
                            <h3 class="section-title">Leave Requests</h3>

                            <table>
                                <thead>
                                    <tr>
                                        <th>Staff</th>
                                        <th>Type</th>
                                        <th>Start</th>
                                        <th>End</th>
                                        <th class="days">Days</th>
                                        <th class="status-col">Status</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="lr" items="${leaveRequests}">
                                        <tr onclick="location.href = 'approve_reject.jsp?requestId=${lr.id}'"
                                            style="cursor:pointer">
                                            <td>${lr.staff}</td>
                                            <td>${lr.type}</td>
                                            <td>
                                                <fmt:formatDate value="${lr.start}" pattern="yyyy-MM-dd"/>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${lr.end}" pattern="yyyy-MM-dd"/>
                                            </td>
                                            <td class="days">
                                                ${(lr.end.time - lr.start.time) / (1000*60*60*24) + 1}
                                            </td>
                                            <td class="status-col">
                                                <span class="status ${lr.status.toLowerCase()}">
                                                    ${lr.status}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>

                                    <c:if test="${empty leaveRequests}">
                                        <tr>
                                            <td colspan="6">No pending leave requests</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <!-- Staff On Leave Today -->
                        <div class="card">
                            <h3 class="section-title">Staff On Leave Today</h3>

                            <ul class="leave-list">
                                <c:forEach var="t" items="${todayLeave}">
                                    <li>
                                        <div>
                                            <strong>${t.name}</strong><br>
                                            <small>${t.type} Leave</small>
                                        </div>
                                        <span class="badge ongoing">Ongoing</span>
                                    </li>
                                </c:forEach>

                                <c:if test="${empty todayLeave}">
                                    <li>No staff on leave today</li>
                                    </c:if>
                            </ul>
                        </div>

                    </div>

                    <!-- ===== RIGHT CONTENT ===== -->
                    <div class="content-right">

                        <!-- Team Summary -->
                        <div class="card">
                            <h3 class="section-title">Team Summary</h3>

                            <div class="summary-box">
                                <h3>${pendingCount}</h3>
                                <span>Pending Requests</span>
                            </div>

                            <div class="summary-box">
                                <h3>${approvedCount}</h3>
                                <span>Approved This Month</span>
                            </div>

                            <div class="summary-box">
                                <h3>${rejectedCount}</h3>
                                <span>Rejected</span>
                            </div>
                        </div>

                        <!-- Quick Insights -->
                        <div class="card">
                            <h3 class="section-title">Quick Insights</h3>

                            <div class="summary-box">
                                <h3>${totalStaff}</h3>
                                <span>Total Staff (Department)</span>
                            </div>

                            <div class="summary-box">
                                <h3>${currentlyOnLeave}</h3>
                                <span>Currently On Leave</span>
                            </div>
                        </div>

                    </div>

                </div>
            </div>

            <script>
                function toggleSidebar() {
                    const sidebar = document.getElementById('sidebar');
                    sidebar.classList.toggle('closed');
                }
            </script>
    </body>
</html>

