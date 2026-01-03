<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
    
    <head>
        <meta charset="UTF-8">
        <title>Employee Information Interface</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        
        <!-- Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/employeeInformation.css">
    </head>

    <body>
        <div class="wrapper">

            <!-- ================= SIDEBAR ================= -->
            <!-- 🔴 UNCHANGED -->
            <div class="sidebar" id="sidebar">
                <!-- Brand / Toggle -->
                <div class="brand">
                    <span>TERLAJAK LARIS</span>
                    <span class="toggle-btn">☰</span>
                </div>

                <div class="profile">
                    <img src="https://i.imgur.com/7k12EPD.png">
                    <h4>AMIRUL AIMAN BIN LEO</h4>
                    <p>Admin</p>
                </div>

                <!-- Navigation Menu -->
                <div class="menu">
                    <a href="<%= request.getContextPath()%>/AdminDashboardServlet"><i class="fas fa-th-large"></i><span>Dashboard</span></a>        
                    <a href="<%= request.getContextPath()%>/employeeInformation.jsp" class="active"><i class="fas fa-users"></i><span>Employees</span></a>
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
            <!-- ================= MAIN CONTENT ================= -->
            <div class="content">
                
                <div class="page-title">Employee Information</div>
                
                <!-- Toolbar (UNCHANGED) -->
                <div class="toolbar">
                    <select id="sortField">
                        <option value="">Any</option>
                        <option value="id">ID</option>
                        <option value="name">Name</option>
                        <option value="position">Position</option>
                        <option value="department">Department</option>
                    </select>

                    <select id="sortOrder">
                        <option value="">Any</option>
                        <option value="asc">Ascending</option>
                        <option value="desc">Descending</option>
                    </select>

                    <button class="btn btn-filter" id="openFilter">
                        <i class="fas fa-filter"></i> Filter
                    </button>

                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input id="searchInput" placeholder="Search">
                    </div>

                    <button class="btn btn-add"
                            onclick="location.href='addEmployeeInformation.jsp'">
                        Add Employee
                    </button>
                </div>

                <div class="employee-section">
                    <div id="employeeList"></div>
                </div>
            </div>
        </div>

        <!-- ================= FILTER MODAL (UNCHANGED) ================= -->
        <div class="filter-modal" id="filterModal">
            <div class="filter-box">
                <h3>Filter Employees</h3>

                <select id="filterDept">
                    <option value="">Any</option>
                </select>


                <label>Position</label>
                <select id="filterPosition">
                    <option value="">Any</option>
                </select>

                <label>Status</label>
                <select id="filterStatus">
                    <option value="">Any</option>
                    <option>Available</option>
                    <option>Unavailable</option>
                </select>

                <div class="filter-actions">
                    <button class="btn" id="resetFilter">Reset</button>
                    <button class="btn btn-add" id="applyFilter">Apply</button>
                </div>
            </div>
        </div>
    

        <!-- ================= SCRIPT ================= -->
        <script>
            /* ================= SIDEBAR LOGIC ================= */
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

            /* ===== DOM ELEMENTS (MUST COME FIRST) ===== */
            const list = document.getElementById("employeeList");
            const searchInput = document.getElementById("searchInput");
            const sortField = document.getElementById("sortField");
            const sortOrder = document.getElementById("sortOrder");
            const filterDept = document.getElementById("filterDept");
            const filterPosition = document.getElementById("filterPosition");
            const filterStatus = document.getElementById("filterStatus");

            /* ===== RENDER FUNCTION (UNCHANGED UI) ===== */
            function render(data) {
                list.innerHTML = "";

                if (data.length === 0) {
                    list.innerHTML = "<p style='text-align:center;'>No employees found</p>";
                    return;
                }

                data.forEach(emp => {
                    const row = document.createElement("div");
                    row.className = "employee-row";

                    const statusClass = (emp.status === "Unavailable") ? "on-leave" : "available";

                    row.innerHTML =
                        '<div class="emp-id">' + emp.id + '</div>' +

                        '<div class="emp-avatar">' +
                            '<img src="https://i.imgur.com/7k12EPD.png" alt="Employee">' +
                        '</div>' +

                        '<div class="emp-name">' + emp.name + '</div>' +
                        '<div class="emp-position">' + emp.position + '</div>' +
                        '<div class="emp-department">' + emp.department + '</div>' +

                        '<div class="status ' + (emp.status === "Unavailable" ? "leave" : "available") + '">' +
                            (emp.status === "Unavailable" ? "On Leave" : "Available") +
                        '</div>' +

                        '<div class="emp-action">' +
                            '<i class="fas fa-pen edit-btn" ' +
                               'onclick="location.href=\'employeeUpdatePage.jsp?id=' + emp.id + '\'">' +
                            '</i>' +
                        '</div>';
                
                    list.appendChild(row);
                });
            }

            /* ===== FETCH DATA FROM SERVLET ===== */
            let employees = [];

            fetch("${pageContext.request.contextPath}/EmployeeInformationServlet")
                .then(res => res.json())
                .then(data => {
                    employees = data;
                    render(employees);
                    populateFilters(employees); // 🔥 important
                })
                .catch(err => console.error("Fetch error:", err));


            /* ===== YOUR EXISTING FILTER / SORT / SEARCH JS CONTINUES BELOW ===== */
            function applyAll() {
                let result = [...employees];

                // SEARCH
                const q = searchInput.value.toLowerCase();
                if (q) {
                    result = result.filter(e =>
                        e.name.toLowerCase().includes(q) ||
                        e.position.toLowerCase().includes(q) ||
                        e.department.toLowerCase().includes(q)
                    );
                }

                // FILTER
                if (filterDept.value) {
                    result = result.filter(e => e.department === filterDept.value);
                }
                if (filterPosition.value) {
                    result = result.filter(e => e.position === filterPosition.value);
                }
                if (filterStatus.value) {
                    result = result.filter(e => e.status === filterStatus.value);
                }
                


                // SORT
               if (sortField.value && sortOrder.value) {
                    result.sort((a, b) => {
                        let v1 = a[sortField.value];
                        let v2 = b[sortField.value];

                        if (typeof v1 === "string") v1 = v1.toLowerCase();
                        if (typeof v2 === "string") v2 = v2.toLowerCase();

                        if (v1 < v2) return sortOrder.value === "desc" ? 1 : -1;
                        if (v1 > v2) return sortOrder.value === "desc" ? -1 : 1;
                        return 0;
                    });
                }

                render(result);
            }
            
            searchInput.oninput = applyAll;
            sortField.onchange = applyAll;
            sortOrder.onchange = applyAll;
            document.getElementById("applyFilter").onclick = applyAll;
            document.getElementById("resetFilter").onclick = () => {
                filterDept.value = "";
                filterPosition.value = "";
                filterStatus.value = "";
                sortField.value = "";
                sortOrder.value = "";
                searchInput.value = "";
                render(employees);
            };

            
            function populateFilters(data) {
                const deptSet = new Set();

                data.forEach(e => {
                    deptSet.add(e.department);
                });

                filterDept.innerHTML = '<option value="">Any</option>';
                filterPosition.innerHTML = '<option value="">Any</option>';

                deptSet.forEach(d => {
                    const opt = document.createElement("option");
                    opt.value = d;
                    opt.textContent = d;
                    filterDept.appendChild(opt);
                });
            }

            function updatePositionFilter() {
                const selectedDept = filterDept.value;

                filterPosition.innerHTML = '<option value="">Any</option>';

                let filtered = employees;

                if (selectedDept) {
                    filtered = employees.filter(e => e.department === selectedDept);
                }

                const posSet = new Set();
                filtered.forEach(e => posSet.add(e.position));

                posSet.forEach(p => {
                    const opt = document.createElement("option");
                    opt.value = p;
                    opt.textContent = p;
                    filterPosition.appendChild(opt);
                });
            }
            
            filterDept.onchange = () => {
                updatePositionFilter();
                applyAll(); // re-filter list immediately
            };




        </script>
    </body>
</html>
