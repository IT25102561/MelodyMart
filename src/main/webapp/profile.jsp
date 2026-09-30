<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="models.Address" %>
<%
    User u = (User) request.getAttribute("user");
    if (u == null) {
        u = (User) session.getAttribute("currentUser");
    }
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/user?action=login");
        return;
    }
    String msg = request.getParameter("msg");
    String err = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Profile & Address Book | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/orders">My Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/user?action=profile" class="active">My Profile</a></li>
            <li><a href="<%= request.getContextPath() %>/user?action=logout">Logout</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:900px;">
    <h1 style="color:var(--primary); margin-bottom:6px;">My Account & Address Book</h1>
    <p style="color:var(--gray-600); margin-bottom:25px;">Member 1 (IT25101726): Personal Information & Delivery Destinations</p>

    <% if (msg != null) { %>
        <div class="alert alert-success">Action processed successfully! (<%= msg %>)</div>
    <% } %>
    <% if (err != null) { %>
        <div class="alert alert-danger"><%= err %></div>
    <% } %>

    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:25px; align-items:start;">
        <!-- Left: Profile Details & Update -->
        <div>
            <div class="card">
                <h3 class="card-title">Personal Profile Details</h3>
                <form action="<%= request.getContextPath() %>/user" method="post">
                    <input type="hidden" name="action" value="updateProfile">

                    <div style="margin-bottom:12px;">
                        <label style="font-weight:600; font-size:0.85rem;">Account Email (Fixed)</label>
                        <input type="email" class="form-control" value="<%= u.getEmail() %>" disabled style="background:#f1f5f9;">
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-weight:600; font-size:0.85rem;">Full Name *</label>
                        <input type="text" name="fullName" required class="form-control" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Full name must contain letters and spaces only (minimum 2 characters)" value="<%= u.getFullName() %>">
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-weight:600; font-size:0.85rem;">Mobile Phone *</label>
                        <input type="text" name="phone" required class="form-control" pattern="^(?:0|\+94)?7[0-9]{8}$" maxlength="12" inputmode="tel" title="Valid Sri Lankan mobile: 07XXXXXXXX or +947XXXXXXXX" value="<%= u.getPhone() %>">
                    </div>

                    <div style="margin-bottom:18px;">
                        <label style="font-weight:600; font-size:0.85rem;">System Role & Status</label>
                        <div style="margin-top:4px;">
                            <span class="badge badge-active"><%= u.getRole() %></span>
                            <span class="badge badge-paid" style="margin-left:6px;"><%= u.getStatus() %></span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width:100%;">Save Profile Changes</button>
                </form>

                <div style="margin-top:25px; border-top:1px solid var(--gray-200); padding-top:15px;">
                    <form action="<%= request.getContextPath() %>/user" method="post" onsubmit="return confirmAction('Are you sure you want to deactivate your MelodyMart customer account?');">
                        <input type="hidden" name="action" value="deactivateAccount">
                        <button type="submit" class="btn btn-danger btn-sm" style="width:100%;">Deactivate Customer Account</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Right: Address Book -->
        <div>
            <div class="card">
                <h3 class="card-title">Saved Shipping Destinations</h3>
                <% if (u.getAddresses() == null || u.getAddresses().isEmpty()) { %>
                    <p style="color:var(--gray-600); font-size:0.88rem; margin-bottom:15px;">No addresses saved yet. Add your first delivery destination below.</p>
                <% } else { %>
                    <div style="margin-bottom:20px;">
                        <% for (Address a : u.getAddresses()) { %>
                            <div style="border:1px solid var(--gray-200); background:#f8fafc; padding:12px 14px; border-radius:var(--radius); margin-bottom:10px; display:flex; justify-content:space-between; align-items:flex-start;">
                                <div>
                                    <div style="display:flex; align-items:center; gap:8px;">
                                        <strong><%= a.getLabel() %></strong>
                                        <% if (a.isPrimary()) { %>
                                            <span style="background:#dcfce7; color:#15803d; font-size:0.72rem; padding:1px 6px; border-radius:4px; font-weight:bold;">PRIMARY</span>
                                        <% } %>
                                    </div>
                                    <div style="font-size:0.85rem; color:var(--gray-800); margin-top:4px;">
                                        <%= a.getStreet() %>, <%= a.getCity() %>
                                    </div>
                                    <div style="font-size:0.78rem; color:var(--gray-600);">
                                        <%= a.getDistrict() %> District | Postal: <%= a.getPostalCode() %>
                                    </div>
                                </div>
                                <div style="display:flex; gap:6px; align-items:center;">
                                    <% if (!a.isPrimary()) { %>
                                        <form action="<%= request.getContextPath() %>/user" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="setPrimaryAddress">
                                            <input type="hidden" name="addressId" value="<%= a.getId() %>">
                                            <button type="submit" class="btn btn-secondary btn-sm" style="padding:2px 8px; font-size:0.75rem;">Set Primary</button>
                                        </form>
                                    <% } %>
                                    <form action="<%= request.getContextPath() %>/user" method="post" onsubmit="return confirmAction('Delete this address?');" style="display:inline;">
                                        <input type="hidden" name="action" value="removeAddress">
                                        <input type="hidden" name="addressId" value="<%= a.getId() %>">
                                        <button type="submit" class="btn btn-danger btn-sm" style="padding:2px 8px; font-size:0.75rem;">Delete</button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <h4 style="color:var(--primary); font-size:1rem; margin-bottom:10px; border-top:1px solid var(--gray-200); padding-top:15px;">+ Add New Address</h4>
                <form action="<%= request.getContextPath() %>/user" method="post">
                    <input type="hidden" name="action" value="addAddress">

                    <div style="margin-bottom:8px;">
                        <label style="font-size:0.82rem; font-weight:600;">Address Label (e.g. Home, Music Studio)</label>
                        <input type="text" name="label" required class="form-control" placeholder="Home" minlength="2" maxlength="30" pattern="^[A-Za-z0-9\s.'-]+$" title="Address label must contain alphanumeric characters and spaces only">
                    </div>

                    <div style="margin-bottom:8px;">
                        <label style="font-size:0.82rem; font-weight:600;">Street Address</label>
                        <input type="text" name="street" required class="form-control" placeholder="No. 12/A, Station Road" minlength="5" maxlength="200">
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:8px; margin-bottom:8px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">City / Town</label>
                            <input type="text" name="city" required class="form-control" placeholder="Kadawatha" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="50" title="Valid city name">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">District (Sri Lanka)</label>
                            <select name="district" class="form-control">
                                <option value="Colombo">Colombo</option>
                                <option value="Gampaha">Gampaha</option>
                                <option value="Kalutara">Kalutara</option>
                                <option value="Kandy">Kandy</option>
                                <option value="Galle">Galle</option>
                                <option value="Matara">Matara</option>
                                <option value="Kurunegala">Kurunegala</option>
                                <option value="Jaffna">Jaffna</option>
                            </select>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:8px; margin-bottom:12px; align-items:center;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Postal Code</label>
                            <input type="text" name="postalCode" required class="form-control" placeholder="11850" pattern="^[0-9]{5}$" maxlength="5" inputmode="numeric" title="Must be a 5-digit postal code (e.g. 11850)">
                        </div>
                        <div style="padding-top:18px;">
                            <label style="font-size:0.85rem; cursor:pointer;">
                                <input type="checkbox" name="isPrimary" value="true"> Make Primary Address
                            </label>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-secondary btn-sm" style="width:100%;">Save Address to Address Book</button>
                </form>
            </div>

            <!-- Password Update Card -->
            <div class="card" style="margin-top:20px;">
                <h3 class="card-title">Change Account Password</h3>
                <p style="font-size:0.8rem; color:var(--gray-600); margin-bottom:12px;">Enforces Policy ERR_USER_PASSWORD_STRENGTH (min 8 chars, letters & numbers).</p>
                <form action="<%= request.getContextPath() %>/user" method="post">
                    <input type="hidden" name="action" value="updatePassword">

                    <div style="margin-bottom:8px;">
                        <label style="font-size:0.82rem; font-weight:600;">Current Password *</label>
                        <input type="password" name="oldPassword" required class="form-control" placeholder="••••••••">
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-size:0.82rem; font-weight:600;">New Password *</label>
                        <input type="password" name="newPassword" required class="form-control" placeholder="••••••••" minlength="8" pattern="^(?=.*[A-Za-z])(?=.*\d).{8,}$" title="Must contain at least 8 characters with letters & numbers (Policy ERR_USER_PASSWORD_STRENGTH)">
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm" style="width:100%;">Update Password</button>
                </form>
            </div>

            <!-- Login Session History Card -->
            <div class="card" style="margin-top:20px;">
                <h3 class="card-title">Login Session History & Security</h3>
                <p style="font-size:0.8rem; color:var(--gray-600); margin-bottom:10px;">Member 1 READ: Track user login sessions and timestamps.</p>
                <ul style="font-size:0.82rem; color:var(--gray-700); padding-left:18px; margin:0;">
                    <% for (String log : dao.UserDAO.getLoginHistory(u.getId())) { %>
                        <li style="margin-bottom:4px;">🔑 <%= log %></li>
                    <% } %>
                </ul>
            </div>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>