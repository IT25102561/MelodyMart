package dao;

import models.*;
import utils.DatabaseUtil;
import utils.FileStorageUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

/**
 * MelodyMart - Order Persistence & Management DAO
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 * Satisfies: "Save the orders for now. Give the text file to all six members."
 * Writes every placed order to the database (orders and order_items tables) and orders.txt.
 */
public class OrderDAO {
    private static final Map<String, Order> orderStore = new ConcurrentHashMap<>();
    private static final AtomicInteger orderIdCounter = new AtomicInteger(1003);

    private final ProductDAO productDAO = new ProductDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final FulfillmentDAO fulfillmentDAO = new FulfillmentDAO();

    static {
        loadOrdersFromDatabase();
    }

    public static synchronized void loadOrdersFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT order_id, user_id, customer_name, customer_email, customer_phone, shipping_address, city, district, courier_name, tracking_number, subtotal, delivery_fee, discount_amount, total_amount, payment_method, payment_status, fulfillment_status, voucher_code, order_date FROM orders ORDER BY order_date DESC")) {

            ProductDAO pdao = new ProductDAO();
            int maxId = 1002;
            orderStore.clear();

            while (rs.next()) {
                Order o = new Order();
                String ordId = rs.getString("order_id");
                o.setOrderId(ordId);
                o.setUserId(rs.getInt("user_id"));
                o.setCustomerName(rs.getString("customer_name"));
                o.setCustomerEmail(rs.getString("customer_email"));
                o.setCustomerPhone(rs.getString("customer_phone"));
                o.setShippingAddress(rs.getString("shipping_address"));
                o.setCity(rs.getString("city"));
                o.setDistrict(rs.getString("district"));
                o.setCourierName(rs.getString("courier_name"));
                o.setTrackingNumber(rs.getString("tracking_number"));
                o.setSubtotal(rs.getDouble("subtotal"));
                o.setDeliveryFee(rs.getDouble("delivery_fee"));
                o.setDiscountAmount(rs.getDouble("discount_amount"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setPaymentMethod(rs.getString("payment_method"));
                o.setPaymentStatus(rs.getString("payment_status"));
                o.setFulfillmentStatus(rs.getString("fulfillment_status"));
                o.setVoucherCode(rs.getString("voucher_code"));
                o.setOrderDate(rs.getString("order_date"));

                // Load items for this order
                List<CartItem> items = new ArrayList<>();
                try (PreparedStatement ips = conn.prepareStatement("SELECT product_id, product_name, quantity, unit_price, subtotal FROM order_items WHERE order_id = ?")) {
                    ips.setString(1, ordId);
                    try (ResultSet irs = ips.executeQuery()) {
                        while (irs.next()) {
                            int prodId = irs.getInt("product_id");
                            int qty = irs.getInt("quantity");
                            Product p = pdao.getProductByIdAdmin(prodId);
                            if (p != null) {
                                items.add(new CartItem(p, qty));
                            }
                        }
                    }
                } catch (Exception ignored) {}

                o.setItems(items);
                orderStore.put(ordId, o);

                // Check counter
                if (ordId.startsWith("ORD-2026-")) {
                    try {
                        int num = Integer.parseInt(ordId.substring("ORD-2026-".length()));
                        if (num > maxId) maxId = num;
                    } catch (Exception ignored) {}
                }
            }

            orderIdCounter.set(maxId);
            System.out.println("[OrderDAO] Successfully loaded " + orderStore.size() + " orders from database.");

        } catch (Exception ex) {
            System.err.println("[OrderDAO] Notice loading orders from DB: " + ex.getMessage());
        }
    }

