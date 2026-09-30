package dao;

import models.Product;
import strategies.product.ProductSortStrategy;
import utils.DatabaseUtil;
import utils.FileStorageUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 */
public class ProductDAO {
    private static final Map<Integer, Product> productStore = new ConcurrentHashMap<>();
    private static final AtomicInteger productIdCounter = new AtomicInteger(10);

    static {
        loadProductsFromDatabase();
    }

    public static synchronized void loadProductsFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT id, code, name, category, brand, price, discount_percent, description, technical_specs, warranty_policy, image_url, stock_quantity, display_order, is_archived FROM products ORDER BY display_order ASC")) {

            int maxId = 10;
            productStore.clear();

            while (rs.next()) {
                int id = rs.getInt("id");
                String code = rs.getString("code");
                String name = rs.getString("name");
                String category = rs.getString("category");
                String brand = rs.getString("brand");
                double price = rs.getDouble("price");
                double discount = rs.getDouble("discount_percent");
                String desc = rs.getString("description");
                String specs = rs.getString("technical_specs");
                String warranty = rs.getString("warranty_policy");
                String img = rs.getString("image_url");
                int stock = rs.getInt("stock_quantity");
                int displayOrder = rs.getInt("display_order");
                boolean archived = rs.getInt("is_archived") == 1;

                Product p = new Product(id, code, name, category, brand, price, discount, desc, specs, warranty, img, stock, displayOrder, archived);
                productStore.put(id, p);
                if (id > maxId) maxId = id;
            }

