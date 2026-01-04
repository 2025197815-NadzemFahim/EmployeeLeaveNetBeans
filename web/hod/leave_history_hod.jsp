<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.leave.model.LeaveHistory" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Leave History - HOD</title>

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


            /* Main content */
            .main {
                flex: 1;
                padding: 20px;
            }

            .header {
                background: linear-gradient(to right, #0f172a, #94a3b8);
                padding: 18px;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 20px;
            }

            /* Search bar */
            .top-bar {
                display: flex;
                justify-content: flex-end;
                margin-bottom: 15px;
            }

            .search {
                padding: 8px 12px;
                border-radius: 6px;
                border: 1px solid #ccc;
                width: 220px;
            }

            /* Card */
            .card {
                background: white;
                padding: 20px;
                border-radius: 8px;
                overflow-x: auto;
            }

            /* Table */
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 650px; /* forces horizontal scroll on small screens */
            }

            th, td {
                padding: 14px;
                text-align: center;
            }

            th {
                color: black;
                font-weight: 600;
            }

            td{
                color : #555;
                font-weight: 600;
            }

            tbody tr:nth-child(odd) {
                background: #f2f2f2;
            }


            /*button view and delete*/
            .modal {
                display: none;
                position: fixed;
                z-index: 2000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.6);
                justify-content: center;
                align-items: center;
            }

            .modal-content {
                background: #ffffff;
                width: 85%;
                max-width: 1100px;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 6px 25px rgba(0,0,0,0.25);
                font-family: 'Poppins', sans-serif;
                animation: popupFade 0.25s ease-out;
                font-size: 18px;
            }

            .modal-content h2 {
                font-size: 30px;
                font-weight: 700;
                margin-bottom: 25px;
            }

            .close {
                position: absolute;
                right: 25px;
                top: 15px;
                font-size: 38px;
                cursor: pointer;
                font-weight: bold;
                color: #444;
            }

            .close:hover {
                color: black;
            }

            @keyframes popupFade {
                from { opacity: 0; transform: translateY(-8px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .btn-view {
                padding: 8px 14px;
                border: none;
                background: #2962ff;
                color: white;
                border-radius: 6px;
                cursor: pointer;
                font-weight: 600;
                margin-right: 6px;
            }

            .btn-delete {
                padding: 8px 14px;
                border: none;
                background: #d50000;
                color: white;
                border-radius: 6px;
                cursor: pointer;
                font-weight: 600;
            }

            .btn-view:hover { background: #0039cb; }
            .btn-delete:hover { background: #9b0000; }

            /*===View Popup Modal====*/
            .modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.6);
                justify-content: center;
                align-items: center;
            }

            .modal-content {
                background: white;
                width: 80%;
                max-width: 900px;
                padding: 30px;
                border-radius: 12px;
                position: relative;
                animation: fadeIn 0.3s ease-in-out;
            }

            .modal-content h2 {
                font-size: 28px;
                margin-bottom: 20px;
            }

            .close {
                position: absolute;
                right: 20px;
                top: 10px;
                font-size: 38px;
                cursor: pointer;
                color: #555;
                font-weight: bold;
            }

            .close:hover { color: black; }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(-10px); }
                to { opacity: 1; transform: translateY(0); }
            }


            .status-approved { color: #00c853; font-weight: bold; }
            .status-rejected { color: #ff1744; font-weight: bold; }
            .status-pending { color: #ffab00; font-weight: bold; }

            /* Responsive */
            @media (max-width: 768px) {
                .wrapper { flex-direction: column; }
                .sidebar { width: 100%; }
                .sidebar.closed { width: 100%; }
                .header { font-size: 22px; text-align: center; }
                .top-bar { justify-content: center; }
                .search { width: 100%; max-width: 300px; }
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
                    <a href="<%= request.getContextPath()%>/HODDashboardServlet"><i class="fas fa-th-large"></i>Dashboard</a>
                    <a  href="<%= request.getContextPath()%>/ViewProfileHODServlet"><i class="fas fa-user"></i>Profile</a>
                    <a href="<%= request.getContextPath()%>/hod/apply_leave.jsp"><i class="fas fa-calendar-plus"></i>Apply Leave</a>
                    <a href="<%= request.getContextPath()%>/LeaveListServlet"><i class="fas fa-bell"></i>Requests</a>
                    <a href="<%= request.getContextPath()%>/LeaveHistoryHodServlet" class="active"><i class="fas fa-history"></i>Leave History</a>
                    <a href="<%= request.getContextPath()%>/NotificationHodServlet"><i class="fas fa-bell"></i>Notifications</a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet"><i class="fas fa-sign-out-alt"></i>Logout</a>
                </div>
            </div>

            <!-- Main Content -->
            <div class="main">
                <div class="header" style="color: #ffffff;">Leave History Record</div>

                <!-- Search Bar -->
                <div class="top-bar">
                    <input type="text" class="search" placeholder="Search leave..." id="searchInput">
                </div>

                <!-- Card + Table -->
                <div class="card">
                    <table id="leaveTable">
                        <thead>
                            <tr>
                                <th>Request ID</th>
                                <th>Leave Type</th>
                                <th>Status</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Balance</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="leaveTableBody">

                            <%
                                List<com.leave.model.LeaveHistory> leaveHistory
                                        = (List<com.leave.model.LeaveHistory>) request.getAttribute("leaveHistory");

                                if (leaveHistory != null && !leaveHistory.isEmpty()) {
                                    for (com.leave.model.LeaveHistory lh : leaveHistory) {
                                        String statusClass = "";
                                        if ("APPROVED".equalsIgnoreCase(lh.getStatus())) {
                                            statusClass = "status-approved";
                                        } else if ("REJECTED".equalsIgnoreCase(lh.getStatus())) {
                                            statusClass = "status-rejected";
                                        } else {
                                            statusClass = "status-pending";
                                        }
                            %>
                            <tr>
                                <td><%= lh.getRequestId()%></td>
                                <td><%= lh.getLeaveType()%></td>
                                <td class="<%= statusClass%>"><%= lh.getStatus()%></td>
                                <td><%= lh.getStartDate()%></td>
                                <td><%= lh.getEndDate()%></td>
                                <td><%= lh.getLeaveBalance()%></td>
                                <td>
                                    <button class="btn-view" onclick="openViewPopup(<%= lh.getRequestId()%>)">
                                        View
                                    </button>
                                    <button class="btn-delete" onclick="deleteLeave(<%= lh.getRequestId()%>)">
                                        Delete
                                    </button>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="7">No leave history found.</td></tr>
                            <% }%>

                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Close wrapper -->
        </div>
    </div>

    <!-- Popup Modal (Corporate Big UI) -->
    <div id="viewModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeViewPopup()">×</span>
            <h2>Leave Application Details</h2>
            <div id="modalBody">Loading...</div>
        </div>
    </div>

    <!-- Modal CSS -->
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.6);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background: #ffffff;
            width: 85%;
            max-width: 1100px;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 6px 25px rgba(0,0,0,0.25);
            font-family: 'Poppins', sans-serif;
            animation: popupFade 0.25s ease-out;
            font-size: 18px;
        }

        .modal-content h2 {
            font-size: 30px;
            font-weight: 700;
            margin-bottom: 25px;
        }

        .close {
            position: absolute;
            right: 25px;
            top: 15px;
            font-size: 38px;
            cursor: pointer;
            font-weight: bold;
            color: #444;
        }

        .close:hover {
            color: black;
        }

        @keyframes popupFade {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .btn-view {
            padding: 8px 14px;
            border: none;
            background: #2962ff;
            color: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            margin-right: 6px;
        }

        .btn-delete {
            padding: 8px 14px;
            border: none;
            background: #d50000;
            color: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
        }

        .btn-view:hover { background: #0039cb; }
        .btn-delete:hover { background: #9b0000; }
    </style>

    <!-- JavaScript -->
    <script>
    // Realtime table search
        document.getElementById("searchInput").addEventListener("keyup", function () {
            let filter = this.value.toLowerCase();
            let rows = document.querySelectorAll("#leaveTableBody tr");

            rows.forEach(row => {
                row.style.display = row.innerText.toLowerCase().includes(filter) ? "" : "none";
            });
        });

    // Open popup + fetch DB data
        function openViewPopup(requestId) {
            document.getElementById("viewModal").style.display = "flex";
            fetch("<%= request.getContextPath()%>/ViewLeavePopupServlet?requestId=" + requestId)
                    .then(res => res.text())
                    .then(data => document.getElementById("modalBody").innerHTML = data)
                    .catch(() => document.getElementById("modalBody").innerHTML = "Failed to load data");
        }

    // Close popup
        function closeViewPopup() {
            document.getElementById("viewModal").style.display = "none";
            document.getElementById("modalBody").innerHTML = "Loading...";
        }

    // Delete leave from DB
        function deleteLeave(requestId) {
            if (confirm("Delete this leave application?")) {
                fetch("<%= request.getContextPath()%>/DeleteLeaveServlet?requestId=" + requestId)
                        .then(res => res.text())
                        .then(msg => {
                            alert(msg);
                            location.reload();
                        })
                        .catch(() => alert("Delete failed"));
            }
        }
    </script>



    <script>
        /* Sidebar open/close */
        document.querySelector(".toggle-btn").addEventListener("click", function () {
            document.getElementById("sidebar").classList.toggle("closed");
        });



        /* Search realtime (fix sebab ID dah wujud) */
        document.getElementById("searchInput").addEventListener("keyup", function () {
            let filter = this.value.toLowerCase();
            let rows = document.querySelectorAll("#leaveTable tbody tr");

            rows.forEach(row => {
                let text = row.innerText.toLowerCase();
                row.style.display = text.includes(filter) ? "" : "none";
            });
        });
    </script>

</body>
</html>
