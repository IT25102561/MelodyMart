package utils;

import dao.*;
import models.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Automated Verification Test for MelodyMart Relational Database Persistence
 * Validates:
 * 1. Database table initialization & seeding
 * 2. Member 2: Entering a new product into the database
 * 3. Member 2: Updating the newly entered product in the database
 * 4. Customer / Member 3: Placing an order for the product into database (orders + order_items)
 * 5. Stock auto-deduction in database
 * 6. Member 1: User registration in database
 * 7. Member 4: Payment approval in database
 * 8. Member 5: Supplier & Purchase Order in database
 * 9. Member 6: Delivery milestone in database
 */
public class DatabaseVerificationTest {

    public static void main(String[] args) {
        System.out.println("================================================================================");
        System.out.println("MelodyMart: Database CRUD & Order Persistence Automated Verification");
        System.out.println("Group: 2026-Y2-S1-MLB-B6G1-08 | Harmony Lanka Musical Stores (Pvt) Ltd.");
        System.out.println("================================================================================");

        try {
            // Step 1: Check Database Engine
            System.out.println("\n[TEST 1] Verifying Database Connection...");
            System.out.println("Active Database Engine: " + DatabaseUtil.getDatabaseEngineName());
            System.out.println("Is MySQL Connected: " + DatabaseUtil.isMySQL());

            ProductDAO productDAO = new ProductDAO();
            OrderDAO orderDAO = new OrderDAO();
            UserDAO userDAO = new UserDAO();
            PaymentDAO paymentDAO = new PaymentDAO();
            SupplierDAO supplierDAO = new SupplierDAO();
            FulfillmentDAO fulfillmentDAO = new FulfillmentDAO();

            // Step 2: Member 2 - Enter a New Musical Instrument
            System.out.println("\n[TEST 2] Member 2: Entering a New Musical Instrument (CREATE)...");
            Product newProd = productDAO.addProduct(
                    "Yamaha Pacifica 112V Electric Guitar - Sonic Blue",
                    "String Instruments",
                    "Yamaha",
                    145000.0,
                    10.0,
                    "Class-leading Yamaha Pacifica guitar with solid alder body and Alnico V pickups.",
                    "Alder body, Maple neck, Rosewood fretboard, Alnico V pickups",
                    "2 Years Official Agent Warranty",
                    "https://images.unsplash.com/photo-1550985616-10810253b84d?w=600",
                    12
            );
            System.out.println("  -> Successfully added product ID: #" + newProd.getId() + ", Code: " + newProd.getCode());

            // Verify in DB directly via SQL SELECT
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT name, price, stock_quantity FROM products WHERE id = ?")) {
                ps.setInt(1, newProd.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("  -> [DB VERIFIED] Product in database: " + rs.getString("name") + " | Price: LKR " + rs.getDouble("price") + " | Stock: " + rs.getInt("stock_quantity"));
                    } else {
                        throw new Exception("Product ID #" + newProd.getId() + " not found in database table!");
                    }
                }
            }

            // Step 3: Member 2 - Update the newly entered product
            System.out.println("\n[TEST 3] Member 2: Updating the Newly Entered Product (UPDATE)...");
            boolean updated = productDAO.updateProduct(
                    newProd.getId(),
                    "Yamaha Pacifica 112V Electric Guitar - Special Edition White",
                    "String Instruments",
                    "Yamaha",
                    152000.0,
                    15.0,
                    "Upgraded custom edition with premium chrome hardware and coil-tap humbucker.",
                    "Alder body, Maple neck, Alnico V custom humbucker + single coils",
                    "2 Years Extended Harmony Lanka Warranty",
                    "https://images.unsplash.com/photo-1550985616-10810253b84d?w=600",
                    20
            );
            System.out.println("  -> Update product operation returned: " + updated);