    /**
     * Creates and saves a new order, saving directly into relational database (orders + order_items),
     * deducting inventory in database, generating payment and fulfillment records in database,
     * and persistently writing the order details to orders.txt.
     */
    public synchronized Order createAndSaveOrder(int userId, String customerName, String email, String phone,
                                                String address, String city, String district,
                                                String courierName, String paymentMethod,
                                                String bankSlipUrl, Cart cart) throws Exception {
        if (cart == null || cart.getItems().isEmpty()) {
            throw new Exception("Cannot place order with an empty cart.");
        }
        if (customerName == null || customerName.trim().isEmpty()) {
            throw new Exception("Customer full name is required.");
        }
        if (phone == null || phone.trim().isEmpty()) {
            throw new Exception("Contact phone number is required.");
        }

        int newId = orderIdCounter.incrementAndGet();
        String orderId = "ORD-2026-" + newId;
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        Order order = new Order();
        order.setOrderId(orderId);
        order.setUserId(userId);
        order.setCustomerName(customerName.trim());
        order.setCustomerEmail(email != null ? email.trim() : "");
        order.setCustomerPhone(phone.trim());
        order.setShippingAddress(address != null ? address.trim() : "");
        order.setCity(city != null ? city.trim() : "");
        order.setDistrict(district != null ? district.trim() : "Colombo");
        order.setCourierName(courierName != null ? courierName : "Koombiyo Delivery");
        order.setSubtotal(cart.getSubtotal());
        order.setDeliveryFee(cart.getDeliveryFee());
        order.setDiscountAmount(cart.getDiscountAmount());
        order.setTotalAmount(cart.getGrandTotal());
        order.setPaymentMethod(paymentMethod);
        order.setVoucherCode(cart.getVoucherCode());
        order.setOrderDate(now);
        order.setFulfillmentStatus("PROCESSING");

        // Copy cart items
        List<CartItem> orderedItems = new ArrayList<>();
        for (CartItem it : cart.getItems()) {
            orderedItems.add(new CartItem(it.getProduct(), it.getQuantity()));
            // Member 5 & Database: Deduct stock automatically in DB
            productDAO.deductStock(it.getProduct().getId(), it.getQuantity());
        }
        order.setItems(orderedItems);

        // Member 4 & Database: Create payment transaction & invoice in DB
        Payment payment = paymentDAO.initiatePayment(orderId, order.getTotalAmount(), paymentMethod, bankSlipUrl);
        order.setPaymentStatus(payment.getPaymentStatus());
        paymentDAO.generateInvoice(order, payment);

        // Member 6 & Database: Create fulfillment dispatch job in DB
        double codAmt = "COD".equalsIgnoreCase(paymentMethod) ? order.getTotalAmount() : 0.0;
        Fulfillment fulfillment = fulfillmentDAO.createDispatchJob(orderId, customerName, address + ", " + city, courierName, codAmt);
        order.setTrackingNumber(fulfillment.getTrackingNumber());

        // ==============================================================
        // RELATIONAL DATABASE PERSISTENCE: INSERT/UPDATE orders & order_items
        // ==============================================================
        String insertOrderSql = "INSERT INTO orders (order_id, user_id, customer_name, customer_email, customer_phone, shipping_address, city, district, courier_name, tracking_number, subtotal, delivery_fee, discount_amount, total_amount, payment_method, payment_status, fulfillment_status, voucher_code, order_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String updateOrderSql = "UPDATE orders SET user_id=?, customer_name=?, customer_email=?, customer_phone=?, shipping_address=?, city=?, district=?, courier_name=?, tracking_number=?, subtotal=?, delivery_fee=?, discount_amount=?, total_amount=?, payment_method=?, payment_status=?, fulfillment_status=?, voucher_code=?, order_date=? WHERE order_id=?";
        String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseUtil.getConnection()) {
            boolean orderExists = false;
            try (PreparedStatement chk = conn.prepareStatement("SELECT order_id FROM orders WHERE order_id = ?")) {
                chk.setString(1, order.getOrderId());
                try (ResultSet rs = chk.executeQuery()) {
                    orderExists = rs.next();
                }
            }

            if (orderExists) {
                try (PreparedStatement ops = conn.prepareStatement(updateOrderSql)) {
                    ops.setInt(1, order.getUserId());
                    ops.setString(2, order.getCustomerName());
                    ops.setString(3, order.getCustomerEmail());
                    ops.setString(4, order.getCustomerPhone());
                    ops.setString(5, order.getShippingAddress());
                    ops.setString(6, order.getCity());
                    ops.setString(7, order.getDistrict());
                    ops.setString(8, order.getCourierName());
                    ops.setString(9, order.getTrackingNumber());
                    ops.setDouble(10, order.getSubtotal());
                    ops.setDouble(11, order.getDeliveryFee());
                    ops.setDouble(12, order.getDiscountAmount());
                    ops.setDouble(13, order.getTotalAmount());
                    ops.setString(14, order.getPaymentMethod());
                    ops.setString(15, order.getPaymentStatus());
                    ops.setString(16, order.getFulfillmentStatus());
                    ops.setString(17, order.getVoucherCode() != null ? order.getVoucherCode() : "");
                    ops.setString(18, order.getOrderDate());
                    ops.setString(19, order.getOrderId());
                    ops.executeUpdate();
                }
            } else {
                try (PreparedStatement ops = conn.prepareStatement(insertOrderSql)) {
                    ops.setString(1, order.getOrderId());
                    ops.setInt(2, order.getUserId());
                    ops.setString(3, order.getCustomerName());
                    ops.setString(4, order.getCustomerEmail());
                    ops.setString(5, order.getCustomerPhone());
                    ops.setString(6, order.getShippingAddress());
                    ops.setString(7, order.getCity());
                    ops.setString(8, order.getDistrict());
                    ops.setString(9, order.getCourierName());
                    ops.setString(10, order.getTrackingNumber());
                    ops.setDouble(11, order.getSubtotal());
                    ops.setDouble(12, order.getDeliveryFee());
                    ops.setDouble(13, order.getDiscountAmount());
                    ops.setDouble(14, order.getTotalAmount());
                    ops.setString(15, order.getPaymentMethod());
                    ops.setString(16, order.getPaymentStatus());
                    ops.setString(17, order.getFulfillmentStatus());
                    ops.setString(18, order.getVoucherCode() != null ? order.getVoucherCode() : "");
                    ops.setString(19, order.getOrderDate());
                    ops.executeUpdate();
                }
            }

            try (PreparedStatement del = conn.prepareStatement("DELETE FROM order_items WHERE order_id = ?")) {
                del.setString(1, order.getOrderId());
                del.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ips = conn.prepareStatement(insertItemSql)) {
                for (CartItem it : order.getItems()) {
                    ips.setString(1, order.getOrderId());
                    ips.setInt(2, it.getProduct().getId());
                    ips.setString(3, it.getProduct().getName());
                    ips.setInt(4, it.getQuantity());
                    ips.setDouble(5, it.getProduct().getEffectivePrice());
                    ips.setDouble(6, it.getSubtotal());
                    ips.executeUpdate();
                }
            }

            System.out.println("[OrderDAO] Successfully saved order " + orderId + " and " + order.getItems().size() + " items to relational database.");

        } catch (Exception ex) {
            System.err.println("[OrderDAO] Error saving order to database: " + ex.getMessage());
        }

