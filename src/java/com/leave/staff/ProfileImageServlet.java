package com.leave.staff;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/profile-image")
public class ProfileImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String path = request.getParameter("path");

        if (path == null || path.contains("..")) {
            response.sendError(400);
            return;
        }

        File file = new File("C:/leave_uploads/profile/" + path);

        if (!file.exists()) {
            response.sendError(404);
            return;
        }

        response.setContentType(getServletContext().getMimeType(file.getName()));
        Files.copy(file.toPath(), response.getOutputStream());
    }
}
