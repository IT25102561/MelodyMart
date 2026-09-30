<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.*" %>
<%@ page import="java.util.List" %>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "overview";

    List<User> users = (List<User>) request.getAttribute("users");
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    List<Invoice> invoices = (List<Invoice>) request.getAttribute("invoices");
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    List<PurchaseOrder> purchaseOrders = (List<PurchaseOrder>) request.getAttribute("purchaseOrders");
    List<Fulfillment> fulfillments = (List<Fulfillment>) request.getAttribute("fulfillments");
    List<ReturnRequest> returns = (List<ReturnRequest>) request.getAttribute("returns");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    if (totalRevenue == null) totalRevenue = 0.0;

    String msg = request.getParameter("msg");
    String err = (String) request.getAttribute("errorMessage");
    if (err == null) err = (String) session.getAttribute("errorMessage");
    if (err == null) err = request.getParameter("err");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MelodyMart Management Portal | SLIIT SE2030 Group MLB-B6G1-08</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<header>
    <div class="navbar">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/index.jsp"><span>🎵 MelodyMart</span></a>
            <span class="logo-sub">Internal Management Portal (All 6 Members)</span>
        </div>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/index.jsp">Storefront</a></li>
            <li><a href="<%= request.getContextPath() %>/products">Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" class="active">Admin Portal</a></li>
            <li><a href="<%= request.getContextPath() %>/user?action=logout">Logout</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:1250px;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
        <div>
            <h1 style="color:var(--primary); font-size:1.8rem;">MelodyMart Central Management System</h1>
            <div style="font-size:0.82rem; margin-top:4px; display:flex; align-items:center; gap:8px;">
                <span class="badge badge-active" style="font-size:0.75rem;">LIVE DATABASE</span>
                <span style="color:var(--gray-600);">Persistence: <strong><%= utils.DatabaseUtil.getDatabaseEngineName() %></strong></span>
            </div>
            <p style="color:var(--gray-600); font-size:0.9rem;">
                SLIIT SE2030 (Year 2, Sem 1) | Group: <strong>2026-Y2-S1-MLB-B6G1-08</strong> | Harmony Lanka Musical Stores (Pvt) Ltd.
            </p>
        </div>
        <div>
            <span style="background:#e0f2fe; color:#0369a1; padding:6px 12px; border-radius:var(--radius); font-weight:bold; font-size:0.85rem;">
                Total Sales: LKR <%= String.format("%,.2f", totalRevenue) %>
            </span>
        </div>
    </div>

    <% if (msg != null) { %>
        <div class="alert alert-success">Operation successful: <strong><%= msg.replace("_", " ") %></strong></div>
    <% } %>
    <% if (err != null) { %>
        <div class="alert alert-danger"><%= err %></div>
    <% } %>

    <!-- 6 Members Tab Navigation -->
    <div class="admin-tabs">
        <a href="<%= request.getContextPath() %>/admin?tab=overview" class="admin-tab-btn <%= "overview".equals(activeTab) ? "active" : "" %>">
            📊 Executive Overview
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=users" class="admin-tab-btn <%= "users".equals(activeTab) ? "active" : "" %>">
            👥 6.1 Users (IT25101726)
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=products" class="admin-tab-btn <%= "products".equals(activeTab) ? "active" : "" %>">
            🎸 6.2 Products (IT25102561)
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=orders" class="admin-tab-btn <%= "orders".equals(activeTab) ? "active" : "" %>">
            🛒 6.3 Orders & Cart (IT25103636)
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=payments" class="admin-tab-btn <%= "payments".equals(activeTab) ? "active" : "" %>">
            💳 6.4 Payments & Invoices (IT25101556)
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=inventory" class="admin-tab-btn <%= "inventory".equals(activeTab) ? "active" : "" %>">
            📦 6.5 Inventory & Suppliers (IT25103441)
        </a>
        <a href="<%= request.getContextPath() %>/admin?tab=fulfillments" class="admin-tab-btn <%= "fulfillments".equals(activeTab) ? "active" : "" %>">
            🚚 6.6 Fulfillment & Returns (IT25100652)
        </a>
    </div>
    <!-- TAB 0: OVERVIEW -->
    <% if ("overview".equals(activeTab)) { %>
        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap:18px; margin-bottom:25px;">
            <div class="card" style="text-align:center; padding:18px;">
                <div style="font-size:1.8rem; font-weight:700; color:var(--primary);"><%= users != null ? users.size() : 0 %></div>
                <div style="color:var(--gray-600); font-size:0.85rem;">Registered Users</div>
            </div>
            <div class="card" style="text-align:center; padding:18px;">
                <div style="font-size:1.8rem; font-weight:700; color:var(--accent);"><%= products != null ? products.size() : 0 %></div>
                <div style="color:var(--gray-600); font-size:0.85rem;">Musical Instruments</div>
            </div>
            <div class="card" style="text-align:center; padding:18px;">
                <div style="font-size:1.8rem; font-weight:700; color:var(--success);"><%= orders != null ? orders.size() : 0 %></div>
                <div style="color:var(--gray-600); font-size:0.85rem;">Customer Orders Saved</div>
            </div>
            <div class="card" style="text-align:center; padding:18px;">
                <div style="font-size:1.8rem; font-weight:700; color:var(--info);"><%= suppliers != null ? suppliers.size() : 0 %></div>
                <div style="color:var(--gray-600); font-size:0.85rem;">Active Suppliers</div>
            </div>
            <div class="card" style="text-align:center; padding:18px;">
                <div style="font-size:1.8rem; font-weight:700; color:var(--primary);"><%= fulfillments != null ? fulfillments.size() : 0 %></div>
                <div style="color:var(--gray-600); font-size:0.85rem;">Courier Dispatches</div>
            </div>
        </div>

        <div class="card">
            <h3 class="card-title">SLIIT SE2030 Group Members & Assigned CRUD Responsibility Matrix</h3>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Module</th>
                            <th>Student Name</th>
                            <th>IT Number</th>
                            <th>Assigned Operations</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>6.1 User Account & Profile Management</strong></td>
                            <td>Perera D. A. P. W.</td>
                            <td><code>IT25101726</code></td>
                            <td>Register (SHA-256), View Profiles, Edit Details/Password, Deactivate User</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                        <tr>
                            <td><strong>6.2 Product Catalog & Search/Filtering</strong></td>
                            <td>Senarathna U. G. S. P.</td>
                            <td><code>IT25102561</code></td>
                            <td>Add 10 Instruments, Multi-filter (Brand/Price/Category), Update Specs, Archive</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                        <tr>
                            <td><strong>6.3 Shopping Cart, Checkout & Payment</strong></td>
                            <td>Pavishanth K.</td>
                            <td><code>IT25103636</code></td>
                            <td>Add to Cart, Dynamic Sri Lankan Courier Calculation, Vouchers, Clear Cart</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                        <tr>
                            <td><strong>6.4 Payment Gateway & Invoice System</strong></td>
                            <td>Ekanayaka E. A. T. T.</td>
                            <td><code>IT25101556</code></td>
                            <td>Transactions (Card/Bank Slip/COD/Wallets), VAT e-Invoices, Status Update, Refund</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                        <tr>
                            <td><strong>6.5 Real-Time Inventory & Supplier Management</strong></td>
                            <td>Premasiri R. M. R. R.</td>
                            <td><code>IT25103441</code></td>
                            <td>Register Suppliers, Issue POs, Auto-deduct stock on checkout, Low-stock alerts</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                        <tr>
                            <td><strong>6.6 Order Fulfilment, Delivery Tracking & Returns</strong></td>
                            <td>Nellampitiya T. T.</td>
                            <td><code>IT25100652</code></td>
                            <td>Dispatch Jobs (Koombiyo/Domex/Pronto), Live Tracking, COD Milestones, Returns</td>
                            <td><span class="badge badge-active">Active</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    <% } %>

    <!-- TAB 1: USERS (Member 1) -->
    <% if ("users".equals(activeTab)) { %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; flex-wrap:wrap; gap:10px;">
                <div>
                    <h3 class="card-title" style="margin-bottom:4px;">Member 1: User Account & Profile Management (IT25101726 - Perera D. A. P. W.)</h3>
                    <p style="color:var(--gray-600); font-size:0.85rem; margin:0;">
                        SLIIT Module 6.1 | Full Relational Database CRUD with Secure Password Hashing (SHA-256), Address Book & Role-Based Access
                    </p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-primary btn-sm" onclick="openAdminAddUserModal()" style="display:inline-flex; align-items:center; gap:6px;">
                        <span>➕ Register New User</span>
                        <span class="badge" style="background:#22c55e; color:#fff; font-size:0.65rem;">CREATE</span>
                    </button>
                    <button type="button" class="btn btn-sm" onclick="openAdminAddAddressModal(0)" style="background:#0284c7; color:#fff; display:inline-flex; align-items:center; gap:6px;">
                        <span>📍 Add Stored Address</span>
                        <span class="badge" style="background:#38bdf8; color:#0369a1; font-size:0.65rem;">CREATE</span>
                    </button>
                </div>
            </div>

            <!-- Member 1 CRUD Specification Badges -->
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; margin-bottom:20px; font-size:0.78rem;">
                <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#15803d; display:block; margin-bottom:2px;">[CREATE] Account & Address Registration</strong>
                    <span style="color:#166534;">Register new customer and staff user accounts with secure password hashing; add new shipping, billing, and contact addresses to the user's address book.</span>
                </div>
                <div style="background:#f0f9ff; border:1px solid #bae6fd; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#0369a1; display:block; margin-bottom:2px;">[READ] Profile & Session Inspection</strong>
                    <span style="color:#075985;">View customer profiles, fetch stored address books, view login session history, and retrieve role-based access permissions for internal staff.</span>
                </div>
                <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b45309; display:block; margin-bottom:2px;">[UPDATE] Credentials & Role Governance</strong>
                    <span style="color:#92400e;">Edit personal details (name, phone, email preferences), update account passwords, set primary shipping destinations, and modify assigned staff roles.</span>
                </div>
                <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b91c1c; display:block; margin-bottom:2px;">[DELETE] Termination & Deactivation</strong>
                    <span style="color:#991b1b;">Remove saved addresses from the profile, deactivate customer accounts upon request, or terminate staff access records.</span>
                </div>
            </div>

            <!-- Section 1: Registered Accounts & Staff Governance -->
            <div style="margin-bottom:25px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">👥 Registered Accounts & Staff Governance (READ, UPDATE, DELETE)</h4>
                    <span style="font-size:0.8rem; color:var(--gray-600);">SHA-256 Hashed Passwords | Role-Based Access Control</span>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Address Book</th>
                                <th>Created At</th>
                                <th style="text-align:center;">Actions (UPDATE & DELETE)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null && !users.isEmpty()) { for (User u : users) { %>
                                <tr style="<%= "DEACTIVATED".equalsIgnoreCase(u.getStatus()) ? "opacity:0.65; background:#fef2f2;" : "" %>">
                                    <td><strong>#<%= u.getId() %></strong></td>
                                    <td><strong><%= u.getFullName() %></strong></td>
                                    <td><%= u.getEmail() %></td>
                                    <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                                    <td>
                                        <span class="badge <%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "badge-danger" : ("CUSTOMER".equalsIgnoreCase(u.getRole()) ? "badge-active" : "badge-warning") %>">
                                            <%= u.getRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= "ACTIVE".equalsIgnoreCase(u.getStatus()) ? "badge-active" : "badge-deactivated" %>">
                                            <%= u.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-size:0.82rem; font-weight:600; color:var(--primary);">
                                            <%= u.getAddresses() != null ? u.getAddresses().size() : 0 %> saved
                                        </span>
                                        <button type="button" class="btn btn-sm" style="padding:1px 6px; font-size:0.7rem; background:#0284c7; color:#fff; margin-left:4px;" 
                                                onclick="openAdminAddAddressModal(<%= u.getId() %>)">
                                            + Add
                                        </button>
                                    </td>
                                    <td style="font-size:0.8rem; color:var(--gray-600);"><%= u.getCreatedAt() != null ? u.getCreatedAt() : "-" %></td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [UPDATE] Edit Details & Role -->
                                            <button type="button" class="btn btn-warning btn-sm" style="padding:3px 8px; font-size:0.78rem;" 
                                                    onclick="openAdminEditUserModal(
                                                        <%= u.getId() %>,
                                                        '<%= u.getFullName().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= u.getPhone() != null ? u.getPhone().replace("'", "\\'").replace("\"", "&quot;") : "" %>',
                                                        '<%= u.getRole() %>',
                                                        '<%= u.getStatus() %>'
                                                    )">
                                                ✏️ Edit
                                            </button>

                                            <!-- [UPDATE] Reset Password -->
                                            <button type="button" class="btn btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#8b5cf6; color:#fff;" 
                                                    onclick="openAdminResetPasswordModal(
                                                        <%= u.getId() %>,
                                                        '<%= u.getFullName().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= u.getEmail().replace("'", "\\'").replace("\"", "&quot;") %>'
                                                    )">
                                                🔑 Password
                                            </button>

                                            <!-- [READ] Login Session History & Permissions -->
                                            <button type="button" class="btn btn-info btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#0284c7; color:#fff;" 
                                                    onclick="openAdminUserSessionModal(
                                                        <%= u.getId() %>,
                                                        '<%= u.getFullName().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= u.getEmail().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= u.getRole() %>'
                                                    )">
                                                📜 Sessions
                                            </button>

                                            <!-- [DELETE] Deactivate / Reactivate User -->
                                            <% if ("ACTIVE".equalsIgnoreCase(u.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/user" method="post" onsubmit="return confirmAction('Deactivate account for <%= u.getFullName().replace("'", "\\'") %>?');" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="adminDeactivateUser">
                                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem;" title="Deactivate customer account or terminate staff access">
                                                        🚫 Deactivate
                                                    </button>
                                                </form>
                                            <% } else { %>
                                                <form action="<%= request.getContextPath() %>/user" method="post" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="adminReactivateUser">
                                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                    <button type="submit" class="btn btn-success btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#16a34a; color:#fff;" title="Reactivate user account">
                                                        ✅ Reactivate
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE] Delete User from Database -->
                                            <form action="<%= request.getContextPath() %>/user" method="post" onsubmit="return confirmAction('Permanently delete user <%= u.getFullName().replace("'", "\\'") %> from database? This cannot be undone.');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="adminDeleteUser">
                                                <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete user from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="9" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No registered user accounts found. Click "+ Register New User" to create one.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Section 2: Stored Address Books (READ, UPDATE, DELETE) -->
            <div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">📍 Stored Address Books (READ, UPDATE, DELETE)</h4>
                    <button type="button" class="btn btn-sm" onclick="openAdminAddAddressModal(0)" style="background:#0284c7; color:#fff;">
                        + Add Address
                    </button>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Account Holder</th>
                                <th>Address Label</th>
                                <th>Street Address</th>
                                <th>City</th>
                                <th>District</th>
                                <th>Postal Code</th>
                                <th>Primary Destination</th>
                                <th style="text-align:center;">Actions (UPDATE & DELETE)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% boolean hasAnyAddress = false;
                               if (users != null) { 
                                   for (User u : users) { 
                                       if (u.getAddresses() != null && !u.getAddresses().isEmpty()) {
                                           for (Address a : u.getAddresses()) { 
                                               hasAnyAddress = true; %>
                                <tr>
                                    <td><strong><%= u.getFullName() %></strong> (#<%= u.getId() %>)</td>
                                    <td><span class="badge" style="background:#e0f2fe; color:#0369a1; font-weight:600;"><%= a.getLabel() %></span></td>
                                    <td><%= a.getStreet() %></td>
                                    <td><%= a.getCity() %></td>
                                    <td><%= a.getDistrict() %></td>
                                    <td><code><%= a.getPostalCode() %></code></td>
                                    <td>
                                        <% if (a.isPrimary()) { %>
                                            <span class="badge badge-success" style="background:#16a34a; color:#fff;">⭐ Primary Shipping</span>
                                        <% } else { %>
                                            <span style="color:var(--gray-500); font-size:0.8rem;">Secondary</span>
                                        <% } %>
                                    </td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [UPDATE] Set Primary Destination -->
                                            <% if (!a.isPrimary()) { %>
                                                <form action="<%= request.getContextPath() %>/user" method="post" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="adminSetPrimaryAddress">
                                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                    <input type="hidden" name="addressId" value="<%= a.getId() %>">
                                                    <button type="submit" class="btn btn-warning btn-sm" style="padding:2px 7px; font-size:0.75rem;" title="Set as primary shipping destination">
                                                        ⭐ Set Primary
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [DELETE] Remove Address -->
                                            <form action="<%= request.getContextPath() %>/user" method="post" onsubmit="return confirmAction('Remove this address from profile?');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="adminRemoveAddress">
                                                <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                <input type="hidden" name="addressId" value="<%= a.getId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:2px 7px; font-size:0.75rem;" title="Remove saved address from profile">
                                                    🗑️ Remove
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }}}} 
                               if (!hasAnyAddress) { %>
                                <tr>
                                    <td colspan="8" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No saved addresses found. Click "+ Add Address" to link an address to an account.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <% } %>
    <!-- TAB 2: PRODUCTS (Member 2) -->
    <% if ("products".equals(activeTab)) { %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; flex-wrap:wrap; gap:10px;">
                <div>
                    <h3 class="card-title" style="margin-bottom:4px;">Member 2: Product Catalog & Advanced Search/Filtering (IT25102561 - Senarathna U. G. S. P.)</h3>
                    <p style="color:var(--gray-600); font-size:0.85rem; margin:0;">
                        SLIIT Module 6.2 | Full Relational Database CRUD with Multi-Faceted Filtering & Side-by-Side Instrument Comparison Matrix
                    </p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-primary btn-sm" onclick="openAddProductModal()" style="display:inline-flex; align-items:center; gap:6px;">
                        <span>🎸 + Add New Instrument</span>
                        <span class="badge" style="background:#22c55e; color:#fff; font-size:0.65rem;">CREATE</span>
                    </button>
                    <button type="button" class="btn btn-sm" onclick="openComparisonMatrixModal()" style="background:#8b5cf6; color:#fff; display:inline-flex; align-items:center; gap:6px;">
                        <span>⚖️ Comparison Matrix</span>
                        <span class="badge" style="background:#c084fc; color:#581c87; font-size:0.65rem;">READ</span>
                    </button>
                    <a href="<%= request.getContextPath() %>/products" target="_blank" class="btn btn-sm" style="background:#0284c7; color:#fff; display:inline-flex; align-items:center; gap:6px; text-decoration:none;">
                        <span>🔍 Live Storefront Catalog</span>
                        <span class="badge" style="background:#38bdf8; color:#0369a1; font-size:0.65rem;">READ</span>
                    </a>
                </div>
            </div>

            <!-- Member 2 CRUD Specification Badges -->
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; margin-bottom:20px; font-size:0.78rem;">
                <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#15803d; display:block; margin-bottom:2px;">[CREATE] Instrument Registration</strong>
                    <span style="color:#166534;">Add new musical instruments with technical specifications, high-resolution media galleries, retail pricing, warranty policies, and brand taxonomy.</span>
                </div>
                <div style="background:#f0f9ff; border:1px solid #bae6fd; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#0369a1; display:block; margin-bottom:2px;">[READ] Multi-Faceted Catalog</strong>
                    <span style="color:#075985;">Browse instruments by category, execute multi-faceted filters (brand, price bracket, specifications), and render side-by-side instrument comparison matrices.</span>
                </div>
                <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b45309; display:block; margin-bottom:2px;">[UPDATE] Catalog & Price Governance</strong>
                    <span style="color:#92400e;">Modify product descriptions, update prices and active promotional discounts, revise technical specs, and adjust display order/media.</span>
                </div>
                <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b91c1c; display:block; margin-bottom:2px;">[DELETE] Delist & Soft-Delete</strong>
                    <span style="color:#991b1b;">Delist discontinued musical gear, delete obsolete categories, or soft-delete archived products from public visibility.</span>
                </div>
            </div>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Code</th>
                            <th>Instrument Name</th>
                            <th>Category</th>
                            <th>Brand</th>
                            <th>Retail (LKR)</th>
                            <th>Discount</th>
                            <th>Effective (LKR)</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th style="text-align:center;">Actions (UPDATE & DELETE)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (products != null) { for (Product p : products) { %>
                            <tr style="<%= p.isArchived() ? "opacity:0.65; background:#fee2e2;" : "" %>">
                                <td><strong>#<%= p.getId() %></strong></td>
                                <td><code><%= p.getCode() %></code></td>
                                <td><strong><%= p.getName() %></strong></td>
                                <td><%= p.getCategory() %></td>
                                <td><%= p.getBrand() %></td>
                                <td><%= String.format("%,.2f", p.getPrice()) %></td>
                                <td><%= (int)p.getDiscountPercent() %>%</td>
                                <td><strong><%= String.format("%,.2f", p.getEffectivePrice()) %></strong></td>
                                <td>
                                    <span class="badge-stock <%= p.getStockQuantity() > 5 ? "badge-in-stock" : "badge-low-stock" %>">
                                        <%= p.getStockQuantity() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge <%= p.isArchived() ? "badge-deactivated" : "badge-active" %>">
                                        <%= p.isArchived() ? "Delisted" : "Active" %>
                                    </span>
                                </td>
                                <td style="text-align:center;">
                                    <div style="display:inline-flex; gap:6px; align-items:center;">
                                        <!-- [UPDATE] Edit Details -->
                                        <button type="button" class="btn btn-warning btn-sm" style="background:#f59e0b; color:#fff; font-weight:600; padding:3px 8px; font-size:0.78rem;" 
                                                onclick="selectProductForEdit(<%= p.getId() %>)">
                                            ✏️ Edit
                                        </button>

                                        <!-- [ARCHIVE/DELIST] Delist / Restore -->
                                        <% if (!p.isArchived()) { %>
                                            <form action="<%= request.getContextPath() %>/products" method="post" onsubmit="return confirmAction('Delist this musical instrument from public storefront?');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="delistProduct">
                                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-warning btn-sm" style="padding:3px 8px; font-size:0.78rem;" title="Delist discontinued musical gear">
                                                    🚫 Delist
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <form action="<%= request.getContextPath() %>/products" method="post" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="restoreProduct">
                                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-success btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#16a34a; color:#fff;" title="Restore delisted instrument to active catalog">
                                                    ✅ Restore
                                                </button>
                                            </form>
                                        <% } %>

                                        <!-- [HARD DELETE] Delete Product from Database -->
                                        <form action="<%= request.getContextPath() %>/products" method="post" onsubmit="return confirmAction('Permanently delete <%= p.getName().replace("'", "\\'") %> from database? This cannot be undone.');" style="display:inline; margin:0;">
                                            <input type="hidden" name="action" value="deleteProduct">
                                            <input type="hidden" name="id" value="<%= p.getId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete product from database">
                                                🗑️ Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>

            <!-- SECTION: EDIT MUSICAL INSTRUMENT (CRUD UPDATE - Member 2) -->
            <div id="editProductSection" style="margin-top:25px; padding:20px; background:#fffbeb; border:2px solid #fde68a; border-radius:var(--radius); display:none;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                    <h4 style="color:#b45309; margin:0; display:flex; align-items:center; gap:8px;">
                        <span>✏️ Edit Musical Instrument Details (CRUD UPDATE - Member 2)</span>
                        <span id="t2_editingBadge" class="badge" style="background:#fef3c7; color:#92400e; font-size:0.8rem; padding:3px 8px; border:1px solid #fcd34d;">
                            Select Instrument
                        </span>
                    </h4>
                    <button type="button" onclick="closeInlineProductEdit()" style="background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; border-radius:4px; padding:3px 10px; cursor:pointer; font-weight:600; font-size:0.8rem;">✕ Close Edit</button>
                </div>

                <!-- Quick Dropdown Picker to choose any instrument to edit -->
                <div style="margin-bottom:15px; background:white; padding:10px 14px; border-radius:6px; border:1px solid #fed7aa;">
                    <label style="font-weight:600; font-size:0.85rem; color:#9a3412;">Choose Any Instrument to Edit Details:</label>
                    <select id="tab2ProductPicker" class="form-control" onchange="onSelectTab2Product(this)" style="margin-top:4px;">
                        <option value="">-- Select an instrument to load its details into the form below --</option>
                        <% if (products != null) { for (Product prod : products) { %>
                            <option value="<%= prod.getId() %>"
                                data-code="<%= prod.getCode() %>"
                                data-name="<%= prod.getName().replace("\"", "&quot;") %>"
                                data-category="<%= prod.getCategory() %>"
                                data-brand="<%= prod.getBrand() %>"
                                data-price="<%= prod.getPrice() %>"
                                data-discount="<%= prod.getDiscountPercent() %>"
                                data-stock="<%= prod.getStockQuantity() %>"
                                data-desc="<%= prod.getDescription().replace("\"", "&quot;").replace("\n", " ").replace("\r", "") %>"
                                data-specs="<%= prod.getTechnicalSpecs().replace("\"", "&quot;").replace("\n", " ").replace("\r", "") %>"
                                data-warranty="<%= prod.getWarrantyPolicy().replace("\"", "&quot;") %>"
                                data-img="<%= prod.getImageUrl() %>">
                                #<%= prod.getId() %> (<%= prod.getCode() %>) - <%= prod.getName() %> | LKR <%= String.format("%,.2f", prod.getPrice()) %> | Stock: <%= prod.getStockQuantity() %>
                            </option>
                        <% }} %>
                    </select>
                </div>

                <form id="tab2EditForm" action="<%= request.getContextPath() %>/products" method="post" style="background:white; padding:20px; border-radius:var(--radius); border:1px solid #fde68a;">
                    <input type="hidden" name="action" value="updateProduct">
                    <input type="hidden" name="id" id="t2_edit_id">
                    <input type="hidden" name="returnTab" value="products">

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Product Code</label>
                            <input type="text" id="t2_edit_code" readonly class="form-control" style="background:#f1f5f9; font-weight:bold;">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Instrument Name *</label>
                            <input type="text" name="name" id="t2_edit_name" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Category *</label>
                            <select name="category" id="t2_edit_category" class="form-control">
                                <option value="String Instruments">String Instruments</option>
                                <option value="Keyboards & Pianos">Keyboards & Pianos</option>
                                <option value="Drums & Percussion">Drums & Percussion</option>
                                <option value="Wind Instruments">Wind Instruments</option>
                                <option value="Traditional Sri Lankan">Traditional Sri Lankan</option>
                            </select>
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Brand *</label>
                            <input type="text" name="brand" id="t2_edit_brand" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Retail Price (LKR) *</label>
                            <input type="number" step="0.01" name="price" id="t2_edit_price" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Discount (%)</label>
                            <input type="number" step="0.1" name="discountPercent" id="t2_edit_discount" class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Stock Quantity *</label>
                            <input type="number" name="stockQuantity" id="t2_edit_stock" required class="form-control">
                        </div>
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-size:0.82rem; font-weight:600;">Marketing Description *</label>
                        <textarea name="description" id="t2_edit_description" required class="form-control" rows="2"></textarea>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Technical Specifications *</label>
                            <input type="text" name="technicalSpecs" id="t2_edit_specs" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Warranty Period (Years - Numbers Only) *</label>
                            <input type="number" min="0" max="25" step="1" name="warrantyPolicy" id="t2_edit_warranty" required class="form-control" placeholder="e.g. 2" title="Warranty must contain numbers only (e.g. 1, 2, 3 years).">
                        </div>
                    </div>

                    <div style="margin-bottom:16px;">
                        <label style="font-size:0.82rem; font-weight:600;">High-Resolution Image URL *</label>
                        <input type="text" name="imageUrl" id="t2_edit_image" required class="form-control">
                    </div>

                    <div style="display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" class="btn btn-secondary" onclick="closeInlineProductEdit()">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="background:#d97706; border-color:#d97706; font-weight:bold;">
                            Save Changes in Database
                        </button>
                    </div>
                </form>
            </div>
        </div>
    <% } %>
    <!-- TAB 3: ORDERS (Member 3 & Saved Orders) -->
    <% if ("orders".equals(activeTab)) { %>
        <div class="card">
            <h3 class="card-title">
                <span>Member 3: Customer Orders & Cart Persistence (IT25103636)</span>
                <span style="font-size:0.85rem; color:var(--success); font-weight:normal;">All Orders Saved to <code>orders.txt</code></span>
            </h3>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Date</th>
                            <th>Customer Name</th>
                            <th>Phone / Destination</th>
                            <th>Items</th>
                            <th>Total (LKR)</th>
                            <th>Payment</th>
                            <th>Courier Partner</th>
                            <th>Status</th>
                            <th>Invoice</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (orders != null) { for (Order o : orders) { %>
                            <tr>
                                <td><strong><%= o.getOrderId() %></strong></td>
                                <td style="font-size:0.8rem; color:var(--gray-600);"><%= o.getOrderDate() %></td>
                                <td><%= o.getCustomerName() %></td>
                                <td style="font-size:0.8rem;"><%= o.getCustomerPhone() %><br><%= o.getCity() %> (<%= o.getDistrict() %>)</td>
                                <td style="font-size:0.8rem; max-width:200px;"><%= o.getItemsSummary() %></td>
                                <td><strong>LKR <%= String.format("%,.2f", o.getTotalAmount()) %></strong></td>
                                <td><span class="badge badge-<%= o.getPaymentStatus().toLowerCase() %>"><%= o.getPaymentStatus() %></span></td>
                                <td><%= o.getCourierName() %><br><code style="font-size:0.75rem;"><%= o.getTrackingNumber() %></code></td>
                                <td><span class="badge badge-<%= o.getFulfillmentStatus().toLowerCase() %>"><%= o.getFulfillmentStatus() %></span></td>
                                <td>
                                    <div style="display:flex; gap:4px; align-items:center;">
                                        <a href="<%= request.getContextPath() %>/invoice?orderId=<%= o.getOrderId() %>" class="btn btn-secondary btn-sm" target="_blank">PDF</a>
                                        <button type="button" class="btn btn-primary btn-sm" onclick="openOrderEditModal(
                                            '<%= o.getOrderId() %>',
                                            '<%= o.getCustomerName().replace("'", "\\'") %>',
                                            '<%= o.getCustomerPhone() %>',
                                            '<%= o.getShippingAddress().replace("'", "\\'") %>',
                                            '<%= o.getCity().replace("'", "\\'") %>',
                                            '<%= o.getDistrict().replace("'", "\\'") %>',
                                            '<%= o.getCourierName() %>',
                                            '<%= o.getPaymentStatus() %>',
                                            '<%= o.getFulfillmentStatus() %>'
                                        )">Update</button>
                                        <form action="<%= request.getContextPath() %>/orders" method="post" onsubmit="return confirmAction('Permanently delete order <%= o.getOrderId() %> from database? This will remove all linked items, payments, and invoices.');" style="display:inline; margin:0;">
                                            <input type="hidden" name="action" value="deleteOrder">
                                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete order from database">
                                                🗑️ Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>

            <!-- Member 3: Musical Instrument Update Section -->
            <div style="margin-top:25px; padding:20px; background:#f0fdf4; border:1px solid #bbf7d0; border-radius:var(--radius);">
                <h4 style="color:#166534; margin-bottom:8px;">Member 3: Update Musical Instrument / Pricing & Inventory (UPDATE CRUD)</h4>
                <p style="font-size:0.85rem; color:#15803d; margin-bottom:15px;">
                    This section allows Member 3 (Cart, Checkout & Inventory Sync) to select and update any product directly in the database.
                </p>
                <div style="margin-bottom:15px;">
                    <label style="font-weight:600; font-size:0.85rem; color:#166534;">Select Instrument to Update:</label>
                    <select id="m3ProductPicker" class="form-control" onchange="onSelectMember3Product(this)">
                        <option value="">-- Choose Any Product to Edit Details --</option>
                        <% if (products != null) { for (Product prod : products) { %>
                            <option value="<%= prod.getId() %>"
                                data-code="<%= prod.getCode() %>"
                                data-name="<%= prod.getName().replace("\"", "&quot;") %>"
                                data-category="<%= prod.getCategory() %>"
                                data-brand="<%= prod.getBrand() %>"
                                data-price="<%= prod.getPrice() %>"
                                data-discount="<%= prod.getDiscountPercent() %>"
                                data-stock="<%= prod.getStockQuantity() %>"
                                data-desc="<%= prod.getDescription().replace("\"", "&quot;").replace("\n", " ").replace("\r", "") %>"
                                data-specs="<%= prod.getTechnicalSpecs().replace("\"", "&quot;").replace("\n", " ").replace("\r", "") %>"
                                data-warranty="<%= prod.getWarrantyPolicy().replace("\"", "&quot;") %>"
                                data-img="<%= prod.getImageUrl() %>">
                                #<%= prod.getId() %> - <%= prod.getName() %> (LKR <%= String.format("%,.2f", prod.getPrice()) %>, Stock: <%= prod.getStockQuantity() %>)
                            </option>
                        <% }} %>
                    </select>
                </div>

                <form id="m3EditForm" action="<%= request.getContextPath() %>/products" method="post" style="display:none; background:white; padding:20px; border-radius:var(--radius); border:1px solid #86efac; box-shadow:var(--shadow);">
                    <input type="hidden" name="action" value="updateProduct">
                    <input type="hidden" name="id" id="m3_id">
                    <input type="hidden" name="returnTab" value="orders">

                    <h5 style="color:var(--primary); margin-bottom:12px;">Edit Instrument Details & Database Record</h5>
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Product Code</label>
                            <input type="text" id="m3_code" readonly class="form-control" style="background:#f1f5f9;">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Instrument Name *</label>
                            <input type="text" name="name" id="m3_name" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Category *</label>
                            <select name="category" id="m3_category" class="form-control">
                                <option value="String Instruments">String Instruments</option>
                                <option value="Keyboards & Pianos">Keyboards & Pianos</option>
                                <option value="Drums & Percussion">Drums & Percussion</option>
                                <option value="Wind Instruments">Wind Instruments</option>
                                <option value="Traditional Sri Lankan">Traditional Sri Lankan</option>
                            </select>
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Brand *</label>
                            <input type="text" name="brand" id="m3_brand" required class="form-control">
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Retail Price (LKR) *</label>
                            <input type="number" step="0.01" name="price" id="m3_price" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Discount Percentage (%)</label>
                            <input type="number" step="0.1" name="discountPercent" id="m3_discount" class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Available Stock Quantity *</label>
                            <input type="number" name="stockQuantity" id="m3_stock" required class="form-control">
                        </div>
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-size:0.82rem; font-weight:600;">Description *</label>
                        <textarea name="description" id="m3_description" required class="form-control" rows="2"></textarea>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Technical Specifications *</label>
                            <input type="text" name="technicalSpecs" id="m3_specs" required class="form-control">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Warranty Period (Years - Numbers Only) *</label>
                            <input type="number" min="0" max="25" step="1" name="warrantyPolicy" id="m3_warranty" required class="form-control" placeholder="e.g. 2" title="Warranty must contain numbers only (e.g. 1, 2, 3 years).">
                        </div>
                    </div>

                    <div style="margin-bottom:15px;">
                        <label style="font-size:0.82rem; font-weight:600;">Product Image URL *</label>
                        <input type="text" name="imageUrl" id="m3_image" required class="form-control">
                    </div>

                    <div style="display:flex; gap:10px;">
                        <button type="submit" class="btn btn-primary">Save & Update Instrument in Database</button>
                        <button type="button" class="btn btn-secondary" onclick="document.getElementById('m3EditForm').style.display='none'">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    <% } %>
    <!-- TAB 4: PAYMENTS & INVOICES (Member 4: IT25101556 - Ekanayaka E. A. T. T.) -->
    <% if ("payments".equals(activeTab)) { 
        int totalTxns = payments != null ? payments.size() : 0;
        int paidCount = 0;
        int pendingCount = 0;
        int refundCount = 0;
        int failedCount = 0;
        int archivedCount = 0;
        double totalPaidAmount = 0.0;
        double totalPendingAmount = 0.0;
        double totalRefundedAmount = 0.0;

        if (payments != null) {
            for (Payment p : payments) {
                if ("PAID".equalsIgnoreCase(p.getPaymentStatus())) {
                    paidCount++;
                    totalPaidAmount += p.getAmount();
                } else if ("PENDING".equalsIgnoreCase(p.getPaymentStatus())) {
                    pendingCount++;
                    totalPendingAmount += p.getAmount();
                } else if ("REFUNDED".equalsIgnoreCase(p.getPaymentStatus())) {
                    refundCount++;
                    totalRefundedAmount += p.getAmount();
                } else if ("FAILED".equalsIgnoreCase(p.getPaymentStatus()) || "VOIDED".equalsIgnoreCase(p.getPaymentStatus())) {
                    failedCount++;
                } else if ("ARCHIVED".equalsIgnoreCase(p.getPaymentStatus())) {
                    archivedCount++;
                }
            }
        }
    %>
        <div class="card">
            <!-- Card Header with All 4 CRUD Badges -->
            <div style="border-bottom:1px solid var(--gray-200); padding-bottom:16px; margin-bottom:20px;">
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                    <div>
                        <h3 class="card-title" style="margin:0; font-size:1.35rem; color:var(--primary);">
                            6.4 Payment Gateway & Invoice System
                            <span class="badge badge-active" style="font-size:0.8rem; margin-left:6px;">IT25101556</span>
                            <span style="font-size:0.95rem; font-weight:normal; color:var(--gray-700);">Ekanayaka E. A. T. T.</span>
                        </h3>
                    </div>
                    <div>
                        <button type="button" onclick="toggleCreatePaymentForm()" class="btn btn-primary" style="font-weight:600; padding:7px 16px;">
                            + Initiate New Transaction & Issue E-Invoice (CREATE)
                        </button>
                    </div>
                </div>

                <!-- 4 CRUD Badges Specification Matrix Display -->
                <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; margin-top:14px; font-size:0.8rem;">
                    <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:6px; padding:8px 12px;">
                        <span style="background:#10b981; color:#fff; font-weight:700; padding:2px 6px; border-radius:3px; font-size:0.75rem;">CREATE</span>
                        <div style="color:#065f46; margin-top:4px;">Initiate transaction records across payment channels & auto-generate itemized e-invoices with tax breakdowns.</div>
                    </div>
                    <div style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:6px; padding:8px 12px;">
                        <span style="background:#3b82f6; color:#fff; font-weight:700; padding:2px 6px; border-radius:3px; font-size:0.75rem;">READ</span>
                        <div style="color:#1e40af; margin-top:4px;">Track real-time payment states (Pending, Paid, Failed, Refunded), download official PDF tax invoices, & access histories.</div>
                    </div>
                    <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:6px; padding:8px 12px;">
                        <span style="background:#f59e0b; color:#fff; font-weight:700; padding:2px 6px; border-radius:3px; font-size:0.75rem;">UPDATE</span>
                        <div style="color:#92400e; margin-top:4px;">Update transaction status following manual bank slip review/webhooks, & record processed refund details.</div>
                    </div>
                    <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:6px; padding:8px 12px;">
                        <span style="background:#ef4444; color:#fff; font-weight:700; padding:2px 6px; border-radius:3px; font-size:0.75rem;">DELETE</span>
                        <div style="color:#991b1b; margin-top:4px;">Void failed or unverified payment attempts, archive obsolete billing records, & cancel invalidated draft invoices.</div>
                    </div>
                </div>
            </div>

            <!-- Real-time State KPI Summary Metrics (READ) -->
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap:14px; margin-bottom:22px;">
                <div style="background:#f8fafc; border:1px solid var(--gray-300); border-radius:var(--radius); padding:12px 14px; text-align:center;">
                    <div style="font-size:0.8rem; color:var(--gray-600); font-weight:600;">Total Transactions</div>
                    <div style="font-size:1.4rem; font-weight:700; color:var(--primary);"><%= totalTxns %></div>
                    <div style="font-size:0.75rem; color:var(--gray-500);">All Payment Records</div>
                </div>
                <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:var(--radius); padding:12px 14px; text-align:center;">
                    <div style="font-size:0.8rem; color:#065f46; font-weight:600;">Paid / Verified</div>
                    <div style="font-size:1.4rem; font-weight:700; color:#10b981;"><%= paidCount %></div>
                    <div style="font-size:0.75rem; color:#047857;">LKR <%= String.format("%,.2f", totalPaidAmount) %></div>
                </div>
                <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:var(--radius); padding:12px 14px; text-align:center;">
                    <div style="font-size:0.8rem; color:#92400e; font-weight:600;">Pending Slip Review</div>
                    <div style="font-size:1.4rem; font-weight:700; color:#f59e0b;"><%= pendingCount %></div>
                    <div style="font-size:0.75rem; color:#b45309;">LKR <%= String.format("%,.2f", totalPendingAmount) %></div>
                </div>
                <div style="background:#faf5ff; border:1px solid #e9d5ff; border-radius:var(--radius); padding:12px 14px; text-align:center;">
                    <div style="font-size:0.8rem; color:#6b21a8; font-weight:600;">Processed Refunds</div>
                    <div style="font-size:1.4rem; font-weight:700; color:#8b5cf6;"><%= refundCount %></div>
                    <div style="font-size:0.75rem; color:#7c3aed;">LKR <%= String.format("%,.2f", totalRefundedAmount) %></div>
                </div>
                <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:var(--radius); padding:12px 14px; text-align:center;">
                    <div style="font-size:0.8rem; color:#991b1b; font-weight:600;">Voided / Failed</div>
                    <div style="font-size:1.4rem; font-weight:700; color:#ef4444;"><%= failedCount %></div>
                    <div style="font-size:0.75rem; color:#dc2626;">Unverified / Voided</div>
                </div>
            </div>

            <!-- [CREATE] Form: Initiate Payment Transaction & Auto-Generate Itemized E-Invoice -->
            <div id="createPaymentFormContainer" style="display:none; background:#f0fdf4; border:2px solid #86efac; border-radius:var(--radius); padding:22px; margin-bottom:25px; box-shadow:var(--shadow);">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid #bbf7d0; padding-bottom:10px;">
                    <h4 style="color:#166534; margin:0; font-size:1.15rem; display:flex; align-items:center; gap:8px;">
                        <span>💳 Initiate New Transaction & Auto-Generate Itemized E-Invoice (CREATE)</span>
                    </h4>
                    <button type="button" onclick="toggleCreatePaymentForm()" style="background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; border-radius:4px; padding:3px 10px; cursor:pointer; font-weight:600; font-size:0.8rem;">✕ Close Form</button>
                </div>
                <p style="font-size:0.85rem; color:#15803d; margin-bottom:15px;">
                    Initiate transaction records across payment channels (Credit/Debit Card, Bank Transfer Slip, Digital Wallet, Cash on Delivery) and automatically generate an official compliant e-invoice with 8% VAT tax breakdown.
                </p>

                <form action="<%= request.getContextPath() %>/payment" method="post" style="background:white; padding:18px; border-radius:var(--radius); border:1px solid #bbf7d0;">
                    <input type="hidden" name="action" value="initiatePayment">

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:14px; margin-bottom:14px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600; color:#166534;">Select Existing Order Reference (Optional)</label>
                            <select id="m4_orderPicker" class="form-control" onchange="onSelectOrderForPayment(this)">
                                <option value="">-- Manual / Enter Custom Order ID --</option>
                                <% if (orders != null) { for (Order ord : orders) { %>
                                    <option value="<%= ord.getOrderId() %>"
                                        data-name="<%= ord.getCustomerName().replace("\"", "&quot;") %>"
                                        data-email="<%= ord.getCustomerEmail() %>"
                                        data-phone="<%= ord.getCustomerPhone() %>"
                                        data-address="<%= ord.getShippingAddress().replace("\"", "&quot;") %>, <%= ord.getCity() %>, <%= ord.getDistrict() %>"
                                        data-amount="<%= ord.getTotalAmount() %>"
                                        data-method="<%= ord.getPaymentMethod() %>">
                                        <%= ord.getOrderId() %> - <%= ord.getCustomerName() %> (LKR <%= String.format("%,.2f", ord.getTotalAmount()) %> | <%= ord.getPaymentStatus() %>)
                                    </option>
                                <% }} %>
                            </select>
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Order Reference ID *</label>
                            <input type="text" name="orderId" id="m4_orderId" required class="form-control" placeholder="e.g. ORD-2026-015">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Transaction Amount (LKR) *</label>
                            <input type="number" step="0.01" name="amount" id="m4_amount" required class="form-control" placeholder="48500.00">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Payment Channel *</label>
                            <select name="paymentMethod" id="m4_method" required class="form-control">
                                <option value="CREDIT_CARD">💳 Credit / Debit Card (Visa / MasterCard / AMEX)</option>
                                <option value="BANK_TRANSFER">🏦 Bank Deposit / Transfer Slip (Online / Branch)</option>
                                <option value="DIGITAL_WALLET">📱 Digital Wallet (Genie / FriMi / eZ Cash / mCash)</option>
                                <option value="COD">💵 Cash on Delivery (COD Courier Collection)</option>
                            </select>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:14px; margin-bottom:14px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Customer Full Name *</label>
                            <input type="text" name="customerName" id="m4_customerName" required class="form-control" placeholder="e.g. Ruwan Silva">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Customer Email *</label>
                            <input type="email" name="customerEmail" id="m4_customerEmail" required class="form-control" placeholder="ruwan@example.com">
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Customer Phone Number *</label>
                            <input type="text" name="customerPhone" id="m4_customerPhone" required class="form-control" placeholder="0771234567">
                        </div>
                    </div>

                    <div style="margin-bottom:14px;">
                        <label style="font-size:0.82rem; font-weight:600;">Billing / Delivery Address *</label>
                        <input type="text" name="billingAddress" id="m4_billingAddress" required class="form-control" placeholder="No. 12, Temple Road, Colombo 04">
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:14px; margin-bottom:16px;">
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Bank Deposit Slip Reference / Webhook URL</label>
                            <input type="text" name="bankSlipUrl" id="m4_slip" class="form-control" placeholder="SLIP-BOC-99214.jpg or Bank Reference Code">
                            <span style="font-size:0.75rem; color:var(--gray-600);">Required for Bank Transfer verification review</span>
                        </div>
                        <div>
                            <label style="font-size:0.82rem; font-weight:600;">Gateway Reference / Authorization Code</label>
                            <input type="text" name="transactionRef" id="m4_ref" class="form-control" placeholder="AUTH-COMM-998822 or Gateway Webhook ID">
                        </div>
                    </div>

                    <div style="margin-bottom:18px; background:#f8fafc; padding:12px 14px; border-radius:6px; border:1px solid var(--gray-200);">
                        <label style="display:flex; align-items:center; gap:8px; cursor:pointer; font-weight:600; font-size:0.88rem; color:var(--primary);">
                            <input type="checkbox" name="autoGenerateInvoice" value="true" checked>
                            <span>🧾 Auto-generate itemized official e-Invoice with 8% VAT tax breakdown in database</span>
                        </label>
                        <div style="font-size:0.78rem; color:var(--gray-600); margin-left:24px; margin-top:2px;">
                            Calculates 8% Sri Lankan VAT tax breakdown, produces an official Tax Invoice Number (INV-2026-XXX), and links it to the payment record.
                        </div>
                    </div>

                    <div style="display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" class="btn btn-secondary" onclick="toggleCreatePaymentForm()">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="background:#16a34a; border-color:#16a34a; font-weight:bold; padding:8px 20px;">
                            💳 Record Transaction & Issue E-Invoice
                        </button>
                    </div>
                </form>
            </div>

            <!-- Quick State Filter Buttons & Search Filter (READ) -->
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:16px;">
                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-sm btn-secondary" onclick="filterPaymentsByStatus('ALL')">All (<%= totalTxns %>)</button>
                    <button type="button" class="btn btn-sm btn-success" style="background:#10b981; color:#fff;" onclick="filterPaymentsByStatus('PAID')">Paid (<%= paidCount %>)</button>
                    <button type="button" class="btn btn-sm btn-warning" style="background:#f59e0b; color:#fff;" onclick="filterPaymentsByStatus('PENDING')">Pending (<%= pendingCount %>)</button>
                    <button type="button" class="btn btn-sm" style="background:#8b5cf6; color:#fff;" onclick="filterPaymentsByStatus('REFUNDED')">Refunded (<%= refundCount %>)</button>
                    <button type="button" class="btn btn-sm btn-danger" onclick="filterPaymentsByStatus('VOIDED')">Voided/Failed (<%= failedCount %>)</button>
                </div>
                <div style="min-width:260px;">
                    <input type="text" id="paymentSearchInput" onkeyup="filterPaymentsSearch(this.value)" class="form-control" placeholder="🔍 Search Txn, Order, Channel, Customer..." style="padding:6px 12px; font-size:0.85rem;">
                </div>
            </div>

            <!-- Interactive Payments Table (READ, UPDATE, DELETE) -->
            <div class="table-responsive" style="margin-bottom:30px;">
                <table id="paymentsTable">
                    <thead>
                        <tr>
                            <th>Txn ID</th>
                            <th>Order Ref</th>
                            <th>Amount (LKR)</th>
                            <th>Channel</th>
                            <th>Real-Time State</th>
                            <th>Gateway Ref / Slip</th>
                            <th>Timestamp</th>
                            <th style="min-width:280px;">CRUD Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (payments != null) { for (Payment p : payments) { 
                            String statusUpper = p.getPaymentStatus() != null ? p.getPaymentStatus().toUpperCase() : "PENDING";
                            String methodLabel = p.getPaymentMethod();
                            if ("CREDIT_CARD".equalsIgnoreCase(p.getPaymentMethod())) methodLabel = "💳 Card";
                            else if ("BANK_TRANSFER".equalsIgnoreCase(p.getPaymentMethod())) methodLabel = "🏦 Bank Slip";
                            else if ("DIGITAL_WALLET".equalsIgnoreCase(p.getPaymentMethod())) methodLabel = "📱 Wallet";
                            else if ("COD".equalsIgnoreCase(p.getPaymentMethod())) methodLabel = "💵 COD";
                        %>
                            <tr class="payment-row" data-status="<%= statusUpper %>" data-search="<%= (p.getTransactionId() + " " + p.getOrderId() + " " + p.getPaymentMethod() + " " + (p.getTransactionRef() != null ? p.getTransactionRef() : "")).toLowerCase() %>">
                                <td><code><%= p.getTransactionId() %></code></td>
                                <td><strong><%= p.getOrderId() %></strong></td>
                                <td><strong>LKR <%= String.format("%,.2f", p.getAmount()) %></strong></td>
                                <td><%= methodLabel %></td>
                                <td>
                                    <span class="badge badge-<%= p.getPaymentStatus().toLowerCase() %>">
                                        <%= p.getPaymentStatus() %>
                                    </span>
                                </td>
                                <td style="font-size:0.8rem; max-width:220px;">
                                    <%= p.getTransactionRef() != null ? p.getTransactionRef() : "" %>
                                    <% if (p.getBankSlipUrl() != null && !p.getBankSlipUrl().isEmpty()) { %>
                                        <br><span style="color:#0369a1; font-weight:600; font-size:0.75rem;">📎 <%= p.getBankSlipUrl() %></span>
                                    <% } %>
                                    <% if (p.getRefundDetails() != null && !p.getRefundDetails().isEmpty()) { %>
                                        <br><span style="color:#7c3aed; font-size:0.75rem; font-style:italic;"><%= p.getRefundDetails() %></span>
                                    <% } %>
                                </td>
                                <td style="font-size:0.8rem; color:var(--gray-600);"><%= p.getTimestamp() %></td>
                                <td>
                                    <div style="display:flex; flex-wrap:wrap; gap:4px; align-items:center;">
                                        <!-- [READ]: View / Download Official Tax Invoice -->
                                        <a href="<%= request.getContextPath() %>/invoice?orderId=<%= p.getOrderId() %>" 
                                           target="_blank" 
                                           class="btn btn-secondary btn-sm" 
                                           style="padding:3px 7px; font-size:0.75rem;" 
                                           title="Download/Print Official PDF Tax Invoice with 8% VAT">
                                           📄 Tax Invoice
                                        </a>

                                        <!-- [READ]: Customer Transaction History -->
                                        <button type="button" 
                                                class="btn btn-info btn-sm" 
                                                style="padding:3px 7px; font-size:0.75rem; background:#0284c7; color:#fff;" 
                                                onclick="showCustomerHistory('<%= p.getOrderId() %>', '<%= p.getTransactionId() %>', '<%= p.getAmount() %>')">
                                            📜 History
                                        </button>

                                        <!-- [UPDATE]: Review Bank Slip or Update Transaction Status -->
                                        <button type="button" 
                                                class="btn btn-warning btn-sm" 
                                                style="padding:3px 7px; font-size:0.75rem; background:#f59e0b; color:#fff; font-weight:600;" 
                                                onclick="openReviewModal(
                                                    '<%= p.getTransactionId() %>',
                                                    '<%= p.getOrderId() %>',
                                                    '<%= p.getPaymentStatus() %>',
                                                    '<%= p.getPaymentMethod() %>',
                                                    '<%= p.getAmount() %>',
                                                    '<%= p.getBankSlipUrl() != null ? p.getBankSlipUrl().replace("'", "\'") : "" %>',
                                                    '<%= p.getTransactionRef() != null ? p.getTransactionRef().replace("'", "\'") : "" %>'
                                                )">
                                            ✏️ Review / Update
                                        </button>

                                        <!-- [UPDATE]: Process Refund (Available for PAID transactions) -->
                                        <% if ("PAID".equalsIgnoreCase(p.getPaymentStatus())) { %>
                                            <button type="button" 
                                                    class="btn btn-sm" 
                                                    style="padding:3px 7px; font-size:0.75rem; background:#8b5cf6; color:#fff; font-weight:600;" 
                                                    onclick="openRefundModal('<%= p.getTransactionId() %>', '<%= p.getOrderId() %>', <%= p.getAmount() %>)">
                                                💸 Refund
                                            </button>
                                        <% } %>

                                        <!-- [DELETE]: Void Failed or Unverified Payment Attempts -->
                                        <% if ("PENDING".equalsIgnoreCase(p.getPaymentStatus()) || "FAILED".equalsIgnoreCase(p.getPaymentStatus())) { %>
                                            <button type="button" 
                                                    class="btn btn-danger btn-sm" 
                                                    style="padding:3px 7px; font-size:0.75rem; background:#dc2626; color:#fff;" 
                                                    onclick="openVoidModal('<%= p.getTransactionId() %>', '<%= p.getOrderId() %>')">
                                                🚫 Void
                                            </button>
                                        <% } %>

                                        <!-- [DELETE]: Archive Obsolete Billing Record -->
                                        <form action="<%= request.getContextPath() %>/payment" method="post" onsubmit="return confirmAction('Archive this billing record in database?');" style="display:inline; margin:0;">
                                            <input type="hidden" name="action" value="archivePayment">
                                            <input type="hidden" name="txnId" value="<%= p.getTransactionId() %>">
                                            <button type="submit" class="btn btn-secondary btn-sm" style="padding:3px 6px; font-size:0.75rem;" title="Archive obsolete billing record">📁 Archive</button>
                                        </form>

                                        <!-- [HARD DELETE]: Delete Payment Record from Database -->
                                        <form action="<%= request.getContextPath() %>/payment" method="post" onsubmit="return confirmAction('Permanently delete payment transaction <%= p.getTransactionId() %> from database?');" style="display:inline; margin:0;">
                                            <input type="hidden" name="action" value="deletePayment">
                                            <input type="hidden" name="txnId" value="<%= p.getTransactionId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 6px; font-size:0.75rem; background:#b91c1c; color:#fff;" title="Permanently delete payment transaction from database">🗑️ Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>

            <!-- Section 2: [READ & DELETE] Official E-Invoices & Tax Breakdowns (8% VAT) -->
            <div style="border-top:2px solid var(--gray-200); padding-top:20px; margin-top:25px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; flex-wrap:wrap; gap:8px;">
                    <div>
                        <h4 style="color:var(--primary); margin:0; font-size:1.15rem; display:flex; align-items:center; gap:8px;">
                            <span>🧾 Official Itemized E-Invoices with Tax Breakdowns (8% VAT)</span>
                            <span class="badge" style="background:#e0f2fe; color:#0369a1; font-size:0.8rem;">
                                <%= invoices != null ? invoices.size() : 0 %> E-Invoices Issued
                            </span>
                        </h4>
                        <p style="font-size:0.82rem; color:var(--gray-600); margin:4px 0 0;">
                            Compliant with Inland Revenue Department of Sri Lanka (IRD) 8% VAT tax regulations and verified under Module 6.4.
                        </p>
                    </div>
                </div>

                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Invoice No</th>
                                <th>Order ID</th>
                                <th>Date</th>
                                <th>Customer Name & Billing Address</th>
                                <th>Subtotal (LKR)</th>
                                <th>VAT (8%)</th>
                                <th>Total (LKR)</th>
                                <th>Payment State</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (invoices != null && !invoices.isEmpty()) { 
                                for (Invoice inv : invoices) { %>
                                <tr>
                                    <td><code><%= inv.getInvoiceNumber() %></code></td>
                                    <td><strong><%= inv.getOrderId() %></strong></td>
                                    <td style="font-size:0.8rem; color:var(--gray-600);"><%= inv.getInvoiceDate() %></td>
                                    <td style="font-size:0.85rem;">
                                        <strong><%= inv.getCustomerName() %></strong><br>
                                        <span style="font-size:0.78rem; color:var(--gray-600);"><%= inv.getBillingAddress() %></span>
                                    </td>
                                    <td>LKR <%= String.format("%,.2f", inv.getSubtotal()) %></td>
                                    <td style="color:#0369a1; font-weight:600;">LKR <%= String.format("%,.2f", inv.getVatAmount()) %></td>
                                    <td><strong>LKR <%= String.format("%,.2f", inv.getTotalAmount()) %></strong></td>
                                    <td>
                                        <span class="badge badge-<%= inv.getPaymentStatus() != null ? inv.getPaymentStatus().toLowerCase() : "paid" %>">
                                            <%= inv.getPaymentStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="display:flex; gap:5px; align-items:center;">
                                            <!-- [READ]: View / Print PDF Tax Invoice -->
                                            <a href="<%= request.getContextPath() %>/invoice?no=<%= inv.getInvoiceNumber() %>" 
                                               target="_blank" 
                                               class="btn btn-primary btn-sm" 
                                               style="padding:3px 8px; font-size:0.78rem;">
                                               🖨️ PDF
                                            </a>

                                            <!-- [DELETE]: Cancel Invalidated Draft Invoice -->
                                            <% if (!"PAID".equalsIgnoreCase(inv.getPaymentStatus()) && !"CANCELLED".equalsIgnoreCase(inv.getPaymentStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/payment" method="post" onsubmit="return confirmAction('Cancel this invalidated draft invoice?');" style="margin:0;">
                                                    <input type="hidden" name="action" value="cancelDraftInvoice">
                                                    <input type="hidden" name="invoiceNumber" value="<%= inv.getInvoiceNumber() %>">
                                                    <input type="hidden" name="cancelReason" value="Cancelled by Accounts Officer">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem;" title="Cancel invalidated draft invoice">
                                                        ❌ Cancel
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE]: Delete Invoice from Database -->
                                            <form action="<%= request.getContextPath() %>/payment" method="post" onsubmit="return confirmAction('Permanently delete invoice <%= inv.getInvoiceNumber() %> from database?');" style="margin:0; display:inline;">
                                                <input type="hidden" name="action" value="deleteInvoice">
                                                <input type="hidden" name="invoiceNumber" value="<%= inv.getInvoiceNumber() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete invoice from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="9" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No invoices found. When orders or payments are initiated, official e-invoices are auto-generated here.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <% } %>

    <!-- TAB 5: INVENTORY & SUPPLIERS (Member 5) -->
    <% if ("inventory".equals(activeTab)) { %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; flex-wrap:wrap; gap:10px;">
                <div>
                    <h3 class="card-title" style="margin-bottom:4px;">Member 5: Real-Time Inventory & Supplier Management (IT25103441)</h3>
                    <p style="color:var(--gray-600); font-size:0.85rem; margin:0;">
                        SLIIT Module 6.5 | Full Relational Database CRUD with Live Stock Adjustments & Warranty Batch Receipt
                    </p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-primary btn-sm" onclick="openAddSupplierModal()" style="display:inline-flex; align-items:center; gap:6px;">
                        <span>➕ Register New Supplier</span>
                        <span class="badge" style="background:#22c55e; color:#fff; font-size:0.65rem;">CREATE</span>
                    </button>
                    <button type="button" class="btn btn-sm" onclick="openCreatePoModal()" style="background:#0284c7; color:#fff; display:inline-flex; align-items:center; gap:6px;">
                        <span>📋 Issue Purchase Order</span>
                        <span class="badge" style="background:#38bdf8; color:#0369a1; font-size:0.65rem;">CREATE</span>
                    </button>
                    <button type="button" class="btn btn-sm" onclick="openAdjustStockModal(0, '', 0)" style="background:#f59e0b; color:#fff; display:inline-flex; align-items:center; gap:6px;">
                        <span>📦 Adjust Stock / Log Return</span>
                        <span class="badge" style="background:#fbbf24; color:#78350f; font-size:0.65rem;">UPDATE</span>
                    </button>
                </div>
            </div>

            <!-- Member 5 CRUD Specification Badges -->
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; margin-bottom:20px; font-size:0.78rem;">
                <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#15803d; display:block; margin-bottom:2px;">[CREATE] Inbound Procurement</strong>
                    <span style="color:#166534;">Register new instrument suppliers, generate stock POs, and record incoming stock batches with warranty batches.</span>
                </div>
                <div style="background:#f0f9ff; border:1px solid #bae6fd; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#0369a1; display:block; margin-bottom:2px;">[READ] Live Warehouse Monitoring</strong>
                    <span style="color:#075985;">Monitor live warehouse stock levels, review automated low-stock and reorder alerts, inspect supplier records.</span>
                </div>
                <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b45309; display:block; margin-bottom:2px;">[UPDATE] Inventory Adjustments</strong>
                    <span style="color:#92400e;">Auto-deduct available stock on checkout, adjust stock counts for returns/damages, update supplier contract details.</span>
                </div>
                <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b91c1c; display:block; margin-bottom:2px;">[DELETE] Deprecate & Invalidate</strong>
                    <span style="color:#991b1b;">Deactivate discontinued supplier profiles and cancel draft or invalid purchase order requisitions.</span>
                </div>
            </div>

            <!-- Section 1: Automated Low-Stock Reorder Alerts -->
            <div style="background:#fefce8; border:1px solid #fef08a; padding:15px; border-radius:var(--radius); margin-bottom:20px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                    <h4 style="color:#854d0e; margin:0;">⚠️ Automated Low-Stock Reorder Alerts (&lt; 10 units):</h4>
                    <span style="font-size:0.75rem; color:#a16207; font-weight:600;">Triggered by Real-Time Stock Engine</span>
                </div>
                <div style="display:flex; flex-wrap:wrap; gap:10px;">
                    <% boolean hasLowStock = false;
                       if (products != null) { for (Product p : products) {
                        if (p.getStockQuantity() <= 10 && !p.isArchived()) { 
                            hasLowStock = true; %>
                            <span style="background:#fff; border:1px solid #fde047; padding:5px 12px; border-radius:6px; font-size:0.85rem; display:inline-flex; align-items:center; gap:6px; box-shadow:0 1px 2px rgba(0,0,0,0.05);">
                                <strong style="color:#854d0e;"><%= p.getName() %></strong>
                                <span class="badge <%= p.getStockQuantity() == 0 ? "badge-danger" : "badge-warning" %>" style="font-size:0.72rem;">
                                    <%= p.getStockQuantity() == 0 ? "OUT OF STOCK" : p.getStockQuantity() + " left" %>
                                </span>
                                <button type="button" class="btn btn-sm" style="padding:1px 6px; font-size:0.72rem; background:#f59e0b; color:#fff;" 
                                        onclick="openAdjustStockModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'").replace("\"", "&quot;") %>', <%= p.getStockQuantity() %>)">
                                    + Stock
                                </button>
                            </span>
                    <% }}} 
                       if (!hasLowStock) { %>
                            <span style="color:#15803d; font-size:0.85rem;">✅ All inventory items are currently well-stocked above minimum reorder thresholds.</span>
                    <% } %>
                </div>
            </div>

            <!-- Section 2: Live Warehouse Stock Levels (READ & UPDATE) -->
            <div style="margin-bottom:25px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">📊 Live Warehouse Stock Levels (READ & UPDATE)</h4>
                    <span style="font-size:0.8rem; color:var(--gray-600);">Auto-deducted on checkout | Direct return/damage adjustments</span>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Instrument Name</th>
                                <th>Category</th>
                                <th>Brand</th>
                                <th>Retail Price</th>
                                <th>Available Stock</th>
                                <th>Status</th>
                                <th style="text-align:center;">Quick Stock Adjustments (UPDATE)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (products != null && !products.isEmpty()) { 
                                for (Product p : products) { 
                                    if (!p.isArchived()) { %>
                                <tr>
                                    <td><code><%= p.getCode() %></code></td>
                                    <td><strong><%= p.getName() %></strong></td>
                                    <td><%= p.getCategory() %></td>
                                    <td><%= p.getBrand() %></td>
                                    <td>LKR <%= String.format("%,.2f", p.getPrice()) %></td>
                                    <td>
                                        <span style="font-weight:bold; font-size:0.95rem; color:<%= p.getStockQuantity() <= 5 ? "#dc2626" : (p.getStockQuantity() <= 10 ? "#d97706" : "#16a34a") %>;">
                                            <%= p.getStockQuantity() %> units
                                        </span>
                                    </td>
                                    <td>
                                        <% if (p.getStockQuantity() == 0) { %>
                                            <span class="badge badge-danger">Out of Stock</span>
                                        <% } else if (p.getStockQuantity() <= 10) { %>
                                            <span class="badge badge-warning">Low Stock</span>
                                        <% } else { %>
                                            <span class="badge badge-success">In Stock</span>
                                        <% } %>
                                    </td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <button type="button" class="btn btn-warning btn-sm" style="padding:3px 8px; font-size:0.78rem;" 
                                                    onclick="openAdjustStockModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'").replace("\"", "&quot;") %>', <%= p.getStockQuantity() %>)">
                                                ✏️ Adjust
                                            </button>
                                            <form action="<%= request.getContextPath() %>/inventory" method="post" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="adjustStock">
                                                <input type="hidden" name="productId" value="<%= p.getId() %>">
                                                <input type="hidden" name="delta" value="10">
                                                <button type="submit" class="btn btn-secondary btn-sm" style="padding:3px 6px; font-size:0.75rem;" title="Quick restock +10 units">
                                                    +10
                                                </button>
                                            </form>
                                            <% if (p.getStockQuantity() > 0) { %>
                                                <form action="<%= request.getContextPath() %>/inventory" method="post" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="adjustStock">
                                                    <input type="hidden" name="productId" value="<%= p.getId() %>">
                                                    <input type="hidden" name="delta" value="-1">
                                                    <button type="submit" class="btn btn-secondary btn-sm" style="padding:3px 6px; font-size:0.75rem; color:#dc2626;" title="Deduct 1 unit (e.g. damaged)">
                                                        -1
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% }}} else { %>
                                <tr>
                                    <td colspan="8" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No products found in catalog.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Section 3: Registered Suppliers (Sri Lanka & International) (READ, UPDATE, DELETE) -->
            <div style="margin-bottom:25px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">🏢 Registered Suppliers (READ, UPDATE, DELETE)</h4>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openAddSupplierModal()">
                        + Register Supplier
                    </button>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Company Name</th>
                                <th>Contact Person</th>
                                <th>Email / Phone</th>
                                <th>Address</th>
                                <th>Supplied Categories</th>
                                <th>Status</th>
                                <th style="text-align:center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (suppliers != null && !suppliers.isEmpty()) { for (Supplier s : suppliers) { %>
                                <tr>
                                    <td><code><%= s.getSupplierCode() %></code></td>
                                    <td><strong><%= s.getCompanyName() %></strong></td>
                                    <td><%= s.getContactPerson() %></td>
                                    <td><%= s.getEmail() %><br><span style="font-size:0.8rem; color:var(--gray-600);"><%= s.getPhone() %></span></td>
                                    <td style="font-size:0.82rem;"><%= s.getAddress() %></td>
                                    <td><span style="font-size:0.82rem; background:#f1f5f9; padding:2px 6px; border-radius:4px;"><%= s.getSuppliedCategories() %></span></td>
                                    <td>
                                        <span class="badge <%= s.isActive() ? "badge-active" : "badge-deactivated" %>">
                                            <%= s.isActive() ? "Active" : "Inactive" %>
                                        </span>
                                    </td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [UPDATE] Edit Details -->
                                            <button type="button" class="btn btn-warning btn-sm" style="padding:3px 8px; font-size:0.78rem;" 
                                                    onclick="openEditSupplierModal(
                                                        <%= s.getId() %>,
                                                        '<%= s.getCompanyName().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= s.getContactPerson() != null ? s.getContactPerson().replace("'", "\\'").replace("\"", "&quot;") : "" %>',
                                                        '<%= s.getEmail().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                        '<%= s.getPhone() != null ? s.getPhone().replace("'", "\\'").replace("\"", "&quot;") : "" %>',
                                                        '<%= s.getAddress() != null ? s.getAddress().replace("'", "\\'").replace("\"", "&quot;") : "" %>',
                                                        '<%= s.getSuppliedCategories() != null ? s.getSuppliedCategories().replace("'", "\\'").replace("\"", "&quot;") : "" %>'
                                                    )">
                                                ✏️ Edit
                                            </button>

                                            <!-- [DELETE] Deactivate / Reactivate -->
                                            <% if (s.isActive()) { %>
                                                <form action="<%= request.getContextPath() %>/inventory" method="post" onsubmit="return confirmAction('Deactivate supplier profile for <%= s.getCompanyName().replace("'", "\\'") %>?');" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="deactivateSupplier">
                                                    <input type="hidden" name="id" value="<%= s.getId() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem;" title="Deactivate supplier profile">
                                                        🚫 Deactivate
                                                    </button>
                                                </form>
                                            <% } else { %>
                                                <form action="<%= request.getContextPath() %>/inventory" method="post" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="reactivateSupplier">
                                                    <input type="hidden" name="id" value="<%= s.getId() %>">
                                                    <button type="submit" class="btn btn-success btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#16a34a; color:#fff;" title="Reactivate supplier profile">
                                                        ✅ Reactivate
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE] Delete Supplier from Database -->
                                            <form action="<%= request.getContextPath() %>/inventory" method="post" onsubmit="return confirmAction('Permanently delete supplier <%= s.getCompanyName().replace("'", "\\'") %> from database? This will remove all linked purchase orders.');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="deleteSupplier">
                                                <input type="hidden" name="id" value="<%= s.getId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete supplier from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="8" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No registered suppliers found. Click "+ Register New Supplier" to create one.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Section 4: Stock Purchase Orders & Batch Receipts (READ, CREATE/UPDATE, DELETE) -->
            <div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">📦 Stock Purchase Orders & Batch Receipts (READ, CREATE, UPDATE, DELETE)</h4>
                    <button type="button" class="btn btn-sm" onclick="openCreatePoModal()" style="background:#0284c7; color:#fff;">
                        + Issue Purchase Order
                    </button>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>PO Number</th>
                                <th>Supplier</th>
                                <th>Order Date</th>
                                <th>Expected Delivery</th>
                                <th>Items & Batch Details</th>
                                <th>Total (LKR)</th>
                                <th>Status</th>
                                <th style="text-align:center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (purchaseOrders != null && !purchaseOrders.isEmpty()) { for (PurchaseOrder po : purchaseOrders) { %>
                                <tr>
                                    <td><code><%= po.getPoNumber() %></code></td>
                                    <td><strong><%= po.getSupplierName() %></strong></td>
                                    <td><%= po.getOrderDate() %></td>
                                    <td><%= po.getExpectedDeliveryDate() %></td>
                                    <td style="font-size:0.85rem;"><%= po.getItemsSummary() %></td>
                                    <td><strong>LKR <%= String.format("%,.2f", po.getTotalAmount()) %></strong></td>
                                    <td>
                                        <span class="badge badge-<%= po.getStatus().toLowerCase() %>">
                                            <%= po.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [CREATE/UPDATE] Receive Stock Batch with Warranty Batch -->
                                            <% if (!"RECEIVED".equalsIgnoreCase(po.getStatus()) && !"CANCELLED".equalsIgnoreCase(po.getStatus())) { %>
                                                <button type="button" class="btn btn-success btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#16a34a; color:#fff;" 
                                                        onclick="openReceiveBatchModal(
                                                            '<%= po.getPoNumber() %>',
                                                            '<%= po.getItemsSummary().replace("'", "\\'").replace("\"", "&quot;") %>',
                                                            <%= po.getTotalQuantity() %>
                                                        )">
                                                    📥 Receive Batch
                                                </button>
                                            <% } %>

                                            <!-- [DELETE] Cancel Draft/Invalid Purchase Order -->
                                            <% if (!"RECEIVED".equalsIgnoreCase(po.getStatus()) && !"CANCELLED".equalsIgnoreCase(po.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/inventory" method="post" onsubmit="return confirmAction('Cancel Purchase Order <%= po.getPoNumber() %>?');" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="cancelPO">
                                                    <input type="hidden" name="poNumber" value="<%= po.getPoNumber() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem;" title="Cancel invalid/draft purchase order">
                                                        ❌ Cancel
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE] Delete Purchase Order from Database -->
                                            <form action="<%= request.getContextPath() %>/inventory" method="post" onsubmit="return confirmAction('Permanently delete Purchase Order <%= po.getPoNumber() %> from database?');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="deletePO">
                                                <input type="hidden" name="poNumber" value="<%= po.getPoNumber() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 8px; font-size:0.78rem; background:#b91c1c; color:#fff;" title="Permanently delete purchase order from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="8" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No purchase orders found. Click "+ Issue Purchase Order" to generate one.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <% } %>
    <!-- TAB 6: FULFILLMENT & RETURNS (Member 6) -->
    <% if ("fulfillments".equals(activeTab)) { %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; flex-wrap:wrap; gap:10px;">
                <div>
                    <h3 class="card-title" style="margin-bottom:4px;">Member 6: Order Fulfilment, Delivery Tracking & Returns (IT25100652)</h3>
                    <p style="color:var(--gray-600); font-size:0.85rem; margin:0;">
                        SLIIT Module 6.6 | Full Relational Database CRUD with 4-Step Tracking, Courier Handover & Warranty Ticket Lifecycle
                    </p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateDispatchModal()" style="display:inline-flex; align-items:center; gap:6px;">
                        <span>🚚 + Create Dispatch Job</span>
                        <span class="badge" style="background:#22c55e; color:#fff; font-size:0.65rem;">CREATE</span>
                    </button>
                    <a href="<%= request.getContextPath() %>/order_tracking.jsp" target="_blank" class="btn btn-sm" style="background:#0284c7; color:#fff; display:inline-flex; align-items:center; gap:6px; text-decoration:none;">
                        <span>🔍 Live Customer Tracking</span>
                        <span class="badge" style="background:#38bdf8; color:#0369a1; font-size:0.65rem;">READ</span>
                    </a>
                </div>
            </div>

            <!-- Member 6 CRUD Specification Badges -->
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; margin-bottom:20px; font-size:0.78rem;">
                <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#15803d; display:block; margin-bottom:2px;">[CREATE] Dispatch & Claims</strong>
                    <span style="color:#166534;">Generate dispatch jobs, assign partner courier tracking identifiers, submit return & warranty tickets.</span>
                </div>
                <div style="background:#f0f9ff; border:1px solid #bae6fd; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#0369a1; display:block; margin-bottom:2px;">[READ] Delivery Milestones</strong>
                    <span style="color:#075985;">Track real-time 4-step progress (Processing, Shipped, In-Transit, Delivered), review courier logs and notes.</span>
                </div>
                <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b45309; display:block; margin-bottom:2px;">[UPDATE] Progress Milestones</strong>
                    <span style="color:#92400e;">Update delivery status across milestones, record COD collection status, advance return ticket review stages.</span>
                </div>
                <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:6px; padding:8px 12px;">
                    <strong style="color:#b91c1c; display:block; margin-bottom:2px;">[DELETE] Cancel & Dismiss</strong>
                    <span style="color:#991b1b;">Cancel dispatch jobs prior to courier handover and dismiss invalid or withdrawn customer return claims.</span>
                </div>
            </div>

            <!-- Section 1: Active Courier Dispatch Jobs -->
            <div style="margin-bottom:25px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">🚚 Active Courier Dispatch Jobs (READ, UPDATE, DELETE)</h4>
                    <span style="font-size:0.8rem; color:var(--gray-600);">Koombiyo | Domex Express | Pronto Lanka | Certis Lanka</span>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Tracking Number</th>
                                <th>Order Ref</th>
                                <th>Recipient</th>
                                <th>Courier Partner</th>
                                <th>Status</th>
                                <th>COD Collection</th>
                                <th>Dispatched At</th>
                                <th style="text-align:center;">Actions (UPDATE & DELETE)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (fulfillments != null && !fulfillments.isEmpty()) { for (Fulfillment f : fulfillments) { %>
                                <tr>
                                    <td>
                                        <a href="<%= request.getContextPath() %>/track?trackingNumber=<%= f.getTrackingNumber() %>" target="_blank" style="color:var(--info); font-weight:bold; text-decoration:none;">
                                            <%= f.getTrackingNumber() %> 🔗
                                        </a>
                                    </td>
                                    <td><code><%= f.getOrderId() %></code></td>
                                    <td><strong><%= f.getCustomerName() %></strong></td>
                                    <td><%= f.getCourierName() %></td>
                                    <td><span class="badge badge-<%= f.getDeliveryStatus().toLowerCase() %>"><%= f.getDeliveryStatus() %></span></td>
                                    <td>
                                        <% if (f.getCodAmount() > 0) { %>
                                            <span style="font-size:0.82rem; font-weight:600; color:<%= f.isCodCollected() ? "#16a34a" : "#ea580c" %>;">
                                                <%= f.isCodCollected() ? "✅ Collected (LKR " + String.format("%,.2f", f.getCodAmount()) + ")" : "⏳ Pending COD (LKR " + String.format("%,.2f", f.getCodAmount()) + ")" %>
                                            </span>
                                            <% if (!f.isCodCollected()) { %>
                                                <form action="<%= request.getContextPath() %>/fulfillment" method="post" style="display:inline; margin-left:4px;">
                                                    <input type="hidden" name="action" value="recordCod">
                                                    <input type="hidden" name="trackingNumber" value="<%= f.getTrackingNumber() %>">
                                                    <input type="hidden" name="collected" value="true">
                                                    <button type="submit" class="btn btn-sm" style="padding:1px 5px; font-size:0.7rem; background:#16a34a; color:#fff;" title="Mark Cash Collected">Mark Paid</button>
                                                </form>
                                            <% } %>
                                        <% } else { %>
                                            <span style="color:var(--gray-500); font-size:0.82rem;">Prepaid</span>
                                        <% } %>
                                    </td>
                                    <td style="font-size:0.8rem;"><%= f.getDispatchedAt() %></td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [UPDATE] Status Milestone -->
                                            <form action="<%= request.getContextPath() %>/fulfillment" method="post" style="display:flex; gap:4px; margin:0;">
                                                <input type="hidden" name="action" value="updateDeliveryStatus">
                                                <input type="hidden" name="trackingNumber" value="<%= f.getTrackingNumber() %>">
                                                <input type="hidden" name="orderId" value="<%= f.getOrderId() %>">
                                                <select name="status" class="form-control" style="width:115px; padding:2px 4px; font-size:0.78rem;">
                                                    <option value="PROCESSING" <%= "PROCESSING".equals(f.getDeliveryStatus()) ? "selected" : "" %>>Processing</option>
                                                    <option value="SHIPPED" <%= "SHIPPED".equals(f.getDeliveryStatus()) ? "selected" : "" %>>Shipped</option>
                                                    <option value="IN_TRANSIT" <%= "IN_TRANSIT".equals(f.getDeliveryStatus()) ? "selected" : "" %>>In-Transit</option>
                                                    <option value="DELIVERED" <%= "DELIVERED".equals(f.getDeliveryStatus()) ? "selected" : "" %>>Delivered</option>
                                                </select>
                                                <button type="submit" class="btn btn-secondary btn-sm" style="padding:3px 6px; font-size:0.75rem;">Set</button>
                                            </form>

                                            <!-- [DELETE] Cancel Dispatch -->
                                            <% if (!"DELIVERED".equalsIgnoreCase(f.getDeliveryStatus()) && !"CANCELLED".equalsIgnoreCase(f.getDeliveryStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/fulfillment" method="post" onsubmit="return confirmAction('Cancel courier dispatch job <%= f.getTrackingNumber() %>?');" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="cancelDispatch">
                                                    <input type="hidden" name="trackingNumber" value="<%= f.getTrackingNumber() %>">
                                                    <input type="hidden" name="orderId" value="<%= f.getOrderId() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 6px; font-size:0.75rem;" title="Cancel dispatch order prior to handover">
                                                        ❌ Cancel
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE] Delete Dispatch Job from Database -->
                                            <form action="<%= request.getContextPath() %>/fulfillment" method="post" onsubmit="return confirmAction('Permanently delete dispatch job <%= f.getTrackingNumber() %> from database?');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="deleteFulfillment">
                                                <input type="hidden" name="trackingNumber" value="<%= f.getTrackingNumber() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 6px; font-size:0.75rem; background:#b91c1c; color:#fff;" title="Permanently delete dispatch record from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="8" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No active dispatch jobs found. Click "+ Create Dispatch Job" to issue one.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Section 2: Return & Warranty Tickets -->
            <div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <h4 style="color:var(--primary); margin:0;">🛡️ Return & Warranty Tickets (READ, UPDATE, DELETE)</h4>
                    <span style="font-size:0.8rem; color:var(--gray-600);">Under Review | Approved | Completed | Rejected</span>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Ticket ID</th>
                                <th>Order Ref</th>
                                <th>Customer</th>
                                <th>Reason</th>
                                <th>Item Details</th>
                                <th>Stage</th>
                                <th style="text-align:center;">Actions (UPDATE & DELETE)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (returns != null && !returns.isEmpty()) { for (ReturnRequest r : returns) { %>
                                <tr>
                                    <td><code><%= r.getTicketId() %></code></td>
                                    <td><%= r.getOrderId() %></td>
                                    <td><strong><%= r.getCustomerName() %></strong></td>
                                    <td><span style="color:var(--danger); font-weight:600;"><%= r.getReason() %></span></td>
                                    <td style="font-size:0.82rem;"><%= r.getItemDetails() %></td>
                                    <td><span class="badge badge-<%= r.getStage().toLowerCase() %>"><%= r.getStage() %></span></td>
                                    <td style="text-align:center;">
                                        <div style="display:inline-flex; gap:6px; align-items:center;">
                                            <!-- [UPDATE] Advance Stage -->
                                            <form action="<%= request.getContextPath() %>/fulfillment" method="post" style="display:flex; gap:4px; margin:0;">
                                                <input type="hidden" name="action" value="updateReturnStage">
                                                <input type="hidden" name="ticketId" value="<%= r.getTicketId() %>">
                                                <select name="stage" class="form-control" style="width:115px; padding:2px 4px; font-size:0.78rem;">
                                                    <option value="UNDER_REVIEW" <%= "UNDER_REVIEW".equals(r.getStage()) ? "selected" : "" %>>Under Review</option>
                                                    <option value="APPROVED" <%= "APPROVED".equals(r.getStage()) ? "selected" : "" %>>Approved</option>
                                                    <option value="COMPLETED" <%= "COMPLETED".equals(r.getStage()) ? "selected" : "" %>>Completed</option>
                                                    <option value="REJECTED" <%= "REJECTED".equals(r.getStage()) ? "selected" : "" %>>Rejected</option>
                                                </select>
                                                <button type="submit" class="btn btn-primary btn-sm" style="padding:3px 6px; font-size:0.75rem;">Update</button>
                                            </form>

                                            <!-- [DELETE] Dismiss Ticket -->
                                            <% if (!"COMPLETED".equalsIgnoreCase(r.getStage()) && !"REJECTED".equalsIgnoreCase(r.getStage())) { %>
                                                <form action="<%= request.getContextPath() %>/fulfillment" method="post" onsubmit="return confirmAction('Dismiss return ticket <%= r.getTicketId() %>?');" style="display:inline; margin:0;">
                                                    <input type="hidden" name="action" value="dismissReturn">
                                                    <input type="hidden" name="ticketId" value="<%= r.getTicketId() %>">
                                                    <input type="hidden" name="dismissReason" value="Dismissed by Administrator">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 6px; font-size:0.75rem;" title="Dismiss invalid or withdrawn return request">
                                                        ❌ Dismiss
                                                    </button>
                                                </form>
                                            <% } %>

                                            <!-- [HARD DELETE] Delete Return Ticket from Database -->
                                            <form action="<%= request.getContextPath() %>/fulfillment" method="post" onsubmit="return confirmAction('Permanently delete return ticket <%= r.getTicketId() %> from database?');" style="display:inline; margin:0;">
                                                <input type="hidden" name="action" value="deleteReturn">
                                                <input type="hidden" name="ticketId" value="<%= r.getTicketId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding:3px 6px; font-size:0.75rem; background:#b91c1c; color:#fff;" title="Permanently delete return ticket from database">
                                                    🗑️ Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="7" style="text-align:center; color:var(--gray-500); padding:16px;">
                                        No customer return tickets filed.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <% } %>
</div>

<!-- MODAL: [CREATE] CREATE DISPATCH JOB (Member 6) -->
<div id="createDispatchModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:580px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">🚚 Create Courier Dispatch Job (Member 6)</h3>
            <button type="button" onclick="closeCreateDispatchModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/fulfillment" method="post">
            <input type="hidden" name="action" value="createDispatch">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Select Order to Dispatch *</label>
                <select name="orderId" id="disp_orderSelect" class="form-control" required onchange="onSelectDispatchOrder(this)">
                    <option value="">-- Choose Order --</option>
                    <% if (orders != null) { for (Order ord : orders) { %>
                        <option value="<%= ord.getOrderId() %>" 
                                data-name="<%= ord.getCustomerName().replace("\"", "&quot;") %>" 
                                data-address="<%= ord.getShippingAddress().replace("\"", "&quot;") %>, <%= ord.getCity() %>, <%= ord.getDistrict() %>"
                                data-courier="<%= ord.getCourierName() %>"
                                data-cod="<%= "CASH_ON_DELIVERY".equalsIgnoreCase(ord.getPaymentMethod()) && !"PAID".equalsIgnoreCase(ord.getPaymentStatus()) ? ord.getTotalAmount() : 0 %>">
                            <%= ord.getOrderId() %> - <%= ord.getCustomerName() %> (LKR <%= String.format("%,.2f", ord.getTotalAmount()) %>)
                        </option>
                    <% }} %>
                </select>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Recipient Full Name *</label>
                    <input type="text" name="customerName" id="disp_customerName" required class="form-control" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Full name must contain letters and spaces only.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Partner Courier *</label>
                    <select name="courierName" id="disp_courierName" class="form-control">
                        <option value="Koombiyo Delivery">Koombiyo Delivery</option>
                        <option value="Domex Courier">Domex Courier</option>
                        <option value="Pronto Lanka">Pronto Lanka</option>
                        <option value="Certis Lanka">Certis Lanka</option>
                    </select>
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Delivery Address *</label>
                <textarea name="shippingAddress" id="disp_shippingAddress" required class="form-control" rows="2" minlength="5" maxlength="500"></textarea>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">COD Collection Amount (LKR) (0 if prepaid)</label>
                <input type="number" step="0.01" min="0" name="codAmount" id="disp_codAmount" value="0.00" class="form-control">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeCreateDispatchModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">
                    Generate Dispatch & Tracking Number
                </button>
            </div>
        </form>
    </div>
</div>



<footer>
    <div class="footer-bottom">
        &copy; 2026 MelodyMart - Harmony Lanka Musical Stores (Pvt) Ltd. All rights reserved.
    </div>
</footer>

<script src="<%= request.getContextPath() %>/js/main.js"></script>

<!-- MODAL: EDIT PRODUCT (CRUD UPDATE) -->
<div id="productEditModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:650px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0;">Edit / Update Musical Instrument</h3>
            <button type="button" onclick="closeProductEditModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/products" method="post">
            <input type="hidden" name="action" value="updateProduct">
            <input type="hidden" name="id" id="edit_prod_id">

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Product Code</label>
                    <input type="text" id="edit_prod_code" readonly class="form-control" style="background:#f1f5f9;">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Category *</label>
                    <select name="category" id="edit_prod_category" class="form-control">
                        <option value="String Instruments">String Instruments</option>
                        <option value="Keyboards & Pianos">Keyboards & Pianos</option>
                        <option value="Drums & Percussion">Drums & Percussion</option>
                        <option value="Wind Instruments">Wind Instruments</option>
                        <option value="Traditional Sri Lankan">Traditional Sri Lankan</option>
                    </select>
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Instrument Name *</label>
                <input type="text" name="name" id="edit_prod_name" required class="form-control" minlength="3" maxlength="150" title="Product name must be at least 3 characters.">
            </div>

            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Brand *</label>
                    <input type="text" name="brand" id="edit_prod_brand" required class="form-control" minlength="2" maxlength="100" title="Brand must be at least 2 characters.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Retail Price (LKR) *</label>
                    <input type="number" step="0.01" min="1" name="price" id="edit_prod_price" required class="form-control" title="Retail price must be at least LKR 1.00.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Discount (%)</label>
                    <input type="number" step="0.1" min="0" max="100" name="discountPercent" id="edit_prod_discount" class="form-control" title="Promotional discount must be between 0% and 100%.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Stock *</label>
                    <input type="number" min="0" step="1" name="stockQuantity" id="edit_prod_stock" required class="form-control" title="Stock quantity must be a non-negative integer.">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Description *</label>
                <textarea name="description" id="edit_prod_desc" required class="form-control" rows="2" minlength="5" maxlength="2000" placeholder="Product description (min 5 chars)"></textarea>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Technical Specs *</label>
                    <input type="text" name="technicalSpecs" id="edit_prod_specs" required class="form-control" minlength="3" maxlength="500">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Warranty Period (Years - Numbers Only) *</label>
                    <input type="number" min="0" max="25" step="1" name="warrantyPolicy" id="edit_prod_warranty" required class="form-control" placeholder="e.g. 2" title="Warranty must contain numbers only (e.g. 1, 2, 3 years).">
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Image Media URL *</label>
                <input type="url" name="imageUrl" id="edit_prod_image" required class="form-control" maxlength="500" title="Valid image URL starting with http:// or https://">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeProductEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: EDIT ORDER (Member 3) -->
<div id="orderEditModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:600px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0;">Update Order Details (Member 3)</h3>
            <button type="button" onclick="closeOrderEditModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/orders" method="post">
            <input type="hidden" name="action" value="updateOrder">
            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Order ID</label>
                <input type="text" name="orderId" id="ord_edit_id" readonly class="form-control" style="background:#f1f5f9; font-weight:bold;">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Customer Full Name *</label>
                    <input type="text" name="customerName" id="ord_edit_name" required class="form-control">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Phone Number *</label>
                    <input type="text" name="customerPhone" id="ord_edit_phone" required class="form-control">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Delivery Address *</label>
                <input type="text" name="shippingAddress" id="ord_edit_address" required class="form-control">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">City *</label>
                    <input type="text" name="city" id="ord_edit_city" required class="form-control">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">District *</label>
                    <input type="text" name="district" id="ord_edit_district" required class="form-control">
                </div>
            </div>

            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap:12px; margin-bottom:18px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Courier Partner</label>
                    <select name="courierName" id="ord_edit_courier" class="form-control">
                        <option value="Koombiyo Delivery">Koombiyo Delivery</option>
                        <option value="Domex Courier">Domex Courier</option>
                        <option value="Pronto Lanka">Pronto Lanka</option>
                        <option value="Certis Lanka">Certis Lanka</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Payment Status</label>
                    <select name="paymentStatus" id="ord_edit_pay_status" class="form-control">
                        <option value="PENDING">PENDING</option>
                        <option value="PAID">PAID</option>
                        <option value="FAILED">FAILED</option>
                        <option value="REFUNDED">REFUNDED</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Fulfillment Status</label>
                    <select name="fulfillmentStatus" id="ord_edit_ful_status" class="form-control">
                        <option value="PROCESSING">PROCESSING</option>
                        <option value="SHIPPED">SHIPPED</option>
                        <option value="IN_TRANSIT">IN_TRANSIT</option>
                        <option value="DELIVERED">DELIVERED</option>
                        <option value="CANCELLED">CANCELLED</option>
                    </select>
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeOrderEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Order Changes in Database</button>
            </div>
        </form>
    </div>
</div>


<!-- MODAL: [UPDATE] REVIEW BANK SLIP / UPDATE STATUS (Member 4) -->
<div id="reviewStatusModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:550px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.2rem;">✏️ Review Bank Slip & Update Status (Member 4)</h3>
            <button type="button" onclick="closeReviewModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/payment" method="post">
            <input type="hidden" name="action" value="updateStatus">
            <input type="hidden" name="txnId" id="rev_txnId">
            <input type="hidden" name="orderId" id="rev_orderId">

            <div style="background:#f8fafc; padding:12px; border-radius:6px; margin-bottom:15px; font-size:0.85rem;">
                <div>Transaction ID: <strong id="rev_txnDisplay"></strong></div>
                <div>Order Ref: <strong id="rev_orderDisplay"></strong></div>
                <div>Amount: <strong id="rev_amountDisplay"></strong></div>
                <div id="rev_slipRow" style="margin-top:6px; display:none;">
                    Deposit Slip: <span id="rev_slipDisplay" style="color:#0369a1; font-weight:600;"></span>
                </div>
            </div>

            <div style="margin-bottom:14px;">
                <label style="font-size:0.82rem; font-weight:600;">Transaction Status *</label>
                <select name="status" id="rev_statusSelect" class="form-control" required>
                    <option value="PAID">PAID (Approve Bank Deposit Slip / Verified)</option>
                    <option value="PENDING">PENDING (Awaiting Verification / Documents)</option>
                    <option value="FAILED">FAILED (Invalid Bank Slip / Rejected)</option>
                    <option value="REFUNDED">REFUNDED (Processed Refund)</option>
                </select>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Bank Slip Review Notes / Gateway Webhook Reference</label>
                <textarea name="notes" id="rev_notes" class="form-control" rows="3" placeholder="e.g. Verified at Commercial Bank Colombo 07 branch slip #88214 or Gateway webhook confirmed."></textarea>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeReviewModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Save Status in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [UPDATE] PROCESS REFUND (Member 4) -->
<div id="refundModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:520px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#6b21a8; margin:0; font-size:1.2rem;">💸 Record Processed Refund Details (Member 4)</h3>
            <button type="button" onclick="closeRefundModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/payment" method="post">
            <input type="hidden" name="action" value="refund">
            <input type="hidden" name="txnId" id="ref_txnId">
            <input type="hidden" name="orderId" id="ref_orderId">

            <div style="background:#faf5ff; border:1px solid #e9d5ff; padding:12px; border-radius:6px; margin-bottom:15px; font-size:0.85rem;">
                <div>Transaction ID: <strong id="ref_txnDisplay"></strong></div>
                <div>Order Ref: <strong id="ref_orderDisplay"></strong></div>
                <div>Original Total: <strong id="ref_origAmountDisplay"></strong></div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Refund Amount (LKR) *</label>
                <input type="number" step="0.01" name="refundAmount" id="ref_amount" required class="form-control">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Refund Reason (Validation: Required) *</label>
                <textarea name="refundReason" id="ref_reason" required class="form-control" rows="2" placeholder="e.g. Customer returned defective guitar bow under warranty / Order cancelled."></textarea>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Refund Transaction Reference / Bank Slip</label>
                <input type="text" name="refundRef" id="ref_reference" class="form-control" placeholder="e.g. REV-BOC-55102 or Gateway Refund ID">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeRefundModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="background:#8b5cf6; border-color:#8b5cf6; font-weight:bold;">
                    Confirm & Record Refund in Database
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [DELETE] VOID PAYMENT ATTEMPT (Member 4) -->
<div id="voidModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:480px; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#991b1b; margin:0; font-size:1.2rem;">🚫 Void Payment Attempt (Member 4)</h3>
            <button type="button" onclick="closeVoidModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/payment" method="post">
            <input type="hidden" name="action" value="voidPayment">
            <input type="hidden" name="txnId" id="void_txnId">
            <input type="hidden" name="orderId" id="void_orderId">

            <p style="font-size:0.85rem; color:var(--gray-700); margin-bottom:14px;">
                Voiding this failed or unverified payment attempt will mark the transaction as <strong>VOIDED</strong> in the database and audit logs.
            </p>

            <div style="margin-bottom:16px;">
                <label style="font-size:0.82rem; font-weight:600;">Reason for Voiding *</label>
                <input type="text" name="voidReason" required class="form-control" minlength="3" maxlength="500" placeholder="e.g. Unverified deposit slip / Fraudulent payment attempt / Timeout">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeVoidModal()">Cancel</button>
                <button type="submit" class="btn btn-danger" style="font-weight:bold;">Confirm Void in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [READ] CUSTOMER TRANSACTION HISTORY (Member 4) -->
<div id="customerHistoryModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:620px; max-height:85vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.2rem;">📜 Customer Transaction History (Member 4)</h3>
            <button type="button" onclick="closeCustomerHistoryModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <div id="customerHistoryContent">
            <!-- Dynamic history loaded via JavaScript -->
        </div>
        <div style="display:flex; justify-content:flex-end; margin-top:20px;">
            <button type="button" class="btn btn-secondary" onclick="closeCustomerHistoryModal()">Close</button>
        </div>
    </div>
</div>

<!-- MODAL: [CREATE] REGISTER NEW SUPPLIER (Member 5) -->
<div id="addSupplierModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:600px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">➕ Register New Instrument Supplier (Member 5)</h3>
            <button type="button" onclick="closeAddSupplierModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/inventory" method="post">
            <input type="hidden" name="action" value="addSupplier">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Company / Supplier Name *</label>
                <input type="text" name="companyName" required class="form-control" placeholder="e.g. Yamaha Music Lanka (Pvt) Ltd">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Contact Person *</label>
                    <input type="text" name="contactPerson" required class="form-control" placeholder="e.g. Nimal Perera">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Phone Number *</label>
                    <input type="text" name="phone" required class="form-control" placeholder="e.g. +94 11 258 7410">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Official Email Address *</label>
                <input type="email" name="email" required class="form-control" placeholder="e.g. procurement@yamahamusic.lk">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Warehouse / Business Address *</label>
                <textarea name="address" required class="form-control" rows="2" placeholder="e.g. 555 Union Place, Colombo 02, Sri Lanka"></textarea>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Supplied Musical Categories *</label>
                <input type="text" name="categories" required class="form-control" placeholder="e.g. Guitars, Keyboards, Drums, Audio Gear">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAddSupplierModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Register Supplier in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [UPDATE] EDIT SUPPLIER DETAILS (Member 5) -->
<div id="editSupplierModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:600px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">✏️ Update Supplier Details (Member 5)</h3>
            <button type="button" onclick="closeEditSupplierModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/inventory" method="post">
            <input type="hidden" name="action" value="updateSupplier">
            <input type="hidden" name="id" id="edit_sup_id">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Company / Supplier Name *</label>
                <input type="text" name="companyName" id="edit_sup_company" required class="form-control" pattern="^[A-Za-z0-9\s.,&'()-]+$" minlength="3" maxlength="150" title="Valid company name (min 3 chars).">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Contact Person</label>
                    <input type="text" name="contactPerson" id="edit_sup_contact" class="form-control" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Phone Number</label>
                    <input type="text" name="phone" id="edit_sup_phone" class="form-control" pattern="^(?:0|\+94)?[0-9\s-]{9,15}$" minlength="9" maxlength="15" inputmode="tel">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Official Email Address *</label>
                <input type="email" name="email" id="edit_sup_email" required class="form-control" maxlength="100">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Warehouse / Business Address</label>
                <textarea name="address" id="edit_sup_address" class="form-control" rows="2" minlength="5" maxlength="500"></textarea>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Supplied Musical Categories</label>
                <input type="text" name="categories" id="edit_sup_categories" class="form-control" pattern="^[A-Za-z0-9\s,.-]+$" minlength="2" maxlength="200">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeEditSupplierModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Save Changes in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [CREATE] GENERATE PURCHASE ORDER (Member 5) -->
<div id="createPoModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:600px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">📋 Generate Stock Purchase Order (PO) (Member 5)</h3>
            <button type="button" onclick="closeCreatePoModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/inventory" method="post">
            <input type="hidden" name="action" value="createPO">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Select Registered Supplier *</label>
                <select name="supplierId" required class="form-control">
                    <option value="">-- Choose Supplier --</option>
                    <% if (suppliers != null) { for (Supplier s : suppliers) { %>
                        <option value="<%= s.getId() %>"><%= s.getCompanyName() %> (<%= s.getSupplierCode() %>)</option>
                    <% }} %>
                </select>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Items & Specifications Summary *</label>
                <textarea name="itemsSummary" required class="form-control" rows="2" minlength="3" maxlength="500" placeholder="e.g. Yamaha F310 Acoustic Guitars - Natural (Qty 20), Roland SPD-20X (Qty 5)"></textarea>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Total Quantity (Units) *</label>
                    <input type="number" name="quantity" min="1" step="1" required class="form-control" placeholder="e.g. 25">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Total PO Amount (LKR) *</label>
                    <input type="number" step="0.01" min="1" name="totalAmount" required class="form-control" placeholder="e.g. 1500000.00">
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Expected Delivery Date *</label>
                <input type="date" name="expectedDate" required class="form-control">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeCreatePoModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="background:#0284c7; border-color:#0284c7; font-weight:bold;">Generate & Issue PO</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [CREATE/UPDATE] RECORD INCOMING STOCK BATCH (Member 5) -->
<div id="receiveBatchModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:580px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#16a34a; margin:0; font-size:1.25rem;">📥 Record Stock Batch & Warranty (Member 5)</h3>
            <button type="button" onclick="closeReceiveBatchModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/inventory" method="post">
            <input type="hidden" name="action" value="receiveBatch">
            <input type="hidden" name="poNumber" id="rec_poNumber">

            <div style="background:#f0fdf4; border:1px solid #bbf7d0; padding:12px; border-radius:6px; margin-bottom:15px; font-size:0.85rem;">
                <div>PO Reference: <strong id="rec_poDisplay" style="color:#15803d;"></strong></div>
                <div style="margin-top:4px;">Items: <span id="rec_summaryDisplay" style="color:#166534;"></span></div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Link to Catalog Product (Auto-Restock) *</label>
                <select name="productId" id="rec_productId" class="form-control" required>
                    <option value="">-- Choose Product to Restock --</option>
                    <% if (products != null) { for (Product p : products) { if (!p.isArchived()) { %>
                        <option value="<%= p.getId() %>"><%= p.getName() %> (Current Stock: <%= p.getStockQuantity() %> units)</option>
                    <% }}} %>
                </select>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Received Batch Quantity *</label>
                    <input type="number" name="quantity" id="rec_quantity" min="1" step="1" required class="form-control">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Warranty Batch Identifier *</label>
                    <input type="text" name="warrantyBatch" required class="form-control" placeholder="e.g. WB-2026-YMH-8812" pattern="^[A-Za-z0-9_-]+$" minlength="3" maxlength="50" title="Alphanumeric batch code (e.g. WB-2026-YMH-8812)">
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeReceiveBatchModal()">Cancel</button>
                <button type="submit" class="btn btn-success" style="background:#16a34a; border-color:#16a34a; font-weight:bold;">
                    Confirm Batch & Restock
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [UPDATE] ADJUST STOCK / LOG RETURN (Member 5) -->
<div id="adjustStockModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:540px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#b45309; margin:0; font-size:1.25rem;">📦 Adjust Stock / Log Return (Member 5)</h3>
            <button type="button" onclick="closeAdjustStockModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/inventory" method="post">
            <input type="hidden" name="action" value="adjustStock">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Select Instrument / Product *</label>
                <select name="productId" id="adj_productId" class="form-control" required onchange="onSelectAdjustProduct(this)">
                    <option value="">-- Choose Product --</option>
                    <% if (products != null) { for (Product p : products) { if (!p.isArchived()) { %>
                        <option value="<%= p.getId() %>" data-stock="<%= p.getStockQuantity() %>"><%= p.getName() %> (Current: <%= p.getStockQuantity() %>)</option>
                    <% }}} %>
                </select>
            </div>

            <div id="adj_stockInfo" style="background:#fffbeb; border:1px solid #fde68a; padding:10px; border-radius:6px; margin-bottom:12px; font-size:0.85rem; display:none;">
                Current Warehouse Stock: <strong id="adj_stockDisplay" style="color:#b45309;"></strong> units
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Adjustment Operation *</label>
                    <select id="adj_type" class="form-control" onchange="updateAdjDelta()">
                        <option value="ADD">➕ Add Stock (Restock / Return)</option>
                        <option value="DEDUCT">➖ Deduct Stock (Damage / Loss)</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Quantity Units *</label>
                    <input type="number" id="adj_units" min="1" step="1" value="1" required class="form-control" oninput="updateAdjDelta()">
                    <input type="hidden" name="delta" id="adj_delta" value="1">
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">Reason / Audit Log Note *</label>
                <textarea name="reason" required class="form-control" rows="2" minlength="3" maxlength="500" placeholder="e.g. Customer returned undamaged item ticket #RET-2026-004 or Received new delivery."></textarea>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAdjustStockModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="background:#f59e0b; border-color:#f59e0b; font-weight:bold;">
                    Apply Stock Adjustment
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [CREATE] REGISTER NEW USER (Member 1) -->
<div id="adminAddUserModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:560px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">➕ Register User Account (Member 1)</h3>
            <button type="button" onclick="closeAdminAddUserModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="adminCreateUser">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Full Name *</label>
                <input type="text" name="fullName" required class="form-control" placeholder="e.g. Kasun Chamara" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Full name must contain letters and spaces only.">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Email Address *</label>
                    <input type="email" name="email" required class="form-control" placeholder="e.g. kasun@example.com" maxlength="100">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Phone (Sri Lanka) *</label>
                    <input type="text" name="phone" required class="form-control" placeholder="e.g. 0771234567" pattern="^(?:0|\+94)?7[0-9]{8}$" maxlength="12" inputmode="tel" title="Sri Lankan mobile format: 07XXXXXXXX or +947XXXXXXXX.">
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:18px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Account Password * (SHA-256 Hashed)</label>
                    <input type="password" name="password" required minlength="8" maxlength="50" pattern="^(?=.*[A-Za-z])(?=.*\d).{8,}$" class="form-control" placeholder="Min 8 chars, letters & numbers" title="Password must be at least 8 characters and contain both letters and numbers.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Assigned Role *</label>
                    <select name="role" class="form-control">
                        <option value="CUSTOMER">CUSTOMER (Shopper)</option>
                        <option value="SALES_STAFF">SALES_STAFF (Orders)</option>
                        <option value="INVENTORY_STAFF">INVENTORY_STAFF (Suppliers)</option>
                        <option value="FINANCE_STAFF">FINANCE_STAFF (Payments)</option>
                        <option value="ADMIN">ADMIN (Full Privileges)</option>
                    </select>
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAdminAddUserModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Register Account in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [UPDATE] EDIT USER DETAILS & ROLE (Member 1) -->
<div id="adminEditUserModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:540px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">✏️ Edit Personal Details & Role (Member 1)</h3>
            <button type="button" onclick="closeAdminEditUserModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="adminUpdateUser">
            <input type="hidden" name="userId" id="m1_edit_userId">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Full Name *</label>
                <input type="text" name="fullName" id="m1_edit_fullName" required class="form-control">
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Phone Number *</label>
                <input type="text" name="phone" id="m1_edit_phone" required class="form-control">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:18px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Assigned Role *</label>
                    <select name="role" id="m1_edit_role" class="form-control">
                        <option value="CUSTOMER">CUSTOMER</option>
                        <option value="SALES_STAFF">SALES_STAFF</option>
                        <option value="INVENTORY_STAFF">INVENTORY_STAFF</option>
                        <option value="FINANCE_STAFF">FINANCE_STAFF</option>
                        <option value="ADMIN">ADMIN</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Account Status *</label>
                    <select name="status" id="m1_edit_status" class="form-control">
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="DEACTIVATED">DEACTIVATED</option>
                    </select>
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAdminEditUserModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Save Changes in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [UPDATE] RESET USER PASSWORD (Member 1) -->
<div id="adminResetPasswordModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:480px; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#8b5cf6; margin:0; font-size:1.25rem;">🔑 Update Account Password (Member 1)</h3>
            <button type="button" onclick="closeAdminResetPasswordModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="adminUpdatePassword">
            <input type="hidden" name="userId" id="m1_pwd_userId">

            <div style="background:#faf5ff; border:1px solid #e9d5ff; padding:12px; border-radius:6px; margin-bottom:15px; font-size:0.85rem;">
                <div>User: <strong id="m1_pwd_userName"></strong></div>
                <div>Email: <span id="m1_pwd_userEmail" style="color:#7c3aed;"></span></div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">New Secure Password * (SHA-256 Hashed)</label>
                <input type="password" name="newPassword" required minlength="8" maxlength="50" pattern="^(?=.*[A-Za-z])(?=.*\d).{8,}$" class="form-control" placeholder="Enter new password (min 8 chars, letters & numbers)" title="Password must be at least 8 characters and contain both letters and numbers.">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAdminResetPasswordModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="background:#8b5cf6; border-color:#8b5cf6; font-weight:bold;">
                    Update Password in Database
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [CREATE] ADD STORED ADDRESS (Member 1) -->
<div id="adminAddAddressModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:560px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#0284c7; margin:0; font-size:1.25rem;">📍 Add Stored Address (Member 1)</h3>
            <button type="button" onclick="closeAdminAddAddressModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/user" method="post">
            <input type="hidden" name="action" value="adminAddAddress">

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Select Account Holder *</label>
                <select name="userId" id="m1_addr_userId" class="form-control" required>
                    <option value="">-- Choose User --</option>
                    <% if (users != null) { for (User usr : users) { %>
                        <option value="<%= usr.getId() %>"><%= usr.getFullName() %> (<%= usr.getEmail() %>)</option>
                    <% }} %>
                </select>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Address Label *</label>
                    <select name="label" class="form-control">
                        <option value="Home">Home</option>
                        <option value="Office">Office</option>
                        <option value="Studio">Studio</option>
                        <option value="Billing Address">Billing Address</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Postal Code *</label>
                    <input type="text" name="postalCode" required class="form-control" placeholder="e.g. 10100" pattern="^[0-9]{5}$" maxlength="5" inputmode="numeric" title="5-digit Sri Lankan postal code (e.g. 10100).">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Street Address *</label>
                <input type="text" name="street" required class="form-control" placeholder="e.g. 142/B Galle Road" minlength="3" maxlength="255">
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">City *</label>
                    <input type="text" name="city" required class="form-control" placeholder="e.g. Colombo" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="50">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">District *</label>
                    <select name="district" class="form-control">
                        <option value="Colombo">Colombo</option>
                        <option value="Gampaha">Gampaha</option>
                        <option value="Kalutara">Kalutara</option>
                        <option value="Kandy">Kandy</option>
                        <option value="Galle">Galle</option>
                        <option value="Kurunegala">Kurunegala</option>
                        <option value="Matara">Matara</option>
                        <option value="Anuradhapura">Anuradhapura</option>
                    </select>
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600; display:flex; align-items:center; gap:8px;">
                    <input type="checkbox" name="isPrimary" value="true">
                    <span>Set as Primary Shipping Destination</span>
                </label>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAdminAddAddressModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="background:#0284c7; border-color:#0284c7; font-weight:bold;">
                    Save Address in Database
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [READ] USER LOGIN SESSIONS & ROLE PERMISSIONS (Member 1) -->
<div id="adminUserSessionModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:580px; max-height:85vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">📜 Login Sessions & Role Permissions (Member 1)</h3>
            <button type="button" onclick="closeAdminUserSessionModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <div style="background:#f8fafc; padding:12px; border-radius:6px; margin-bottom:15px; font-size:0.85rem;">
            <div>Account: <strong id="m1_sess_userName"></strong></div>
            <div>Email: <span id="m1_sess_userEmail" style="color:#0369a1;"></span></div>
            <div>Assigned Role: <span class="badge badge-active" id="m1_sess_userRole" style="font-size:0.75rem;"></span></div>
        </div>

        <h4 style="color:var(--primary); font-size:0.95rem; margin-bottom:8px;">Role-Based Access Permissions:</h4>
        <div id="m1_sess_permissions" style="margin-bottom:15px; font-size:0.82rem; background:#f0fdf4; border:1px solid #bbf7d0; padding:10px; border-radius:6px; color:#166534;">
            <!-- Dynamically populated -->
        </div>

        <h4 style="color:var(--primary); font-size:0.95rem; margin-bottom:8px;">Recorded Login Session History:</h4>
        <ul id="m1_sess_history" style="font-size:0.82rem; color:var(--gray-700); line-height:1.6; padding-left:20px;">
            <!-- Dynamically populated -->
        </ul>

        <div style="display:flex; justify-content:flex-end; margin-top:20px;">
            <button type="button" class="btn btn-secondary" onclick="closeAdminUserSessionModal()">Close</button>
        </div>
    </div>
</div>
<!-- MODAL: [CREATE] ADD NEW MUSICAL INSTRUMENT (Member 2) -->
<div id="addProductModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:90%; max-width:650px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:var(--primary); margin:0; font-size:1.25rem;">🎸 Add New Musical Instrument (Member 2)</h3>
            <button type="button" onclick="closeAddProductModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>
        <form action="<%= request.getContextPath() %>/products" method="post">
            <input type="hidden" name="action" value="addProduct">

            <div style="display:grid; grid-template-columns: 2fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Instrument Name *</label>
                    <input type="text" name="name" required class="form-control" placeholder="e.g. Yamaha FG800 Acoustic Guitar" minlength="3" maxlength="150" title="Product name must be at least 3 characters.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Category *</label>
                    <select name="category" class="form-control" required>
                        <option value="String Instruments">String Instruments</option>
                        <option value="Keyboards & Pianos">Keyboards & Pianos</option>
                        <option value="Drums & Percussion">Drums & Percussion</option>
                        <option value="Wind Instruments">Wind Instruments</option>
                        <option value="Traditional Sri Lankan">Traditional Sri Lankan</option>
                    </select>
                </div>
            </div>

            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Brand *</label>
                    <input type="text" name="brand" required class="form-control" placeholder="e.g. Yamaha" minlength="2" maxlength="100" title="Brand must be at least 2 characters.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Retail Price (LKR) *</label>
                    <input type="number" step="0.01" min="1" name="price" required class="form-control" placeholder="e.g. 78500.00" title="Retail price must be at least LKR 1.00.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Discount (%)</label>
                    <input type="number" step="0.1" min="0" max="100" name="discountPercent" value="0.0" class="form-control" title="Promotional discount must be between 0% and 100%.">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Initial Stock *</label>
                    <input type="number" min="0" step="1" name="stockQuantity" required class="form-control" placeholder="e.g. 15" title="Stock quantity must be a non-negative integer.">
                </div>
            </div>

            <div style="margin-bottom:12px;">
                <label style="font-size:0.82rem; font-weight:600;">Marketing Description *</label>
                <textarea name="description" required class="form-control" rows="2" minlength="5" maxlength="2000" placeholder="Rich description of acoustic tonal characteristics, wood materials, and craftsmanship."></textarea>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Technical Specifications *</label>
                    <input type="text" name="technicalSpecs" required class="form-control" minlength="3" maxlength="500" placeholder="e.g. Solid Spruce Top, Nato Back/Sides, Rosewood Fingerboard">
                </div>
                <div>
                    <label style="font-size:0.82rem; font-weight:600;">Warranty Period (Years - Numbers Only) *</label>
                    <input type="number" min="0" max="25" step="1" name="warrantyPolicy" required class="form-control" placeholder="e.g. 2" title="Warranty must contain numbers only (e.g. 1, 2, 3 years).">
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:0.82rem; font-weight:600;">High-Resolution Image URL *</label>
                <input type="url" name="imageUrl" required class="form-control" maxlength="500" value="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80" title="Valid image URL starting with http:// or https://">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAddProductModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" style="font-weight:bold;">Register Instrument in Database</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: [READ] SIDE-BY-SIDE INSTRUMENT COMPARISON MATRIX (Member 2) -->
<div id="comparisonMatrixModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center;">
    <div style="background:white; border-radius:var(--radius); padding:25px; width:95%; max-width:900px; max-height:90vh; overflow-y:auto; box-shadow:var(--shadow-lg);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
            <h3 style="color:#8b5cf6; margin:0; font-size:1.25rem;">⚖️ Side-by-Side Instrument Comparison Matrix (Member 2)</h3>
            <button type="button" onclick="closeComparisonMatrixModal()" style="border:none; background:none; font-size:1.5rem; cursor:pointer; color:var(--gray-600);">&times;</button>
        </div>

        <p style="font-size:0.85rem; color:var(--gray-600); margin-bottom:15px;">
            Select any 2 or 3 musical instruments from the catalog to render a side-by-side technical, acoustic, and price comparison matrix.
        </p>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:20px;">
            <div>
                <label style="font-size:0.82rem; font-weight:600;">Instrument A:</label>
                <select id="comp_itemA" class="form-control" onchange="renderComparisonMatrix()">
                    <% if (products != null) { for (int i = 0; i < products.size(); i++) { Product pr = products.get(i); %>
                        <option value="<%= pr.getId() %>" <%= i == 0 ? "selected" : "" %>
                            data-name="<%= pr.getName().replace("\"", "&quot;") %>"
                            data-cat="<%= pr.getCategory() %>"
                            data-brand="<%= pr.getBrand() %>"
                            data-price="LKR <%= String.format("%,.2f", pr.getPrice()) %>"
                            data-eff="LKR <%= String.format("%,.2f", pr.getEffectivePrice()) %>"
                            data-disc="<%= (int)pr.getDiscountPercent() %>%"
                            data-stock="<%= pr.getStockQuantity() %> units"
                            data-specs="<%= pr.getTechnicalSpecs().replace("\"", "&quot;") %>"
                            data-warranty="<%= pr.getWarrantyPolicy().replace("\"", "&quot;") %>"
                            data-img="<%= pr.getImageUrl() %>">
                            <%= pr.getName() %> (<%= pr.getBrand() %>)
                        </option>
                    <% }} %>
                </select>
            </div>
            <div>
                <label style="font-size:0.82rem; font-weight:600;">Instrument B:</label>
                <select id="comp_itemB" class="form-control" onchange="renderComparisonMatrix()">
                    <% if (products != null) { for (int i = 0; i < products.size(); i++) { Product pr = products.get(i); %>
                        <option value="<%= pr.getId() %>" <%= i == 1 ? "selected" : "" %>
                            data-name="<%= pr.getName().replace("\"", "&quot;") %>"
                            data-cat="<%= pr.getCategory() %>"
                            data-brand="<%= pr.getBrand() %>"
                            data-price="LKR <%= String.format("%,.2f", pr.getPrice()) %>"
                            data-eff="LKR <%= String.format("%,.2f", pr.getEffectivePrice()) %>"
                            data-disc="<%= (int)pr.getDiscountPercent() %>%"
                            data-stock="<%= pr.getStockQuantity() %> units"
                            data-specs="<%= pr.getTechnicalSpecs().replace("\"", "&quot;") %>"
                            data-warranty="<%= pr.getWarrantyPolicy().replace("\"", "&quot;") %>"
                            data-img="<%= pr.getImageUrl() %>">
                            <%= pr.getName() %> (<%= pr.getBrand() %>)
                        </option>
                    <% }} %>
                </select>
            </div>
        </div>

        <div id="matrixContainer" class="table-responsive">
            <!-- Dynamic comparison table rendered via JavaScript -->
        </div>

        <div style="display:flex; justify-content:flex-end; margin-top:20px;">
            <button type="button" class="btn btn-secondary" onclick="closeComparisonMatrixModal()">Close</button>
        </div>
    </div>
</div>
<script>
function selectProductForEdit(id) {
    var picker = document.getElementById('tab2ProductPicker');
    if (picker) {
        picker.value = id;
        onSelectTab2Product(picker);
    }
}

function onSelectTab2Product(sel) {
    var opt = sel.options[sel.selectedIndex];
    var section = document.getElementById('editProductSection');
    if (!opt || !opt.value) {
        return;
    }
    section.style.display = 'block';
    document.getElementById('t2_edit_id').value = opt.value;
    document.getElementById('t2_edit_code').value = opt.getAttribute('data-code') || '';
    document.getElementById('t2_edit_name').value = opt.getAttribute('data-name') || '';
    document.getElementById('t2_edit_category').value = opt.getAttribute('data-category') || 'String Instruments';
    document.getElementById('t2_edit_brand').value = opt.getAttribute('data-brand') || '';
    document.getElementById('t2_edit_price').value = opt.getAttribute('data-price') || '';
    document.getElementById('t2_edit_discount').value = opt.getAttribute('data-discount') || '0.0';
    document.getElementById('t2_edit_stock').value = opt.getAttribute('data-stock') || '';
    document.getElementById('t2_edit_description').value = opt.getAttribute('data-desc') || '';
    document.getElementById('t2_edit_specs').value = opt.getAttribute('data-specs') || '';
    var rawW2 = opt.getAttribute('data-warranty') || '';
    var mW2 = rawW2.match(/\d+/);
    document.getElementById('t2_edit_warranty').value = mW2 ? mW2[0] : (rawW2.toLowerCase().indexOf('no') !== -1 ? '0' : '1');
    document.getElementById('t2_edit_image').value = opt.getAttribute('data-img') || '';

    var badge = document.getElementById('t2_editingBadge');
    if (badge) {
        badge.innerText = 'Editing #' + opt.value + ' - ' + (opt.getAttribute('data-name') || '');
    }
    section.scrollIntoView({ behavior: 'smooth' });
}

function closeInlineProductEdit() {
    var section = document.getElementById('editProductSection');
    if (section) section.style.display = 'none';
}

function openProductEditModal(id, code, name, category, brand, price, discount, stock, desc, specs, warranty, img) {
    document.getElementById('edit_prod_id').value = id;
    document.getElementById('edit_prod_code').value = code;
    document.getElementById('edit_prod_name').value = name;
    document.getElementById('edit_prod_category').value = category;
    document.getElementById('edit_prod_brand').value = brand;
    document.getElementById('edit_prod_price').value = price;
    document.getElementById('edit_prod_discount').value = discount;
    document.getElementById('edit_prod_stock').value = stock;
    document.getElementById('edit_prod_desc').value = desc;
    document.getElementById('edit_prod_specs').value = specs;
    var wStr = (warranty != null) ? warranty.toString() : '';
    var mW = wStr.match(/\d+/);
    document.getElementById('edit_prod_warranty').value = mW ? mW[0] : (wStr.toLowerCase().indexOf('no') !== -1 ? '0' : '1');
    document.getElementById('edit_prod_image').value = img;
    document.getElementById('productEditModal').style.display = 'flex';
}

function closeProductEditModal() {
    document.getElementById('productEditModal').style.display = 'none';
}

function openOrderEditModal(orderId, name, phone, addr, city, dist, courier, payStatus, fulStatus) {
    document.getElementById('ord_edit_id').value = orderId;
    document.getElementById('ord_edit_name').value = name;
    document.getElementById('ord_edit_phone').value = phone;
    document.getElementById('ord_edit_address').value = addr;
    document.getElementById('ord_edit_city').value = city;
    document.getElementById('ord_edit_district').value = dist;
    document.getElementById('ord_edit_courier').value = courier;
    document.getElementById('ord_edit_pay_status').value = payStatus;
    document.getElementById('ord_edit_ful_status').value = fulStatus;
    document.getElementById('orderEditModal').style.display = 'flex';
}

function closeOrderEditModal() {
    document.getElementById('orderEditModal').style.display = 'none';
}

function onSelectMember3Product(sel) {
    var opt = sel.options[sel.selectedIndex];
    var form = document.getElementById('m3EditForm');
    if (!opt || !opt.value) {
        form.style.display = 'none';
        return;
    }
    document.getElementById('m3_id').value = opt.value;
    document.getElementById('m3_code').value = opt.getAttribute('data-code');
    document.getElementById('m3_name').value = opt.getAttribute('data-name');
    document.getElementById('m3_category').value = opt.getAttribute('data-category');
    document.getElementById('m3_brand').value = opt.getAttribute('data-brand');
    document.getElementById('m3_price').value = opt.getAttribute('data-price');
    document.getElementById('m3_discount').value = opt.getAttribute('data-discount');
    document.getElementById('m3_stock').value = opt.getAttribute('data-stock');
    document.getElementById('m3_description').value = opt.getAttribute('data-desc');
    document.getElementById('m3_specs').value = opt.getAttribute('data-specs');
    var rawW3 = opt.getAttribute('data-warranty') || '';
    var mW3 = rawW3.match(/\d+/);
    document.getElementById('m3_warranty').value = mW3 ? mW3[0] : (rawW3.toLowerCase().indexOf('no') !== -1 ? '0' : '1');
    document.getElementById('m3_image').value = opt.getAttribute('data-img');
    form.style.display = 'block';
}


function toggleCreatePaymentForm() {
    var c = document.getElementById('createPaymentFormContainer');
    if (c) {
        c.style.display = (c.style.display === 'none' || c.style.display === '') ? 'block' : 'none';
        if (c.style.display === 'block') c.scrollIntoView({ behavior: 'smooth' });
    }
}

function onSelectOrderForPayment(sel) {
    var opt = sel.options[sel.selectedIndex];
    if (!opt || !opt.value) return;
    document.getElementById('m4_orderId').value = opt.value;
    document.getElementById('m4_customerName').value = opt.getAttribute('data-name') || '';
    document.getElementById('m4_customerEmail').value = opt.getAttribute('data-email') || '';
    document.getElementById('m4_customerPhone').value = opt.getAttribute('data-phone') || '';
    document.getElementById('m4_billingAddress').value = opt.getAttribute('data-address') || '';
    document.getElementById('m4_amount').value = opt.getAttribute('data-amount') || '';
    var method = opt.getAttribute('data-method');
    if (method) {
        var mSel = document.getElementById('m4_method');
        if (mSel) {
            for (var i = 0; i < mSel.options.length; i++) {
                if (mSel.options[i].value.equalsIgnoreCase && mSel.options[i].value.equalsIgnoreCase(method)) {
                    mSel.selectedIndex = i;
                    break;
                }
            }
        }
    }
}

function filterPaymentsByStatus(status) {
    var rows = document.querySelectorAll('.payment-row');
    rows.forEach(function(row) {
        if (status === 'ALL') {
            row.style.display = '';
        } else if (status === 'VOIDED') {
            var st = row.getAttribute('data-status');
            row.style.display = (st === 'VOIDED' || st === 'FAILED') ? '' : 'none';
        } else {
            row.style.display = (row.getAttribute('data-status') === status) ? '' : 'none';
        }
    });
}

function filterPaymentsSearch(query) {
    var q = query.toLowerCase().trim();
    var rows = document.querySelectorAll('.payment-row');
    rows.forEach(function(row) {
        var searchData = row.getAttribute('data-search') || '';
        row.style.display = searchData.indexOf(q) !== -1 ? '' : 'none';
    });
}

function openReviewModal(txnId, orderId, status, method, amount, slip, ref) {
    document.getElementById('rev_txnId').value = txnId;
    document.getElementById('rev_orderId').value = orderId;
    document.getElementById('rev_txnDisplay').innerText = txnId;
    document.getElementById('rev_orderDisplay').innerText = orderId;
    document.getElementById('rev_amountDisplay').innerText = 'LKR ' + parseFloat(amount).toLocaleString('en-US', {minimumFractionDigits:2});
    document.getElementById('rev_statusSelect').value = status;
    document.getElementById('rev_notes').value = ref || '';

    var slipRow = document.getElementById('rev_slipRow');
    if (slip && slip.trim() !== '') {
        document.getElementById('rev_slipDisplay').innerText = slip;
        slipRow.style.display = 'block';
    } else {
        slipRow.style.display = 'none';
    }
    document.getElementById('reviewStatusModal').style.display = 'flex';
}

function closeReviewModal() {
    document.getElementById('reviewStatusModal').style.display = 'none';
}

function openRefundModal(txnId, orderId, amount) {
    document.getElementById('ref_txnId').value = txnId;
    document.getElementById('ref_orderId').value = orderId;
    document.getElementById('ref_txnDisplay').innerText = txnId;
    document.getElementById('ref_orderDisplay').innerText = orderId;
    document.getElementById('ref_origAmountDisplay').innerText = 'LKR ' + parseFloat(amount).toLocaleString('en-US', {minimumFractionDigits:2});
    document.getElementById('ref_amount').value = amount;
    document.getElementById('refundModal').style.display = 'flex';
}

function closeRefundModal() {
    document.getElementById('refundModal').style.display = 'none';
}

function openVoidModal(txnId, orderId) {
    document.getElementById('void_txnId').value = txnId;
    document.getElementById('void_orderId').value = orderId;
    document.getElementById('voidModal').style.display = 'flex';
}

function closeVoidModal() {
    document.getElementById('voidModal').style.display = 'none';
}

function showCustomerHistory(orderId, txnId, amount) {
    var content = '<div style="background:#f8fafc; padding:15px; border-radius:6px; margin-bottom:15px;">' +
        '<div><strong>Order Reference:</strong> ' + orderId + '</div>' +
        '<div><strong>Primary Transaction:</strong> ' + txnId + '</div>' +
        '<div><strong>Billed Total:</strong> LKR ' + parseFloat(amount).toLocaleString('en-US', {minimumFractionDigits:2}) + '</div>' +
        '</div>' +
        '<h4 style="color:var(--primary); font-size:0.95rem; margin-bottom:8px;">Transaction State Audit Log:</h4>' +
        '<ul style="font-size:0.85rem; color:var(--gray-700); line-height:1.6; padding-left:20px;">' +
        '<li>Transaction record initiated across designated payment gateway channel.</li>' +
        '<li>Official IRD-compliant tax e-invoice auto-generated with 8% VAT breakdown.</li>' +
        '<li>Real-time state synchronization active with MelodyMart Central Management Portal.</li>' +
        '</ul>';
    document.getElementById('customerHistoryContent').innerHTML = content;
    document.getElementById('customerHistoryModal').style.display = 'flex';
}

function closeCustomerHistoryModal() {
    document.getElementById('customerHistoryModal').style.display = 'none';
}


// ==========================================
// MEMBER 5: INVENTORY & SUPPLIER MODALS (IT25103441)
// ==========================================
function openAddSupplierModal() {
    document.getElementById('addSupplierModal').style.display = 'flex';
}
function closeAddSupplierModal() {
    document.getElementById('addSupplierModal').style.display = 'none';
}

function openEditSupplierModal(id, company, contact, email, phone, address, categories) {
    document.getElementById('edit_sup_id').value = id;
    document.getElementById('edit_sup_company').value = company;
    document.getElementById('edit_sup_contact').value = contact;
    document.getElementById('edit_sup_email').value = email;
    document.getElementById('edit_sup_phone').value = phone;
    document.getElementById('edit_sup_address').value = address;
    document.getElementById('edit_sup_categories').value = categories;
    document.getElementById('editSupplierModal').style.display = 'flex';
}
function closeEditSupplierModal() {
    document.getElementById('editSupplierModal').style.display = 'none';
}

function openCreatePoModal() {
    document.getElementById('createPoModal').style.display = 'flex';
}
function closeCreatePoModal() {
    document.getElementById('createPoModal').style.display = 'none';
}

function openReceiveBatchModal(poNumber, summary, qty) {
    document.getElementById('rec_poNumber').value = poNumber;
    document.getElementById('rec_poDisplay').innerText = poNumber;
    document.getElementById('rec_summaryDisplay').innerText = summary;
    document.getElementById('rec_quantity').value = qty || 1;
    document.getElementById('receiveBatchModal').style.display = 'flex';
}
function closeReceiveBatchModal() {
    document.getElementById('receiveBatchModal').style.display = 'none';
}

function openAdjustStockModal(prodId, prodName, currentStock) {
    var sel = document.getElementById('adj_productId');
    if (prodId > 0) {
        sel.value = prodId;
        document.getElementById('adj_stockDisplay').innerText = currentStock;
        document.getElementById('adj_stockInfo').style.display = 'block';
    } else {
        sel.selectedIndex = 0;
        document.getElementById('adj_stockInfo').style.display = 'none';
    }
    document.getElementById('adj_units').value = 1;
    document.getElementById('adj_type').value = 'ADD';
    updateAdjDelta();
    document.getElementById('adjustStockModal').style.display = 'flex';
}
function closeAdjustStockModal() {
    document.getElementById('adjustStockModal').style.display = 'none';
}

function onSelectAdjustProduct(sel) {
    var opt = sel.options[sel.selectedIndex];
    if (opt && opt.value) {
        var stock = opt.getAttribute('data-stock') || '0';
        document.getElementById('adj_stockDisplay').innerText = stock;
        document.getElementById('adj_stockInfo').style.display = 'block';
    } else {
        document.getElementById('adj_stockInfo').style.display = 'none';
    }
}

function updateAdjDelta() {
    var type = document.getElementById('adj_type').value;
    var units = parseInt(document.getElementById('adj_units').value) || 1;
    if (type === 'DEDUCT') {
        document.getElementById('adj_delta').value = -Math.abs(units);
    } else {
        document.getElementById('adj_delta').value = Math.abs(units);
    }
}


// ==========================================
// MEMBER 6: DISPATCH MODAL (IT25100652)
// ==========================================
function openCreateDispatchModal() {
    document.getElementById('createDispatchModal').style.display = 'flex';
}
function closeCreateDispatchModal() {
    document.getElementById('createDispatchModal').style.display = 'none';
}
function onSelectDispatchOrder(sel) {
    var opt = sel.options[sel.selectedIndex];
    if (!opt || !opt.value) return;
    document.getElementById('disp_customerName').value = opt.getAttribute('data-name') || '';
    document.getElementById('disp_shippingAddress').value = opt.getAttribute('data-address') || '';
    var courier = opt.getAttribute('data-courier');
    if (courier) {
        var cSel = document.getElementById('disp_courierName');
        for (var i = 0; i < cSel.options.length; i++) {
            if (cSel.options[i].value === courier) {
                cSel.selectedIndex = i;
                break;
            }
        }
    }
    document.getElementById('disp_codAmount').value = opt.getAttribute('data-cod') || '0.00';
}


// ==========================================
// MEMBER 1: USER ACCOUNT & PROFILE MODALS (IT25101726)
// ==========================================
function openAdminAddUserModal() {
    document.getElementById('adminAddUserModal').style.display = 'flex';
}
function closeAdminAddUserModal() {
    document.getElementById('adminAddUserModal').style.display = 'none';
}

function openAdminEditUserModal(id, name, phone, role, status) {
    document.getElementById('m1_edit_userId').value = id;
    document.getElementById('m1_edit_fullName').value = name;
    document.getElementById('m1_edit_phone').value = phone;
    document.getElementById('m1_edit_role').value = role;
    document.getElementById('m1_edit_status').value = status;
    document.getElementById('adminEditUserModal').style.display = 'flex';
}
function closeAdminEditUserModal() {
    document.getElementById('adminEditUserModal').style.display = 'none';
}

function openAdminResetPasswordModal(id, name, email) {
    document.getElementById('m1_pwd_userId').value = id;
    document.getElementById('m1_pwd_userName').innerText = name;
    document.getElementById('m1_pwd_userEmail').innerText = email;
    document.getElementById('adminResetPasswordModal').style.display = 'flex';
}
function closeAdminResetPasswordModal() {
    document.getElementById('adminResetPasswordModal').style.display = 'none';
}

function openAdminAddAddressModal(userId) {
    var sel = document.getElementById('m1_addr_userId');
    if (userId > 0) {
        sel.value = userId;
    } else {
        sel.selectedIndex = 0;
    }
    document.getElementById('adminAddAddressModal').style.display = 'flex';
}
function closeAdminAddAddressModal() {
    document.getElementById('adminAddAddressModal').style.display = 'none';
}

function openAdminUserSessionModal(id, name, email, role) {
    document.getElementById('m1_sess_userName').innerText = name;
    document.getElementById('m1_sess_userEmail').innerText = email;
    document.getElementById('m1_sess_userRole').innerText = role;

    var permText = '';
    if (role === 'ADMIN') {
        permText = '<strong>Full System Access:</strong> Complete governance over users, product catalog, orders, payments, invoices, inventory suppliers, and dispatch fulfillment.';
    } else if (role === 'SALES_STAFF') {
        permText = '<strong>Sales Operations:</strong> Customer order processing, order status updates, and courier dispatch management.';
    } else if (role === 'INVENTORY_STAFF') {
        permText = '<strong>Warehouse & Procurement:</strong> Supplier registration, stock purchase orders, batch receiving, and inventory adjustment.';
    } else if (role === 'FINANCE_STAFF') {
        permText = '<strong>Accounts & Billing:</strong> Payment reconciliation, VAT invoice generation, refund processing, and bank slip review.';
    } else {
        permText = '<strong>Customer Storefront:</strong> Browse musical instrument catalog, cart management, online checkout, profile editing, and order tracking.';
    }
    document.getElementById('m1_sess_permissions').innerHTML = permText;

    var hist = '<li>Active Web Session: MelodyMart Management Portal (IP: 127.0.0.1 / SSL Secured)</li>' +
               '<li>Authentication Method: SHA-256 Digest Verification</li>' +
               '<li>Access Token: Verified & Persistent in Relational Database</li>';
    document.getElementById('m1_sess_history').innerHTML = hist;

    document.getElementById('adminUserSessionModal').style.display = 'flex';
}
function closeAdminUserSessionModal() {
    document.getElementById('adminUserSessionModal').style.display = 'none';
}


// ==========================================
// MEMBER 2: PRODUCT CATALOG MODALS (IT25102561)
// ==========================================
function openAddProductModal() {
    document.getElementById('addProductModal').style.display = 'flex';
}
function closeAddProductModal() {
    document.getElementById('addProductModal').style.display = 'none';
}

function openComparisonMatrixModal() {
    document.getElementById('comparisonMatrixModal').style.display = 'flex';
    renderComparisonMatrix();
}
function closeComparisonMatrixModal() {
    document.getElementById('comparisonMatrixModal').style.display = 'none';
}

function renderComparisonMatrix() {
    var selA = document.getElementById('comp_itemA');
    var selB = document.getElementById('comp_itemB');
    var optA = selA.options[selA.selectedIndex];
    var optB = selB.options[selB.selectedIndex];
    if (!optA || !optB) return;

    var html = '<table style="width:100%; border-collapse:collapse; font-size:0.85rem;">' +
        '<thead>' +
            '<tr style="background:#f8fafc; border-bottom:2px solid var(--gray-200);">' +
                '<th style="padding:10px; text-align:left; width:25%;">Feature / Spec</th>' +
                '<th style="padding:10px; text-align:center; width:37.5%; color:#8b5cf6;">' + optA.getAttribute('data-name') + '</th>' +
                '<th style="padding:10px; text-align:center; width:37.5%; color:#0284c7;">' + optB.getAttribute('data-name') + '</th>' +
            '</tr>' +
        '</thead>' +
        '<tbody>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Preview</td>' +
                '<td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;"><img src="' + optA.getAttribute('data-img') + '" style="height:70px; border-radius:4px; object-fit:cover;"></td>' +
                '<td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;"><img src="' + optB.getAttribute('data-img') + '" style="height:70px; border-radius:4px; object-fit:cover;"></td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Category</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-cat') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-cat') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Brand</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;"><strong>' + optA.getAttribute('data-brand') + '</strong></td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;"><strong>' + optB.getAttribute('data-brand') + '</strong></td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Retail Price</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-price') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-price') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Discount</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-disc') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-disc') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Effective Price</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0; font-weight:bold; color:#16a34a;">' + optA.getAttribute('data-eff') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0; font-weight:bold; color:#16a34a;">' + optB.getAttribute('data-eff') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Available Stock</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-stock') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-stock') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Technical Specs</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-specs') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-specs') + '</td></tr>' +
            '<tr><td style="padding:8px; font-weight:600; border-bottom:1px solid #e2e8f0;">Warranty Policy</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optA.getAttribute('data-warranty') + '</td><td style="padding:8px; text-align:center; border-bottom:1px solid #e2e8f0;">' + optB.getAttribute('data-warranty') + '</td></tr>' +
        '</tbody>' +
    '</table>';
    document.getElementById('matrixContainer').innerHTML = html;
}