        // Save order in memory store
        orderStore.put(orderId, order);

        // Save the order to orders.txt file persistently
        writeOrderToTextFile(order);

        // Clear cart
        cart.clear();

        return order;
    }

    /**
     * Formats order and appends to orders.txt
     */
    private void writeOrderToTextFile(Order o) {
        StringBuilder sb = new StringBuilder();
        sb.append("ORDER ID:         ").append(o.getOrderId()).append("\n");
        sb.append("ORDER DATE:       ").append(o.getOrderDate()).append("\n");
        sb.append("CUSTOMER:         ").append(o.getCustomerName()).append(" (Phone: ").append(o.getCustomerPhone()).append(", Email: ").append(o.getCustomerEmail()).append(")\n");
        sb.append("DELIVERY ADDRESS: ").append(o.getShippingAddress()).append(", ").append(o.getCity()).append(", ").append(o.getDistrict()).append(" (Sri Lanka)\n");
        sb.append("COURIER PARTNER:  ").append(o.getCourierName()).append(" [Tracking: ").append(o.getTrackingNumber()).append("]\n");
        sb.append("ITEMS PURCHASED:\n");
        for (CartItem it : o.getItems()) {
            sb.append("  - ").append(it.getProduct().getName())
              .append(" | Qty: ").append(it.getQuantity())
              .append(" | Unit: LKR ").append(String.format("%,.2f", it.getProduct().getEffectivePrice()))
              .append(" | Subtotal: LKR ").append(String.format("%,.2f", it.getSubtotal())).append("\n");
        }
        sb.append("SUBTOTAL:         LKR ").append(String.format("%,.2f", o.getSubtotal())).append("\n");
        sb.append("DELIVERY FEE:     LKR ").append(String.format("%,.2f", o.getDeliveryFee())).append("\n");
        if (o.getDiscountAmount() > 0) {
            sb.append("DISCOUNT:        -LKR ").append(String.format("%,.2f", o.getDiscountAmount())).append(" (Promo: ").append(o.getVoucherCode()).append(")\n");
        }
        sb.append("TOTAL AMOUNT:     LKR ").append(String.format("%,.2f", o.getTotalAmount())).append("\n");
        sb.append("PAYMENT METHOD:   ").append(o.getPaymentMethod()).append(" (Status: ").append(o.getPaymentStatus()).append(")\n");
        sb.append("FULFILLMENT:      ").append(o.getFulfillmentStatus()).append("\n");

        FileStorageUtil.appendOrder(sb.toString());
    }

    public Order getOrderById(String orderId) {
        return orderStore.get(orderId);
    }

    public List<Order> getAllOrders() {
        return orderStore.values().stream()
                .sorted(Comparator.comparing(Order::getOrderDate).reversed())
                .collect(Collectors.toList());
    }

    public List<Order> getOrdersByCustomerEmail(String email) {
        if (email == null) return Collections.emptyList();
        return orderStore.values().stream()
                .filter(o -> email.equalsIgnoreCase(o.getCustomerEmail()))
                .sorted(Comparator.comparing(Order::getOrderDate).reversed())
                .collect(Collectors.toList());
    }

    public boolean updateFulfillmentStatus(String orderId, String newStatus) {
        String sql = "UPDATE orders SET fulfillment_status=? WHERE order_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, orderId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[OrderDAO] Error updating fulfillment status in DB: " + ex.getMessage());
        }

        Order o = orderStore.get(orderId);
        if (o != null) {
            o.setFulfillmentStatus(newStatus);
            return true;
        }
        return false;
    }

    public boolean updatePaymentStatus(String orderId, String newStatus) {
        String sql = "UPDATE orders SET payment_status=? WHERE order_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, orderId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[OrderDAO] Error updating payment status in DB: " + ex.getMessage());
        }

        Order o = orderStore.get(orderId);
        if (o != null) {
            o.setPaymentStatus(newStatus);
            return true;
        }
        return false;
    }

    public boolean updateOrderDetails(String orderId, String customerName, String phone, String address, String city, String district, String courierName) {
        String sql = "UPDATE orders SET customer_name=?, customer_phone=?, shipping_address=?, city=?, district=?, courier_name=? WHERE order_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerName != null ? customerName.trim() : "");
            ps.setString(2, phone != null ? phone.trim() : "");
            ps.setString(3, address != null ? address.trim() : "");
            ps.setString(4, city != null ? city.trim() : "");
            ps.setString(5, district != null ? district.trim() : "");
            ps.setString(6, courierName != null ? courierName.trim() : "");
            ps.setString(7, orderId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[OrderDAO] Error updating order details in DB: " + ex.getMessage());
        }

        Order o = orderStore.get(orderId);
        if (o != null) {
            if (customerName != null) o.setCustomerName(customerName.trim());
            if (phone != null) o.setCustomerPhone(phone.trim());
            if (address != null) o.setShippingAddress(address.trim());
            if (city != null) o.setCity(city.trim());
            if (district != null) o.setDistrict(district.trim());
            if (courierName != null) o.setCourierName(courierName.trim());
            return true;
        }
        return false;
    }

    public boolean deleteOrder(String orderId) {
        String sqlItems = "DELETE FROM order_items WHERE order_id=?";
        String sqlPay = "DELETE FROM payments WHERE order_id=?";
        String sqlInv = "DELETE FROM invoices WHERE order_id=?";
        String sqlFul = "DELETE FROM fulfillments WHERE order_id=?";
        String sqlRet = "DELETE FROM return_requests WHERE order_id=?";
        String sqlOrd = "DELETE FROM orders WHERE order_id=?";
        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) { ps.setString(1, orderId); ps.executeUpdate(); } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlPay)) { ps.setString(1, orderId); ps.executeUpdate(); } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlInv)) { ps.setString(1, orderId); ps.executeUpdate(); } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlFul)) { ps.setString(1, orderId); ps.executeUpdate(); } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlRet)) { ps.setString(1, orderId); ps.executeUpdate(); } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlOrd)) {
                ps.setString(1, orderId);
                ps.executeUpdate();
                System.out.println("[OrderDAO] Permanently removed order " + orderId + " from database.");
            }
        } catch (Exception ex) {
            System.err.println("[OrderDAO] Error deleting order from DB: " + ex.getMessage());
        }

        orderStore.remove(orderId);
        return true;
    }
}
