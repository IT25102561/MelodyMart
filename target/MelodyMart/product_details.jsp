<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Product" %>
<%@ page import="models.Cart" %>
<%@ page import="models.User" %>
<%@ page import="dao.CartDAO" %>
<%
    Product p = (Product) request.getAttribute("product");
    if (p == null) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            p = new dao.ProductDAO().getProductById(Integer.parseInt(idStr));
        }
    }
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/products");
        return;
    }
    CartDAO cartDAO = new CartDAO();
    Cart cart = cartDAO.getCart(session);
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= p.getName() %> | MelodyMart Sri Lanka</title>
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
            <li><a href="<%= request.getContextPath() %>/products" class="active">Instrument Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/cart">Cart <span class="cart-badge"><%= cart.getTotalItemCount() %></span></a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <p style="margin-bottom: 15px;"><a href="<%= request.getContextPath() %>/products" style="color:var(--primary); text-decoration:none;">&larr; Back to Instruments Catalog</a></p>

    <div class="card" style="display:grid; grid-template-columns: 1fr 1fr; gap:35px; align-items:start;">
        <div>
            <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" style="width:100%; border-radius:var(--radius); object-fit:cover; max-height:420px; box-shadow:var(--shadow);">
        </div>
        <div>
            <span class="product-category"><%= p.getCategory() %></span>
            <h1 style="color:var(--gray-800); font-size:1.8rem; margin:8px 0 12px;"><%= p.getName() %></h1>
            <p style="color:var(--gray-600); font-size:0.9rem; margin-bottom:15px;">
                Brand: <strong><%= p.getBrand() %></strong> | Item Code: <strong><%= p.getCode() %></strong>
            </p>

            <div style="background:#f8fafc; padding:15px; border-radius:var(--radius); border:1px solid var(--gray-200); margin-bottom:20px;">
                <div style="display:flex; align-items:baseline; gap:12px;">
                    <span class="price-current" style="font-size:1.8rem;">LKR <%= String.format("%,.2f", p.getEffectivePrice()) %></span>
                    <% if (p.getDiscountPercent() > 0) { %>
                        <span class="price-original" style="font-size:1.1rem;">LKR <%= String.format("%,.2f", p.getPrice()) %></span>
                        <span class="badge-discount" style="font-size:0.85rem;"><%= (int)p.getDiscountPercent() %>% OFF SAVINGS</span>
                    <% } %>
                </div>
                <div style="margin-top:8px; font-size:0.85rem; color:var(--gray-600);">
                    Status:
                    <% if (p.getStockQuantity() > 0) { %>
                        <span style="color:var(--success); font-weight:bold;">In Stock (<%= p.getStockQuantity() %> units available at Colombo Central Warehouse)</span>
                    <% } else { %>
                        <span style="color:var(--danger); font-weight:bold;">Currently Out of Stock</span>
                    <% } %>
                </div>
            </div>

            <p style="margin-bottom:20px; color:var(--gray-800);"><%= p.getDescription() %></p>

            <form action="<%= request.getContextPath() %>/cart" method="post" style="display:flex; gap:12px; align-items:center; margin-bottom:25px;">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <label style="font-weight:600;">Quantity:</label>
                <input type="number" name="quantity" value="1" min="1" max="<%= Math.max(1, p.getStockQuantity()) %>" class="form-control" style="width:80px; text-align:center;">
                <button type="submit" class="btn btn-primary" style="padding:10px 24px; font-size:1rem;" <%= p.getStockQuantity() <= 0 ? "disabled" : "" %>>
                    Add to Shopping Cart
                </button>
            </form>

            <div style="border-top:1px solid var(--gray-200); padding-top:16px;">
                <h4 style="margin-bottom:6px; color:var(--primary);">Technical Specifications</h4>
                <p style="font-size:0.88rem; color:var(--gray-600); background:#f1f5f9; padding:10px; border-radius:6px;"><%= p.getTechnicalSpecs() %></p>
            </div>

            <div style="margin-top:16px;">
                <h4 style="margin-bottom:6px; color:var(--primary);">Warranty & Protection in Sri Lanka</h4>
                <p style="font-size:0.88rem; color:var(--gray-600);">🛡️ <%= p.getWarrantyPolicy() %></p>
            </div>

            <div style="margin-top:20px; padding:12px 16px; background:#fef3c7; border:1px solid #fde047; border-radius:var(--radius); display:flex; justify-content:space-between; align-items:center;">
                <span style="font-size:0.85rem; color:#854d0e; font-weight:600;">🛠️ Admin / Member 2/3 Action:</span>
                <a href="<%= request.getContextPath() %>/admin?tab=products" class="btn btn-warning btn-sm">Edit Instrument in Admin Portal</a>
            </div>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>