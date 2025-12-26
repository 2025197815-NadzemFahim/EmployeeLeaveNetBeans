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
    public void init() {
        db = new Database();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<GenerateRecord> records = db.getAllRecords();
        System.out.println("Total records fetched: " + records.size());

        request.setAttribute("recordList", records);
        RequestDispatcher rd =
                request.getRequestDispatcher("/admin/GenerateRecord.jsp");
        rd.forward(request, response);
    }
}
