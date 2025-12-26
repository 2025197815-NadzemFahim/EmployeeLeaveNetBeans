<%-- 
    Document   : apply_leave
    Created on : Dec 24, 2025, 8:36:20 PM
    Author     : suweg
--%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Apply Leave</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            /* ===== Use your provided CSS ===== */
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
    "SELECT lt.type_id, lt.name, elb.balance " +
    "FROM employee_leave_balance elb " +
    "JOIN leave_type lt ON elb.type_id = lt.type_id " +
    "WHERE elb.employee_id = ?"
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
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn" onclick="toggleSidebar()">☰</span>
                </div>


                <!-- ================= SIDEBAR PROFILE ================= -->
                <div class="profile">
                    <img src="<%= request.getContextPath()%>/profile-image?path=<%= profileImage%>"
                         onerror="this.src='<%= request.getContextPath()%>/images/default_profile.png'">
                    <h4><%= empName%></h4>
                    <p><%= empPost%></p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/DashboardStaffServlet"><i class="fas fa-th-large"></i>Dashboard</a>
                    <a href="<%= request.getContextPath()%>/ViewProfileServlet"><i class="fas fa-user"></i>Profile</a>
                    <a  href="<%= request.getContextPath()%>/staff/apply_leave.jsp" class="active"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
                    <a href="<%= request.getContextPath()%>/LeaveHistoryStaffServlet"><i class="fas fa-history"></i>Leave History</a>
                    <a><i class="fas fa-bell"></i>Notifications</a>
                    <a><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>

            <!-- ===== MAIN CONTENT ONLY ===== -->

            <div class="main">

                <div class="header" style="color: #ffffff;">Add New Leave</div>

                <div class="card">

                    <form action="<%= request.getContextPath()%>/StaffApplyLeaveServlet"
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

                </body>
                </html>



