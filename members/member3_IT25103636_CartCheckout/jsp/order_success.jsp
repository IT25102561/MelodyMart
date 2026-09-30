<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Order" %>
<%@ page import="dao.OrderDAO" %>
<%
    String orderId = request.getParameter("orderId");
    Order order = null;
    if (orderId != null && !orderId.trim().isEmpty()) {
        order = new OrderDAO().getOrderById(orderId.trim());
    }
    if (order == null) {
        order = (Order) session.getAttribute("lastPlacedOrder");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed | MelodyMart Sri Lanka</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<header>
    <div class="navbar">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/index.jsp">
                <span>🎵 MelodyMart</span>
            </a>
            <span class="logo-sub">Harmony Lanka Musical Stores</span>
        </div>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
            <li><a href="<%= request.getContextPath() %>/products">Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/orders">Order History</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:750px;">
    <% if (order != null) { %>
        <div class="card" style="text-align:center; padding:35px 25px;">
            <div style="font-size:3rem; margin-bottom:10px;">🎉</div>
            <h1 style="color:var(--success); font-size:1.9rem; margin-bottom:6px;">Thank You! Your Order is Placed</h1>
            <p style="color:var(--gray-600); font-size:1rem; margin-bottom:20px;">
                Your order has been recorded into the MelodyMart store system and saved permanently in <code>orders.txt</code>.
            </p>

            <div style="background:#f8fafc; border:1px solid var(--gray-200); border-radius:var(--radius); padding:20px; text-align:left; margin-bottom:25px;">
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Order Identifier:</span>
                    <strong><%= order.getOrderId() %></strong>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Customer:</span>
                    <span><%= order.getCustomerName() %> (<%= order.getCustomerPhone() %>)</span>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Delivery Address:</span>
                    <span><%= order.getShippingAddress() %>, <%= order.getCity() %>, <%= order.getDistrict() %></span>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Courier Service:</span>
                    <span><strong><%= order.getCourierName() %></strong></span>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Courier Tracking Number:</span>
                    <span style="background:#e0f2fe; color:#0369a1; padding:2px 8px; border-radius:4px; font-weight:bold;"><%= order.getTrackingNumber() %></span>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--gray-600);">Payment Method:</span>
                    <span><%= order.getPaymentMethod() %> (<%= order.getPaymentStatus() %>)</span>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:1.15rem; font-weight:bold; color:var(--primary); border-top:1px solid var(--gray-300); padding-top:10px; margin-top:10px;">
                    <span>Total Paid / Payable:</span>
                    <span>LKR <%= String.format("%,.2f", order.getTotalAmount()) %></span>
                </div>
            </div>

            <div style="display:flex; gap:12px; justify-content:center; flex-wrap:wrap;">
                <a href="<%= request.getContextPath() %>/invoice?orderId=<%= order.getOrderId() %>" class="btn btn-primary" target="_blank">
                    📄 View & Print Official Tax E-Invoice
                </a>
                <a href="<%= request.getContextPath() %>/track?trackingNumber=<%= order.getTrackingNumber() %>" class="btn btn-accent">
                    🚚 Track Live Courier Dispatch
                </a>
                <a href="<%= request.getContextPath() %>/orders" class="btn btn-secondary">
                    📋 View Order History
                </a>
            </div>
        </div>
    <% } else { %>
        <div class="card" style="text-align:center; padding:40px;">
            <h2>No active order found.</h2>
            <p style="color:var(--gray-600); margin:10px 0 20px;">Please check your order history or return to the instruments catalog.</p>
            <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">Go to Catalog</a>
        </div>
    <% } %>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>