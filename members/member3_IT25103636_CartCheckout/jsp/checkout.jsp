<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Cart" %>
<%@ page import="models.CartItem" %>
<%@ page import="models.User" %>
<%@ page import="models.Address" %>
<%
    Cart cart = (Cart) request.getAttribute("cart");
    if (cart == null) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }
    User user = (User) request.getAttribute("user");
    Address primaryAddr = null;
    if (user != null && user.getAddresses() != null) {
        for (Address a : user.getAddresses()) {
            if (a.isPrimary()) { primaryAddr = a; break; }
        }
        if (primaryAddr == null && !user.getAddresses().isEmpty()) {
            primaryAddr = user.getAddresses().get(0);
        }
    }
    String error = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/cart">&larr; Back to Cart</a></li>
            <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <h1 style="color:var(--primary); margin-bottom:8px;">Secure Sri Lanka Checkout</h1>
    <p style="color:var(--gray-600); margin-bottom:25px;">Orders are immediately registered, saved to <code>orders.txt</code>, and assigned a courier tracking code.</p>

    <% if (error != null) { %>
        <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/checkout" method="post">
        <div style="display:grid; grid-template-columns: 3fr 2fr; gap:30px; align-items:start;">
            <div>
                <!-- Section 1: Customer & Delivery Address -->
                <div class="card">
                    <h3 class="card-title">1. Recipient & Delivery Information</h3>
                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                        <div>
                            <label style="font-weight:600; font-size:0.85rem;">Full Name *</label>
                            <input type="text" name="customerName" required class="form-control" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Full name must contain letters and spaces only (minimum 2 characters)" value="<%= (user != null) ? user.getFullName() : "Amila Silva" %>">
                        </div>
                        <div>
                            <label style="font-weight:600; font-size:0.85rem;">Contact Phone (Sri Lanka 07X) *</label>
                            <input type="text" name="phone" required class="form-control" placeholder="0771234567" pattern="^(?:0|\+94)?7[0-9]{8}$" maxlength="12" inputmode="tel" title="Valid Sri Lankan mobile: 07XXXXXXXX or +947XXXXXXXX" value="<%= (user != null) ? user.getPhone() : "0778899001" %>">
                        </div>
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-weight:600; font-size:0.85rem;">Email Address *</label>
                        <input type="email" name="email" required class="form-control" maxlength="100" value="<%= (user != null) ? user.getEmail() : "amila.silva@gmail.com" %>">
                    </div>

                    <div style="margin-bottom:12px;">
                        <label style="font-weight:600; font-size:0.85rem;">Street Address *</label>
                        <input type="text" name="shippingAddress" required class="form-control" minlength="5" maxlength="200" placeholder="No. 12/A, Station Road" value="<%= (primaryAddr != null) ? primaryAddr.getStreet() : "12/A, Kandy Road" %>">
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:12px;">
                        <div>
                            <label style="font-weight:600; font-size:0.85rem;">City / Town *</label>
                            <input type="text" name="city" required class="form-control" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="50" placeholder="Kadawatha" title="Valid city name" value="<%= (primaryAddr != null) ? primaryAddr.getCity() : "Kadawatha" %>">
                        </div>
                        <div>
                            <label style="font-weight:600; font-size:0.85rem;">District *</label>
                            <select name="district" id="districtSelect" class="form-control">
                                <option value="Colombo" <%= (primaryAddr != null && "Colombo".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Colombo</option>
                                <option value="Gampaha" <%= (primaryAddr != null && "Gampaha".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "selected" %>>Gampaha</option>
                                <option value="Kalutara" <%= (primaryAddr != null && "Kalutara".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Kalutara</option>
                                <option value="Kandy" <%= (primaryAddr != null && "Kandy".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Kandy</option>
                                <option value="Galle" <%= (primaryAddr != null && "Galle".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Galle</option>
                                <option value="Matara" <%= (primaryAddr != null && "Matara".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Matara</option>
                                <option value="Kurunegala" <%= (primaryAddr != null && "Kurunegala".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Kurunegala</option>
                                <option value="Jaffna" <%= (primaryAddr != null && "Jaffna".equalsIgnoreCase(primaryAddr.getDistrict())) ? "selected" : "" %>>Jaffna</option>
                            </select>
                        </div>
                        <div>
                            <label style="font-weight:600; font-size:0.85rem;">Postal Code *</label>
                            <input type="text" name="postalCode" required class="form-control" pattern="^[0-9]{5}$" maxlength="5" inputmode="numeric" placeholder="10115" title="5-digit postal code (e.g. 10115)" value="<%= (primaryAddr != null && primaryAddr.getPostalCode() != null) ? primaryAddr.getPostalCode() : "11850" %>">
                        </div>
                    </div>
                </div>

                <!-- Section 2: Partner Courier Selection -->
                <div class="card">
                    <h3 class="card-title">2. Sri Lankan Courier Partner (Member 6)</h3>
                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:12px;">
                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:block;">
                            <input type="radio" name="courierName" value="Koombiyo Delivery" checked>
                            <strong>Koombiyo</strong>
                            <div style="font-size:0.78rem; color:var(--gray-600); margin-top:4px;">1-2 Business Days (Islandwide network)</div>
                        </label>
                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:block;">
                            <input type="radio" name="courierName" value="Domex Courier">
                            <strong>Domex</strong>
                            <div style="font-size:0.78rem; color:var(--gray-600); margin-top:4px;">Next-Day Express Dispatch</div>
                        </label>
                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:block;">
                            <input type="radio" name="courierName" value="Pronto Logistics">
                            <strong>Pronto</strong>
                            <div style="font-size:0.78rem; color:var(--gray-600); margin-top:4px;">Standard Heavy Gear Courier</div>
                        </label>
                    </div>
                </div>

                <!-- Section 3: Payment Channel Selection -->
                <div class="card">
                    <h3 class="card-title">3. Payment Channel (Member 4)</h3>
                    <div style="display:flex; flex-direction:column; gap:10px;">
                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:flex; align-items:center; gap:10px;">
                            <input type="radio" name="paymentMethod" value="CREDIT_CARD" checked>
                            <div>
                                <strong>Credit / Debit Card (Visa / MasterCard)</strong>
                                <div style="font-size:0.78rem; color:var(--gray-600);">Instant confirmation via secure online gateway simulator</div>
                            </div>
                        </label>

                        <div id="cardDetailsBox" style="background:#f0f9ff; border:1px solid #bae6fd; padding:12px; border-radius:var(--radius); font-size:0.85rem;">
                            <strong style="color:#0369a1;">Card Details (Member 4 Gateway Simulator):</strong>
                            <div style="margin-top:8px;">
                                <label style="font-weight:600; font-size:0.8rem;">16-Digit Card Number *</label>
                                <input type="text" name="cardNumber" id="cardNumberInput" class="form-control" placeholder="4532 0150 8821 9934" pattern="[0-9\s]{16,19}" maxlength="19" inputmode="numeric" title="16-digit card number" value="4532 0150 8821 9934">
                            </div>
                            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-top:8px;">
                                <div>
                                    <label style="font-weight:600; font-size:0.8rem;">Expiry (MM/YY) *</label>
                                    <input type="text" name="cardExpiry" id="cardExpiryInput" class="form-control" placeholder="12/28" pattern="(0[1-9]|1[0-2])\/[0-9]{2}" maxlength="5" title="Expiry date in MM/YY format" value="12/28">
                                </div>
                                <div>
                                    <label style="font-weight:600; font-size:0.8rem;">CVV / CVC (3-4 digits) *</label>
                                    <input type="text" name="cardCvv" id="cardCvvInput" class="form-control" placeholder="789" pattern="[0-9]{3,4}" maxlength="4" inputmode="numeric" title="3 or 4 digit CVV" value="789">
                                </div>
                            </div>
                        </div>

                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:flex; align-items:center; gap:10px;">
                            <input type="radio" name="paymentMethod" value="BANK_TRANSFER">
                            <div>
                                <strong>Direct Bank Transfer / CDM Slip</strong>
                                <div style="font-size:0.78rem; color:var(--gray-600);">Bank of Ceylon (BOC) / Commercial Bank / Sampath Bank</div>
                            </div>
                        </label>

                        <div id="bankDetailsBox" style="display:none; background:#fefce8; border:1px solid #fef08a; padding:12px; border-radius:var(--radius); font-size:0.85rem;">
                            <strong>MelodyMart Bank Account Details:</strong><br>
                            - Bank: Commercial Bank of Ceylon | Kollupitiya Branch<br>
                            - Account Name: Harmony Lanka Musical Stores (Pvt) Ltd<br>
                            - Account Number: 1000 8829 4410<br>
                            <label style="display:block; margin-top:8px; font-weight:600;">Deposit Slip Reference / File Name:</label>
                            <input type="text" name="bankSlipUrl" class="form-control" placeholder="slip_deposit_receipt.jpg" pattern="^[A-Za-z0-9._-]+\.(jpg|jpeg|png|pdf)$" title="Valid receipt file name (e.g. slip_deposit.jpg or receipt.pdf)">
                        </div>

                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:flex; align-items:center; gap:10px;">
                            <input type="radio" name="paymentMethod" value="DIGITAL_WALLET">
                            <div>
                                <strong>Sri Lankan Digital Wallet (FriMi / eZ Cash / Genie)</strong>
                                <div style="font-size:0.78rem; color:var(--gray-600);">QR payment scan and wallet push notification</div>
                            </div>
                        </label>

                        <label style="border:1px solid var(--gray-300); padding:12px; border-radius:var(--radius); cursor:pointer; display:flex; align-items:center; gap:10px;">
                            <input type="radio" name="paymentMethod" value="COD">
                            <div>
                                <strong>Cash on Delivery (COD)</strong>
                                <div style="font-size:0.78rem; color:var(--gray-600);">Pay cash directly to the courier agent upon receiving your instrument</div>
                            </div>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Order Review Sidebar -->
            <div class="card" style="position:sticky; top:80px;">
                <h3 class="card-title">Order Items (<%= cart.getItems().size() %>)</h3>

                <input type="hidden" id="cartSubtotalHidden" value="<%= cart.getSubtotal() %>">
                <input type="hidden" id="cartDiscountHidden" value="<%= cart.getDiscountAmount() %>">

                <div style="max-height:240px; overflow-y:auto; margin-bottom:15px; border-bottom:1px solid var(--gray-200); padding-bottom:10px;">
                    <% for (CartItem item : cart.getItems()) { %>
                        <div style="display:flex; justify-content:space-between; margin-bottom:8px; font-size:0.85rem;">
                            <span><%= item.getProduct().getName() %> <strong>x<%= item.getQuantity() %></strong></span>
                            <span>LKR <%= String.format("%,.2f", item.getSubtotal()) %></span>
                        </div>
                    <% } %>
                </div>

                <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:0.9rem;">
                    <span>Subtotal:</span>
                    <span>LKR <%= String.format("%,.2f", cart.getSubtotal()) %></span>
                </div>
                <% if (cart.getDiscountAmount() > 0) { %>
                    <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:0.9rem; color:var(--danger);">
                        <span>Voucher Discount:</span>
                        <span>-LKR <%= String.format("%,.2f", cart.getDiscountAmount()) %></span>
                    </div>
                <% } %>
                <div style="display:flex; justify-content:space-between; margin-bottom:12px; font-size:0.9rem;">
                    <span>Courier Delivery Fee:</span>
                    <span id="deliveryFeeDisplay">LKR <%= String.format("%,.2f", cart.getDeliveryFee()) %></span>
                </div>

                <div style="display:flex; justify-content:space-between; font-size:1.25rem; font-weight:700; color:var(--primary); border-top:2px solid var(--gray-200); padding-top:12px; margin-bottom:20px;">
                    <span>Net Total:</span>
                    <span id="grandTotalDisplay">LKR <%= String.format("%,.2f", cart.getGrandTotal()) %></span>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%; padding:14px; font-size:1.05rem; font-weight:700;">
                    Confirm & Save Order Now
                </button>

                <p style="font-size:0.75rem; color:var(--gray-600); text-align:center; margin-top:12px;">
                    🔒 By confirming, your order will be persistently recorded to <code>orders.txt</code> and the official MelodyMart sales registry.
                </p>
            </div>
        </div>
    </form>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>