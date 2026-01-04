<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    /* ================= BASIC SETUP ================= */
    int empId = Integer.parseInt(request.getParameter("id"));

    Connection conn = null;
    PreparedStatement psEmp = null;
    PreparedStatement psLeave = null;
    ResultSet rsEmp = null;
    ResultSet rsLeave = null;

    /* employee fields */
    String name="", email="", department="", role="", position="", address="";
    Date dob = null, admissionDate = null;

    try {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        conn = DriverManager.getConnection(
            "jdbc:derby://localhost:1527/LeaveDB","app","app"
        );

        /* ================= EMPLOYEE INFO ================= */
        psEmp = conn.prepareStatement(
            "SELECT * FROM employee WHERE employee_id=?"
        );
        psEmp.setInt(1, empId);
        rsEmp = psEmp.executeQuery();

        if (rsEmp.next()) {
            name = rsEmp.getString("name");
            email = rsEmp.getString("email");
            department = rsEmp.getString("department");
            role = rsEmp.getString("role");
            position = rsEmp.getString("position");
            address = rsEmp.getString("address");
            dob = rsEmp.getDate("date_of_birth");
            admissionDate = rsEmp.getDate("admission_date");
        }

        /* ================= LEAVE INFO (DYNAMIC) ================= */
        psLeave = conn.prepareStatement(
            "SELECT lt.type_id, lt.name, elb.balance " +
            "FROM employee_leave_balance elb " +
            "JOIN leave_type lt ON elb.type_id = lt.type_id " +
            "WHERE elb.employee_id=? " +
            "ORDER BY lt.type_id"
        );
        psLeave.setInt(1, empId);
        rsLeave = psLeave.executeQuery();

    } catch(Exception e){
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Employee Information</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/employeeUpdatePage.css">
        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>

    <body>
        <div class="wrapper">

            <!-- ================= SIDEBAR (UNCHANGED) ================= -->
            <div class="sidebar" id="sidebar">
                <!-- Brand / Toggle -->
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

            <!-- ================= MAIN FORM ================= -->
            <form class="main" id="employeeForm"
                  method="post"
                  action="${pageContext.request.contextPath}/updateEmployeeServlet">

                <input type="hidden" name="employeeId" value="<%= empId %>">

                <div class="page-title">Employee Information</div>

                <div class="page-content">

                    <!-- HEADER -->
                    <div class="card profile-header">
                        <div class="profile-left">
                            <img src="https://i.imgur.com/7k12EPD.png">
                            <div>
                                <h2><%= name %></h2>
                                <p><%= email %></p>
                            </div>
                        </div>
                        <div class="status">Available</div>
                    </div>

                    <!-- PERSONAL INFO -->
                    <div class="card">
                        <h3>Personal Information</h3>

                        <div class="form-grid">
                            <div class="form-group">
                                <label>Employee ID</label>
                                <input type="text" value="<%= empId %>" disabled>
                            </div>

                            <div class="form-group">
                                <label>Full Name</label>
                                <input type="text" name="name" value="<%= name %>">
                            </div>

                            <div class="form-group">
                                <label>Date of Birth</label>
                                <input type="date" name="dob"
                                       value="<%= dob == null ? "" : dob.toString() %>">
                            </div>

                            <div class="form-group">
                                <label>Email</label>
                                <input type="text" name="email" value="<%= email %>">
                            </div>

                            <div class="form-group">
                                <label>Role</label>
                                <select name="role">
                                    <option value="ADMIN" <%= "ADMIN".equals(role)?"selected":"" %>>ADMIN</option>
                                    <option value="STAFF" <%= "STAFF".equals(role)?"selected":"" %>>STAFF</option>
                                    <option value="HOD"   <%= "HOD".equals(role)?"selected":"" %>>HOD</option>
                                    <option value="CEO"   <%= "CEO".equals(role)?"selected":"" %>>CEO</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Department</label>
                                <input type="text" name="department" value="<%= department %>">
                            </div>

                            <div class="form-group">
                                <label>Position</label>
                                <input type="text" name="position" value="<%= position %>">
                            </div>

                            <div class="form-group">
                                <label>Admission Date</label>
                                <input type="date" name="admissionDate"
                                       value="<%= admissionDate == null ? "" : admissionDate.toString() %>">
                            </div>

                            <div class="form-group full">
                                <label>Address</label>
                                <textarea name="address"><%= address %></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- LEAVE INFO (DYNAMIC) -->
                    <div class="card">
                        <h3>Leave Information</h3>
                        <div class="form-grid">

                            <%
                            while (rsLeave.next()) {
                                int typeId = rsLeave.getInt("type_id");
                                String leaveName = rsLeave.getString("name");
                                int balance = rsLeave.getInt("balance");
                            %>

                            <div class="form-group">
                                <label><%= leaveName %> Leave</label>
                                <input type="number"
                                    name="leave_<%= typeId %>"
                                    value="<%= balance %>"
                                    onfocus="this.defaultValue = this.value">

                            </div>

                            <%
                            }
                            %>

                        </div>
                    </div>

                    <!-- ACTIONS -->
                    <div class="form-actions">
                        <button type="button" class="btn-back" onclick="confirmBack()">Back</button>
                        <button type="button" class="btn-cancel" onclick="confirmCancel()">Cancel</button>
                        <button type="button" class="btn-submit" onclick="confirmSubmit()">Submit</button>
                    </div>

                </div>
            </form>
        </div>

        <script>
            /* ================= SIDEBAR LOGIC ================= */
            document.querySelector(".toggle-btn")?.addEventListener("click", () => {
                document.getElementById("sidebar").classList.toggle("closed");
            });

            document.querySelectorAll(".menu-group").forEach(group => {
                const parent = group.querySelector(".menu-parent");
                const submenu = group.querySelector(".submenu");
                parent?.addEventListener("click", () => {
                    parent.classList.toggle("open");
                    submenu?.classList.toggle("open");
                });
            });

            /* ================= FORM ACTIONS ================= */

            // CANCEL → restore DB-loaded values (SAFE)
            function confirmCancel() {
                if (confirm("Discard all changes?")) {
                    document.getElementById("employeeForm").reset();
                }
            }

            // SUBMIT → always submit
            function confirmSubmit() {
                if (confirm("Are you sure want to submit?")) {
                    document.getElementById("employeeForm").submit();
                }
            }

            // BACK → just go back
            function confirmBack() {
                if (confirm("Go back without saving changes?")) {
                    window.location.href = "employeeInformation.jsp";
                }
            }


            /* ================= VALIDATION ================= */
            document.addEventListener("DOMContentLoaded", () => {
                document.querySelectorAll('input[type="number"]').forEach(input => {
                    input.addEventListener("input", () => {
                        if (input.value < 0) input.value = 0;
                    });
                });
            });

        </script>
    </body>
</html>

<%
    
/* ================= CLEAN UP ================= */
if (rsEmp != null) rsEmp.close();
if (psEmp != null) psEmp.close();
if (rsLeave != null) rsLeave.close();
if (psLeave != null) psLeave.close();
if (conn != null) conn.close();

%>
