package com.leave.admin;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DownloadAttachmentServlet")
public class DownloadAttachmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fileName = request.getParameter("file");

        // Null safety
        if (fileName == null || fileName.isEmpty()) {
            response.getWriter().println("Invalid file request.");
            return;
        }

        // Strip folder if DB stored "attachments/filename.pdf"
        if (fileName.contains("/")) {
            fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
        }

        // Correct real path
        File file = new File("C:/leave_uploads/attachments/" + fileName);

        if (file.exists()) {
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + "\"");

            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream os = response.getOutputStream()) {

                byte[] buffer = new byte[4096];
                int bytes;
                while ((bytes = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytes);
                }
            }
        } else {
            response.getWriter().println("File not found in server folder.");
        }
    }
}
