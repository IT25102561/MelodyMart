<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.Product" %>
<%@ page import="models.Cart" %>
<%@ page import="models.User" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="java.util.List" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<String> categories = (List<String>) request.getAttribute("categories");
    List<String> brands = (List<String>) request.getAttribute("brands");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    String selectedBrand = (String) request.getAttribute("selectedBrand");
    String query = (String) request.getAttribute("query");
    Double minPrice = (Double) request.getAttribute("minPrice");
    Double maxPrice = (Double) request.getAttribute("maxPrice");

    if (products == null) {
        // Fallback if accessed directly without servlet
        dao.ProductDAO pDao = new dao.ProductDAO();
        products = pDao.getAllProducts();
        categories = pDao.getCategories();
        brands = pDao.getBrands();
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
    <title>Musical Instrument Catalog | MelodyMart Sri Lanka</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<div class="top-bar">
    🇱🇰 MelodyMart Catalog - Browse 10 Authentic Musical Instruments with Official Sri Lankan Warranty
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
            <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
            <li><a href="<%= request.getContextPath() %>/products" class="active">Instrument Catalog</a></li>
            <li><a href="<%= request.getContextPath() %>/cart">Cart <span class="cart-badge"><%= cart.getTotalItemCount() %></span></a></li>
            <li><a href="<%= request.getContextPath() %>/track">Track Order</a></li>
            <li><a href="<%= request.getContextPath() %>/returns">Returns & Warranty</a></li>
            <% if (currentUser != null) { %>
                <li><a href="<%= request.getContextPath() %>/user?action=profile">Hi, <%= currentUser.getFullName().split(" ")[0] %></a></li>
                <li><a href="<%= request.getContextPath() %>/user?action=logout">Logout</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/user?action=login">Login</a></li>
            <% } %>
            <li><a href="<%= request.getContextPath() %>/admin" style="background:#fde047; color:#1e293b; padding:4px 8px; border-radius:4px;">Admin</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <div style="margin-bottom: 25px;">
        <h1 style="color:var(--primary);">Instrument Catalog (10 Musical Instruments)</h1>
        <p style="color:var(--gray-600);">Member 2 (IT25102561): Advanced Search, Multi-criteria Filtering & Instrument Comparison</p>
    </div>

    <div class="catalog-layout">
        <!-- Filter Sidebar -->
        <aside class="filter-sidebar">
            <h3>Search & Filters</h3>
            <form action="<%= request.getContextPath() %>/products" method="get">
                <div class="filter-group">
                    <label>Keyword Search</label>
                    <input type="text" name="query" class="form-control" placeholder="Guitar, Flute, Drum..." value="<%= (query != null) ? query : "" %>">
                </div>

                <div class="filter-group">
                    <label>Category</label>
                    <select name="category" class="form-control">
                        <option value="ALL">All Categories</option>
                        <% if (categories != null) { for (String cat : categories) { %>
                            <option value="<%= cat %>" <%= (cat.equalsIgnoreCase(selectedCategory)) ? "selected" : "" %>><%= cat %></option>
                        <% }} %>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Brand</label>
                    <select name="brand" class="form-control">
                        <option value="ALL">All Brands</option>
                        <% if (brands != null) { for (String b : brands) { %>
                            <option value="<%= b %>" <%= (b.equalsIgnoreCase(selectedBrand)) ? "selected" : "" %>><%= b %></option>
                        <% }} %>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Price Range (LKR)</label>
                    <div style="display:flex; gap:8px;">
                        <input type="number" name="minPrice" class="form-control" placeholder="Min" value="<%= (minPrice != null) ? minPrice : "" %>">
                        <input type="number" name="maxPrice" class="form-control" placeholder="Max" value="<%= (maxPrice != null) ? maxPrice : "" %>">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;">Apply Filters</button>
                <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary" style="width:100%; text-align:center; margin-top:8px; display:block;">Reset Filters</a>
            </form>
        </aside>

        <!-- Product Grid Area -->
        <main>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                <div style="font-weight:600; color:var(--gray-600);">Showing <%= products.size() %> Instruments</div>
                <div style="font-size:0.85rem; color:var(--primary);">* Prices include Sri Lankan import duties & local taxes</div>
            </div>

            <% if (products.isEmpty()) { %>
                <div class="card" style="text-align:center; padding:40px;">
                    <h3>No musical instruments found matching your criteria.</h3>
                    <p style="color:var(--gray-600); margin:10px 0 20px;">Try loosening your filters or resetting search keywords.</p>
                    <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">View All Instruments</a>
                </div>
            <% } else { %>
                <div class="product-grid">
                    <% for (Product p : products) { %>
                        <div class="product-card">
                            <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" class="product-image">
                            <div class="product-body">
                                <span class="product-category"><%= p.getCategory() %></span>
                                <h3 class="product-title"><%= p.getName() %></h3>
                                <div class="product-brand">Brand: <strong><%= p.getBrand() %></strong></div>
                                <p style="font-size:0.83rem; color:var(--gray-600); margin-bottom:8px;">
                                    <%= p.getDescription().length() > 85 ? p.getDescription().substring(0, 85) + "..." : p.getDescription() %>
                                </p>

                                <div class="product-price-row">
                                    <span class="price-current">LKR <%= String.format("%,.2f", p.getEffectivePrice()) %></span>
                                    <% if (p.getDiscountPercent() > 0) { %>
                                        <span class="price-original">LKR <%= String.format("%,.2f", p.getPrice()) %></span>
                                        <span class="badge-discount"><%= (int)p.getDiscountPercent() %>% OFF</span>
                                    <% } %>
                                </div>

                                <div>
                                    <% if (p.getStockQuantity() > 5) { %>
                                        <span class="badge-stock badge-in-stock">In Stock (<%= p.getStockQuantity() %> units)</span>
                                    <% } else if (p.getStockQuantity() > 0) { %>
                                        <span class="badge-stock badge-low-stock">Low Stock (<%= p.getStockQuantity() %> left)</span>
                                    <% } else { %>
                                        <span class="badge-stock" style="background:#fee2e2; color:#b91c1c;">Out of Stock</span>
                                    <% } %>
                                </div>

                                <div class="product-actions">
                                    <a href="<%= request.getContextPath() %>/product-detail?id=<%= p.getId() %>" class="btn btn-secondary btn-sm" style="flex:1; text-align:center;">Details</a>
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

                <!-- Member 2: Side-by-Side Instrument Comparison Matrix -->
                <div class="card" style="margin-top:40px; border-top:3px solid var(--primary);">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                        <div>
                            <h3 style="color:var(--primary); margin:0;">Side-by-Side Instrument Comparison Matrix</h3>
                            <p style="color:var(--gray-600); font-size:0.85rem; margin:4px 0 0;">
                                Member 2 (IT25102561): Technical specifications, retail pricing, warranty, and features comparison.
                            </p>
                        </div>
                        <span class="badge badge-active">Live Comparison Matrix</span>
                    </div>

                    <div style="overflow-x:auto;">
                        <table class="data-table" style="font-size:0.85rem; width:100%;">
                            <thead>
                                <tr style="background:#f1f5f9;">
                                    <th style="width:18%;">Feature / Spec</th>
                                    <% int count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <th style="width:20%; text-align:center;">
                                            <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" style="width:70px; height:50px; object-fit:cover; border-radius:4px; display:block; margin:0 auto 6px;">
                                            <strong><%= p.getName() %></strong>
                                        </th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>Category</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center;"><span class="badge" style="background:#e0f2fe; color:#0369a1;"><%= p.getCategory() %></span></td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Brand & Origin</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center;"><strong><%= p.getBrand() %></strong></td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Retail Price (LKR)</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center; color:var(--primary); font-weight:bold;">
                                            LKR <%= String.format("%,.2f", p.getEffectivePrice()) %>
                                            <% if (p.getDiscountPercent() > 0) { %>
                                                <br><small style="color:#16a34a; font-weight:normal;">(<%= (int)p.getDiscountPercent() %>% OFF)</small>
                                            <% } %>
                                        </td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Technical Specs</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center; font-size:0.8rem; color:var(--gray-700);"><%= p.getTechnicalSpecs() %></td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Warranty Policy</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center;"><span class="badge badge-paid"><%= p.getWarrantyPolicy() %></span></td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Stock Status</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center;">
                                            <% if (p.getStockQuantity() > 0) { %>
                                                <span style="color:#16a34a; font-weight:600;">In Stock (<%= p.getStockQuantity() %>)</span>
                                            <% } else { %>
                                                <span style="color:#dc2626; font-weight:600;">Out of Stock</span>
                                            <% } %>
                                        </td>
                                    <% } %>
                                </tr>
                                <tr>
                                    <td><strong>Action</strong></td>
                                    <% count = 0; for (Product p : products) { if (count++ >= 4) break; %>
                                        <td style="text-align:center;">
                                            <a href="<%= request.getContextPath() %>/product-detail?id=<%= p.getId() %>" class="btn btn-secondary btn-sm" style="font-size:0.78rem; padding:3px 8px;">View Details</a>
                                        </td>
                                    <% } %>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            <% } %>
        </main>
    </div>
</div>

<footer>
    <div class="footer-bottom">
        &copy; 2026 MelodyMart - Harmony Lanka Musical Stores (Pvt) Ltd. All rights reserved.
    </div>
</footer>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>