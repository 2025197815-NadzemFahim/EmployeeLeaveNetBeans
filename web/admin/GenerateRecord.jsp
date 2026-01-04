<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.leave.model.GenerateRecord" %>
<%
    List<GenerateRecord> records = (List<GenerateRecord>) request.getAttribute("recordList");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Generate Leave Record</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            /* Reset & Global */
            * {
                box-sizing: border-box;
                font-family: "Poppins", sans-serif;
            }

            body {
                margin: 0;
                background: #f2f2f2;
            }

            /* Layout */
            .wrapper {
                display: flex;
                min-height: 100vh;
            }
            .main {
                flex: 1;
                padding: 20px;
            }
            .header {
                background: linear-gradient(to right, #0f172a, #94a3b8);
                color:white;
                padding: 18px;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 20px;
            }

            body {
                margin: 0;
                background: #f5f7fb; /* match others */
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
                background: #1e293b; /* UPDATED */
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
                color: #94a3b8; /* UPDATED */
            }

            /* ===== MENU ===== */
            .menu a,
            .menu-parent {
                display: flex;
                align-items: center;
                padding: 12px;
                margin-bottom: 6px;
                text-decoration: none;
                color: #dcdcdc; /* UPDATED */
                border-radius: 6px;
                font-size: 14px;
                gap: 12px;
                transition: background 0.2s ease, color 0.2s ease;
            }

            .menu a i,
            .menu-parent i {
                width: 20px;
                text-align: center;
                font-size: 16px;
            }

            /* ===== HOVER ===== */
            .menu a:hover,
            .menu-parent:hover {
                background: #1e293b; /* UPDATED */
            }

            /* ===== ACTIVE ===== */
            .menu a.active {
                background: #ffffff;
                color: #0f172a; /* UPDATED */
                font-weight: bold;
            }

            /* ===== DROPDOWN PARENT ===== */
            .menu-group .menu-parent {
                background: #111827; /* UPDATED */
                font-weight: 600;
            }

            /* Arrow indicator */
            .menu-group .menu-parent::after {
                content: "▼";
                font-size: 10px;
                margin-left: auto;
                margin-right: 10px;
                color: #cbd5f5; /* UPDATED */
                transition: transform 0.2s ease;
            }

            .menu-group .menu-parent.open::after {
                transform: rotate(180deg);
            }

            /* ===== SUBMENU ===== */
            .menu-group .submenu {
                margin-left: 32px;
                display: none;
                flex-direction: column;
            }

            .menu-group .submenu.open {
                display: flex;
            }

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

            /* Filter Card */
            .filter-card {
                background: #fff;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .filters {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 15px;
            }
            .filters label {
                font-size: 13px;
            }
            .filters input, .filters select {
                width: 100%;
                padding: 8px;
                border-radius: 5px;
                border: 1px solid #ccc;
            }
            .filter-actions {
                margin-top: 20px;
                display: flex;
                gap: 10px;
            }

            /* Buttons */
            .btn {
                padding: 8px 18px;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 13px;
            }
            .btn-generate { background: #ff1744; color: #fff; }
            .btn-reset { background: #e0e0e0; }
            .btn-pdf { background: #ff1744; color: #fff; }
            .btn-excel { background: #00c853; color: #fff; }
            .btn-print { background: #eeeeee; }

            /* Table */
            .card {
                background: #fff;
                padding: 20px;
                border-radius: 8px;
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 750px;
            }
            th, td {
                padding: 14px;
                text-align: center;
            }
            th { color: #000; font-weight: 600; }
            td { color: #555; font-weight: 600; }
            tbody tr:nth-child(odd) { background: #f2f2f2; }

            /* Status */
            .status-approved { color: #00c853; font-weight: bold; }
            .status-rejected { color: #ff1744; font-weight: bold; }
            .status-pending { color: #ffab00; font-weight: bold; }

            /* Table Actions */
            .table-actions { margin-top: 15px; display: flex; gap: 10px; }

            /* Responsive */
            @media (max-width: 768px) {
                .wrapper { flex-direction: column; }
                .sidebar, .sidebar.closed { width: 100%; }
                .header { font-size: 22px; text-align: center; }
                .filters { grid-template-columns: 1fr; }
            }
        </style>
    </head>
    <body>
        <div class="wrapper">
            <!-- ===== Sidebar ===== -->
            <div class="sidebar" id="sidebar">
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn">☰</span>
                </div>

                <div class="profile">
                    <img src="${pageContext.request.contextPath}/profile-image?path=${profileImage}"
                         onerror="this.src='${pageContext.request.contextPath}/images/default_profile.png'">

                    <h4>${profileName}</h4>
                    <p>${profilePosition}</p>
                </div>

                <div class="menu">
                    <a href="<%= request.getContextPath()%>/AdminDashboardServlet"><i class="fas fa-th-large"></i><span>Dashboard</span></a>    
                    <a href="<%= request.getContextPath()%>/admin/employeeInformation.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
                    <a href="<%= request.getContextPath()%>/admin/LeavePolicies.jsp"><i class="fas fa-file-lines"></i><span>Policies</span></a>
                    <a href="<%= request.getContextPath()%>/admin/GenerateRecord.jsp" class="active"><i class="fas fa-th-large"></i>Reports</a>

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

            <!-- Main -->
            <div class="main">
                <div class="header">Generate Leave Record</div>

                <!-- Filters -->
                <div class="filter-card">
                    <div class="filters">
                        <div>
                            <label>Start Date</label>
                            <input type="date" id="startDate">
                        </div>
                        <div>
                            <label>End Date</label>
                            <input type="date" id="endDate">
                        </div>
                        <div>
                            <label>Leave Type</label>
                            <select id="leaveType">
                                <option value="">All</option>
                                <option>Medical Leave</option>
                                <option>Annual Leave</option>
                                <option>Emergency Leave</option>
                                <option>Maternity Leave</option>
                            </select>
                        </div>
                        <div>
                            <label>Status</label>
                            <select id="status">
                                <option value="">All</option>
                                <option>APPROVED</option>
                                <option>REJECTED</option>
                                <option>PENDING</option>
                            </select>
                        </div>
                    </div>
                    <div class="filter-actions">
                        <button class="btn btn-generate">Generate</button>
                        <button class="btn btn-reset">Reset</button>
                    </div>
                </div>

                <!-- Table -->
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
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (records != null) {
                                    for (GenerateRecord r : records) {
                            %>
                            <tr>
                                <td><%= r.getRequestId()%></td>
                                <td><%= r.getLeaveType()%></td>
                                <td class="<%= r.getStatus().equals("APPROVED") ? "status-approved" : r.getStatus().equals("REJECTED") ? "status-rejected" : "status-pending"%>">
                                    <%= r.getStatus()%>
                                </td>
                                <td><%= r.getStartDate()%></td>
                                <td><%= r.getEndDate()%></td>
                                <td><%= r.getBalance()%></td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>

                    <div class="table-actions">
                        <button class="btn btn-pdf">Export PDF</button>
                        <button class="btn btn-excel">Export Excel</button>
                        <button class="btn btn-print">Print</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- jsPDF -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.29/jspdf.plugin.autotable.min.js"></script>

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
            window.onload = function () {

                /* ===== ADMIN NAME FROM SESSION (NO HARDCODE) ===== */
                const adminName = "<%= session.getAttribute("name") != null
            ? session.getAttribute("name"        ).toString()
                    : ""%>";

                /* ===== FILTER TABLE ===== */
                function filterTable() {
                    const leaveType = document.getElementById("leaveType").value;
                    const status = document.getElementById("status").value;
                    const startDate = document.getElementById("startDate").value;
                    const endDate = document.getElementById("endDate").value;

                    document.querySelectorAll("#leaveTable tbody tr").forEach(r => {
                        let show = true;

                        if (leaveType && r.cells[1].innerText.trim() !== leaveType)
                            show = false;
                        if (status && r.cells[2].innerText.trim().toUpperCase() !== status)
                            show = false;
                        if (startDate && r.cells[3].innerText < startDate)
                            show = false;
                        if (endDate && r.cells[4].innerText > endDate)
                            show = false;

                        r.style.display = show ? "" : "none";
                    });
                }

                /* ===== RESET FILTER ===== */
                function resetFilters() {
                    document.querySelectorAll("input, select").forEach(e => e.value = "");
                    document.querySelectorAll("#leaveTable tbody tr").forEach(r => r.style.display = "");
                }

                /* ===== EXPORT EXCEL ===== */
                function exportExcel() {
                    let csv = [];
                    document.querySelectorAll("#leaveTable tr").forEach((row, index) => {
                        if (index === 0 || row.style.display !== "none") {
                            csv.push([...row.children].map(c => `"${c.innerText}"`).join(","));
                        }
                    });
                    const blob = new Blob([csv.join("\n")], {type: "text/csv"});
                    const a = document.createElement("a");
                    a.href = URL.createObjectURL(blob);
                    a.download = "Leave_Record.csv";
                    a.click();
                }

                /* ===== PRINT ===== */
                function printSelected() {
                    let w = window.open("", "_blank");

                    let generatedBy = adminName
                            ? "<p><b>Generated by:</b> " + adminName + "</p>"
                            : "";

                    w.document.write(
                            "<html><head><title>Leave Record</title>" +
                            "<style>" +
                            "body{font-family:Poppins,Arial;padding:30px;color:#333;}" +
                            "table{width:100%;border-collapse:collapse;margin-top:15px;font-size:13px;}" +
                            "th,td{border:1px solid #aaa;padding:8px;text-align:center;}" +
                            "th{background:#f0f0f0;}" +
                            "</style></head><body>" +
                            "<h2 style='text-align:center'>TERLAJAK LARIS</h2>" +
                            "<h3 style='text-align:center;font-weight:normal'>Leave Record Report</h3>" +
                            generatedBy +
                            "<p><b>Date:</b> " + new Date().toLocaleDateString() + "</p>" +
                            document.getElementById("leaveTable").outerHTML +
                            "</body></html>"
                            );

                    w.document.close();
                    w.print();
                }

                /* ===== EXPORT PDF ===== */
                function exportPDF() {
                    const {jsPDF} = window.jspdf;
                    const doc = new jsPDF("p", "mm", "a4");

                    doc.setFont("helvetica", "bold");
                    doc.setFontSize(18);
                    doc.text("TERLAJAK LARIS", 105, 15, {align: "center"});

                    doc.setFontSize(14);
                    doc.text("Leave Record Report", 105, 23, {align: "center"});

                    doc.setFontSize(10);
                    doc.setFont("helvetica", "normal");

                    let y = 32;
                    if (adminName) {
                        doc.text("Generated by: " + adminName, 14, y);
                        y += 6;
                    }
                    doc.text("Date: " + new Date().toLocaleDateString(), 14, y);

                    let rows = [];
                    document.querySelectorAll("#leaveTable tbody tr").forEach(r => {
                        if (r.style.display !== "none") {
                            rows.push([
                                r.cells[0].innerText,
                                r.cells[1].innerText,
                                r.cells[2].innerText,
                                r.cells[3].innerText,
                                r.cells[4].innerText,
                                r.cells[5].innerText
                            ]);
                        }
                    });

                    if (!rows.length) {
                        alert("No records to export");
                        return;
                    }

                    doc.autoTable({
                        startY: y + 8,
                        head: [["ID", "Leave Type", "Status", "Start Date", "End Date", "Balance"]],
                        body: rows,
                        theme: "grid",
                        styles: {fontSize: 9, halign: "center"}
                    });

                    doc.save("Leave_Record_Report.pdf");
                }

                /* ===== BUTTON EVENT BINDING ===== */
                document.querySelector(".btn-generate").onclick = filterTable;
                document.querySelector(".btn-reset").onclick = resetFilters;
                document.querySelector(".btn-excel").onclick = exportExcel;
                document.querySelector(".btn-print").onclick = printSelected;
                document.querySelector(".btn-pdf").onclick = exportPDF;
            };
        </script>


    </body>
</html>
