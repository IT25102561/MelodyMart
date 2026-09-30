<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Order" %>
<%@ page import="models.CartItem" %>
<%@ page import="dao.OrderDAO" %>
<%
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        String idParam = request.getParameter("id");
        if (idParam != null) {
            order = new OrderDAO().getOrderById(idParam.trim());
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details <%= (order != null) ? order.getOrderId() : "" %> | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/orders" class="active">Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:850px;">
    <p style="margin-bottom: 15px;"><a href="<%= request.getContextPath() %>/orders" style="color:var(--primary); text-decoration:none;">&larr; Back to Order History</a></p>

    <% if (order != null) { %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; border-bottom:1px solid var(--gray-200); padding-bottom:15px; margin-bottom:20px;">
                <div>
                    <h2 style="color:var(--primary); margin-bottom:4px;">Order <%= order.getOrderId() %></h2>
                    <div style="font-size:0.85rem; color:var(--gray-600);">Placed on: <strong><%= order.getOrderDate() %></strong></div>
                </div>
                <div style="text-align:right;">
                    <div>Payment: <span class="badge badge-<%= order.getPaymentStatus().toLowerCase() %>"><%= order.getPaymentStatus() %></span></div>
                    <div style="margin-top:4px;">Delivery: <span class="badge badge-<%= order.getFulfillmentStatus().toLowerCase() %>"><%= order.getFulfillmentStatus() %></span></div>
                </div>
            </div>

            <!-- Customer & Shipping Details -->
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; margin-bottom:20px; font-size:0.88rem; background:#f8fafc; padding:15px; border-radius:var(--radius); border:1px solid var(--gray-200);">
                <div>
                    <strong style="color:var(--primary); display:block; margin-bottom:6px;">Recipient Details:</strong>
                    <div><%= order.getCustomerName() %></div>
                    <div>Phone: <%= order.getCustomerPhone() %></div>
                    <div>Email: <%= order.getCustomerEmail() %></div>
                </div>
                <div>
                    <strong style="color:var(--primary); display:block; margin-bottom:6px;">Courier Dispatch:</strong>
                    <div>Partner: <strong><%= order.getCourierName() %></strong></div>
                    <div>Tracking Code: <code style="font-weight:bold; color:var(--info);"><%= order.getTrackingNumber() %></code></div>
                    <div>Destination: <%= order.getShippingAddress() %>, <%= order.getCity() %> (<%= order.getDistrict() %>)</div>
                </div>
            </div>

            <!-- Order Items Table -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Musical Instrument</th>
                            <th>Unit Price</th>
                            <th style="text-align:center;">Quantity</th>
                            <th style="text-align:right;">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (order.getItems() != null) { for (CartItem it : order.getItems()) { %>
                            <tr>
                                <td>
                                    <strong><%= it.getProduct().getName() %></strong>
                                    <div style="font-size:0.75rem; color:var(--gray-600);"><%= it.getProduct().getBrand() %> | <%= it.getProduct().getCategory() %></div>
                                </td>
                                <td>LKR <%= String.format("%,.2f", it.getProduct().getEffectivePrice()) %></td>
                                <td style="text-align:center;"><%= it.getQuantity() %></td>
                                <td style="text-align:right;"><strong>LKR <%= String.format("%,.2f", it.getSubtotal()) %></strong></td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>

            <!-- Totals -->
            <div style="margin-left:auto; width:300px; margin-top:15px; font-size:0.9rem;">
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span>Subtotal:</span>
                    <span>LKR <%= String.format("%,.2f", order.getSubtotal()) %></span>
                </div>
                <% if (order.getDiscountAmount() > 0) { %>
                    <div style="display:flex; justify-content:space-between; margin-bottom:6px; color:var(--danger);">
                        <span>Voucher Discount:</span>
                        <span>-LKR <%= String.format("%,.2f", order.getDiscountAmount()) %></span>
                    </div>
                <% } %>
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span>Courier Delivery Fee:</span>
                    <span>LKR <%= String.format("%,.2f", order.getDeliveryFee()) %></span>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:1.2rem; font-weight:bold; color:var(--primary); border-top:2px solid var(--gray-300); padding-top:8px; margin-top:8px;">
                    <span>Net Total:</span>
                    <span>LKR <%= String.format("%,.2f", order.getTotalAmount()) %></span>
                </div>
            </div>

            <!-- Action Buttons -->
            <div style="margin-top:25px; border-top:1px solid var(--gray-200); padding-top:18px; display:flex; gap:10px; justify-content:flex-end;">
                <a href="<%= request.getContextPath() %>/invoice?orderId=<%= order.getOrderId() %>" class="btn btn-primary btn-sm" target="_blank">📄 View Tax E-Invoice</a>
                <a href="<%= request.getContextPath() %>/track?trackingNumber=<%= order.getTrackingNumber() %>" class="btn btn-accent btn-sm">🚚 Track Delivery</a>
            </div>
        </div>
    <% } else { %>
        <div class="card" style="text-align:center; padding:35px;">
            <h3>Order not found.</h3>
            <p style="color:var(--gray-600); margin:10px 0 20px;">Please check the Order ID or return to the orders list.</p>
            <a href="<%= request.getContextPath() %>/orders" class="btn btn-primary">View All Orders</a>
        </div>
    <% } %>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
