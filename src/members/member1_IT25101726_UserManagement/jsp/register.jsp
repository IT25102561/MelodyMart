<%
    String error = (String) request.getAttribute("errorMessage");
    String regFullName = (String) request.getAttribute("regFullName");
    String regEmail = (String) request.getAttribute("regEmail");
    String regPhone = (String) request.getAttribute("regPhone");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Registration | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/user?action=login">Login</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:520px; margin-top:35px;">
    <div class="card">
        <h2 style="color:var(--primary); margin-bottom:6px; text-align:center;">Register Customer Account</h2>
        <p style="color:var(--gray-600); font-size:0.85rem; text-align:center; margin-bottom:20px;">
            Member 1 (IT25101726): User Creation with SHA-256 Hashing & Sri Lankan Mobile Validation
        </p>

        <% if (error != null) { %>
            <div class="alert alert-danger" style="border-left:4px solid #ef4444; padding:12px; margin-bottom:15px; border-radius:4px; background:#fef2f2; color:#b91c1c; font-size:0.9rem;">
                <strong>⚠️ Registration Error:</strong> <%= error %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="register">

            <div style="margin-bottom:12px;">
                <label style="font-weight:600; font-size:0.85rem;">Full Name *</label>
                <input type="text" name="fullName" required class="form-control" placeholder="e.g. Kasun Chamara Perera" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Full name must contain letters and spaces only (minimum 2 characters)" value="<%= (regFullName != null) ? regFullName : "" %>">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-weight:600; font-size:0.85rem;">Email Address *</label>
                <input type="email" name="email" required class="form-control" placeholder="e.g. kasun.perera@gmail.com" maxlength="100" value="<%= (regEmail != null) ? regEmail : "" %>">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-weight:600; font-size:0.85rem;">Sri Lankan Mobile Phone *</label>
                <input type="text" name="phone" required class="form-control" placeholder="07XXXXXXXX or +947XXXXXXXX" pattern="^(?:0|\+94)?7[0-9]{8}$" maxlength="12" inputmode="tel" title="Must be valid Sri Lankan mobile: 07XXXXXXXX or +947XXXXXXXX" value="<%= (regPhone != null) ? regPhone : "" %>">
                <small style="font-size:0.75rem; color:var(--gray-600);">Example: 0771234567, 0712345678, 0763456789</small>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-weight:600; font-size:0.85rem;">Password * (Min 8 chars, letters & numbers)</label>
                <input type="password" name="password" required class="form-control" placeholder="••••••••" minlength="8" pattern="^(?=.*[A-Za-z])(?=.*\d).{8,}$" title="Must contain at least 8 characters with letters & numbers (Policy ERR_USER_PASSWORD_STRENGTH)">
                <small style="font-size:0.75rem; color:var(--gray-600);">Must contain at least 8 characters with letters & numbers (Policy ERR_USER_PASSWORD_STRENGTH)</small>
            </div>

            <button type="submit" class="btn btn-primary" style="width:100%; padding:11px; font-size:1rem;">Complete Registration</button>
        </form>

        <div style="margin-top:20px; text-align:center; font-size:0.88rem;">
            Already have an account? <a href="<%= request.getContextPath() %>/user?action=login" style="color:var(--primary); font-weight:600;">Sign In Here</a>
        </div>
    </div>
</div>

</body>
</html>