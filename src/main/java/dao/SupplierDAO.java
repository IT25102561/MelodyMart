package dao;

import models.PurchaseOrder;
import models.Supplier;
import strategies.inventory.*;
import utils.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 */
public class SupplierDAO {
    private static final Map<Integer, Supplier> supplierStore = new ConcurrentHashMap<>();
    private static final Map<String, PurchaseOrder> poStore = new ConcurrentHashMap<>();
    private static final AtomicInteger supplierIdCounter = new AtomicInteger(10);
    private static final AtomicInteger poIdCounter = new AtomicInteger(100);

    static {
        loadSuppliersFromDatabase();
    }

    public static synchronized void loadSuppliersFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 1. Load Suppliers
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, supplier_code, company_name, contact_person, email, phone, address, supplied_categories, is_active FROM suppliers ORDER BY id ASC")) {

                int maxId = 10;
                supplierStore.clear();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String code = rs.getString("supplier_code");
                    String name = rs.getString("company_name");
                    String contact = rs.getString("contact_person");
                    String email = rs.getString("email");
                    String phone = rs.getString("phone");
                    String address = rs.getString("address");
                    String cats = rs.getString("supplied_categories");
                    boolean active = rs.getInt("is_active") == 1;

                    Supplier s = new Supplier(id, code, name, contact, email, phone, address, cats, active);
                    supplierStore.put(id, s);
                    if (id > maxId) maxId = id;
                    if (code != null && code.startsWith("SUP-LKA-")) {
                        try {
                            int cnum = Integer.parseInt(code.substring("SUP-LKA-".length()));
                            if (cnum > maxId) maxId = cnum;
                        } catch (Exception ignored) {}
                    }
                }
                supplierIdCounter.set(Math.max(maxId, 10));
            }

            // 2. Load Purchase Orders
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, po_number, supplier_id, supplier_name, order_date, expected_delivery_date, items_summary, total_quantity, total_amount, status FROM purchase_orders ORDER BY id DESC")) {

                int maxPo = 100;
                poStore.clear();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String poNo = rs.getString("po_number");
                    int supId = rs.getInt("supplier_id");
                    String supName = rs.getString("supplier_name");
                    String oDate = rs.getString("order_date");
                    String eDate = rs.getString("expected_delivery_date");
                    String items = rs.getString("items_summary");
                    int qty = rs.getInt("total_quantity");
                    double amt = rs.getDouble("total_amount");
                    String status = rs.getString("status");

                    PurchaseOrder po = new PurchaseOrder(id, poNo, supId, supName, oDate, eDate, items, qty, amt, status);
                    poStore.put(poNo, po);
                    if (id > maxPo) maxPo = id;
                    if (poNo != null && poNo.startsWith("PO-2026-")) {
                        try {
                            int pnum = Integer.parseInt(poNo.substring("PO-2026-".length()));
                            if (pnum > maxPo) maxPo = pnum;
                        } catch (Exception ignored) {}
                    }
                }
                poIdCounter.set(Math.max(maxPo, 100));
            }

            System.out.println("[SupplierDAO] Successfully loaded " + supplierStore.size() + " suppliers and " + poStore.size() + " POs from database.");

        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Notice loading suppliers/POs from DB: " + ex.getMessage());
        }
    }

    // ==========================================
    // CREATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public Supplier addSupplier(String companyName, String contactPerson, String email,
                               String phone, String address, String categories) throws Exception {
        utils.ValidationUtil.validateSupplier(companyName, email);
        int newId = supplierIdCounter.incrementAndGet();
        String code = "SUP-LKA-" + String.format("%03d", newId);

        String sql = "INSERT INTO suppliers (supplier_code, company_name, contact_person, email, phone, address, supplied_categories, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, code);
            ps.setString(2, companyName.trim());
            ps.setString(3, contactPerson != null ? contactPerson.trim() : "");
            ps.setString(4, email.trim());
            ps.setString(5, phone != null ? phone.trim() : "");
            ps.setString(6, address != null ? address.trim() : "");
            ps.setString(7, categories != null ? categories.trim() : "General Supplies");
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) newId = gk.getInt(1);
            } catch (Exception ignored) {}

            System.out.println("[SupplierDAO] Added supplier " + companyName + " to database.");
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error inserting supplier into DB: " + ex.getMessage());
        }

        Supplier s = new Supplier(newId, code, companyName.trim(), contactPerson, email.trim(), phone, address, categories, true);
        supplierStore.put(newId, s);
        return s;
    }

    public PurchaseOrder createPurchaseOrder(int supplierId, String itemsSummary, int quantity, double totalAmount, String expectedDate) throws Exception {
        return createPurchaseOrder(supplierId, itemsSummary, quantity, totalAmount, expectedDate, new StandardSupplierPricingStrategy());
    }

    public PurchaseOrder createPurchaseOrder(int supplierId, String itemsSummary, int quantity, double totalAmount, String expectedDate, SupplierPricingStrategy pricingStrategy) throws Exception {
        Supplier sup = supplierStore.get(supplierId);
        if (sup == null) {
            throw new Exception("Supplier not found with ID: " + supplierId);
        }
        utils.ValidationUtil.validatePurchaseOrder(quantity, totalAmount, expectedDate);

        double effectiveAmount = totalAmount;
        if (pricingStrategy != null && quantity > 0) {
            double discountRate = pricingStrategy.getDiscountRate(quantity);
            if (discountRate != 0.0) {
                effectiveAmount = totalAmount * (1.0 - discountRate);
                if (effectiveAmount < 0) effectiveAmount = 0.0;
            }
        }

        int newId = poIdCounter.incrementAndGet();
        String poNo = "PO-2026-" + String.format("%03d", newId);
        String today = LocalDate.now().toString();

        String sql = "INSERT INTO purchase_orders (po_number, supplier_id, supplier_name, order_date, expected_delivery_date, items_summary, total_quantity, total_amount, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, poNo);
            ps.setInt(2, supplierId);
            ps.setString(3, sup.getCompanyName());
            ps.setString(4, today);
            ps.setString(5, expectedDate);
            ps.setString(6, itemsSummary);
            ps.setInt(7, quantity);
            ps.setDouble(8, effectiveAmount);
            ps.setString(9, "ISSUED");
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) newId = gk.getInt(1);
            } catch (Exception ignored) {}

            String tier = (pricingStrategy != null) ? pricingStrategy.getPricingTierName() : "STANDARD";
            System.out.println("[SupplierDAO] Created purchase order " + poNo + " [PricingTier: " + tier + "] in database.");
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error inserting PO into DB: " + ex.getMessage());
        }

        PurchaseOrder po = new PurchaseOrder(newId, poNo, supplierId, sup.getCompanyName(), today, expectedDate, itemsSummary, quantity, effectiveAmount, "ISSUED");
        poStore.put(poNo, po);
        return po;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public Supplier getSupplierById(int id) {
        return supplierStore.get(id);
    }

    public List<Supplier> getAllSuppliers() {
        return supplierStore.values().stream()
                .filter(Supplier::isActive)
                .sorted(Comparator.comparingInt(Supplier::getId))
                .collect(Collectors.toList());
    }

    public List<Supplier> getAllSuppliersAdmin() {
        return supplierStore.values().stream()
                .sorted(Comparator.comparingInt(Supplier::getId))
                .collect(Collectors.toList());
    }

    public List<PurchaseOrder> getAllPurchaseOrders() {
        return poStore.values().stream()
                .sorted(Comparator.comparing(PurchaseOrder::getOrderDate).reversed())
                .collect(Collectors.toList());
    }

    // ==========================================
    // UPDATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean updateSupplier(int id, String companyName, String contactPerson, String email, String phone, String address, String categories) throws Exception {
        utils.ValidationUtil.validateSupplier(companyName, email);
        Supplier s = supplierStore.get(id);
        if (s == null) return false;

        String sql = "UPDATE suppliers SET company_name=?, contact_person=?, email=?, phone=?, address=?, supplied_categories=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, companyName != null ? companyName.trim() : s.getCompanyName());
            ps.setString(2, contactPerson != null ? contactPerson.trim() : s.getContactPerson());
            ps.setString(3, email != null ? email.trim() : s.getEmail());
            ps.setString(4, phone != null ? phone.trim() : s.getPhone());
            ps.setString(5, address != null ? address.trim() : s.getAddress());
            ps.setString(6, categories != null ? categories.trim() : s.getSuppliedCategories());
            ps.setInt(7, id);
            ps.executeUpdate();
            System.out.println("[SupplierDAO] Updated supplier ID #" + id + " in database.");
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error updating supplier in DB: " + ex.getMessage());
        }

        if (companyName != null && !companyName.trim().isEmpty()) s.setCompanyName(companyName.trim());
        if (contactPerson != null) s.setContactPerson(contactPerson);
        if (email != null) s.setEmail(email.trim());
        if (phone != null) s.setPhone(phone.trim());
        if (address != null) s.setAddress(address.trim());
        if (categories != null) s.setSuppliedCategories(categories.trim());
        return true;
    }

    public boolean updatePoStatus(String poNumber, String newStatus) {
        PurchaseOrder po = poStore.get(poNumber);
        if (po == null) return false;

        String sql = "UPDATE purchase_orders SET status=? WHERE po_number=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, poNumber);
            ps.executeUpdate();
            System.out.println("[SupplierDAO] Updated PO " + poNumber + " status to " + newStatus + " in database.");
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error updating PO status in DB: " + ex.getMessage());
        }

        po.setStatus(newStatus);
        return true;
    }

    // ==========================================
    // DELETE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean deactivateSupplier(int id) {
        Supplier s = supplierStore.get(id);
        if (s != null) {
            String sql = "UPDATE suppliers SET is_active=0 WHERE id=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            } catch (Exception ex) {
                System.err.println("[SupplierDAO] Error deactivating supplier in DB: " + ex.getMessage());
            }

            s.setActive(false);
            return true;
        }
        return false;
    }

    public boolean cancelPurchaseOrder(String poNumber) {
        PurchaseOrder po = poStore.get(poNumber);
        if (po != null) {
            String sql = "UPDATE purchase_orders SET status='CANCELLED' WHERE po_number=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, poNumber);
                ps.executeUpdate();
            } catch (Exception ex) {
                System.err.println("[SupplierDAO] Error cancelling PO in DB: " + ex.getMessage());
            }

            po.setStatus("CANCELLED");
            return true;
        }
        return false;
    }
    public boolean reactivateSupplier(int id) {
        Supplier s = supplierStore.get(id);
        if (s != null) {
            String sql = "UPDATE suppliers SET is_active=1 WHERE id=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.executeUpdate();
                System.out.println("[SupplierDAO] Reactivated supplier ID #" + id + " in database.");
            } catch (Exception ex) {
                System.err.println("[SupplierDAO] Error reactivating supplier in DB: " + ex.getMessage());
            }

            s.setActive(true);
            return true;
        }
        return false;
    }

    public boolean receiveStockBatch(String poNumber, int productId, int quantity, String warrantyBatch) {
        PurchaseOrder po = poStore.get(poNumber);
        if (po != null) {
            String suffix = " [BATCH RECEIVED: Qty " + quantity + ", Warranty: " + (warrantyBatch != null && !warrantyBatch.isEmpty() ? warrantyBatch : "Standard 1-Year") + "]";
            String updatedSummary = po.getItemsSummary() + suffix;
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE purchase_orders SET status='RECEIVED', items_summary=? WHERE po_number=?")) {
                ps.setString(1, updatedSummary);
                ps.setString(2, poNumber);
                ps.executeUpdate();
                System.out.println("[SupplierDAO] Received stock batch for PO " + poNumber + " in database.");
            } catch (Exception ex) {
                System.err.println("[SupplierDAO] Error updating PO status in DB: " + ex.getMessage());
            }

            po.setStatus("RECEIVED");
            po.setItemsSummary(updatedSummary);

            if (productId > 0 && quantity > 0) {
                new ProductDAO().addStock(productId, quantity);
            }
            return true;
        }
        return false;
    }

    public boolean deleteSupplier(int id) {
        String sqlPo = "DELETE FROM purchase_orders WHERE supplier_id=?";
        String sqlSup = "DELETE FROM suppliers WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlPo)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlSup)) {
                ps.setInt(1, id);
                ps.executeUpdate();
                System.out.println("[SupplierDAO] Permanently removed supplier ID #" + id + " from database.");
            }
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error deleting supplier from DB: " + ex.getMessage());
        }

        supplierStore.remove(id);
        return true;
    }

    public boolean deletePurchaseOrder(String poNumber) {
        String sql = "DELETE FROM purchase_orders WHERE po_number=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, poNumber);
            ps.executeUpdate();
            System.out.println("[SupplierDAO] Permanently removed PO " + poNumber + " from database.");
        } catch (Exception ex) {
            System.err.println("[SupplierDAO] Error deleting PO from DB: " + ex.getMessage());
        }

        poStore.remove(poNumber);
        return true;
    }
}
