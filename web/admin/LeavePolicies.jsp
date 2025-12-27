<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="com.leave.model.LeavePolicyView"%>

<%
    String view = (String) request.getAttribute("view");
    if (view == null) view = "list";

    @SuppressWarnings("unchecked")
    List<LeavePolicyView> policies = (List<LeavePolicyView>) request.getAttribute("policies");
    LeavePolicyView p = (LeavePolicyView) request.getAttribute("policy");

    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError = (String) request.getAttribute("flashError");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Policies - Admin</title>

    <!-- Match existing admin pages deps -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * { box-sizing: border-box; font-family: "Segoe UI", sans-serif; }
        body { margin: 0; background: #f2f2f2; }
        .wrapper { display: flex; min-height: 100vh; }

        /* Sidebar (same feel as leave_history_admin.html) */
        .sidebar { width: 260px; background: #e0e0e0; padding: 15px; transition: width 0.3s ease; }
        .sidebar.closed { width: 60px; }
        .brand { display:flex; justify-content:space-between; align-items:center; font-weight:bold; margin-bottom:20px; }
        .sidebar.closed .brand span:first-child { display:none; }
        .profile { text-align:center; margin-bottom:25px; transition: opacity 0.3s ease; }
        .sidebar.closed .profile { opacity:0; pointer-events:none; }
        .profile img { width:70px; height:70px; border-radius:50%; object-fit:cover; background:#ccc; margin-bottom:10px; }
        .profile h4 { margin:5px 0 0; font-size:14px; }
        .profile p { margin:0; font-size:12px; color:#555; }

        .menu a, .menu-parent { display:flex; align-items:center; padding:12px; margin-bottom:6px; text-decoration:none; color:#000; border-radius:6px; font-size:14px; gap:12px; }
        .menu a i { width:20px; text-align:center; font-size:16px; }
        .menu a:hover, .menu-parent:hover { background:#cfcfcf; }
        .menu a.active { background:#bdbdbd; font-weight:bold; }

        .menu-group .menu-parent { font-weight:600; }
        .menu-group .menu-parent::after { content:"▼"; font-size:10px; margin-left:auto; margin-right:10px; transition: transform 0.2s ease; }
        .menu-group .menu-parent.open::after { transform: rotate(180deg); }
        .menu-group .submenu { margin-left:32px; display:none; flex-direction:column; }
        .menu-group .submenu.open { display:flex; }

        /* Collapse mode */
        .sidebar.closed .menu a, .sidebar.closed .menu-parent { justify-content:center; padding:12px 0; font-size:0; gap:0; }
        .sidebar.closed .menu a i, .sidebar.closed .menu-parent i { font-size:18px; width:auto; }
        .sidebar.closed .menu a span, .sidebar.closed .menu-parent span { display:none; }
        .sidebar.closed .menu-parent::after { display:none; }
        .sidebar.closed .submenu { margin-left:0; align-items:center; }
        .sidebar.closed .submenu a { justify-content:center; padding:10px 0; gap:0; }
        .sidebar.closed .submenu a i { font-size:16px; }

        /* Main */
        .main { flex:1; padding:20px; }
        .header { background: linear-gradient(to right, #bdbdbd, #eeeeee); padding:18px; font-size:32px; font-weight:bold; margin-bottom:20px; }
        .card { background:#fff; border-radius:10px; padding:20px; box-shadow:0 2px 6px rgba(0,0,0,0.15); }

        .toolbar { display:flex; justify-content:space-between; gap:12px; align-items:center; margin-bottom:15px; flex-wrap:wrap; }
        .search { flex:1; min-width:240px; }
        .search input { width:100%; padding:10px 12px; border:1px solid #cfcfcf; border-radius:8px; font-size:14px; }

        .btn { border:none; border-radius:8px; padding:10px 14px; font-weight:600; cursor:pointer; }
        .btn-primary { background:#4caf50; color:white; }
        .btn-primary:hover { filter:brightness(0.95); }
        .btn-secondary { background:#9e9e9e; color:white; }
        .btn-secondary:hover { filter:brightness(0.95); }
        .btn-danger { background:#e53935; color:white; }
        .btn-danger:hover { filter:brightness(0.95); }

        table { width:100%; border-collapse:collapse; }
        th, td { padding:12px; border-bottom:1px solid #ddd; text-align:left; font-size:14px; }
        th { background:#f5f5f5; }

        .actions { display:flex; gap:8px; }

        .alert { padding:12px 14px; border-radius:10px; margin-bottom:14px; font-size:14px; }
        .alert-success { background:#e8f5e9; border:1px solid #c8e6c9; }
        .alert-error { background:#ffebee; border:1px solid #ffcdd2; }

        .form-grid { display:grid; grid-template-columns: 1fr 1fr; gap:12px; }
        .form-group { display:flex; flex-direction:column; gap:6px; }
        .form-group label { font-size:13px; color:#333; }
        .form-group input, .form-group textarea, .form-group select {
            padding:10px 12px; border:1px solid #cfcfcf; border-radius:8px; font-size:14px;
        }
        textarea { min-height:90px; resize:vertical; }
        .readonly { background:#eeeeee; }

        .form-actions { margin-top:14px; display:flex; gap:10px; }
        @media (max-width: 900px) { .form-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="wrapper">

    <aside class="sidebar" id="sidebar">
        <div class="brand">
            <span>TERLAJAK LARIS</span>
            <i class="fa-solid fa-bars" style="cursor:pointer" onclick="toggleSidebar()"></i>
        </div>

        <div class="profile">
            <img src="../images/default_profile.png" alt="Profile">
            <h4>ADMIN</h4>
            <p>Administrator</p>
        </div>

        <nav class="menu">
            <a href="admin_dashboard.html"><i class="fa-solid fa-house"></i><span>Dashboard</span></a>
            <a class="active" href="../LeavePolicyAdminServlet?action=list"><i class="fa-solid fa-file-lines"></i><span>Policies</span></a>

            <div class="menu-group">
                <div class="menu-parent" onclick="toggleSubmenu()"><i class="fa-solid fa-user"></i><span>Personal</span></div>
                <div class="submenu" id="submenu">
                    <a href="../staff/profile.jsp"><i class="fa-solid fa-id-card"></i><span>Profile</span></a>
                    <a href="../staff/apply_leave.jsp"><i class="fa-solid fa-calendar-plus"></i><span>Apply Leave</span></a>
                    <a href="leave_history_admin.html"><i class="fa-solid fa-clock-rotate-left"></i><span>Leave History</span></a>
                </div>
            </div>

            <a href="../staff/notification.html"><i class="fa-solid fa-bell"></i><span>Notifications</span></a>
            <a href="../login.jsp"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a>
        </nav>
    </aside>

    <main class="main">
        <div class="header">Leave Policies</div>

        <div class="card">
            <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
                <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> <%= flashSuccess %></div>
            <% } %>
            <% if (flashError != null && !flashError.isEmpty()) { %>
                <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> <%= flashError %></div>
            <% } %>

            <% if ("list".equals(view)) { %>

                <div class="toolbar">
                    <div class="search">
                        <input id="searchInput" type="text" placeholder="Search by type name / status / description..." onkeyup="filterTable()">
                    </div>
                    <a class="btn btn-primary" href="../LeavePolicyAdminServlet?action=new"><i class="fa-solid fa-plus"></i> Add New</a>
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
                    <% if (policies != null) {
                        for (LeavePolicyView row : policies) {
                    %>
                        <tr>
                            <td><%= row.getTypeId() %></td>
                            <td><%= row.getTypeName() == null ? "" : row.getTypeName() %></td>
                            <td><%= row.getMaxDays() == null ? "-" : row.getMaxDays() %></td>
                            <td><%= row.getStatus() == null ? "-" : row.getStatus() %></td>
                            <td><%= row.getDescription() == null ? "" : row.getDescription() %></td>
                            <td>
                                <div class="actions">
                                    <a class="btn btn-secondary" href="../LeavePolicyAdminServlet?action=edit&typeId=<%= row.getTypeId() %>">
                                        <i class="fa-solid fa-pen-to-square"></i> Edit
                                    </a>
                                    <form method="post" action="../LeavePolicyAdminServlet" style="margin:0" onsubmit="return confirm('Delete this leave type & policy?');">
                                        <input type="hidden" name="action" value="delete" />
                                        <input type="hidden" name="typeId" value="<%= row.getTypeId() %>" />
                                        <button class="btn btn-danger" type="submit"><i class="fa-solid fa-trash"></i> Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <%  }
                       } %>
                    </tbody>
                </table>

            <% } else { %>

                <%
                    boolean isEdit = "edit".equals(view);
                    String formAction = isEdit ? "update" : "create";
                    String title = isEdit ? "Edit Policy" : "Add New Leave Type & Policy";
                %>
                <h3 style="margin-top:0"><%= title %></h3>

                <form method="post" action="../LeavePolicyAdminServlet">
                    <input type="hidden" name="action" value="<%= formAction %>" />

                    <div class="form-grid">
                        <% if (isEdit) { %>
                        <div class="form-group">
                            <label>Type ID</label>
                            <input name="typeId" value="<%= p != null ? p.getTypeId() : "" %>" readonly class="readonly" />
                        </div>
                        <% } else { %>
                        <input type="hidden" name="typeId" value="" />
                        <% } %>

                        <div class="form-group">
                            <label>Leave Type</label>
                            <input name="leaveType" value="<%= isEdit && p != null ? (p.getTypeName()==null?"":p.getTypeName()) : "" %>" <%= isEdit ? "readonly class='readonly'" : "" %> required />
                        </div>

                        <div class="form-group">
                            <label>Max Day Allowed</label>
                            <input type="number" name="maxDays" min="1" value="<%= isEdit && p != null && p.getMaxDays()!=null ? p.getMaxDays() : "" %>" required />
                        </div>

                        <div class="form-group">
                            <label>Status</label>
                            <select name="status" required>
                                <%
                                    String st = (isEdit && p != null && p.getStatus()!=null) ? p.getStatus() : "";
                                %>
                                <option value="" <%= st.isEmpty() ? "selected" : "" %>>-- Select --</option>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(st) ? "selected" : "" %>>ACTIVE</option>
                                <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(st) ? "selected" : "" %>>INACTIVE</option>
                            </select>
                        </div>

                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Description</label>
                            <textarea name="description" placeholder="Optional"><%= isEdit && p != null && p.getDescription()!=null ? p.getDescription() : "" %></textarea>
                        </div>
                    </div>

                    <% if (!isEdit) { %>
                        <div style="margin-top:10px; font-size:12px; color:#666;">
                            <i class="fa-solid fa-circle-info"></i> Type ID will be auto-generated by the database.
                        </div>
                    <% } %>

                    <div class="form-actions">
                        <button class="btn btn-primary" type="submit"><i class="fa-solid fa-floppy-disk"></i> Save</button>
                        <a class="btn btn-secondary" href="../LeavePolicyAdminServlet?action=list"><i class="fa-solid fa-arrow-left"></i> Back</a>
                    </div>
                </form>

            <% } %>

        </div>
    </main>

</div>

<script>
    function toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('closed');
    }
    function toggleSubmenu() {
        document.getElementById('submenu').classList.toggle('open');
        const parent = document.querySelector('.menu-parent');
        parent.classList.toggle('open');
    }
    function filterTable() {
        const input = document.getElementById('searchInput');
        if (!input) return;
        const filter = input.value.toLowerCase();
        const table = document.getElementById('policyTable');
        const tr = table.getElementsByTagName('tr');
        for (let i = 1; i < tr.length; i++) {
            const tds = tr[i].getElementsByTagName('td');
            let rowText = '';
            for (let j = 0; j < tds.length; j++) rowText += (tds[j].innerText || '').toLowerCase() + ' ';
            tr[i].style.display = rowText.includes(filter) ? '' : 'none';
        }
    }
</script>

</body>
</html>
