/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.leave.hod;

import java.io.*;
import java.nio.file.*;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateProfileHODServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class UpdateProfileHODServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        if (employeeId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app")) {

            // ===== CHANGE PASSWORD =====
            if ("changePassword".equals(action)) {

                String newPassword = request.getParameter("newPassword");
                String confirm = request.getParameter("confirmPassword");

                if (!newPassword.equals(confirm)) {
                    response.sendRedirect("ViewProfileHODServlet?error=passwordMismatch");
                    return;
                }

                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE employee SET password=? WHERE employee_id=?"
                );
                ps.setString(1, newPassword); // (hash later if needed)
                ps.setInt(2, employeeId);
                ps.executeUpdate();

                response.sendRedirect("ViewProfileHODServlet?success=password");
            }

            // ===== CHANGE PROFILE IMAGE =====
            if ("changeProfileImage".equals(action)) {

                Part imagePart = request.getPart("profileImage");

                if (imagePart != null && imagePart.getSize() > 0) {

                    String fileName = System.currentTimeMillis() + "_"
                            + Paths.get(imagePart.getSubmittedFileName()).getFileName();

                    String uploadDir = "C:/leave_uploads/profile";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();

                    File file = new File(dir, fileName);
                    Files.copy(imagePart.getInputStream(), file.toPath(),
                            StandardCopyOption.REPLACE_EXISTING);

                    String dbPath = "profile/" + fileName;

                    PreparedStatement ps = conn.prepareStatement(
                            "UPDATE employee SET profile_image=? WHERE employee_id=?"
                    );
                    ps.setString(1, dbPath);
                    ps.setInt(2, employeeId);
                    ps.executeUpdate();

                    response.sendRedirect("ViewProfileHODServlet?success=image");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ViewProfileHODServlet?error=updateFailed");
        }
    }
}
