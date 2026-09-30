<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Invoice" %>
<%@ page import="dao.PaymentDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="models.Order" %>
<%@ page import="models.Payment" %>
<%
    Invoice inv = (Invoice) request.getAttribute("invoice");
    if (inv == null) {
        String invNo = request.getParameter("no");
        String orderId = request.getParameter("orderId");
        PaymentDAO paymentDAO = new PaymentDAO();
        if (invNo != null) {
            inv = paymentDAO.getInvoiceByNumber(invNo);
        } else if (orderId != null) {
            inv = paymentDAO.getInvoiceByOrderId(orderId);
            if (inv == null) {
                Order o = new OrderDAO().getOrderById(orderId);
                if (o != null) {
                    Payment p = paymentDAO.getPaymentByOrderId(orderId);
                    inv = paymentDAO.generateInvoice(o, p);
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tax Invoice <%= (inv != null) ? inv.getInvoiceNumber() : "" %> | MelodyMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        @media print {
            header, .no-print, footer { display: none !important; }
            body { background: #fff; }
            .container { max-width: 100%; margin: 0; padding: 0; }
            .card { box-shadow: none; border: none; }
        }
    </style>
</head>
<body>

<header class="no-print">
    <div class="navbar">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/index.jsp"><span>🎵 MelodyMart</span></a>
            <span class="logo-sub">Harmony Lanka Musical Stores</span>
        </div>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/orders">Order History</a></li>
            <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
        </ul>
    </div>
</header>

<div class="container" style="max-width:820px;">
    <div class="no-print" style="margin-bottom:15px; display:flex; justify-content:space-between; align-items:center;">
        <a href="javascript:history.back()" style="color:var(--primary); text-decoration:none;">&larr; Return Back</a>
        <button onclick="window.print()" class="btn btn-primary btn-sm">🖨️ Print / Save as PDF</button>
    </div>

    <% if (inv != null) { %>
        <div class="card" style="padding:35px; border-top:6px solid var(--primary);">
            <!-- Invoice Header -->
            <div style="display:flex; justify-content:space-between; border-bottom:2px solid var(--gray-200); padding-bottom:20px; margin-bottom:25px;">
                <div>
                    <h2 style="color:var(--primary); font-size:1.6rem; margin-bottom:4px;">MelodyMart Sri Lanka</h2>
                    <p style="font-size:0.85rem; color:var(--gray-600); line-height:1.4;">
                        Harmony Lanka Musical Stores (Pvt) Ltd.<br>
                        No. 45, Galle Road, Colombo 03, Sri Lanka<br>
                        VAT Registration No: 11488921-7000<br>
                        Tel: +94 11 284 5678 | Email: billing@melodymart.lk
                    </p>
                </div>
                <div style="text-align:right;">
                    <h3 style="color:var(--gray-800); text-transform:uppercase; letter-spacing:1px;">Official Tax Invoice</h3>
                    <div style="font-weight:700; color:var(--primary); font-size:1.1rem; margin:6px 0;">Invoice #: <%= inv.getInvoiceNumber() %></div>
                    <div style="font-size:0.85rem; color:var(--gray-600);">Order Ref: <strong><%= inv.getOrderId() %></strong></div>
                    <div style="font-size:0.85rem; color:var(--gray-600);">Date: <%= inv.getInvoiceDate() %></div>
                </div>
            </div>

            <!-- Customer & Payment Info -->
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; margin-bottom:25px;">
                <div style="background:#f8fafc; padding:15px; border-radius:var(--radius); font-size:0.88rem;">
                    <strong style="color:var(--primary); display:block; margin-bottom:6px;">Billed To:</strong>
                    <div><%= inv.getCustomerName() %></div>
                    <div>Phone: <%= inv.getCustomerPhone() %></div>
                    <div>Email: <%= inv.getCustomerEmail() %></div>
                    <div>Address: <%= inv.getBillingAddress() %></div>
                </div>
                <div style="background:#f8fafc; padding:15px; border-radius:var(--radius); font-size:0.88rem;">
                    <strong style="color:var(--primary); display:block; margin-bottom:6px;">Payment Information:</strong>
                    <div>Payment Channel: <strong><%= inv.getPaymentMethod() %></strong></div>
                    <div style="margin-top:6px;">Payment Status:
                        <span class="badge badge-<%= inv.getPaymentStatus().toLowerCase() %>"><%= inv.getPaymentStatus() %></span>
                    </div>
                    <div style="margin-top:6px; font-size:0.8rem; color:var(--gray-600);">Verified under Member 4 (IT25101556) e-Billing Engine</div>
                </div>
            </div>

            <!-- Line Items Table -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Item Description & Specifications</th>
                            <th style="text-align:right;">Amount (LKR)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String line : inv.getLineItems()) { %>
                            <tr>
                                <td><%= line %></td>
                                <td style="text-align:right;">Included</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Invoice Totals -->
            <div style="margin-left:auto; width:320px; margin-top:15px; font-size:0.9rem;">
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span>Gross Subtotal:</span>
                    <span>LKR <%= String.format("%,.2f", inv.getSubtotal()) %></span>
                </div>
                <% if (inv.getDiscount() > 0) { %>
                    <div style="display:flex; justify-content:space-between; margin-bottom:6px; color:var(--danger);">
                        <span>Promotional Discount:</span>
                        <span>-LKR <%= String.format("%,.2f", inv.getDiscount()) %></span>
                    </div>
                <% } %>
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span>Courier Delivery Fee:</span>
                    <span>LKR <%= String.format("%,.2f", inv.getDeliveryFee()) %></span>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:0.82rem; color:var(--gray-600);">
                    <span>VAT Included (8%):</span>
                    <span>LKR <%= String.format("%,.2f", inv.getVatAmount()) %></span>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:1.2rem; font-weight:bold; color:var(--primary); border-top:2px solid var(--gray-300); padding-top:8px; margin-top:8px;">
                    <span>Total Amount (LKR):</span>
                    <span>LKR <%= String.format("%,.2f", inv.getTotalAmount()) %></span>
                </div>
            </div>

            <!-- Footer note -->
            <div style="margin-top:35px; border-top:1px solid var(--gray-200); padding-top:15px; font-size:0.78rem; color:var(--gray-600); text-align:center;">
                This is a computer-generated tax invoice issued by MelodyMart. All goods are covered by standard Harmony Lanka warranty terms.
            </div>
        </div>
    <% } else { %>
        <div class="card" style="text-align:center; padding:40px;">
            <h3>Invoice not found.</h3>
            <p style="color:var(--gray-600); margin:10px 0 20px;">Please specify a valid invoice number or order identifier.</p>
            <a href="<%= request.getContextPath() %>/orders" class="btn btn-primary">Return to Orders</a>
        </div>
    <% } %>
</div>

</body>
</html>