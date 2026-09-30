<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.ReturnRequest" %>
<%@ page import="dao.FulfillmentDAO" %>
<%
    ReturnRequest r = (ReturnRequest) request.getAttribute("returnRequest");
    String ticketId = request.getParameter("ticketId");
    String msg = request.getParameter("msg");
    String err = (String) request.getAttribute("errorMessage");
    if (r == null && ticketId != null && !ticketId.trim().isEmpty()) {
        r = new FulfillmentDAO().getReturnById(ticketId.trim());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Returns & Warranty Claims | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/returns" class="active">Returns & Warranty</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:850px;">
    <h1 style="color:var(--primary); margin-bottom:6px;">Returns & Warranty Claim Services</h1>
    <p style="color:var(--gray-600); margin-bottom:25px;">Member 6 (IT25100652): 7-Day Replacement Guarantee & Official Service Support across Sri Lanka</p>

    <% if (err != null) { %>
        <div class="alert alert-danger" style="border-left:4px solid #ef4444; padding:12px; margin-bottom:15px; border-radius:4px; background:#fef2f2; color:#b91c1c; font-size:0.9rem;">
            <strong>⚠️ Error:</strong> <%= err %>
        </div>
    <% } %>
    <% if ("return_submitted".equals(msg)) { %>
        <div class="alert alert-success">Your return/warranty claim ticket has been generated successfully! Our inspection officer will contact you.</div>
    <% } %>

    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:25px; align-items:start;">
        <!-- Submit Ticket Form -->
        <div class="card">
            <h3 class="card-title">Submit New Claim Ticket</h3>
            <form action="<%= request.getContextPath() %>/fulfillment" method="post">
                <input type="hidden" name="action" value="submitReturn">

                <div style="margin-bottom:12px;">
                    <label style="font-weight:600; font-size:0.85rem;">Order Identifier *</label>
                    <input type="text" name="orderId" required class="form-control" placeholder="e.g. ORD-2026-1001" pattern="^[A-Za-z0-9-]+$" minlength="5" maxlength="30" title="Valid Order ID (e.g. ORD-2026-1001)" value="<%= request.getParameter("orderId") != null ? request.getParameter("orderId") : "" %>">
                </div>

                <div style="margin-bottom:12px;">
                    <label style="font-weight:600; font-size:0.85rem;">Customer Name *</label>
                    <input type="text" name="customerName" required class="form-control" placeholder="Amila Silva" pattern="^[A-Za-z\s.'-]+$" minlength="2" maxlength="100" title="Letters and spaces only (minimum 2 characters)">
                </div>

                <div style="margin-bottom:12px;">
                    <label style="font-weight:600; font-size:0.85rem;">Email Address *</label>
                    <input type="email" name="email" required class="form-control" placeholder="customer@example.lk" maxlength="100">
                </div>

                <div style="margin-bottom:12px;">
                    <label style="font-weight:600; font-size:0.85rem;">Reason for Claim *</label>
                    <select name="reason" required class="form-control">
                        <option value="DEFECTIVE_ON_ARRIVAL">Defective on Arrival (Out of Box failure)</option>
                        <option value="TRANSIT_DAMAGE">Damaged during Courier Transit</option>
                        <option value="SOUND_DEFECT">Acoustic / Electronics Sound Defect</option>
                        <option value="WRONG_ITEM_RECEIVED">Wrong Instrument Model Delivered</option>
                    </select>
                </div>

                <div style="margin-bottom:15px;">
                    <label style="font-weight:600; font-size:0.85rem;">Item Details & Issue Description *</label>
                    <textarea name="itemDetails" required class="form-control" rows="3" minlength="5" maxlength="500" placeholder="Describe serial number, string buzzing, crack, or missing accessories..."></textarea>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;">Submit Claim Ticket</button>
            </form>
        </div>

        <!-- Lookup Ticket & Status -->
        <div>
            <div class="card" style="margin-bottom:20px;">
                <h3 class="card-title">Track Claim Ticket Status</h3>
                <form action="<%= request.getContextPath() %>/returns" method="get" style="display:flex; gap:8px;">
                    <input type="text" name="ticketId" class="form-control" placeholder="Ticket ID (e.g. RET-2026-051)" pattern="^[A-Za-z0-9-]+$" minlength="5" maxlength="30" title="Valid Ticket ID (e.g. RET-2026-051)" value="<%= ticketId != null ? ticketId : "" %>" required>
                    <button type="submit" class="btn btn-secondary">Search</button>
                </form>
            </div>

            <% if (r != null) { %>
                <div class="card">
                    <h3 style="color:var(--gray-800); margin-bottom:6px;">Ticket: <%= r.getTicketId() %></h3>
                    <div style="font-size:0.85rem; color:var(--gray-600); margin-bottom:12px;">Order Ref: <strong><%= r.getOrderId() %></strong> | <%= r.getCreatedAt() %></div>

                    <div style="background:#f8fafc; padding:12px; border-radius:var(--radius); margin-bottom:12px; font-size:0.88rem;">
                        <div><strong>Reason:</strong> <%= r.getReason() %></div>
                        <div style="margin-top:4px;"><strong>Details:</strong> <%= r.getItemDetails() %></div>
                    </div>

                    <div style="margin-bottom:12px;">
                        <span style="font-weight:600; font-size:0.88rem;">Current Stage:</span>
                        <span class="badge badge-<%= r.getStage().toLowerCase() %>" style="font-size:0.85rem; margin-left:6px;"><%= r.getStage() %></span>
                    </div>

                    <div style="font-size:0.85rem; color:var(--gray-600);">
                        <strong>Support Officer Resolution Notes:</strong>
                        <p style="margin-top:4px; font-style:italic; background:#fffbeb; padding:8px; border-radius:4px; border:1px solid #fef08a;"><%= r.getResolutionNotes() %></p>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>