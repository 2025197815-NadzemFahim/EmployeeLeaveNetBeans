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
 * Admin CRUD for Leave Type + Leave Policy (Derby).
 *
 * FIX:
 * - Fully qualify tables with schema (APP.) and set schema on connection,
 *   to avoid "Table/View 'LEAVE_TYPE' does not exist" when default schema is not APP.
 *
 * On CREATE (Add New):
 * - Insert into LEAVE_TYPE
 * - Insert into LEAVE_POLICY
 * - Insert into EMPLOYEE_LEAVE_BALANCE for ALL employees (balance = max_days)
 */
@WebServlet(name = "LeavePolicyAdminServlet", urlPatterns = {"/LeavePolicyAdminServlet"})
public class LeavePolicyAdminServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:derby://localhost:1527/LeaveDB";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";
    private static final String DB_SCHEMA = "APP";

    private Connection getConnection() throws SQLException {
        Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        try (Statement st = c.createStatement()) {
            st.execute("SET SCHEMA " + DB_SCHEMA);
        } catch (SQLException ignore) {
            // Still OK because we also schema-qualify tables.
        }
        return c;
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
                        response.sendRedirect("LeavePolicyAdminServlet?action=list");
                        return;
                    }
                    LeavePolicyView item = fetchByTypeId(typeId);
                    if (item == null) {
                        flash(request, "flashError", "Record not found for Type ID " + typeId + ".");
                        response.sendRedirect("LeavePolicyAdminServlet?action=list");
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
            request.setAttribute("policies", new ArrayList<LeavePolicyView>());
            forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("flashError", "Unexpected error: " + e.getMessage());
            request.setAttribute("view", "list");
            request.setAttribute("policies", new ArrayList<LeavePolicyView>());
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

        response.sendRedirect("LeavePolicyAdminServlet?action=list");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Make sure your JSP is named exactly LeavePolicies.jsp in /web/admin/
        RequestDispatcher rd = request.getRequestDispatcher("/admin/LeavePolicies.jsp");
        rd.forward(request, response);
    }

    private int parseInt(String s, int fallback) {
        try { return Integer.parseInt(s); } catch (Exception e) { return fallback; }
    }

    private List<LeavePolicyView> fetchAll() throws SQLException {
        List<LeavePolicyView> out = new ArrayList<>();
        String sql =
            "SELECT lt.type_id, lt.name, lt.description, " +
            "       lp.policy_id, lp.max_days, lp.status " +
            "FROM " + DB_SCHEMA + ".LEAVE_TYPE lt " +
            "LEFT JOIN " + DB_SCHEMA + ".LEAVE_POLICY lp ON lt.type_id = lp.type_id " +
            "ORDER BY lt.type_id";

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
        String sql =
            "SELECT lt.type_id, lt.name, lt.description, " +
            "       lp.policy_id, lp.max_days, lp.status " +
            "FROM " + DB_SCHEMA + ".LEAVE_TYPE lt " +
            "LEFT JOIN " + DB_SCHEMA + ".LEAVE_POLICY lp ON lt.type_id = lp.type_id " +
            "WHERE lt.type_id = ?";

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

        if (name == null || name.isEmpty()) throw new IllegalArgumentException("Leave Type is required.");
        if (maxDays == null || maxDays <= 0) throw new IllegalArgumentException("Max Day Allowed must be a positive number.");
        if (status == null || status.isEmpty()) throw new IllegalArgumentException("Status is required.");

        String sqlType   = "INSERT INTO " + DB_SCHEMA + ".LEAVE_TYPE (name, description) VALUES (?, ?)";
        String sqlPolicy = "INSERT INTO " + DB_SCHEMA + ".LEAVE_POLICY (max_days, type_id, status) VALUES (?, ?, ?)";
        String sqlEmpIds = "SELECT employee_id FROM " + DB_SCHEMA + ".EMPLOYEE";
        String sqlBal    = "INSERT INTO " + DB_SCHEMA + ".EMPLOYEE_LEAVE_BALANCE (employee_id, type_id, balance) VALUES (?, ?, ?)";

        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            int newTypeId;

            // 1) leave_type
            try (PreparedStatement ps = c.prepareStatement(sqlType, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, name);
                ps.setString(2, desc);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys != null && keys.next()) {
                        newTypeId = keys.getInt(1);
                    } else {
                        try (Statement st = c.createStatement();
                             ResultSet rs = st.executeQuery("VALUES IDENTITY_VAL_LOCAL()")) {
                            rs.next();
                            newTypeId = rs.getInt(1);
                        }
                    }
                }
            }

            // 2) leave_policy
            try (PreparedStatement ps = c.prepareStatement(sqlPolicy)) {
                ps.setInt(1, maxDays);
                ps.setInt(2, newTypeId);
                ps.setString(3, status);
                ps.executeUpdate();
            }

            // 3) employee_leave_balance for all employees
            try (PreparedStatement psEmp = c.prepareStatement(sqlEmpIds);
                 ResultSet rsEmp = psEmp.executeQuery();
                 PreparedStatement psBal = c.prepareStatement(sqlBal)) {

                while (rsEmp.next()) {
                    int empId = rsEmp.getInt(1);
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
        if (typeId <= 0) throw new IllegalArgumentException("Invalid Type ID.");

        String desc = trimOrNull(request.getParameter("description"));
        Integer maxDays = parseIntObj(request.getParameter("maxDays"));
        String status = trimOrNull(request.getParameter("status"));

        if (maxDays == null || maxDays <= 0) throw new IllegalArgumentException("Max Day Allowed must be a positive number.");
        if (status == null || status.isEmpty()) throw new IllegalArgumentException("Status is required.");

        String sqlUpdateType   = "UPDATE " + DB_SCHEMA + ".LEAVE_TYPE SET description=? WHERE type_id=?";
        String sqlUpdatePolicy = "UPDATE " + DB_SCHEMA + ".LEAVE_POLICY SET max_days=?, status=? WHERE type_id=?";
        String sqlInsertPolicy = "INSERT INTO " + DB_SCHEMA + ".LEAVE_POLICY (max_days, type_id, status) VALUES (?, ?, ?)";

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
        if (typeId <= 0) throw new IllegalArgumentException("Invalid Type ID.");

        String sqlCountReq  = "SELECT COUNT(*) FROM " + DB_SCHEMA + ".LEAVE_REQUEST WHERE type_id=?";
        String sqlDelBal    = "DELETE FROM " + DB_SCHEMA + ".EMPLOYEE_LEAVE_BALANCE WHERE type_id=?";
        String sqlDelPolicy = "DELETE FROM " + DB_SCHEMA + ".LEAVE_POLICY WHERE type_id=?";
        String sqlDelType   = "DELETE FROM " + DB_SCHEMA + ".LEAVE_TYPE WHERE type_id=?";

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

            try (PreparedStatement ps = c.prepareStatement(sqlDelBal)) {
                ps.setInt(1, typeId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(sqlDelPolicy)) {
                ps.setInt(1, typeId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(sqlDelType)) {
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
