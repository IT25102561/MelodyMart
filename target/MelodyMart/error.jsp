<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MelodyMart | Notice</title>
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
            <li><a href="<%= request.getContextPath() %>/orders">Orders</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:650px; margin-top:40px;">
    <div class="card" style="text-align:center; padding:35px 20px;">
        <div style="font-size:2.8rem; margin-bottom:12px;">🎵</div>
        <h2 style="color:var(--primary); margin-bottom:10px;">MelodyMart System Notice</h2>
        <p style="color:var(--gray-600); margin-bottom:20px;">
            The requested page or resource could not be found, or an unexpected processing event occurred.
        </p>

        <% if (exception != null && exception.getMessage() != null) { %>
            <div class="alert alert-danger" style="text-align:left; font-size:0.85rem;">
                <strong>Details:</strong> <%= exception.getMessage() %>
            </div>
        <% } %>

        <div style="display:flex; justify-content:center; gap:12px; margin-top:20px;">
            <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Return to Storefront</a>
            <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Browse Instruments</a>
        </div>
    </div>
</div>

</body>
</html>