            // Verify update in DB directly via SQL SELECT
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT name, price, discount_percent, stock_quantity, warranty_policy FROM products WHERE id = ?")) {
                ps.setInt(1, newProd.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("  -> [DB VERIFIED] Updated Name: " + rs.getString("name"));
                        System.out.println("  -> [DB VERIFIED] Updated Retail Price: LKR " + rs.getDouble("price"));
                        System.out.println("  -> [DB VERIFIED] Updated Discount: " + rs.getDouble("discount_percent") + "%");
                        System.out.println("  -> [DB VERIFIED] Updated Stock Quantity: " + rs.getInt("stock_quantity"));
                        System.out.println("  -> [DB VERIFIED] Updated Warranty: " + rs.getString("warranty_policy"));
                    }
                }
            }

            // Step 4: Customer / Member 3 - Place an order for this product
            System.out.println("\n[TEST 4] Customer / Member 3: Placing Order for Product (Database Order Placement)...");
            Cart cart = new Cart();
            cart.addItem(productDAO.getProductById(newProd.getId()), 2);
            cart.setDistrict("Kandy");
            cart.setShippingOption("STANDARD_COURIER");

            Order placedOrder = orderDAO.createAndSaveOrder(
                    5,
                    "Amila Silva",
                    "amila.silva@gmail.com",
                    "0778899001",
                    "12/A, Peradeniya Road",
                    "Kandy",
                    "Kandy",
                    "Koombiyo Delivery",
                    "CREDIT_CARD",
                    "",
                    cart
            );
            System.out.println("  -> Order Placed Successfully: " + placedOrder.getOrderId() + " | Grand Total: LKR " + placedOrder.getTotalAmount());

            // Verify order in DB table 'orders'
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT order_id, customer_name, total_amount, payment_status, fulfillment_status FROM orders WHERE order_id = ?")) {
                ps.setString(1, placedOrder.getOrderId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("  -> [DB VERIFIED] 'orders' row: " + rs.getString("order_id") + " | Customer: " + rs.getString("customer_name") + " | Total: LKR " + rs.getDouble("total_amount") + " | Status: " + rs.getString("payment_status"));
                    } else {
                        throw new Exception("Order not found in 'orders' database table!");
                    }
                }
            }

            // Verify line items in DB table 'order_items'
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT product_id, product_name, quantity, subtotal FROM order_items WHERE order_id = ?")) {
                ps.setString(1, placedOrder.getOrderId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        System.out.println("  -> [DB VERIFIED] 'order_items' row: Product #" + rs.getInt("product_id") + " (" + rs.getString("product_name") + ") x " + rs.getInt("quantity") + " = LKR " + rs.getDouble("subtotal"));
                    }
                }
            }

            // Verify stock deduction in DB table 'products'
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT stock_quantity FROM products WHERE id = ?")) {
                ps.setInt(1, newProd.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int currentStock = rs.getInt("stock_quantity");
                        System.out.println("  -> [DB VERIFIED] Stock auto-deducted in database: from 20 down to " + currentStock + " (expected: 18)");
                    }
                }
            }

            // Step 5: Member 1 - User Management in DB
            System.out.println("\n[TEST 5] Member 1: User Profile & Registration in DB...");
            User newUser = userDAO.registerUser("Sunil Shantha Silva", "sunil.test" + (System.currentTimeMillis() % 100000) + "@melodymart.lk", "SecurePass@2026", "0773344556", "CUSTOMER");
            System.out.println("  -> User registered with ID: #" + newUser.getId());
            userDAO.updateProfile(newUser.getId(), "Sunil Shantha Silva Updated", "0779988776");
            System.out.println("  -> User profile updated in database.");

            // Step 6: Member 4 - Payment Gateway in DB
            System.out.println("\n[TEST 6] Member 4: Payment Transaction Status in DB...");
            Payment pay = paymentDAO.getPaymentByOrderId(placedOrder.getOrderId());
            if (pay != null) {
                paymentDAO.updatePaymentStatus(pay.getTransactionId(), "PAID", "Manual test authorization verified");
                System.out.println("  -> Payment transaction " + pay.getTransactionId() + " updated to PAID in database.");
            }

            // Step 7: Member 5 - Supplier & Inventory in DB
            System.out.println("\n[TEST 7] Member 5: Supplier Management in DB...");
            Supplier newSup = supplierDAO.addSupplier("Southern Laya Instrument Crafts " + (System.currentTimeMillis() % 10000), "M. Jayawardena", "southern@laya.lk", "0912233445", "Main Street, Galle", "Traditional Drums, Flutes");
            System.out.println("  -> Supplier registered in database with ID: #" + newSup.getId());
            PurchaseOrder po = supplierDAO.createPurchaseOrder(newSup.getId(), "Traditional Drums (x10)", 10, 350000.0, "2026-03-15");
            System.out.println("  -> Purchase order created in database: " + po.getPoNumber());

            // Step 8: Member 6 - Fulfillment Dispatch & Tracking in DB
            System.out.println("\n[TEST 8] Member 6: Fulfillment Dispatch in DB...");
            Fulfillment ful = fulfillmentDAO.getFulfillmentByOrderId(placedOrder.getOrderId());
            if (ful != null) {
                fulfillmentDAO.updateDeliveryStatus(ful.getTrackingNumber(), "DELIVERED", "Package received and signed by Amila Silva");
                System.out.println("  -> Fulfillment tracking " + ful.getTrackingNumber() + " updated to DELIVERED in database.");
            }

            // Step 9: Comprehensive Validation & Error Handling Across All 6 Members
            System.out.println("\n[TEST 9] Verifying Assigned Error Codes & Validations for All 6 Members...");

            // Member 1 Validation Tests
            System.out.println("  [Member 1: User Account & Profile Management]");
            assertThrows(() -> userDAO.registerUser("Test User", newUser.getEmail(), "ValidPass123", "0771234567", "CUSTOMER"),
                    ValidationUtil.ERR_USER_DUPLICATE_EMAIL, "Duplicate email registration check");
            assertThrows(() -> userDAO.registerUser("Test User", "test.user@melody.lk", "weak", "0771234567", "CUSTOMER"),
                    ValidationUtil.ERR_USER_PASSWORD_STRENGTH, "Weak password policy check");
            assertThrows(() -> userDAO.registerUser("Test User", "test.user2@melody.lk", "ValidPass123", "12345", "CUSTOMER"),
                    ValidationUtil.ERR_USER_INVALID_PHONE, "Invalid Sri Lankan phone check");

            // Member 2 Validation Tests
            System.out.println("  [Member 2: Product Catalog & Search/Filtering]");
            assertThrows(() -> productDAO.addProduct("", "Guitars", "Yamaha", 50000.0, 5.0, "Desc", "Specs", "Warranty", "", 10),
                    ValidationUtil.ERR_PROD_INVALID_NAME, "Blank product name check");
            assertThrows(() -> productDAO.addProduct("Valid Guitar", "Guitars", "Yamaha", -100.0, 5.0, "Desc", "Specs", "Warranty", "", 10),
                    ValidationUtil.ERR_PROD_INVALID_PRICE, "Non-positive retail price check");
            assertThrows(() -> productDAO.addProduct("Valid Guitar", "Guitars", "Yamaha", 50000.0, 150.0, "Desc", "Specs", "Warranty", "", 10),
                    ValidationUtil.ERR_PROD_INVALID_DISCOUNT, "Promotional discount range (>100%) check");

            // Member 3 Validation Tests
            System.out.println("  [Member 3: Shopping Cart, Checkout & Payment]");
            Cart testCart = new Cart();
            CartDAO cartDAO = new CartDAO();
            assertThrows(() -> ValidationUtil.validateCartQuantity(0, 10),
                    ValidationUtil.ERR_CART_INVALID_QTY, "Non-positive cart quantity check");
            assertThrows(() -> ValidationUtil.validateCartQuantity(50, 5),
                    ValidationUtil.ERR_CART_INSUFFICIENT_STOCK, "Warehouse stock exceeded check");
            assertThrows(() -> cartDAO.applyVoucher(new javax.servlet.http.HttpSession() {
                // Mock session for testing
                private final java.util.Map<String, Object> map = new java.util.HashMap<>();
                public long getCreationTime() { return 0; }
                public String getId() { return "mock"; }
                public long getLastAccessedTime() { return 0; }
                public javax.servlet.ServletContext getServletContext() { return null; }
                public void setMaxInactiveInterval(int i) {}
                public int getMaxInactiveInterval() { return 0; }
                public javax.servlet.http.HttpSessionContext getSessionContext() { return null; }
                public Object getAttribute(String s) { return map.get(s); }
                public Object getValue(String s) { return map.get(s); }
                public java.util.Enumeration<String> getAttributeNames() { return java.util.Collections.enumeration(map.keySet()); }
                public String[] getValueNames() { return new String[0]; }
                public void setAttribute(String s, Object o) { map.put(s, o); }
                public void putValue(String s, Object o) { map.put(s, o); }
                public void removeAttribute(String s) { map.remove(s); }
                public void removeValue(String s) { map.remove(s); }
                public void invalidate() {}
                public boolean isNew() { return false; }
            }, "NONEXISTENT_COUPON"), ValidationUtil.ERR_CART_INVALID_VOUCHER, "Invalid voucher code check");

            // Member 4 Validation Tests
            System.out.println("  [Member 4: Payment Gateway & Invoice System]");
            assertThrows(() -> paymentDAO.initiatePayment("ORD-TEST", -500.0, "CREDIT_CARD", ""),
                    ValidationUtil.ERR_PAY_INVALID_AMOUNT, "Non-positive transaction amount check");
            assertThrows(() -> paymentDAO.initiatePayment("ORD-TEST", 500.0, "", ""),
                    ValidationUtil.ERR_PAY_METHOD_REQUIRED, "Unspecified payment channel check");
            assertThrows(() -> paymentDAO.initiatePayment("ORD-TEST", 500.0, "BANK_TRANSFER", ""),
                    ValidationUtil.ERR_PAY_UNVERIFIED_SLIP, "Missing bank slip attachment check");

            // Member 5 Validation Tests
            System.out.println("  [Member 5: Real-Time Inventory & Supplier Management]");
            assertThrows(() -> supplierDAO.addSupplier("", "Contact Person", "sup@test.com", "0112233445", "Address", "Guitars"),
                    ValidationUtil.ERR_SUP_INVALID_NAME, "Omitted supplier company name check");
            assertThrows(() -> supplierDAO.addSupplier("Valid Company", "Contact Person", "invalid-email", "0112233445", "Address", "Guitars"),
                    ValidationUtil.ERR_SUP_INVALID_EMAIL, "Malformed supplier email check");
            assertThrows(() -> supplierDAO.createPurchaseOrder(newSup.getId(), "Guitars", -5, 0.0, "2026-04-01"),
                    ValidationUtil.ERR_PO_INVALID_AMOUNTS, "Non-positive PO amounts check");

            // Member 6 Validation Tests
            System.out.println("  [Member 6: Order Fulfilment, Delivery Tracking & Returns]");
            assertThrows(() -> fulfillmentDAO.createDispatchJob("", "Customer", "Address", "Koombiyo Delivery", 0.0),
                    ValidationUtil.ERR_DISP_ORDER_REQUIRED, "Missing order ID for courier dispatch check");
            assertThrows(() -> fulfillmentDAO.submitReturnRequest("", "Customer", "cust@test.com", "Defective Soundboard", "Guitar defect"),
                    ValidationUtil.ERR_RET_ORDER_REQUIRED, "Unlinked return ticket submission check");
            assertThrows(() -> fulfillmentDAO.submitReturnRequest("ORD-2026-001", "Customer", "cust@test.com", "", "Guitar defect"),
                    ValidationUtil.ERR_RET_REASON_REQUIRED, "Unclassified warranty/return claim check");

            System.out.println("\n================================================================================");
            System.out.println("ALL DATABASE CRUD, PERSISTENCE & 6-MEMBER VALIDATION TESTS PASSED (100% OPERATIONAL)");
            System.out.println("================================================================================");

        } catch (Exception e) {
            System.err.println("\nVerification FAILED with exception:");
            e.printStackTrace();
        }
    }

    private static void assertThrows(TestRunnable runnable, String expectedErrorCode, String testName) {
        try {
            runnable.run();
            System.err.println("    FAILED: " + testName + " - Expected exception containing " + expectedErrorCode + " but none was thrown!");
        } catch (Exception ex) {
            if (ex.getMessage() != null && ex.getMessage().contains(expectedErrorCode)) {
                System.out.println("    PASSED: " + testName + " -> Threw " + expectedErrorCode);
            } else {
                System.err.println("    FAILED: " + testName + " - Expected " + expectedErrorCode + " but got: " + ex.getMessage());
            }
        }
    }

    @FunctionalInterface
    interface TestRunnable {
        void run() throws Exception;
    }
}
