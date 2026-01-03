<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Apply Leave Admin</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            * {
                box-sizing: border-box;
                font-family: "Poppins", sans-serif;
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
                background: #d0d0d0;
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
                padding: 20px;
            }

            /* Header */
            .header {
                background: linear-gradient(to right, #bdbdbd, #eeeeee);
                padding: 18px;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 20px;
            }


            /* Card */
            .card {
                background: white;
                padding: 30px;
                border-radius: 12px;
                max-width: 850px;
                margin: auto;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            }

            /* Form */
            .form-row {
                display: grid;
                grid-template-columns: 180px 400px;
                gap: 15px;
                margin-bottom: 20px;
                align-items: center;
            }

            .form-row.full {
                grid-template-columns: 180px 1fr;
            }

            label {
                font-weight: 600;
            }

            input, select, textarea {
                padding: 10px;
                border-radius: 6px;
                border: 1px solid #ccc;
                width: 100%;
            }

            textarea {
                height: 80px;
                resize: none;
            }

            /* Upload */
            .upload-btn {
                background: #bdbdbd;
                padding: 8px 16px;
                border-radius: 6px;
                border: none;
                cursor: pointer;
            }

            /* Buttons */
            .actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 20px;
            }

            .btn {
                padding: 10px 20px;
                border: none;
                border-radius: 6px;
                color: white;
                cursor: pointer;
            }

            .btn-cancel {
                background: red;
            }

            .btn-submit {
                background: #00c853;
            }
        </style>

    </head>
    <body>
        <%
            // ===== SESSION CHECK =====
            Integer employeeId = (Integer) session.getAttribute("employeeId");
            if (employeeId == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            boolean success = "1".equals(request.getParameter("success"));

            // ===== DB CONNECTION =====
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/LeaveDB", "app", "app"
            );

            // ===== EMPLOYEE INFO =====
            String empName = "";
            String empRole = "";
            String empDept = "";
            String empPost = "";
            String profileImage = "uploads/default.png";

            PreparedStatement psEmp = conn.prepareStatement(
                    "SELECT name, role, department, profile_image, position "
                    + "FROM employee WHERE employee_id=?"
            );
            psEmp.setInt(1, employeeId);
            ResultSet rsEmp = psEmp.executeQuery();

            if (rsEmp.next()) {
                empName = rsEmp.getString("name");
                empRole = rsEmp.getString("role");
                empDept = rsEmp.getString("department");
                empPost = rsEmp.getString("position");

                if (rsEmp.getString("profile_image") != null) {
                    profileImage = rsEmp.getString("profile_image");
                }
            }

            // ===== LEAVE TYPES =====
            PreparedStatement psType = conn.prepareStatement(
                    "SELECT lt.type_id, lt.name, elb.balance "
                    + "FROM employee_leave_balance elb "
                    + "JOIN leave_type lt ON elb.type_id = lt.type_id "
                    + "WHERE elb.employee_id = ?"
            );
            psType.setInt(1, employeeId);
            ResultSet rsType = psType.executeQuery();


        %>

        <%-- SUCCESS POPUP --%>
        <% if (success) { %>
        <script>
            alert("Leave application submitted successfully!");
        </script>
        <% }%>

        <%
            String dateError = request.getParameter("dateError");
            if ("past".equals(dateError)) {
        %>
        <script>alert("Start date must be today or a future date.");</script>
        <%
        } else if ("range".equals(dateError)) {
        %>
        <script>alert("End date cannot be before start date.");</script>
        <%
            }

            String error = request.getParameter("error");
            if ("insufficient".equals(error)) {
        %>
        <script>alert("Insufficient leave balance for selected leave type.");</script>
        <%
        } else if ("nobalance".equals(error)) {
        %>
        <script>alert("No leave balance found for this leave type.");</script>
        <%
            }
        %>

        <div class="wrapper">

            <!-- ===== Sidebar UI ===== -->
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn">☰</span>
                </div>

                <!-- ================= SIDEBAR PROFILE ================= -->
                <div class="profile">
                    <img src="<%= request.getContextPath()%>/profile-image?path=<%= profileImage%>"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
                    <h4><%= empName%></h4>
                    <p><%= empPost%></p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/AdminDashboardServlet"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
                    <a href="employees.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
                    <a href="<%= request.getContextPath()%>/admin/LeavePolicies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
                    <a href="<%= request.getContextPath()%>/admin/GenerateRecord.jsp"><i class="fas fa-th-large"></i>Reports</a>


                    <div class="menu-group">
                        <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
                        <div class="submenu">
                            <a href="<%= request.getContextPath()%>/ViewProfileAdminServlet"><i class="fas fa-id-badge"></i><span>Profile</span></a>
                            <a href="<%= request.getContextPath()%>/admin/apply_leave.jsp" class="active"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
                            <a href="<%= request.getContextPath()%>/LeaveHistoryAdminServlet"><i class="fas fa-history"></i><span>Leave History</span></a>
                        </div>
                    </div>

                    <a href="<%= request.getContextPath()%>/NotificationAdminServlet"><i class="fas fa-bell"></i><span>Notifications</span></a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
                </div>
            </div>


            <!-- ===== MAIN CONTENT ONLY ===== -->

            <div class="main">

                <div class="header" style="color: #ffffff;">Add New Leave</div>

                <div class="card">

                    <form action="<%= request.getContextPath()%>/AdminApplyLeaveServlet"
                          method="post"
                          enctype="multipart/form-data"
                          onsubmit="return validateDates();">

                        <!-- Leave Type -->
                        <div class="form-row full">
                            <label>Leave Type</label>
                            <select name="typeId" required>
                                <% while (rsType.next()) {%>
                                <option value="<%= rsType.getInt("type_id")%>">
                                    <%= rsType.getString("name")%>
                                    (Remaining: <%= rsType.getInt("balance")%> days)
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Start Date -->
                        <div class="form-row">
                            <label>Start Date</label>
                            <input type="date" name="startDate" required>
                        </div>

                        <!-- End Date -->
                        <div class="form-row">
                            <label>End Date</label>
                            <input type="date" name="endDate" required>
                        </div>

                        <!-- Reason -->
                        <div class="form-row full">
                            <label>Reason for Leave</label>
                            <textarea name="reason" required></textarea>
                        </div>

                        <!-- Attachment -->
                        <div class="form-row full">
                            <label>Attachment (if any)</label>
                            <input type="file" name="attachment" class="upload-btn">
                        </div>

                        <!-- Buttons -->
                        <div class="actions">
                            <button type="reset" class="btn btn-cancel">Cancel</button>
                            <button type="submit" class="btn btn-submit">Submit</button>
                        </div>

                    </form>
                </div>

                <%
                    conn.close();
                %>
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

                    function validateDates() {
                        const startDate = document.querySelector('input[name="startDate"]').value;
                        const endDate = document.querySelector('input[name="endDate"]').value;

                        if (!startDate || !endDate)
                            return true;

                        const today = new Date();
                        today.setHours(0, 0, 0, 0);

                        const start = new Date(startDate);
                        const end = new Date(endDate);

                        if (start < today) {
                            alert("Start date must be today or a future date.");
                            return false;
                        }

                        if (end < start) {
                            alert("End date cannot be before start date.");
                            return false;
                        }

                        return true;
                    }
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