            productIdCounter.set(maxId);
            System.out.println("[ProductDAO] Successfully loaded " + productStore.size() + " products from database.");

        } catch (Exception ex) {
            System.err.println("[ProductDAO] Warning loading products from DB: " + ex.getMessage());
        }
    }

    // ==========================================
    // CREATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public Product addProduct(String name, String category, String brand, double price,
                              double discountPercent, String description, String technicalSpecs,
                              String warrantyPolicy, String imageUrl, int stock) throws Exception {
        utils.ValidationUtil.validateProductName(name);
        utils.ValidationUtil.validateProductPrice(price);
        utils.ValidationUtil.validateProductDiscount(discountPercent);
        utils.ValidationUtil.validateProductStock(stock);

        int newId = productIdCounter.incrementAndGet();
        String catCode = (category != null && category.length() >= 3) ? category.substring(0, 3).toUpperCase() : "GEN";
        String code = "MM-" + catCode + "-" + String.format("%03d", newId);

        String sql = "INSERT INTO products (code, name, category, brand, price, discount_percent, description, technical_specs, warranty_policy, image_url, stock_quantity, display_order, is_archived) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, code);
            ps.setString(2, name.trim());
            ps.setString(3, category != null ? category.trim() : "Musical Instruments");
            ps.setString(4, brand != null ? brand.trim() : "Harmony Lanka");
            ps.setDouble(5, price);
            ps.setDouble(6, discountPercent);
            ps.setString(7, description != null ? description.trim() : "");
            ps.setString(8, technicalSpecs != null ? technicalSpecs.trim() : "");
            ps.setString(9, warrantyPolicy != null ? warrantyPolicy.trim() : "1 Year Warranty");
            ps.setString(10, imageUrl != null ? imageUrl.trim() : "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80");
            ps.setInt(11, stock);
            ps.setInt(12, newId);

            ps.executeUpdate();

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    newId = generatedKeys.getInt(1);
                }
            } catch (Exception ignored) {}

        } catch (Exception ex) {
            System.err.println("[ProductDAO] Database insertion error: " + ex.getMessage());
        }

        Product p = new Product(newId, code, name.trim(), category, brand, price, discountPercent,
                description, technicalSpecs, warrantyPolicy, imageUrl, stock, newId, false);
        productStore.put(newId, p);

        // Also append product summary to products.txt for record keeping
        try {
            String logLine = "ID: #" + newId + " | Code: " + code + " | Name: " + name + " | Category: " + category + " | Price: LKR " + price + " | Stock: " + stock;
            FileStorageUtil.appendOrder(logLine);
        } catch (Exception ignored) {}

        return p;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public Product getProductById(int id) {
        Product p = productStore.get(id);
        if (p != null && !p.isArchived()) {
            return p;
        }
        return null;
    }

    public Product getProductByIdAdmin(int id) {
        return productStore.get(id);
    }

    public List<Product> getAllProducts() {
        return productStore.values().stream()
                .filter(p -> !p.isArchived())
                .sorted(Comparator.comparingInt(Product::getDisplayOrder))
                .collect(Collectors.toList());
    }

    public List<Product> getAllProductsAdmin() {
        return productStore.values().stream()
                .sorted(Comparator.comparingInt(Product::getId))
                .collect(Collectors.toList());
    }

    public List<Product> searchAndFilter(String query, String category, String brand, Double minPrice, Double maxPrice) {
        return productStore.values().stream()
                .filter(p -> !p.isArchived())
                .filter(p -> {
                    if (query != null && !query.trim().isEmpty()) {
                        String q = query.toLowerCase().trim();
                        boolean matchName = p.getName().toLowerCase().contains(q);
                        boolean matchBrand = p.getBrand().toLowerCase().contains(q);
                        boolean matchCategory = p.getCategory().toLowerCase().contains(q);
                        boolean matchDesc = p.getDescription().toLowerCase().contains(q);
                        if (!matchName && !matchBrand && !matchCategory && !matchDesc) return false;
                    }
                    if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
                        if (!p.getCategory().equalsIgnoreCase(category.trim())) return false;
                    }
                    if (brand != null && !brand.trim().isEmpty() && !"ALL".equalsIgnoreCase(brand)) {
                        if (!p.getBrand().equalsIgnoreCase(brand.trim())) return false;
                    }
                    if (minPrice != null && p.getEffectivePrice() < minPrice) return false;
                    if (maxPrice != null && maxPrice > 0 && p.getEffectivePrice() > maxPrice) return false;
                    return true;
                })
                .sorted(Comparator.comparingInt(Product::getDisplayOrder))
                .collect(Collectors.toList());
    }

    public List<Product> getAllProducts(ProductSortStrategy strategy) {
        List<Product> list = getAllProducts();
        return (strategy != null) ? strategy.sort(list) : list;
    }

    public List<Product> searchAndFilter(String query, String category, String brand, Double minPrice, Double maxPrice, ProductSortStrategy strategy) {
        List<Product> list = searchAndFilter(query, category, brand, minPrice, maxPrice);
        return (strategy != null) ? strategy.sort(list) : list;
    }

    public List<String> getCategories() {
        return productStore.values().stream()
                .filter(p -> !p.isArchived())
                .map(Product::getCategory)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    public List<String> getBrands() {
        return productStore.values().stream()
                .filter(p -> !p.isArchived())
                .map(Product::getBrand)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    // ==========================================
    // UPDATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean updateProduct(int id, String name, String category, String brand,
                                 double price, double discountPercent, String description,
                                 String technicalSpecs, String warrantyPolicy, String imageUrl,
                                 int stock) throws Exception {
        utils.ValidationUtil.validateProductName(name);
        utils.ValidationUtil.validateProductPrice(price);
        utils.ValidationUtil.validateProductDiscount(discountPercent);
        utils.ValidationUtil.validateProductStock(stock);

        String sql = "UPDATE products SET name=?, category=?, brand=?, price=?, discount_percent=?, description=?, technical_specs=?, warranty_policy=?, image_url=?, stock_quantity=? WHERE id=?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name != null ? name.trim() : "");
            ps.setString(2, category != null ? category.trim() : "");
            ps.setString(3, brand != null ? brand.trim() : "");
            ps.setDouble(4, price);
            ps.setDouble(5, discountPercent);
            ps.setString(6, description != null ? description.trim() : "");
            ps.setString(7, technicalSpecs != null ? technicalSpecs.trim() : "");
            ps.setString(8, warrantyPolicy != null ? warrantyPolicy.trim() : "");
            ps.setString(9, imageUrl != null ? imageUrl.trim() : "");
            ps.setInt(10, stock);
            ps.setInt(11, id);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[ProductDAO] Product ID #" + id + " updated successfully in database.");
            }
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Database update error for ID #" + id + ": " + ex.getMessage());
        }

        Product p = productStore.get(id);
        if (p != null) {
            if (name != null && !name.trim().isEmpty()) p.setName(name.trim());
            if (category != null) p.setCategory(category);
            if (brand != null) p.setBrand(brand);
            p.setPrice(price);
            p.setDiscountPercent(discountPercent);
            if (description != null) p.setDescription(description);
            if (technicalSpecs != null) p.setTechnicalSpecs(technicalSpecs);
            if (warrantyPolicy != null) p.setWarrantyPolicy(warrantyPolicy);
            if (imageUrl != null && !imageUrl.trim().isEmpty()) p.setImageUrl(imageUrl);
            p.setStockQuantity(stock);
            return true;
        }

        return false;
    }

    public synchronized void deductStock(int productId, int quantity) {
        String sql = "UPDATE products SET stock_quantity = CASE WHEN stock_quantity >= ? THEN stock_quantity - ? ELSE 0 END WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setInt(3, productId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Error deducting stock in DB: " + ex.getMessage());
        }

        Product p = productStore.get(productId);
        if (p != null) {
            int current = p.getStockQuantity();
            p.setStockQuantity(Math.max(0, current - quantity));
        }
    }

    public synchronized void addStock(int productId, int quantity) {
        String sql = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Error adding stock in DB: " + ex.getMessage());
        }

        Product p = productStore.get(productId);
        if (p != null) {
            p.setStockQuantity(p.getStockQuantity() + quantity);
        }
    }

    // ==========================================
    // DELETE OPERATIONS (Database Permanent Delete)
    // ==========================================

    public boolean deleteProduct(int id) {
        String sqlItems = "DELETE FROM order_items WHERE product_id=?";
        String sqlProd = "DELETE FROM products WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlProd)) {
                ps.setInt(1, id);
                ps.executeUpdate();
                System.out.println("[ProductDAO] Permanently removed product ID #" + id + " from database.");
            }
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Error deleting product from DB: " + ex.getMessage());
        }

        productStore.remove(id);
        return true;
    }

    public boolean softDeleteProduct(int id) {
        String sql = "UPDATE products SET is_archived=1 WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Error archiving product in DB: " + ex.getMessage());
        }

        Product p = productStore.get(id);
        if (p != null) {
            p.setArchived(true);
            return true;
        }
        return false;
    }

    public boolean restoreProduct(int id) {
        String sql = "UPDATE products SET is_archived=0 WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[ProductDAO] Error restoring product in DB: " + ex.getMessage());
        }

        Product p = productStore.get(id);
        if (p != null) {
            p.setArchived(false);
            return true;
        }
        return false;
    }
}
