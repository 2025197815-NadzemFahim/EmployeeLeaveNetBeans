/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author suweg
 */
@WebServlet("/MarkNotificationReadServlet")
public class MarkNotificationReadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int notiId = Integer.parseInt(request.getParameter("id"));

        try (Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/LeaveDB", "app", "app")) {

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notification SET is_read = TRUE WHERE notification_id = ?"
            );
            ps.setInt(1, notiId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while marking notification as read");
        }
    }
}


