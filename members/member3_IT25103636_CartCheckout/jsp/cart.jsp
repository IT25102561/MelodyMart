<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Cart" %>
<%@ page import="models.CartItem" %>
<%@ page import="models.User" %>
<%@ page import="dao.CartDAO" %>
<%
    CartDAO cartDAO = new CartDAO();
    Cart cart = cartDAO.getCart(session);
    User currentUser = (User) session.getAttribute("currentUser");
    String msg = request.getParameter("msg");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/products">Instrument Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/cart" class="active">Cart <span class="cart-badge"><%= cart.getTotalItemCount() %></span></a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <h1 style="color:var(--primary); margin-bottom:6px;">Your Shopping Cart</h1>
    <p style="color:var(--gray-600); margin-bottom:20px;">Member 3 (IT25103636): Dynamic Cart, Sri Lankan Delivery Calculation & Promo Vouchers</p>

    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } %>
    <% if ("item_added".equals(msg)) { %>
        <div class="alert alert-success">Instrument added to your cart successfully!</div>
    <% } else if ("cart_updated".equals(msg)) { %>
        <div class="alert alert-info">Cart quantities updated.</div>
    <% } else if ("voucher_applied".equals(msg)) { %>
        <div class="alert alert-success">Promotional discount voucher applied!</div>
    <% } %>

    <% if (cart.getItems().isEmpty()) { %>
        <div class="card" style="text-align:center; padding:50px 20px;">
            <h3>Your shopping cart is currently empty.</h3>
            <p style="color:var(--gray-600); margin:12px 0 20px;">Explore our 10 handcrafted and brand musical instruments available in Sri Lanka.</p>
            <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">Browse Instrument Catalog</a>
        </div>
    <% } else { %>
        <div style="display:grid; grid-template-columns: 2fr 1fr; gap:25px; align-items:start;">
            <!-- Cart Items Table -->
            <div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Instrument</th>
                                <th>Unit Price</th>
                                <th style="width:110px;">Quantity</th>
                                <th>Subtotal</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (CartItem item : cart.getItems()) { %>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <img src="<%= item.getProduct().getImageUrl() %>" alt="<%= item.getProduct().getName() %>" style="width:50px; height:50px; object-fit:cover; border-radius:4px;">
                                            <div>
                                                <strong><%= item.getProduct().getName() %></strong>
                                                <div style="font-size:0.75rem; color:var(--gray-600);"><%= item.getProduct().getBrand() %> | <%= item.getProduct().getCategory() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>LKR <%= String.format("%,.2f", item.getProduct().getEffectivePrice()) %></td>
                                    <td>
                                        <form action="<%= request.getContextPath() %>/cart" method="post" style="display:flex; gap:4px;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                            <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" max="<%= item.getProduct().getStockQuantity() %>" step="1" required class="form-control" style="width:65px; padding:4px 6px;">
                                            <button type="submit" class="btn btn-secondary btn-sm" title="Update">↻</button>
                                        </form>
                                    </td>
                                    <td><strong>LKR <%= String.format("%,.2f", item.getSubtotal()) %></strong></td>
                                    <td>
                                        <form action="<%= request.getContextPath() %>/cart" method="post" onsubmit="return confirmAction('Remove this item from your cart?');">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm">Remove</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">&larr; Continue Shopping</a>
                    <form action="<%= request.getContextPath() %>/cart" method="post" onsubmit="return confirmAction('Are you sure you want to clear your entire cart?');">
                        <input type="hidden" name="action" value="clear">
                        <button type="submit" class="btn btn-danger btn-sm">Clear Shopping Cart</button>
                    </form>
                </div>
            </div>

            <!-- Summary Box -->
            <div class="card">
                <h3 class="card-title">Order Summary</h3>

                <!-- Delivery Destination calculation -->
                <form action="<%= request.getContextPath() %>/cart" method="post" style="margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:15px;">
                    <input type="hidden" name="action" value="setPreferences">
                    <label style="font-weight:600; font-size:0.85rem; color:var(--gray-600);">Delivery District (Sri Lanka):</label>
                    <select name="district" id="districtSelect" class="form-control" style="margin:6px 0;" onchange="this.form.submit()">
                        <option value="Colombo" <%= "Colombo".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Colombo (Base: LKR 500)</option>
                        <option value="Gampaha" <%= "Gampaha".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Gampaha (Base: LKR 500)</option>
                        <option value="Kalutara" <%= "Kalutara".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Kalutara (Base: LKR 500)</option>
                        <option value="Kandy" <%= "Kandy".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Kandy (Base: LKR 750)</option>
                        <option value="Galle" <%= "Galle".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Galle (Base: LKR 750)</option>
                        <option value="Matara" <%= "Matara".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Matara (Base: LKR 750)</option>
                        <option value="Kurunegala" <%= "Kurunegala".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Kurunegala (Base: LKR 750)</option>
                        <option value="Jaffna" <%= "Jaffna".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Jaffna (Base: LKR 950)</option>
                        <option value="Batticaloa" <%= "Batticaloa".equalsIgnoreCase(cart.getDistrict()) ? "selected" : "" %>>Batticaloa (Base: LKR 950)</option>
                    </select>

                    <label style="font-weight:600; font-size:0.85rem; color:var(--gray-600); margin-top:8px; display:block;">Shipping Method:</label>
                    <select name="shippingOption" class="form-control" style="margin-top:6px;" onchange="this.form.submit()">
                        <option value="STANDARD_COURIER" <%= "STANDARD_COURIER".equalsIgnoreCase(cart.getShippingOption()) ? "selected" : "" %>>Standard Islandwide Courier</option>
                        <option value="EXPRESS_DOMEX" <%= "EXPRESS_DOMEX".equalsIgnoreCase(cart.getShippingOption()) ? "selected" : "" %>>Express Domex (+LKR 450)</option>
                        <option value="STORE_PICKUP" <%= "STORE_PICKUP".equalsIgnoreCase(cart.getShippingOption()) ? "selected" : "" %>>Store Pickup (Colombo Showroom - FREE)</option>
                    </select>
                </form>

                <!-- Voucher Code Form -->
                <form action="<%= request.getContextPath() %>/cart" method="post" style="margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:15px;">
                    <input type="hidden" name="action" value="applyVoucher">
                    <label style="font-weight:600; font-size:0.85rem; color:var(--gray-600);">Promo Voucher:</label>
                    <div style="display:flex; gap:6px; margin-top:6px;">
                        <input type="text" name="voucherCode" id="voucherCodeInput" class="form-control" placeholder="MELODY10 / AVURUDU15" pattern="^[A-Za-z0-9_-]{3,20}$" maxlength="20" title="Voucher code must be between 3 and 20 alphanumeric characters" value="<%= cart.getVoucherCode() %>">
                        <button type="submit" class="btn btn-secondary btn-sm">Apply</button>
                    </div>
                    <div style="font-size:0.75rem; color:var(--gray-600); margin-top:4px;">Try codes: <code>MELODY10</code>, <code>AVURUDU15</code>, <code>SLIIT2026</code></div>
                </form>

                <!-- Calculations -->
                <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span>Subtotal:</span>
                    <span>LKR <%= String.format("%,.2f", cart.getSubtotal()) %></span>
                </div>
                <% if (cart.getDiscountAmount() > 0) { %>
                    <div style="display:flex; justify-content:space-between; margin-bottom:8px; color:var(--danger);">
                        <span>Voucher Discount (<%= cart.getVoucherCode() %>):</span>
                        <span>-LKR <%= String.format("%,.2f", cart.getDiscountAmount()) %></span>
                    </div>
                <% } %>
                <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
                    <span>Courier Delivery Fee:</span>
                    <span id="deliveryFeeDisplay">LKR <%= String.format("%,.2f", cart.getDeliveryFee()) %></span>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:1.2rem; font-weight:700; color:var(--primary); border-top:2px solid var(--gray-200); padding-top:12px; margin-bottom:20px;">
                    <span>Estimated Total:</span>
                    <span id="grandTotalDisplay">LKR <%= String.format("%,.2f", cart.getGrandTotal()) %></span>
                </div>

                <a href="<%= request.getContextPath() %>/checkout" class="btn btn-primary" style="width:100%; text-align:center; padding:12px; font-size:1rem;">
                    Proceed to Sri Lanka Checkout &rarr;
                </a>
            </div>
        </div>
    <% } %>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>