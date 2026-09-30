<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="models.Product" %>
<%@ page import="models.User" %>
<%@ page import="models.Cart" %>
<%@ page import="java.util.List" %>
<%
    ProductDAO productDAO = new ProductDAO();
    CartDAO cartDAO = new CartDAO();
    List<Product> featured = productDAO.getAllProducts();
    User currentUser = (User) session.getAttribute("currentUser");
    Cart cart = cartDAO.getCart(session);
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MelodyMart | Premier Musical Instrument Store Sri Lanka</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<div class="top-bar">
    🇱🇰 Harmony Lanka Musical Stores (Pvt) Ltd. | Islandwide Delivery with Koombiyo & Domex | Hotline: 011 284 5678
</div>

<header>
    <div class="navbar">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/index.jsp">
                <span>🎵 MelodyMart</span>
            </a>
            <span class="logo-sub">Harmony Lanka Musical Stores</span>
        </div>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/index.jsp" class="active">Home</a></li>
            <li><a href="<%= request.getContextPath() %>/products">Instrument Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/cart">Cart <span class="cart-badge"><%= cart.getTotalItemCount() %></span></a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/returns">Returns & Warranty</a></li>
            <% if (currentUser != null) { %>
                <li><a href="<%= request.getContextPath() %>/user?action=profile">Hi, <%= currentUser.getFullName().split(" ")[0] %></a></li>
                <% if (!"CUSTOMER".equalsIgnoreCase(currentUser.getRole())) { %>
                    <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Staff Portal</a></li>
                <% } %>
                <li><a href="<%= request.getContextPath() %>/user?action=logout">Logout</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/user?action=login">Login / Register</a></li>
                <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin Portal</a></li>
            <% } %>
        </ul>
    </div>
</header>

<div class="container">
    <% if ("welcome".equals(msg)) { %>
        <div class="alert alert-success">Welcome back to MelodyMart! You are securely logged in.</div>
    <% } else if ("logged_out".equals(msg)) { %>
        <div class="alert alert-info">You have been logged out successfully.</div>
    <% } %>

    <div class="hero">
        <h1>Discover Your Sound in Sri Lanka</h1>
        <p>From traditional Kandyan Geta Beraya & handcrafted Ruhunu drums to world-class Yamaha, Roland & Fender instruments. Experience genuine quality with official warranty.</p>
        <div>
            <a href="<%= request.getContextPath() %>/products" class="btn btn-accent" style="font-size:1.05rem; padding:12px 24px;">Explore 10 Instruments Catalog</a>
            <a href="<%= request.getContextPath() %>/track" class="btn btn-secondary" style="font-size:1.05rem; padding:12px 24px; margin-left:10px;">Track Sri Lankan Delivery</a>
        </div>
    </div>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
        <h2 style="color:var(--primary); font-size:1.6rem;">Featured Instruments in Sri Lanka</h2>
        <a href="<%= request.getContextPath() %>/products" style="color:var(--primary); font-weight:600; text-decoration:none;">View All 10 Instruments &rarr;</a>
    </div>

    <div class="product-grid">
        <% for (Product p : featured) { %>
            <div class="product-card">
                <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" class="product-image" loading="lazy">
                <div class="product-body">
                    <span class="product-category"><%= p.getCategory() %></span>
                    <h3 class="product-title"><%= p.getName() %></h3>
                    <div class="product-brand">Brand: <strong><%= p.getBrand() %></strong> | <%= p.getCode() %></div>

                    <div class="product-price-row">
                        <span class="price-current">LKR <%= String.format("%,.2f", p.getEffectivePrice()) %></span>
                        <% if (p.getDiscountPercent() > 0) { %>
                            <span class="price-original">LKR <%= String.format("%,.2f", p.getPrice()) %></span>
                            <span class="badge-discount"><%= (int)p.getDiscountPercent() %>% OFF</span>
                        <% } %>
                    </div>

                    <div>
                        <% if (p.getStockQuantity() > 5) { %>
                            <span class="badge-stock badge-in-stock">In Stock (<%= p.getStockQuantity() %> available)</span>
                        <% } else if (p.getStockQuantity() > 0) { %>
                            <span class="badge-stock badge-low-stock">Low Stock (Only <%= p.getStockQuantity() %> left)</span>
                        <% } else { %>
                            <span class="badge-stock" style="background:#fee2e2; color:#b91c1c;">Out of Stock</span>
                        <% } %>
                    </div>

                    <div class="product-actions">
                        <a href="<%= request.getContextPath() %>/product-detail?id=<%= p.getId() %>" class="btn btn-secondary btn-sm" style="flex:1; text-align:center;">View Specs</a>
                        <form action="<%= request.getContextPath() %>/cart" method="post" style="flex:1;">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="<%= p.getId() %>">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="btn btn-primary btn-sm" style="width:100%;">Add to Cart</button>
                        </form>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <div class="card" style="margin-top:40px; background:linear-gradient(to right, #ffffff, #fffbeb); border-left: 5px solid var(--primary);">
        <h3 style="color:var(--primary); margin-bottom:10px;">Why Choose MelodyMart Sri Lanka?</h3>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(220px, 1fr)); gap:20px; font-size:0.92rem;">
            <div>
                <strong>🚚 Islandwide Express Couriers</strong>
                <p style="color:var(--gray-600); margin-top:4px;">Partnered with Koombiyo, Domex, and Pronto for safe delivery across all 25 districts.</p>
            </div>
            <div>
                <strong>💳 Multi-Channel Sri Lankan Payments</strong>
                <p style="color:var(--gray-600); margin-top:4px;">Bank slip deposit (BOC, Sampath, Commercial Bank), Visa/Mastercard, FriMi, or Cash-on-Delivery (COD).</p>
            </div>
            <div>
                <strong>🥁 Authentic Sri Lankan Craftsmanship</strong>
                <p style="color:var(--gray-600); margin-top:4px;">Handcrafted traditional drums and flutes made by master artisans in Kurunegala and Kandy.</p>
            </div>
            <div>
                <strong>🛡️ Official Tax Invoices & Warranty</strong>
                <p style="color:var(--gray-600); margin-top:4px;">Automated itemized VAT tax e-invoices with guaranteed repair and warranty claim support.</p>
            </div>
        </div>
    </div>
</div>

<footer>
    <div class="footer-content">
        <div class="footer-col">
            <h4>MelodyMart Sri Lanka</h4>
            <p>Harmony Lanka Musical Stores (Pvt) Ltd.<br>No. 45, Galle Road, Colombo 03, Sri Lanka.<br>Registration: PV-98124/2026</p>
        </div>
        <div class="footer-col">
            <h4>Quick Navigation</h4>
            <ul>
                <li><a href="<%= request.getContextPath() %>/products">All 10 Instruments</a></li>
                <li><a href="<%= request.getContextPath() %>/cart">Shopping Cart</a></li>
                <li><a href="<%= request.getContextPath() %>/track">Order Tracking (Koombiyo/Domex)</a></li>
                <li><a href="<%= request.getContextPath() %>/returns">Warranty & Returns Claim</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4>SLIIT SE2030 Project</h4>
            <p>Group: <strong>2026-Y2-S1-MLB-B6G1-08</strong><br>Module: SE2030 (Software Engineering)<br>Year 2 Semester 1 - 6 Members CRUD Operations</p>
        </div>
    </div>
    <div class="footer-bottom">
        &copy; 2026 MelodyMart - Harmony Lanka Musical Stores (Pvt) Ltd. All rights reserved.
    </div>
</footer>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>