<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="com.leave.model.LeavePolicyView"%>

<%
    String cp = request.getContextPath();
    String view = (String) request.getAttribute("view");
    if (view == null) view = "list";

    @SuppressWarnings("unchecked")
    List<LeavePolicyView> policies = (List<LeavePolicyView>) request.getAttribute("policies");
    LeavePolicyView policy = (LeavePolicyView) request.getAttribute("policy");

    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError = (String) request.getAttribute("flashError");

    if (policies == null) policies = Collections.emptyList();

    String profileImg = request.getAttribute("profileImg") == null ? "" : String.valueOf(request.getAttribute("profileImg"));
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Leave Policies - Admin</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * { box-sizing: border-box; font-family: "Poppins", sans-serif; }
        body { margin: 0; background: #f5f7fb; }
        .wrapper { display: flex; min-height: 100vh; }

        /* ===== SIDEBAR (match leave_history_admin.jsp) ===== */
        .sidebar {
            width: 260px;
            background: #0f172a;
            padding: 15px;
            transition: width 0.3s ease;
        }
        .sidebar.closed { width: 60px; }

        .brand {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ffffff;
        }
        .sidebar.closed .brand span:first-child { display: none; }
        .toggle-btn { cursor: pointer; }

        .profile {
            text-align: center;
            margin-bottom: 25px;
            transition: opacity 0.3s ease;
        }
        .sidebar.closed .profile { opacity: 0; pointer-events: none; }

        .profile img {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            object-fit: cover;
            background: #1e293b;
            margin-bottom: 10px;
        }
        .profile h4 {
            margin: 5px 0 0;
            font-size: 14px;
            color: #ffffff;
        }
        .profile p {
            margin: 0;
            font-size: 12px;
            color: #94a3b8;
        }

        .menu a,
        .menu-parent {
            display: flex;
            align-items: center;
            padding: 12px;
            margin-bottom: 6px;
            text-decoration: none;
            color: #dcdcdc;
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

        .menu a:hover,
        .menu-parent:hover { background: #1e293b; }

        .menu a.active {
            background: #ffffff;
            color: #0f172a;
            font-weight: bold;
        }

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
        .menu-group .submenu a { color: #cbd5f5; }

        /* Collapsed */
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
        .sidebar.closed .menu-parent span { display: none; }
        .sidebar.closed .menu-parent::after { display: none; }
        .sidebar.closed .submenu { margin-left: 0; align-items: center; }
        .sidebar.closed .submenu a { justify-content: center; padding: 10px 0; }
        .sidebar.closed .submenu a i { font-size: 16px; }

        /* ===== MAIN ===== */
        .main { flex: 1; padding: 20px; }

        .header {
            background: linear-gradient(to right, #0f172a, #94a3b8);
            padding: 18px;
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ffffff;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,.08);
            overflow-x: auto;
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .search {
            flex: 1;
            min-width: 240px;
        }
        .search input {
            width: 100%;
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        .btn {
            border: none;
            border-radius: 8px;
            padding: 10px 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-add { background: #2ea44f; color: #fff; }
        .btn-add:hover { filter: brightness(0.95); }
        .btn-edit { background: #6b7280; color: #fff; }
        .btn-delete { background: #d1242f; color: #fff; }
        .btn-secondary { background: #6b7280; color: #fff; }

        .actions { display: flex; gap: 8px; }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }
        th, td {
            padding: 14px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th { color: black; font-weight: 600; background: #f2f2f2; }
        td { color: #555; font-weight: 600; }

        .alert {
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 14px;
            font-size: 14px;
        }
        .alert-success { background:#eaffef; border:1px solid #b9f5c8; }
        .alert-error { background:#ffe9ea; border:1px solid #ffb9bf; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label { font-size: 13px; color: #333; }
        .form-group input, .form-group textarea, .form-group select {
            padding: 10px 12px;
            border: 1px solid #cfcfcf;
            border-radius: 8px;
            font-size: 14px;
        }
        textarea { min-height: 90px; resize: vertical; }
        .readonly { background: #eeeeee; }

        .form-actions { margin-top: 14px; display: flex; gap: 10px; justify-content: flex-end; }

        @media (max-width: 768px) {
            .wrapper { flex-direction: column; }
            .sidebar { width: 100%; }
            .sidebar.closed { width: 100%; }
            .header { font-size: 22px; text-align: center; }
            table { min-width: 650px; }
        }
        @media (max-width: 900px) { .form-grid { grid-template-columns: 1fr; } }
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
            <img src="<%= cp %>/profile-image?path=<%= profileImg %>" onerror="this.src='<%= cp %>/images/default_profile.png'">
            <h4><%= session.getAttribute("name") != null ? session.getAttribute("name") : "Admin User" %></h4>
            <p><%= session.getAttribute("position") != null ? session.getAttribute("position") : (session.getAttribute("role") != null ? session.getAttribute("role") : "Admin") %></p>
        </div>

        <div class="menu">
            <a href="<%= cp %>/AdminDashboardServlet"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
            <a href="<%= cp %>/admin/employeeInformation.jsp"><i class="fas fa-users"></i><span>Employees</span></a>
            <a href="<%= cp %>/LeavePolicyAdminServlet" class="active"><i class="fas fa-file-lines"></i><span>Policies</span></a>
            <a href="<%= cp %>/admin/GenerateRecord.jsp"><i class="fas fa-th-large"></i><span>Reports</span></a>

            <div class="menu-group">
                <div class="menu-parent"><i class="fas fa-user"></i><span>Personal</span></div>
                <div class="submenu">
                    <a href="<%= cp %>/ViewProfileAdminServlet"><i class="fas fa-id-badge"></i><span>Profile</span></a>
                    <a href="<%= cp %>/admin/apply_leave.jsp"><i class="fas fa-calendar-plus"></i><span>Apply Leave</span></a>
                    <a href="<%= cp %>/LeaveHistoryAdminServlet"><i class="fas fa-history"></i><span>Leave History</span></a>
                </div>
            </div>

            <a href="<%= cp %>/NotificationAdminServlet"><i class="fas fa-bell"></i><span>Notifications</span></a>
            <a href="<%= cp %>/LogoutServlet"><i class="fas fa-right-from-bracket"></i><span>Logout</span></a>
        </div>
    </div>

    <!-- ===== Main Content ===== -->
    <div class="main">
        <div class="header">Leave Policies</div>

        <div class="card">

            <% if (flashError != null && !flashError.isEmpty()) { %>
                <div class="alert alert-error"><i class="fas fa-triangle-exclamation"></i> <%= flashError %></div>
            <% } %>
            <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
                <div class="alert alert-success"><i class="fas fa-check"></i> <%= flashSuccess %></div>
            <% } %>

            <% if ("list".equals(view)) { %>

                <div class="toolbar">
                    <div class="search">
                        <input id="searchInput" type="text" placeholder="Search by type name / status / description...">
                    </div>
                    <a class="btn btn-add" href="<%= cp %>/LeavePolicyAdminServlet?action=new"><i class="fas fa-plus"></i> Add New</a>
                </div>

                <table id="policyTable">
                    <thead>
                        <tr>
                            <th>Type ID</th>
                            <th>Leave Type</th>
                            <th>Max Day Allowed</th>
                            <th>Status</th>
                            <th>Description</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (LeavePolicyView row : policies) { %>
                            <tr>
                                <td><%= row.getTypeId() %></td>
                                <td><%= row.getTypeName() == null ? "" : row.getTypeName() %></td>
                                <td><%= row.getMaxDays() == null ? "-" : row.getMaxDays() %></td>
                                <td><%= row.getStatus() == null ? "-" : row.getStatus() %></td>
                                <td><%= row.getDescription() == null ? "" : row.getDescription() %></td>
                                <td>
                                    <div class="actions">
                                        <a class="btn btn-edit" href="<%= cp %>/LeavePolicyAdminServlet?action=edit&typeId=<%= row.getTypeId() %>">Edit</a>
                                        <form method="post" action="<%= cp %>/LeavePolicyAdminServlet" style="margin:0" onsubmit="return confirm('Delete this leave type & policy?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="typeId" value="<%= row.getTypeId() %>">
                                            <button class="btn btn-delete" type="submit">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>

            <% } else if ("new".equals(view)) { %>

                <h3 style="margin-top:0">Add New Leave Type & Policy</h3>
                <form method="post" action="<%= cp %>/LeavePolicyAdminServlet">
                    <input type="hidden" name="action" value="create">

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Leave Type</label>
                            <input name="leaveType" required>
                        </div>
                        <div class="form-group">
                            <label>Max Day Allowed</label>
                            <input name="maxDays" type="number" min="1" required>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Active">Active</option>
                                <option value="Disabled">Disabled</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description"></textarea>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a class="btn btn-secondary" href="<%= cp %>/LeavePolicyAdminServlet?action=list">Back</a>
                        <button class="btn btn-add" type="submit">Add</button>
                    </div>
                </form>

            <% } else if ("edit".equals(view) && policy != null) { %>

                <h3 style="margin-top:0">Edit Leave Policy</h3>
                <form method="post" action="<%= cp %>/LeavePolicyAdminServlet">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="typeId" value="<%= policy.getTypeId() %>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Type ID</label>
                            <input class="readonly" value="<%= policy.getTypeId() %>" readonly>
                        </div>
                        <div class="form-group">
                            <label>Leave Type</label>
                            <input class="readonly" value="<%= policy.getTypeName() %>" readonly>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Max Day Allowed</label>
                            <input name="maxDays" type="number" min="1" value="<%= policy.getMaxDays()==null?"":policy.getMaxDays() %>" required>
                        </div>
                        <div class="form-group">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Active" <%= "Active".equalsIgnoreCase(policy.getStatus()) ? "selected" : "" %>>Active</option>
                                <option value="Disabled" <%= "Disabled".equalsIgnoreCase(policy.getStatus()) ? "selected" : "" %>>Disabled</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea name="description"><%= policy.getDescription()==null?"":policy.getDescription() %></textarea>
                    </div>

                    <div class="form-actions">
                        <a class="btn btn-secondary" href="<%= cp %>/LeavePolicyAdminServlet?action=list">Back</a>
                        <button class="btn btn-add" type="submit">Update</button>
                    </div>
                </form>

            <% } %>

        </div>
    </div>

</div>

<script>
    // Sidebar open/close
    (function(){
        var t = document.querySelector('.toggle-btn');
        if (t) t.addEventListener('click', function(){
            var sb = document.getElementById('sidebar');
            if (sb) sb.classList.toggle('closed');
        });
    })();

    // Dropdown Personal open/close
    (function(){
        document.querySelectorAll('.menu-group').forEach(function(group){
            var parent = group.querySelector('.menu-parent');
            var submenu = group.querySelector('.submenu');
            if (!parent || !submenu) return;
            parent.addEventListener('click', function(){
                parent.classList.toggle('open');
                submenu.classList.toggle('open');
            });
        });
    })();

    // Search filter (only on list view)
    (function(){
        var input = document.getElementById('searchInput');
        var table = document.getElementById('policyTable');
        if (!input || !table) return;
        input.addEventListener('keyup', function(){
            var q = (input.value || '').toLowerCase();
            var rows = table.querySelectorAll('tbody tr');
            rows.forEach(function(r){
                var txt = (r.innerText || '').toLowerCase();
                r.style.display = txt.indexOf(q) !== -1 ? '' : 'none';
            });
        });
    })();
</script>

</body>
</html>
