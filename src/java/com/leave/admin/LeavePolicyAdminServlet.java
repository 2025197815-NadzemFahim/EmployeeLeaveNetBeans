package com.leave.admin;

import com.leave.model.LeavePolicyView;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Admin CRUD for Leave Type + Leave Policy.
 *
 * UI rules (based on your requirement):
 * - List shows Type ID, Leave Type, Max Day Allowed, Status, Description, Action (Edit/Delete).
 * - Edit: Type ID + Leave Type are readonly.
 * - Add New: NO Type ID input (auto-increment in DB).
 */
@WebServlet(name = "LeavePolicyAdminServlet", urlPatterns = {"/LeavePolicyAdminServlet"})
public class LeavePolicyAdminServlet extends HttpServlet {

    // Match existing project DB settings
    private static final String DB_URL_PRIMARY  = "jdbc:derby://localhost:1527/EmployeeLeave;create=true";
    private static final String DB_URL_FALLBACK = "jdbc:derby://localhost:1527/LeaveDB;create=true";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    private Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(DB_URL_PRIMARY, DB_USER, DB_PASS);
        } catch (SQLException primaryEx) {
            // Fallback for older local setups
            return DriverManager.getConnection(DB_URL_FALLBACK, DB_USER, DB_PASS);
        }
    }

    private void flash(HttpServletRequest req, String key, String value) {
        HttpSession s = req.getSession();
        s.setAttribute(key, value);
    }

    private String consumeFlash(HttpServletRequest req, String key) {
        HttpSession s = req.getSession(false);
        if (s == null) return null;
        Object v = s.getAttribute(key);
        if (v != null) s.removeAttribute(key);
        return v == null ? null : v.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) action = "list";

        // Flash messages (POST-Redirect-GET)
        request.setAttribute("flashSuccess", consumeFlash(request, "flashSuccess"));
        request.setAttribute("flashError", consumeFlash(request, "flashError"));

        try {
            switch (action) {
                case "new":
                    request.setAttribute("view", "new");
                    forward(request, response);
                    break;

                case "edit":
                    int typeId = parseInt(request.getParameter("typeId"), -1);
                    if (typeId <= 0) {
                        flash(request, "flashError", "Invalid Type ID.");
                        response.sendRedirect(request.getContextPath() + "/LeavePolicyAdminServlet?action=list");
                        return;
                    }
                    LeavePolicyView item = fetchByTypeId(typeId);
                    if (item == null) {
                        flash(request, "flashError", "Record not found for Type ID " + typeId + ".");
                        response.sendRedirect(request.getContextPath() + "/LeavePolicyAdminServlet?action=list");
                        return;
                    }
                    request.setAttribute("view", "edit");
                    request.setAttribute("policy", item);
                    forward(request, response);
                    break;

                case "list":
                default:
                    request.setAttribute("view", "list");
                    request.setAttribute("policies", fetchAll());
                    forward(request, response);
                    break;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("flashError", "Database error: " + e.getMessage());
            request.setAttribute("view", "list");
            try {
                request.setAttribute("policies", fetchAll());
            } catch (SQLException ignored) {}
            forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("flashError", "Unexpected error: " + e.getMessage());
            request.setAttribute("view", "list");
            try { request.setAttribute("policies", fetchAll()); } catch (SQLException ignored) {}
            forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create":
                    handleCreate(request);
                    flash(request, "flashSuccess", "New leave type & policy added.");
                    break;

                case "update":
                    handleUpdate(request);
                    flash(request, "flashSuccess", "Policy updated.");
                    break;

                case "delete":
                    handleDelete(request);
                    flash(request, "flashSuccess", "Policy deleted.");
                    break;

                default:
                    flash(request, "flashError", "Unknown action.");
            }

        } catch (IllegalArgumentException ex) {
            flash(request, "flashError", ex.getMessage());
        } catch (SQLException ex) {
            ex.printStackTrace();
            flash(request, "flashError", "Database error: " + ex.getMessage());
        } catch (Exception ex) {
            ex.printStackTrace();
            flash(request, "flashError", "Unexpected error: " + ex.getMessage());
        }

        // Use absolute (context-aware) redirects to avoid path issues
        response.sendRedirect(request.getContextPath() + "/LeavePolicyAdminServlet?action=list");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Keep in sync with existing project file naming
        // (the JSP file in this project is "LeavePolicies.jsp")
        RequestDispatcher rd = request.getRequestDispatcher("/admin/LeavePolicies.jsp");
        rd.forward(request, response);
    }

    private int parseInt(String s, int fallback) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return fallback;
        }
    }

    private List<LeavePolicyView> fetchAll() throws SQLException {
        List<LeavePolicyView> out = new ArrayList<>();
        String sql = "SELECT lt.type_id, lt.name, lt.description, "
                   + "lp.policy_id, lp.max_days, lp.status "
                   + "FROM leave_type lt "
                   + "LEFT JOIN leave_policy lp ON lt.type_id = lp.type_id "
                   + "ORDER BY lt.type_id";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                LeavePolicyView v = new LeavePolicyView();
                v.setTypeId(rs.getInt("type_id"));
                v.setTypeName(rs.getString("name"));
                v.setDescription(rs.getString("description"));

                int pid = rs.getInt("policy_id");
                v.setPolicyId(rs.wasNull() ? null : pid);

                int md = rs.getInt("max_days");
                v.setMaxDays(rs.wasNull() ? null : md);

                v.setStatus(rs.getString("status"));
                out.add(v);
            }
        }
        return out;
    }

    private LeavePolicyView fetchByTypeId(int typeId) throws SQLException {
        String sql = "SELECT lt.type_id, lt.name, lt.description, "
                   + "lp.policy_id, lp.max_days, lp.status "
                   + "FROM leave_type lt "
                   + "LEFT JOIN leave_policy lp ON lt.type_id = lp.type_id "
                   + "WHERE lt.type_id = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                LeavePolicyView v = new LeavePolicyView();
                v.setTypeId(rs.getInt("type_id"));
                v.setTypeName(rs.getString("name"));
                v.setDescription(rs.getString("description"));

                int pid = rs.getInt("policy_id");
                v.setPolicyId(rs.wasNull() ? null : pid);

                int md = rs.getInt("max_days");
                v.setMaxDays(rs.wasNull() ? null : md);

                v.setStatus(rs.getString("status"));
                return v;
            }
        }
    }

    private void handleCreate(HttpServletRequest request) throws SQLException {
        String name = trimOrNull(request.getParameter("leaveType"));
        String desc = trimOrNull(request.getParameter("description"));
        Integer maxDays = parseIntObj(request.getParameter("maxDays"));
        String status = trimOrNull(request.getParameter("status"));

        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("Leave Type is required.");
        }
        if (maxDays == null || maxDays <= 0) {
            throw new IllegalArgumentException("Max Day Allowed must be a positive number.");
        }
        if (status == null || status.isEmpty()) {
            throw new IllegalArgumentException("Status is required.");
        }

        // Create leave_type (type_id auto-generated)
        String sqlType = "INSERT INTO leave_type (name, description) VALUES (?, ?)";
        String sqlPolicy = "INSERT INTO leave_policy (max_days, type_id, status) VALUES (?, ?, ?)";

        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            int newTypeId;

            try (PreparedStatement ps = c.prepareStatement(sqlType, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, name);
                ps.setString(2, desc);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        newTypeId = keys.getInt(1);
                    } else {
                        // Derby fallback: fetch last identity in this connection
                        try (Statement st = c.createStatement();
                             ResultSet rs = st.executeQuery("VALUES IDENTITY_VAL_LOCAL()")) {
                            rs.next();
                            newTypeId = rs.getInt(1);
                        }
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(sqlPolicy)) {
                ps.setInt(1, maxDays);
                ps.setInt(2, newTypeId);
                ps.setString(3, status);
                ps.executeUpdate();
            }

            // Also initialize employee leave balance for this new type (one row per employee)
            String sqlEmp = "SELECT employee_id FROM employee";
            String sqlBal = "INSERT INTO employee_leave_balance (employee_id, type_id, balance) VALUES (?, ?, ?)";
            try (Statement st = c.createStatement();
                 ResultSet rs = st.executeQuery(sqlEmp);
                 PreparedStatement psBal = c.prepareStatement(sqlBal)) {

                while (rs.next()) {
                    int empId = rs.getInt(1);
                    psBal.setInt(1, empId);
                    psBal.setInt(2, newTypeId);
                    psBal.setInt(3, maxDays);
                    psBal.addBatch();
                }
                psBal.executeBatch();
            }

            c.commit();
        }
    }

    private void handleUpdate(HttpServletRequest request) throws SQLException {
        int typeId = parseInt(request.getParameter("typeId"), -1);
        if (typeId <= 0) {
            throw new IllegalArgumentException("Invalid Type ID.");
        }

        String desc = trimOrNull(request.getParameter("description"));
        Integer maxDays = parseIntObj(request.getParameter("maxDays"));
        String status = trimOrNull(request.getParameter("status"));

        if (maxDays == null || maxDays <= 0) {
            throw new IllegalArgumentException("Max Day Allowed must be a positive number.");
        }
        if (status == null || status.isEmpty()) {
            throw new IllegalArgumentException("Status is required.");
        }

        String sqlUpdateType = "UPDATE leave_type SET description=? WHERE type_id=?";
        String sqlUpdatePolicy = "UPDATE leave_policy SET max_days=?, status=? WHERE type_id=?";
        String sqlInsertPolicy = "INSERT INTO leave_policy (max_days, type_id, status) VALUES (?, ?, ?)";

        try (Connection c = getConnection()) {
            c.setAutoCommit(false);

            try (PreparedStatement ps = c.prepareStatement(sqlUpdateType)) {
                ps.setString(1, desc);
                ps.setInt(2, typeId);
                ps.executeUpdate();
            }

            int updated;
            try (PreparedStatement ps = c.prepareStatement(sqlUpdatePolicy)) {
                ps.setInt(1, maxDays);
                ps.setString(2, status);
                ps.setInt(3, typeId);
                updated = ps.executeUpdate();
            }

            if (updated == 0) {
                try (PreparedStatement ps = c.prepareStatement(sqlInsertPolicy)) {
                    ps.setInt(1, maxDays);
                    ps.setInt(2, typeId);
                    ps.setString(3, status);
                    ps.executeUpdate();
                }
            }

            c.commit();
        }
    }

    private void handleDelete(HttpServletRequest request) throws SQLException {
        int typeId = parseInt(request.getParameter("typeId"), -1);
        if (typeId <= 0) {
            throw new IllegalArgumentException("Invalid Type ID.");
        }

        // Prevent delete if there are leave requests using this type
        String sqlCountReq = "SELECT COUNT(*) FROM leave_request WHERE type_id=?";
        String sqlDelPolicy = "DELETE FROM leave_policy WHERE type_id=?";
        String sqlDelType = "DELETE FROM leave_type WHERE type_id=?";

        try (Connection c = getConnection()) {
            c.setAutoCommit(false);

            int count;
            try (PreparedStatement ps = c.prepareStatement(sqlCountReq)) {
                ps.setInt(1, typeId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    count = rs.getInt(1);
                }
            }

            if (count > 0) {
                c.rollback();
                throw new IllegalArgumentException("Cannot delete: there are " + count + " leave request(s) using this type.");
            }

            try (PreparedStatement ps = c.prepareStatement(sqlDelPolicy)) {
                ps.setInt(1, typeId);
                ps.executeUpdate();
            }


            // Delete balances first to satisfy FK constraints
            try (PreparedStatement ps = c.prepareStatement("DELETE FROM employee_leave_balance WHERE type_id=?")) {
                ps.setInt(1, typeId);
                ps.executeUpdate();
            }


            try (PreparedStatement ps = c.prepareStatement(sqlDelType) ) {
                ps.setInt(1, typeId);
                ps.executeUpdate();
            }

            c.commit();
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private Integer parseIntObj(String s) {
        try {
            if (s == null) return null;
            s = s.trim();
            if (s.isEmpty()) return null;
            return Integer.valueOf(s);
        } catch (Exception e) {
            return null;
        }
    }
}
