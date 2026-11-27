# Employee Leave Management System

A web-based system for managing employee leave applications, built with Java in NetBeans as a group project for **CSC577**.

Employees can apply for leave and track their requests, while managers/admins can review, approve or reject them, all in one place instead of paper forms.

---

## Features

> Edit this list to match what the system actually does.

- **Employee login**: secure access for each employee
- **Apply for leave**: choose the leave type, dates and reason
- **Leave status tracking**: see whether a request is pending, approved or rejected
- **Leave history**: view past leave applications
- **Admin / manager dashboard**: review, approve or reject leave requests
- **Employee management**: add, update or remove employee records

---

## Tech Stack

| Part | Technology |
|------|------------|
| Language | Java |
| Web | JSP / Servlets |
| IDE | Apache NetBeans |
| Build tool | Apache Ant (`build.xml`) |
| Server | [e.g. Apache Tomcat / GlassFish] |
| Database | [e.g. MySQL / Java DB (Derby)] |

---

## Project Structure

```
EmployeeLeaveNetBeans/
├── nbproject/    # NetBeans project settings
├── src/          # Java source code (servlets, classes)
├── web/          # JSP pages, HTML, CSS, images
├── build.xml     # Ant build script
└── .gitignore
```

---

## How to Run

1. Clone this repository:
   ```bash
   git clone https://github.com/2025197815-NadzemFahim/EmployeeLeaveNetBeans.git
   ```
2. Open **Apache NetBeans** and go to **File → Open Project**, then select the cloned folder.
3. Set up the database:
   - Create a database named `[database name]`
   - Import the tables / SQL script (if provided)
   - Update the database connection details in the project if needed
4. Make sure a server (e.g. **Apache Tomcat** or **GlassFish**) is added in NetBeans.
5. Right-click the project and choose **Run**.

---

## Team Members

This project was developed as a group assignment by:

| No.|                  Name                        |                             GitHub                                              |
|----|----------------------------------------------|---------------------------------------------------------------------------------|
| 1  | AQILAH ZAFIRAH BINTI RUSMAN                  | [suwegey](https://github.com/suwegey)                                           |  
| 2  | NURNAJIHAH BINTI ROSALI                      | [nurna](https://github.com/nurna)                                               |
| 3  | NUR IZYAN SYAMIMI BINTI MOHAMMAD FAIZAL      | [izynwho](https://github.com/izynwho)                                           |
| 4  | MUHAMMAD NADZEM FAHIM BIN SELAMAT @ MD ZAINI | [nadzemfahim/2025197815-NadzemFahim](https://github.com/2025197815-NadzemFahim) |
| 5  | NURADNI NABIHAH BINTI MOHAMAD ARIFFIN        | [jepa](https://github.com/jepa)                                                 |
| 6  | MUHAMMAD IZHAN BIN HASHAN ALADI              | [izhan004](https://github.com/izhan004)                                         |
---------------------------------------------------------------------------------------------------------------------------------------

## Credits

- Original repository: [suwegey/EmployeeLeave](https://github.com/suwegey/EmployeeLeave)
- This copy is kept for portfolio purposes, with full commit history from the original project.
- All credit for each part of the system goes to the respective team members listed above.

---

## Course Info

- **Course:** CSC577
- **Institution:** Universiti Teknologi MARA (UiTM)
