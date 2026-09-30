package controllers;

import dao.ProductDAO;
import models.Product;
import strategies.product.ProductSortFactory;
import strategies.product.ProductSortStrategy;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 */
@WebServlet(name = "ProductServlet", urlPatterns = {"/products", "/product-detail"})
public class ProductServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/product-detail".equalsIgnoreCase(servletPath)) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Product product = productDAO.getProductById(id);
                    if (product != null) {
                        req.setAttribute("product", product);
                        req.getRequestDispatcher("/product_details.jsp").forward(req, res);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        // Browse / Search / Filter catalog
        String query = req.getParameter("query");
        String category = req.getParameter("category");
        String brand = req.getParameter("brand");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");

        Double minPrice = null;
        Double maxPrice = null;
        try {
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) minPrice = Double.parseDouble(minPriceStr);
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) maxPrice = Double.parseDouble(maxPriceStr);
        } catch (NumberFormatException ignored) {}

        // Strategy Pattern: Resolve product catalog sorting strategy
        String sortBy = req.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = req.getParameter("sort");
        }
        ProductSortStrategy sortStrategy = ProductSortFactory.getStrategy(sortBy);
        List<Product> products = productDAO.searchAndFilter(query, category, brand, minPrice, maxPrice, sortStrategy);

        req.setAttribute("products", products);
        req.setAttribute("categories", productDAO.getCategories());
        req.setAttribute("brands", productDAO.getBrands());
        req.setAttribute("selectedCategory", category);
        req.setAttribute("selectedBrand", brand);
        req.setAttribute("query", query);
        req.setAttribute("minPrice", minPrice);
        req.setAttribute("maxPrice", maxPrice);
        req.setAttribute("selectedSort", (sortBy != null && !sortBy.trim().isEmpty()) ? sortBy : "default");
        req.setAttribute("activeSortStrategy", sortStrategy.getStrategyName());

        req.getRequestDispatcher("/catalog.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("addProduct".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String category = req.getParameter("category");
                String brand = req.getParameter("brand");
                double price;
                double discount = 0.0;
                int stock = 0;
                try {
                    price = Double.parseDouble(req.getParameter("price"));
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_PRICE: Product retail price must be a valid positive number.");
                }
                try {
                    String dStr = req.getParameter("discountPercent");
                    if (dStr != null && !dStr.trim().isEmpty()) discount = Double.parseDouble(dStr);
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_DISCOUNT: Promotional discount percentage must be a valid number between 0% and 100%.");
                }
                try {
                    String sStr = req.getParameter("stockQuantity");
                    if (sStr != null && !sStr.trim().isEmpty()) stock = Integer.parseInt(sStr);
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_STOCK: Stock quantity must be a valid integer.");
                }
                String description = req.getParameter("description");
                String technicalSpecs = req.getParameter("technicalSpecs");
                String warrantyPolicy = req.getParameter("warrantyPolicy");
                String imageUrl = req.getParameter("imageUrl");

                utils.ValidationUtil.validateProductName(name);
                utils.ValidationUtil.validateBrand(brand);
                utils.ValidationUtil.validateProductPrice(price);
                utils.ValidationUtil.validateProductDiscount(discount);
                utils.ValidationUtil.validateProductStock(stock);
                utils.ValidationUtil.validateWarranty(warrantyPolicy);
                if (description == null || description.trim().length() < 5) {
                    throw new Exception("ERR_PROD_INVALID_NAME: Product description must be at least 5 characters.");
                }

                int wYears = Integer.parseInt(warrantyPolicy.trim());
                String formattedWarranty = (wYears == 0) ? "No Warranty" : (wYears == 1 ? "1 Year Warranty" : wYears + " Years Warranty");

                productDAO.addProduct(name, category, brand, price, discount, description, technicalSpecs, formattedWarranty, imageUrl, stock);
                res.sendRedirect(req.getContextPath() + "/admin?tab=products&msg=product_added");

            } else if ("updateProduct".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String name = req.getParameter("name");
                String category = req.getParameter("category");
                String brand = req.getParameter("brand");
                double price;
                double discount = 0.0;
                int stock = 0;
                try {
                    price = Double.parseDouble(req.getParameter("price"));
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_PRICE: Product retail price must be a valid positive number.");
                }
                try {
                    String dStr = req.getParameter("discountPercent");
                    if (dStr != null && !dStr.trim().isEmpty()) discount = Double.parseDouble(dStr);
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_DISCOUNT: Promotional discount percentage must be a valid number between 0% and 100%.");
                }
                try {
                    String sStr = req.getParameter("stockQuantity");
                    if (sStr != null && !sStr.trim().isEmpty()) stock = Integer.parseInt(sStr);
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_STOCK: Stock quantity must be a valid integer.");
                }
                String description = req.getParameter("description");
                String technicalSpecs = req.getParameter("technicalSpecs");
                String warrantyPolicy = req.getParameter("warrantyPolicy");
                String imageUrl = req.getParameter("imageUrl");

                utils.ValidationUtil.validateProductName(name);
                utils.ValidationUtil.validateBrand(brand);
                utils.ValidationUtil.validateProductPrice(price);
                utils.ValidationUtil.validateProductDiscount(discount);
                utils.ValidationUtil.validateProductStock(stock);
                utils.ValidationUtil.validateWarranty(warrantyPolicy);
                if (description == null || description.trim().length() < 5) {
                    throw new Exception("ERR_PROD_INVALID_NAME: Product description must be at least 5 characters.");
                }

                int wYears = Integer.parseInt(warrantyPolicy.trim());
                String formattedWarranty = (wYears == 0) ? "No Warranty" : (wYears == 1 ? "1 Year Warranty" : wYears + " Years Warranty");

                productDAO.updateProduct(id, name, category, brand, price, discount, description, technicalSpecs, formattedWarranty, imageUrl, stock);
                String returnTab = req.getParameter("returnTab");
                if (returnTab == null || returnTab.trim().isEmpty()) returnTab = "products";
                res.sendRedirect(req.getContextPath() + "/admin?tab=" + returnTab + "&msg=product_updated");

            } else if ("restoreProduct".equalsIgnoreCase(action)) {
                // [DELETE / RESTORE] Restore archived/delisted products to active catalog
                int id = Integer.parseInt(req.getParameter("id"));
                productDAO.restoreProduct(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=products&msg=product_restored");

            } else if ("delistProduct".equalsIgnoreCase(action) || "archiveProduct".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                productDAO.softDeleteProduct(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=products&msg=product_delisted");

            } else if ("deleteProduct".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                productDAO.deleteProduct(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=products&msg=product_deleted");

            } else {
                res.sendRedirect(req.getContextPath() + "/products");
            }
        } catch (Exception ex) {
            String returnTab = req.getParameter("returnTab");
            if (returnTab == null || returnTab.trim().isEmpty()) returnTab = "products";
            req.getSession().setAttribute("errorMessage", ex.getMessage());
            res.sendRedirect(req.getContextPath() + "/admin?tab=" + returnTab);
        }
    }
}
