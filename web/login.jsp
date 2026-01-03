<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Employee Login</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">

<style>
* {
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}

body {
    margin: 0;
    height: 100vh;
}

/* ===== FULL PAGE ===== */
.wrapper {
    display: flex;
    height: 100vh;
    width: 100%;
}

/* ===== LEFT : LOGIN ===== */
.left {
    width: 45%;
    background: #ffffff;
    display: flex;
    justify-content: center;
    align-items: center;
}

.login-container {
    width: 100%;
    max-width: 420px;
}

.logo {
    font-weight: 600;
    margin-bottom: 30px;
    color: #0b5cff;
}

.login-container h2 {
    margin: 0;
    font-weight: 600;
    font-size: 22px;
}

.login-container p {
    font-size: 13px;
    color: #666;
    margin-bottom: 25px;
}

/* Social buttons (optional) */
.social {
    display: flex;
    gap: 12px;
    margin-bottom: 18px;
}

.social button {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    background: #fff;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
}

/* Divider */
.divider {
    text-align: center;
    font-size: 12px;
    color: #999;
    margin: 18px 0;
}

/* Inputs */
label {
    font-size: 12px;
    font-weight: 500;
}

input {
    width: 100%;
    padding: 12px;
    margin-top: 6px;
    margin-bottom: 16px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 13px;
}

input:focus {
    outline: none;
    border-color: #0b5cff;
}

/* Options */
.options {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    margin-bottom: 18px;
}

.options a {
    text-decoration: none;
    color: #0b5cff;
}

/* Button */
.login-btn {
    width: 100%;
    padding: 13px;
    background: #0b5cff;
    border: none;
    color: white;
    border-radius: 6px;
    font-weight: 500;
    cursor: pointer;
}

.footer {
    text-align: center;
    font-size: 12px;
    margin-top: 20px;
}

.footer a {
    color: #0b5cff;
    text-decoration: none;
}

.error {
    color: red;
    font-size: 12px;
    margin-bottom: 12px;
}

/* ===== RIGHT : BACKGROUND CIRCLES ===== */
.right {
    width: 55%;
    position: relative;
    overflow: hidden;

    background: radial-gradient(circle at top left, #102a6e, #061c4a);
    color: white;

    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
}

/* Decorative circles */
.circle {
    position: absolute;
    border-radius: 50%;
    background: rgba(255,255,255,0.06);
}

.circle.one {
    width: 420px;
    height: 420px;
    top: -120px;
    right: -120px;
}

.circle.two {
    width: 320px;
    height: 320px;
    bottom: -100px;
    left: -100px;
}

.circle.three {
    width: 220px;
    height: 220px;
    top: 40%;
    left: 45%;
    transform: translate(-50%, -50%);
}

/* Text on right */
.right h2 {
    font-size: 26px;
    font-weight: 500;
    z-index: 1;
}

.right p {
    font-size: 13px;
    opacity: 0.85;
    max-width: 360px;
    margin: 12px auto 0;
    z-index: 1;
}
</style>
</head>

<body>

<form action="<%= request.getContextPath() %>/LoginServlet" method="post">
<div class="wrapper">

    <!-- LEFT LOGIN -->
    <div class="left">
        <div class="login-container">

            <div class="logo">TERLAJAK LARIS</div>

            <h2>Log in to your Account</h2>
            <p>Welcome back! Please login to continue.</p>

            <%
                String error = request.getParameter("error");
                if ("invalid".equals(error)) {
            %>
                <div class="error">Invalid email or password</div>
            <%
                }
            %>

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Password</label>
            <input type="password" name="password" required>

            <button class="login-btn" type="submit">Log in</button>

            <div class="footer">
                Employee Leave Management System
            </div>

        </div>
    </div>

    <!-- RIGHT BACKGROUND -->
    <div class="right">
        <div>
            <h2>Connect your workforce.</h2>
            <p>Manage employee leave requests in one centralized system.</p>
        </div>

        <div class="circle one"></div>
        <div class="circle two"></div>
        <div class="circle three"></div>
    </div>

</div>
</form>

</body>
</html>
