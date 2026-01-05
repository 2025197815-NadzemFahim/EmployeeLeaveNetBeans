package com.leave.staff;

import com.leave.model.GenerateRecord;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/GenerateRecord")
public class GenerateRecordServlet extends HttpServlet {

    private Database db;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Database db = new Database();   // 🔥 create terus di sini

        List<GenerateRecord> records = db.getAllRecords();
        List<String> leaveTypes = db.getLeaveTypes();

        request.setAttribute("recordList", records);
        request.setAttribute("leaveTypes", leaveTypes);

        RequestDispatcher rd =
                request.getRequestDispatcher("/admin/GenerateRecord.jsp");
        rd.forward(request, response);
    }

}
