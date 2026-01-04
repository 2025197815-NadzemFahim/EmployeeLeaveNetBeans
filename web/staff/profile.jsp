<%-- 
    Document   : profile
    Created on : Dec 25, 2025, 10:48:56 AM
    Author     : suweg
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.sql.ResultSet"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>View Profile</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
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

            /* ===== Main Content ===== */
            .main {
                flex: 1;
                padding: 20px;
            }

            /* Header */
            .header {
                background: linear-gradient(to right, #0f172a, #94a3b8);
                padding: 18px;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 20px;
            }


            .profile-container {
                display: grid;
                grid-template-columns: 280px 1fr;
                gap: 25px;
            }

            /* LEFT CARD */
            .profile-left {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                text-align: center;
            }

            .profile-image img {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                object-fit: cover;
                margin-bottom: 10px;
            }

            .profile-name {
                margin: 10px 0 20px;
            }

            .profile-field {
                margin-bottom: 12px;
                text-align: left;
            }

            .profile-field label {
                font-size: 13px;
                color: #666;
            }

            .profile-field input {
                width: 100%;
                padding: 8px;
                border-radius: 6px;
                border: 1px solid #ccc;
            }

            .btn {
                width: 100%;
                padding: 10px;
                margin-bottom: 10px;
                border: none;
                border-radius: 20px;
                background: #777;
                color: white;
                font-weight: 600;
                cursor: pointer;
            }

            .btn:hover {
                background: #555;
            }

            /* RIGHT SIDE */
            .profile-right {
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            .info-card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
            }

            .info-card h3 {
                margin-bottom: 15px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }

            .info-grid label {
                font-size: 13px;
                color: #666;
            }

            .info-grid input {
                width: 100%;
                padding: 8px;
                border-radius: 6px;
                border: 1px solid #ccc;
                background: #f4f4f4;
            }

        </style>
    </head>
    <body>
        <%
            Map emp = (Map) request.getAttribute("emp");
            List<Map> leaveInfo = (List<Map>) request.getAttribute("leaveInfo");
        %>


        <% if ("password".equals(request.getParameter("success"))) { %>
        <script>alert("Password successfully updated");</script>
        <% } %>

        <% if ("image".equals(request.getParameter("success"))) { %>
        <script>alert("Profile image successfully updated");</script>
        <% }%>

        <div class="wrapper">
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
                </div>

                <div class="profile">
                    <img src="<%= request.getContextPath()%>/profile-image?path=<%= emp.get("profile_image")%>"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">

                    <h4><%= emp.get("name")%></h4>
                    <p><%= emp.get("position")%></p>
                </div>



                <div class="menu">
                    <a href="<%= request.getContextPath()%>/DashboardStaffServlet"><i class="fas fa-th-large"></i>Dashboard</a>
                    <a href="<%= request.getContextPath()%>/ViewProfileServlet" class="active"><i class="fas fa-user"></i>Profile</a>
                    <a  href="<%= request.getContextPath()%>/staff/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
                    <a href="<%= request.getContextPath()%>/LeaveHistoryStaffServlet"><i class="fas fa-history"></i>Leave History</a>
                    <a href="<%= request.getContextPath()%>/NotificationServlet"><i class="fas fa-bell"></i>Notifications</a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>

            <!-- ===== MAIN CONTENT ===== -->
            <div class="main">
                <div class="header" style="color:#ffffff;">My Profile</div>
                <div class="profile-container">

                    <!-- LEFT -->
                    <div class="profile-left">

                        <div class="profile-image">
                            <img src="<%= request.getContextPath()%>/profile-image?path=<%= emp.get("profile_image")%>"
                                 onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
                        </div>

                        <h2 class="profile-name"><%= emp.get("name")%></h2>

                        <div class="profile-field">
                            <label>Email</label>
                            <input type="email" value="<%= emp.get("email")%>" readonly>
                        </div>

                        <!-- CHANGE PASSWORD -->
                        <form action="<%= request.getContextPath()%>/UpdateProfileServlet" method="post">
                            <div class="profile-field">
                                <label>New Password</label>
                                <input type="password" name="newPassword" required>
                            </div>

                            <div class="profile-field">
                                <label>Confirm Password</label>
                                <input type="password" name="confirmPassword" required>
                            </div>

                            <input type="hidden" name="action" value="changePassword">
                            <button class="btn">Change Password</button>
                        </form>

                        <!-- CHANGE IMAGE -->
                        <form action="<%= request.getContextPath()%>/UpdateProfileServlet"
                              method="post"
                              enctype="multipart/form-data">

                            <div class="profile-field">
                                <label>Profile Image</label>
                                <input type="file" name="profileImage" accept="image/*" required>
                            </div>

                            <input type="hidden" name="action" value="changeProfileImage">
                            <button class="btn">Update Profile Image</button>
                        </form>

                    </div>

                    <!-- RIGHT -->
                    <div class="profile-right">

                        <div class="info-card">
                            <h3>Personal Information</h3>

                            <div class="info-grid">

                                <div class="field">
                                    <label>Employee ID</label>
                                    <input type="text" value="S<%= emp.get("employee_id")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Full Name</label>
                                    <input type="text" value="<%= emp.get("name")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Date of Birth</label>
                                    <input type="text" value="<%= emp.get("date_of_birth")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Address</label>
                                    <input type="text" value="<%= emp.get("address")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Admission Date</label>
                                    <input type="text" value="<%= emp.get("admission_date")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Department</label>
                                    <input type="text" value="<%= emp.get("department")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Role</label>
                                    <input type="text" value="<%= emp.get("role")%>" readonly>
                                </div>

                                <div class="field">
                                    <label>Position</label>
                                    <input type="text" value="<%= emp.get("position")%>" readonly>
                                </div>

                            </div>
                        </div>


                        <div class="info-card">
                            <h3>Leave Information</h3>

                            <div class="info-grid">
                                <% for (Map leave : leaveInfo) {%>
                                <div class="field">
                                    <label><%= leave.get("name")%></label>
                                    <input type="text"
                                           value="<%= leave.get("balance")%> / <%= leave.get("max_days")%> Days"
                                           readonly>
                                </div>
                                <% }%>
                            </div>
                        </div>

                        <script>
                            function toggleSidebar() {
                                const sidebar = document.getElementById('sidebar');
                                sidebar.classList.toggle('closed');
                            }

                            /* Filter table by status */
                            function filterStatus() {
                                const filter = document.getElementById("statusFilter").value.toLowerCase();
                                const table = document.getElementById("leaveTable");
                                const trs = table.tBodies[0].getElementsByTagName("tr");

                                for (let i = 0; i < trs.length; i++) {
                                    const status = trs[i].getElementsByTagName("td")[4].textContent.toLowerCase();
                                    trs[i].style.display = (filter === "all" || status === filter) ? "" : "none";
                                }
                            }

                            /* Search table */
                            function searchTable() {
                                const input = document.getElementById("searchInput").value.toLowerCase();
                                const table = document.getElementById("leaveTable");
                                const trs = table.tBodies[0].getElementsByTagName("tr");

                                for (let i = 0; i < trs.length; i++) {
                                    let found = false;
                                    const tds = trs[i].getElementsByTagName("td");
                                    for (let j = 0; j < tds.length - 1; j++) { // exclude Details column
                                        if (tds[j].textContent.toLowerCase().includes(input)) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    trs[i].style.display = found ? "" : "none";
                                }
                            }
                        </script>

                        </body>
                        </html>



