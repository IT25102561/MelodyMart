<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Fulfillment" %>
<%@ page import="dao.FulfillmentDAO" %>
<%
    Fulfillment f = (Fulfillment) request.getAttribute("fulfillment");
    String searchedCode = (String) request.getAttribute("searchedCode");

    if (f == null) {
        String trParam = request.getParameter("trackingNumber");
        if (trParam != null && !trParam.trim().isEmpty()) {
            f = new FulfillmentDAO().getFulfillmentByTracking(trParam.trim());
            searchedCode = trParam.trim();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Courier Delivery Tracking | MelodyMart Sri Lanka</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .timeline {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin: 40px 0;
        }
        .timeline::before {
            content: '';
            position: absolute;
            top: 15px;
            left: 5%;
            right: 5%;
            height: 4px;
            background-color: var(--gray-300);
            z-index: 1;
        }
        .step {
            position: relative;
            z-index: 2;
            text-align: center;
            flex: 1;
        }
        .step-circle {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background-color: var(--gray-300);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-weight: bold;
            font-size: 0.85rem;
        }
        .step.active .step-circle {
            background-color: var(--primary);
        }
        .step.done .step-circle {
            background-color: var(--success);
        }
        .step-label {
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--gray-600);
        }
        .step.active .step-label {
            color: var(--primary);
        }
    </style>
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
            <li><a href="<%= request.getContextPath() %>/track" class="active">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/returns">Returns & Warranty</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:800px;">
    <h1 style="color:var(--primary); margin-bottom:8px;">Live Courier Delivery Tracking</h1>
    <p style="color:var(--gray-600); margin-bottom:25px;">Member 6 (IT25100652): Integrated Delivery Lifecycle with Koombiyo, Domex & Pronto</p>

    <!-- Search Box -->
    <div class="card" style="margin-bottom:25px;">
        <form action="<%= request.getContextPath() %>/track" method="get" style="display:flex; gap:10px;">
            <input type="text" name="trackingNumber" class="form-control" placeholder="Enter Tracking # (e.g. KB-COL-998821) or Order ID (ORD-2026-1001)" pattern="^[A-Za-z0-9-]+$" minlength="4" maxlength="35" title="Valid tracking number or Order ID (e.g. KB-COL-998821 or ORD-2026-1001)" value="<%= (searchedCode != null) ? searchedCode : "" %>" required>
            <button type="submit" class="btn btn-primary" style="white-space:nowrap;">Track Package</button>
        </form>
    </div>

    <% if (f != null) {
        String st = f.getDeliveryStatus().toUpperCase();
        int step = 1;
        if ("SHIPPED".equals(st)) step = 2;
        else if ("IN_TRANSIT".equals(st)) step = 3;
        else if ("DELIVERED".equals(st)) step = 4;
    %>
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; border-bottom:1px solid var(--gray-200); padding-bottom:15px;">
                <div>
                    <h3 style="color:var(--gray-800); margin-bottom:4px;">Tracking: <%= f.getTrackingNumber() %></h3>
                    <div style="font-size:0.88rem; color:var(--gray-600);">Order: <strong><%= f.getOrderId() %></strong> | Recipient: <strong><%= f.getCustomerName() %></strong></div>
                </div>
                <span class="badge badge-<%= f.getDeliveryStatus().toLowerCase() %>" style="font-size:0.9rem; padding:6px 12px;">
                    <%= f.getDeliveryStatus() %>
                </span>
            </div>

            <!-- Visual Timeline -->
            <div class="timeline">
                <div class="step <%= step >= 1 ? (step == 1 ? "active" : "done") : "" %>">
                    <div class="step-circle"><%= step > 1 ? "✓" : "1" %></div>
                    <div class="step-label">Processing</div>
                </div>
                <div class="step <%= step >= 2 ? (step == 2 ? "active" : "done") : "" %>">
                    <div class="step-circle"><%= step > 2 ? "✓" : "2" %></div>
                    <div class="step-label">Dispatched</div>
                </div>
                <div class="step <%= step >= 3 ? (step == 3 ? "active" : "done") : "" %>">
                    <div class="step-circle"><%= step > 3 ? "✓" : "3" %></div>
                    <div class="step-label">In Transit</div>
                </div>
                <div class="step <%= step >= 4 ? "done" : "" %>">
                    <div class="step-circle"><%= step == 4 ? "✓" : "4" %></div>
                    <div class="step-label">Delivered</div>
                </div>
            </div>

            <!-- Details List -->
            <div style="background:#f8fafc; padding:20px; border-radius:var(--radius); border:1px solid var(--gray-200); font-size:0.88rem;">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                    <div><strong>Courier Partner:</strong> <%= f.getCourierName() %></div>
                    <div><strong>Dispatched At:</strong> <%= f.getDispatchedAt() %></div>
                    <div><strong>Destination:</strong> <%= f.getShippingAddress() %></div>
                    <div><strong>Delivered At:</strong> <%= f.getDeliveredAt() != null && !f.getDeliveredAt().isEmpty() ? f.getDeliveredAt() : "Pending Courier Handover" %></div>
                    <% if (f.getCodAmount() > 0) { %>
                        <div><strong>COD Amount:</strong> LKR <%= String.format("%,.2f", f.getCodAmount()) %></div>
                        <div><strong>COD Collection:</strong> <%= f.isCodCollected() ? "Collected by Driver" : "Pending Cash Collection" %></div>
                    <% } %>
                </div>
                <div style="margin-top:15px; border-top:1px solid var(--gray-200); padding-top:10px;">
                    <strong>Latest Courier Activity Log:</strong>
                    <div style="color:var(--gray-600); margin-top:4px;">📝 <%= f.getNotes() %></div>
                </div>
            </div>

            <div style="margin-top:20px; display:flex; justify-content:space-between;">
                <a href="<%= request.getContextPath() %>/invoice?orderId=<%= f.getOrderId() %>" class="btn btn-secondary btn-sm">View Tax Invoice</a>
                <a href="<%= request.getContextPath() %>/returns?orderId=<%= f.getOrderId() %>" class="btn btn-secondary btn-sm">Report Delivery Damage / Claim</a>
            </div>
        </div>
    <% } else if (searchedCode != null) { %>
        <div class="card" style="text-align:center; padding:30px;">
            <h3>No delivery record found for "<%= searchedCode %>".</h3>
            <p style="color:var(--gray-600); margin-top:8px;">Please check the tracking number or test with sample: <code>KB-COL-998821</code> or <code>DX-GAL-443312</code>.</p>
        </div>
    <% } %>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>