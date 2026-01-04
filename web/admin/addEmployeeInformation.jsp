<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add New Employee Information</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        
        <!-- Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
        
        <style>
            /* ---------- GLOBAL RESET ---------- */
            * {
                box-sizing: border-box;
                font-family: 'Poppins', sans-serif;
            }
            body {
                margin: 0;
                background: #f2f2f2;
            }

            /* ---------- MAIN LAYOUT ---------- */
            .wrapper {
                display: flex;
                min-height: 100vh;
            }

            /* ---------- SIDEBAR ---------- */
            .sidebar {
                position: fixed;
                top: 0;
                bottom: 0;
                left: 0;
                width: 260px;
                background: #0f172a; /* UPDATED */
                padding: 15px;
                overflow: hidden;
                transition: width 0.3s ease;
            }

            .sidebar.closed {
                width: 60px;
            }

            /* ---------- BRAND ---------- */
            .brand {
                color: #ffffff;
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-weight: bold;
                margin-bottom: 20px;
            }
            .sidebar.closed .brand span:first-child {
                display: none;
            }

            /* ---------- PROFILE ---------- */
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
                background: #1e293b;   /* ✅ SAFE */
                margin-bottom: 10px;
            }
            .profile h4 {
                margin: 5px 0 0;
                font-size: 14px;
                color: #ffffff;        /* ✅ SAFE */
            }
            .profile p {
                margin: 0;
                font-size: 12px;
                color: #94a3b8;        /* ✅ SAFE */
            }

            /* ---------- MENU ---------- */
            .menu a, .menu-parent {
                display: flex;
                align-items: center;
                padding: 12px;
                margin-bottom: 6px;
                text-decoration: none;
                color: #dcdcdc;        /* ✅ SAFE */
                border-radius: 6px;
                font-size: 14px;
                gap: 12px;
            }
            .menu a i,
            .menu-parent i {
                width: 20px;
                text-align: center;
                font-size: 16px;
            }
            
            .menu a:hover,
            .menu-parent:hover {
                background: #1e293b;
            }
            
            .menu a.active { 
                background: #ffffff;
                color: #0f172a;
                font-weight: bold;
            }


            /* ---------- DROPDOWN ---------- */
            .menu-group .menu-parent { 
                background: #111827;
                font-weight: 600;
            }
            
            .menu-group .menu-parent::after {
                content: "▼";
                font-size: 10px;
                margin-left: auto;
                margin-right: 10px;
                color: #cbd5f5;
                transition: transform 0.2s ease;
            }
            .menu-group .menu-parent.open::after { transform: rotate(180deg); }
            
            .menu-group .submenu {
                margin-left: 32px;
                display: none;
                flex-direction: column;
            }
            
            .menu-group .submenu.open { display: flex; }
            
            .menu-group .submenu a {
                color: #cbd5f5; /* UPDATED */
            }
            
            /* ===== COLLAPSED MODE ===== */
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
            }

            .sidebar.closed .submenu a i {
                font-size: 16px;
            }

            /* ---------- MAIN ---------- */
            .main {
                margin-left: 260px;
                width: calc(100% - 260px);
                padding: 30px;
            }

            .page-title {
                background: linear-gradient(to right, #0f172a, #94a3b8);
                color:white;
                max-width: 1100px;
                margin: 0 auto 30px;
                padding: 18px 24px;
                font-size: 32px;
                font-weight: 700;
            }

            .page-content {
                max-width: 1100px;
                margin: 0 auto;
                display: flex;
                flex-direction: column;
                gap: 30px;
            }

            .card {
                background: #ffffff;
                border-radius: 14px;
                padding: 30px;
            }

            .form-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 20px 30px;
            }

            .form-group label {
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 6px;
                display: block;
            }

            .form-group input,
            .form-group select {
                width: 100%;
                height: 38px;
                padding: 8px 12px;
                border-radius: 8px;
                border: 1px solid #ccc;
            }

            .form-group textarea {
                width: 100%;
                min-height: 90px;
                padding: 10px 12px;
                border-radius: 8px;
                border: 1px solid #ccc;
                resize: vertical;
            }

            .form-group.full {
                grid-column: 1 / -1;
            }

            .form-actions {
                display: flex;
                justify-content: space-between;
                gap: 20px;
                margin: 40px auto 20px;
                max-width: 1100px;
            }

            .btn-back,
            .btn-submit {
                flex: 1;
                height: 45px;
                font-size: 14px;
                font-weight: 600;
                border-radius: 6px;
                border: none;
                cursor: pointer;
            }

            .btn-back {
                background: #555;
                color: #fff;
            }

            .btn-submit {
                background: #00c853;
                color: #fff;
            }

            ::-webkit-scrollbar { width: 0; height: 0; }
            * { scrollbar-width: none; -ms-overflow-style: none; }
        </style>
    </head>

    <body>
        <div class="wrapper">
            <!-- ================= SIDEBAR ================= -->
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn">☰</span>
                </div>

                <div class="profile">
                    <img src="<%= request.getContextPath()%>/profile-image?path=<%= request.getAttribute("profileImg")%>"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
                    <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Staff User"%></h4>
                    <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : session.getAttribute("role")%></p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/AdminDashboardServlet"><i class="fas fa-th-large"></i><span>Dashboard</span></a>        
                    <a href="<%= request.getContextPath()%>/admin/employeeInformation.jsp" class="active"><i class="fas fa-users"></i><span>Employees</span></a>
                    <a href="<%= request.getContextPath()%>/admin/LeavePolicies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
                    <a href="<%= request.getContextPath()%>/admin/GenerateRecord.jsp"><i class="fas fa-th-large"></i>Reports</a>


                    <div class="menu-group">
                        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
                        <div class="submenu">
                            <a href="<%= request.getContextPath()%>/ViewProfileAdminServlet"><i class="fas fa-id-badge"></i><span>Profile</span></a>
                            <a href="<%= request.getContextPath()%>/admin/apply_leave.jsp"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
                            <a href="<%= request.getContextPath()%>/LeaveHistoryAdminServlet"><i class="fas fa-history"></i><span>Leave History</span></a>
                        </div>
                    </div>

                    <a href="<%= request.getContextPath()%>/NotificationAdminServlet"><i class="fas fa-bell"></i><span>Notifications</span></a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
                </div>
            </div>

            <!-- ================= MAIN ================= -->
            <div class="main">
                <div class="page-title">Add New Employee</div>

                <div class="page-content">
                    <div class="card">

                        <!-- ✅ FIXED FORM ACTION -->
                        <form id="employeeForm" action="<%= request.getContextPath() %>/AdminAddEmployee" method="post">

                            
                            <div class="form-grid">
                                
                                <div class="form-group">
                                    <label>Full Name</label>
                                    <input type="text" name="name" id="name" placeholder="Full Name" required>
                                </div>
                                
                                <div class="form-group">
                                    <label>Date Of Birth</label>
                                    <input type="date" name="DoB" id="DoB">
                                </div>

                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="text" name="email" id="email" placeholder="Email" required>
                                </div>
                                
                                <div class="form-group">
                                    <label>Password</label>
                                    <input type="password" name="password" id="password" placeholder="Password" required>
                                </div>

                                <div class="form-group">
                                    <label>Role</label>
                                    <select name="role" id="role" class="role-dropdown" required>
                                        <option value="">Select Role</option>
                                        <option value="ADMIN">ADMIN</option>
                                        <option value="STAFF">STAFF</option>
                                        <option value="HOD">HEAD OF DIRECTOR</option>
                                        <option value="CEO">CHIEF EXECUTIVE OFFICER</option>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label>Department</label>
                                    <input type="text" name="department" id="department" placeholder="Department">
                                </div>
                                
                                <div class="form-group">
                                    <label>Position</label>
                                    <input type="text" name="position" id="position" placeholder="Position">
                                </div>
                                

                                
                                <div class="form-group">
                                    <label>Admission Date</label>
                                    <input type="date" name="admissionDate" id="admissionDate">
                                </div>
                                
                                <div class="form-group full">
                                    <label>Address</label>
                                    <textarea name="address" id="address" placeholder="Address"></textarea>
                                </div>
                                
                            </div>
                            
                            <div class="form-actions">
                                <button type="button" class="btn-back" onclick="confirmBack()">Back</button>
                                <button type="button" class="btn-submit" onclick="confirmSubmit()">Create Employee</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script>  
            document.querySelector(".toggle-btn").addEventListener("click", () => {
                document.getElementById("sidebar").classList.toggle("closed");
            });

            document.querySelectorAll(".menu-group").forEach(group => {
                const parent = group.querySelector(".menu-parent");
                const submenu = group.querySelector(".submenu");
                parent.addEventListener("click", () => {
                    parent.classList.toggle("open");
                    submenu.classList.toggle("open");
                });
            });
            
            function confirmSubmit() {
                if (confirm("Are you sure want to submit?")) {
                    document.getElementById("employeeForm").submit();
                }
            }

            // BACK → just go back
            function confirmBack() {
                if (confirm("Go back without saving changes?")) {
                    window.location.href = "<%= request.getContextPath() %>/admin/employeeInformation.jsp";
                }
            }
        </script>
    </body>
</html>
