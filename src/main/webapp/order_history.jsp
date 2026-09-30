<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Order" %>
<%@ page import="models.User" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="java.util.List" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) {
        orders = new OrderDAO().getAllOrders();
    }
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saved Orders History | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/orders" class="active">Saved Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
        <div>
            <h1 style="color:var(--primary); margin-bottom:4px;">Saved Customer Orders</h1>
            <p style="color:var(--gray-600);">All orders are permanently synchronized and preserved in <code>orders.txt</code>.</p>
        </div>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">+ Place New Order</a>
    </div>

    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Date & Time</th>
                    <th>Customer / Destination</th>
                    <th>Items Summary</th>
                    <th>Total (LKR)</th>
                    <th>Payment</th>
                    <th>Courier Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (orders.isEmpty()) { %>
                    <tr>
                        <td colspan="8" style="text-align:center; padding:30px; color:var(--gray-600);">
                            No orders found. Place an order through the catalog to see it saved here!
                        </td>
                    </tr>
                <% } else { %>
                    <% for (Order o : orders) { %>
                        <tr>
                            <td><strong><%= o.getOrderId() %></strong></td>
                            <td style="font-size:0.82rem; color:var(--gray-600);"><%= o.getOrderDate() %></td>
                            <td>
                                <div><strong><%= o.getCustomerName() %></strong></div>
                                <div style="font-size:0.75rem; color:var(--gray-600);"><%= o.getCity() %>, <%= o.getDistrict() %></div>
                            </td>
                            <td style="max-width:220px; font-size:0.82rem;">
                                <%= o.getItemsSummary() %>
                            </td>
                            <td><strong style="color:var(--primary);">LKR <%= String.format("%,.2f", o.getTotalAmount()) %></strong></td>
                            <td>
                                <span class="badge badge-<%= o.getPaymentStatus().toLowerCase() %>"><%= o.getPaymentStatus() %></span>
                                <div style="font-size:0.72rem; color:var(--gray-600); margin-top:2px;"><%= o.getPaymentMethod() %></div>
                            </td>
                            <td>
                                <span class="badge badge-<%= o.getFulfillmentStatus().toLowerCase() %>"><%= o.getFulfillmentStatus() %></span>
                                <div style="font-size:0.72rem; color:var(--gray-600); margin-top:2px;"><%= o.getCourierName() %></div>
                            </td>
                            <td>
                                <div style="display:flex; gap:6px;">
                                    <a href="<%= request.getContextPath() %>/invoice?orderId=<%= o.getOrderId() %>" class="btn btn-secondary btn-sm" title="View Tax Invoice">Invoice</a>
                                    <a href="<%= request.getContextPath() %>/track?trackingNumber=<%= o.getTrackingNumber() %>" class="btn btn-secondary btn-sm" title="Track Courier">Track</a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>