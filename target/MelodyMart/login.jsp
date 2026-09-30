<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("errorMessage");
    String redirect = request.getParameter("redirect");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Login | MelodyMart Sri Lanka</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<header>
    <div class="navbar">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/index.jsp"><span>🎵 MelodyMart</span></a>
            <span class="logo-sub">Harmony Lanka Musical Stores</span>
        </div>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
            <li><a href="<%= request.getContextPath() %>/products">Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin Portal</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:480px; margin-top:40px;">
    <div class="card">
        <h2 style="color:var(--primary); margin-bottom:6px; text-align:center;">Account Login</h2>
        <p style="color:var(--gray-600); font-size:0.88rem; text-align:center; margin-bottom:20px;">
            Member 1 (IT25101726): User Account & Profile Management
        </p>

        <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="login">

            <div style="margin-bottom:14px;">
                <label style="font-weight:600; font-size:0.85rem;">Email Address</label>
                <input type="email" name="email" required class="form-control" placeholder="kasun.perera@gmail.com" value="admin@melodymart.lk">
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-weight:600; font-size:0.85rem;">Password</label>
                <input type="password" name="password" required class="form-control" placeholder="••••••••" value="Admin@123">
            </div>

            <button type="submit" class="btn btn-primary" style="width:100%; padding:11px; font-size:1rem;">Sign In</button>
        </form>

        <div style="margin-top:20px; text-align:center; font-size:0.88rem;">
            Don't have an account yet? <a href="<%= request.getContextPath() %>/user?action=register" style="color:var(--primary); font-weight:600;">Register Here</a>
        </div>

        <div style="margin-top:25px; border-top:1px solid var(--gray-200); padding-top:15px; font-size:0.78rem; color:var(--gray-600); background:#f8fafc; padding:10px; border-radius:6px;">
            <strong>Demo Credentials (SLIIT SE2030):</strong><br>
            • Admin: <code>admin@melodymart.lk</code> / <code>Admin@123</code><br>
            • Sales Staff: <code>sales@melodymart.lk</code> / <code>Sales@123</code><br>
            • Customer: <code>amila.silva@gmail.com</code> / <code>Amila@2026</code>
        </div>
    </div>
</div>

</body>
</html>