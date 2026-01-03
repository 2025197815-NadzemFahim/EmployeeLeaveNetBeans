<%-- 
    Document   : notification
    Created on : Dec 28, 2025, 8:33:02 PM
    Author     : suweg
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Notifications</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Google Font -->
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            /* ===== Use your provided CSS ===== */
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


            /* ===== CONTAINER ===== */
            .container {
                padding: 20px;
                max-width: 1200px;
                margin: auto;
            }

            /* ===== HEADER ===== */
            .header {
                margin-bottom: 20px;
            }

            .header h2 {
                margin: 0;
            }

            /* ===== SUMMARY CARDS ===== */
            .cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 15px;
                margin-bottom: 20px;
            }

            .card {
                padding: 16px;
                border-radius: 12px;
                color: white;
                box-shadow: 0 6px 15px rgba(0,0,0,0.08);
            }

            .card.approved { background: #2ecc71; }
            .card.rejected { background: #e74c3c; }
            .card.unread   { background: #3498db; }

            .card h3 {
                margin: 0;
                font-size: 26px;
            }

            .card span {
                font-size: 14px;
                opacity: 0.9;
            }

            /* ===== FILTER BAR ===== */
            .filter-bar {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-bottom: 15px;
            }

            .filter-bar input {
                padding: 10px;
                border-radius: 8px;
                border: 1px solid #ddd;
                flex: 1;
                min-width: 200px;
            }
            .filter-bar select {
                padding: 10px;
                border-radius: 8px;
                border: 1px solid #ddd;
                background: white;
                min-width: 150px;
            }

            /* ===== TABLE ===== */
            .table-wrapper {
                overflow-x: auto;
                background: white;
                border-radius: 12px;
                box-shadow: 0 6px 15px rgba(0,0,0,0.05);
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            thead {
                background: #f1f3f9;
            }

            th, td {
                padding: 14px;
                text-align: left;
                font-size: 14px;
            }

            tr:not(:last-child) {
                border-bottom: 1px solid #eee;
            }

            /* ===== STATUS BADGES ===== */
            .badge {
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 500;
                display: inline-block;
            }

            .badge.approved {
                background: #eafaf1;
                color: #27ae60;
            }

            .badge.rejected {
                background: #fdecea;
                color: #c0392b;
            }

            .badge.info {
                background: #ebf5ff;
                color: #2980b9;
            }

            /* ===== READ / UNREAD ===== */
            .unread-row {
                background: #f9fbff;
            }

            /* ===== RESPONSIVE ===== */
            @media (max-width: 600px) {
                th, td {
                    font-size: 13px;
                    padding: 10px;
                }
            }
            .main-content {
                flex: 1;               /* 👈 THIS is the key */
                padding: 20px;
            }
        </style>
    </head>

    <body>
        <div class="wrapper">

            <!-- ===== SIDEBAR ===== -->
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
                </div>

                <div class="profile">
                    <img src="${pageContext.request.contextPath}/profile-image?path=${profileImage}"
                         onerror="this.src='${pageContext.request.contextPath}/images/default_profile.png'">

                    <h4>${profileName}</h4>
                    <p>${profilePosition}</p>
                </div>


                <div class="menu">
                    <a href="<%= request.getContextPath()%>/CEODashboardServlet"><i class="fas fa-th-large"></i>Dashboard</a>
                    <a href="<%= request.getContextPath()%>/ViewProfileCEOServlet"><i class="fas fa-user"></i>Profile</a>
                    <a href="<%= request.getContextPath()%>/LeaveListServlet"><i class="fas fa-bell"></i>Requests</a>
                    <a href="<%= request.getContextPath()%>/NotificationCeoServlet" class="active"><i class="fas fa-bell"></i>Notifications</a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>

            <div class="main-content">

                <div class="container">

                    <!-- ===== HEADER ===== -->
                    <div class="header">
                        <h2>Notifications</h2>
                        <p>Latest updates from leave approvals</p>
                    </div>

                    <!-- ===== SUMMARY CARDS ===== -->
                    <div class="cards">
                        <div class="card approved">
                            <h3>${approvedCount}</h3>
                            <span>Approved</span>
                        </div>

                        <div class="card rejected">
                            <h3>${rejectedCount}</h3>
                            <span>Rejected</span>
                        </div>

                        <div class="card unread">
                            <h3>${unreadCount}</h3>
                            <span>Unread</span>
                        </div>
                    </div>

                    <!-- ===== FILTER BAR ===== -->
                    <div class="filter-bar">
                        <input type="text" id="searchInput" placeholder="Search notification...">

                        <select id="statusFilter" onchange="filterStatus()">
                            <option value="all">All Status</option>
                            <option value="approved">Approved</option>
                            <option value="rejected">Rejected</option>
                            <option value="info">Info</option>
                        </select>
                    </div>

                    <!-- ===== TABLE ===== -->
                    <div class="table-wrapper">
                        <table id="notificationTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Message</th>
                                    <th>Time</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="n" items="${notifications}">
                                    <tr class="${n.isRead ? '' : 'unread-row'}"
                                        data-id="${n.id}"
                                        data-status="${n.status}">

                                        <td>${n.id}</td>
                                        <td>${n.message}</td>
                                        <td>${n.time}</td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${n.status == 'approved'}">
                                                    <span class="badge approved">Approved</span>
                                                </c:when>

                                                <c:when test="${n.status == 'rejected'}">
                                                    <span class="badge rejected">Rejected</span>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="badge info">Info</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                    </tr>
                                </c:forEach>

                                <!-- fallback -->
                                <c:if test="${empty notifications}">
                                    <tr>
                                        <td colspan="4" style="text-align:center; padding:20px;">
                                            No notifications found
                                        </td>
                                    </tr>
                                </c:if>

                            </tbody>
                        </table>
                    </div>

                </div>
            </div>


            <script>
                document.addEventListener("DOMContentLoaded", function () {

                    // ===== TOGGLE SIDEBAR =====
                    window.toggleSidebar = function () {
                        document.getElementById("sidebar").classList.toggle("closed");
                    };

                    // ===== SEARCH =====
                    const searchInput = document.getElementById("searchInput");
                    if (searchInput) {
                        searchInput.addEventListener("keyup", function () {
                            const value = this.value.toLowerCase();
                            document.querySelectorAll("#notificationTable tbody tr").forEach(row => {
                                row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
                            });
                        });
                    }

                    // ===== MARK AS READ =====
                    document.querySelectorAll("#notificationTable tbody tr").forEach(row => {
                        row.addEventListener("click", function () {

                            if (this.classList.contains("unread-row")) {
                                this.classList.remove("unread-row");

                                fetch("MarkNotificationReadServlet", {
                                    method: "POST",
                                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                                    body: "id=" + this.dataset.id
                                });
                            }

                        });
                    });

                });


                /* FILTER STATUS */
                function filterStatus() {
                    const filter = document.getElementById("statusFilter").value;
                    document.querySelectorAll("#notificationTable tbody tr").forEach(row => {
                        row.style.display =
                                filter === "all" || row.dataset.status === filter ? "" : "none";
                    });
                }
            </script>



    </body>
</html>