window.onclick = function(event) {
    var apm = document.getElementById('addProductModal');
    var cmm = document.getElementById('comparisonMatrixModal');
    var aum = document.getElementById('adminAddUserModal');
    var eum = document.getElementById('adminEditUserModal');
    var rpm = document.getElementById('adminResetPasswordModal');
    var aam = document.getElementById('adminAddAddressModal');
    var usm = document.getElementById('adminUserSessionModal');
    var pm = document.getElementById('productEditModal');
    var om = document.getElementById('orderEditModal');
    var rm = document.getElementById('reviewStatusModal');
    var refm = document.getElementById('refundModal');
    var vm = document.getElementById('voidModal');
    var chm = document.getElementById('customerHistoryModal');
    var asm = document.getElementById('addSupplierModal');
    var esm = document.getElementById('editSupplierModal');
    var cpm = document.getElementById('createPoModal');
    var rbm = document.getElementById('receiveBatchModal');
    var adjm = document.getElementById('adjustStockModal');
    var cdm = document.getElementById('createDispatchModal');
    if (event.target === apm) apm.style.display = 'none';
    if (event.target === cmm) cmm.style.display = 'none';
    if (event.target === aum) aum.style.display = 'none';
    if (event.target === eum) eum.style.display = 'none';
    if (event.target === rpm) rpm.style.display = 'none';
    if (event.target === aam) aam.style.display = 'none';
    if (event.target === usm) usm.style.display = 'none';
    if (event.target === pm) pm.style.display = 'none';
    if (event.target === om) om.style.display = 'none';
    if (event.target === rm) rm.style.display = 'none';
    if (event.target === refm) refm.style.display = 'none';
    if (event.target === vm) vm.style.display = 'none';
    if (event.target === chm) chm.style.display = 'none';
    if (event.target === asm) asm.style.display = 'none';
    if (event.target === esm) esm.style.display = 'none';
    if (event.target === cpm) cpm.style.display = 'none';
    if (event.target === rbm) rbm.style.display = 'none';
    if (event.target === adjm) adjm.style.display = 'none';
    if (event.target === cdm) cdm.style.display = 'none';
};
</script>

</body>
</html>
