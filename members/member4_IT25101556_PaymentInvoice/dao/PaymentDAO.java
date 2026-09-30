package dao;

import models.Invoice;
import models.Order;
import models.Payment;
import strategies.payment.*;
import utils.DatabaseUtil;

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
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 * CRUD:
 * - [CREATE] Initiate transaction records across payment channels & auto-generate itemized e-invoices with tax breakdowns.
 * - [READ]   Track real-time payment states, download official PDF tax invoices, and access customer transaction histories.
 * - [UPDATE] Update transaction status following bank slip review/webhooks, and record processed refund details.
 * - [DELETE] Void failed/unverified payment attempts, archive obsolete billing records, and cancel invalidated draft invoices.
 */
public class PaymentDAO {
    private static final Map<String, Payment> paymentStore = new ConcurrentHashMap<>();
    private static final Map<String, Invoice> invoiceStore = new ConcurrentHashMap<>();
    private static final AtomicInteger paymentIdCounter = new AtomicInteger(100);

    static {
        loadPaymentsFromDatabase();
    }

    public static synchronized void loadPaymentsFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 1. Load Payments
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, transaction_id, order_id, amount, payment_method, payment_status, bank_slip_url, transaction_ref, refund_details, timestamp FROM payments ORDER BY timestamp DESC")) {

                int maxId = 10;
                paymentStore.clear();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String txnId = rs.getString("transaction_id");
                    String orderId = rs.getString("order_id");
                    double amount = rs.getDouble("amount");
                    String method = rs.getString("payment_method");
                    String status = rs.getString("payment_status");
                    String slip = rs.getString("bank_slip_url");
                    String ref = rs.getString("transaction_ref");
                    String refund = rs.getString("refund_details");
                    String ts = rs.getString("timestamp");

                    Payment p = new Payment(id, txnId, orderId, amount, method, status, slip, ref, refund, ts);
                    paymentStore.put(txnId, p);
                    if (id > maxId) maxId = id;
                    if (txnId != null && txnId.startsWith("TXN-2026-")) {
                        try {
                            String numStr = txnId.substring("TXN-2026-".length()).split("-")[0];
                            int num = Integer.parseInt(numStr);
                            if (num > maxId) maxId = num;
                        } catch (Exception ignored) {}
                    }
                }
                paymentIdCounter.set(Math.max(maxId, 100));
            }

            // 2. Load Invoices
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT invoice_number, order_id, invoice_date, customer_name, billing_address, subtotal, delivery_fee, discount, vat_amount, total_amount FROM invoices")) {

                invoiceStore.clear();
                while (rs.next()) {
                    Invoice inv = new Invoice();
                    inv.setInvoiceNumber(rs.getString("invoice_number"));
                    inv.setOrderId(rs.getString("order_id"));
                    inv.setInvoiceDate(rs.getString("invoice_date"));
                    inv.setCustomerName(rs.getString("customer_name"));
                    inv.setBillingAddress(rs.getString("billing_address"));
                    inv.setSubtotal(rs.getDouble("subtotal"));
                    inv.setDeliveryFee(rs.getDouble("delivery_fee"));
                    inv.setDiscount(rs.getDouble("discount"));
                    inv.setVatAmount(rs.getDouble("vat_amount"));
                    inv.setTotalAmount(rs.getDouble("total_amount"));
                    inv.setVatRate(0.08);

                    Payment pay = getPaymentByOrderId(inv.getOrderId());
                    inv.setPaymentStatus(pay != null ? pay.getPaymentStatus() : "PAID");
                    inv.setPaymentMethod(pay != null ? pay.getPaymentMethod() : "ONLINE");

                    List<String> items = new ArrayList<>();
                    items.add("Musical Equipment Order (" + inv.getOrderId() + ") | Qty: 1 | Subtotal: LKR " + String.format("%,.2f", inv.getSubtotal()));
                    inv.setLineItems(items);

                    invoiceStore.put(inv.getInvoiceNumber(), inv);
                }
            }

            System.out.println("[PaymentDAO] Successfully loaded " + paymentStore.size() + " payments and " + invoiceStore.size() + " invoices from database.");

        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Notice loading payments/invoices from DB: " + ex.getMessage());
        }
    }

    // ==========================================
    // CREATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public Payment initiatePayment(String orderId, double amount, String paymentMethod, String bankSlipUrl) throws Exception {
        return initiateTransaction(orderId, "", "", "", "", amount, paymentMethod, bankSlipUrl, "", true);
    }

    /**
     * [CREATE] Initiate transaction records across payment channels (credit/debit cards, bank transfer slips, digital wallets, COD)
     * and auto-generate itemized e-invoices with tax breakdowns.
     */
    public Payment initiateTransaction(String orderId, String customerName, String customerEmail,
                                        String customerPhone, String billingAddress, double amount,
                                        String paymentMethod, String bankSlipUrl, String transactionRef,
                                        boolean autoGenerateInvoice) throws Exception {
        return initiateTransaction(orderId, customerName, customerEmail, customerPhone,
                billingAddress, amount, paymentMethod, bankSlipUrl, transactionRef, autoGenerateInvoice,
                PaymentStrategyFactory.getStrategy(paymentMethod));
    }

    public Payment initiateTransaction(String orderId, String customerName, String customerEmail,
                                        String customerPhone, String billingAddress, double amount,
                                        String paymentMethod, String bankSlipUrl, String transactionRef,
                                        boolean autoGenerateInvoice, PaymentStrategy paymentStrategy) throws Exception {
        utils.ValidationUtil.validatePayment(amount, paymentMethod, bankSlipUrl);

        if (orderId == null || orderId.trim().isEmpty()) {
            orderId = "ORD-2026-" + String.format("%03d", paymentIdCounter.get() + 1);
        } else {
            orderId = orderId.trim();
        }

        int newId = paymentIdCounter.incrementAndGet();
        String txnId = "TXN-2026-" + String.format("%04d", newId) + "-" + (System.currentTimeMillis() % 10000);
        String status = "PENDING";
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // Strategy Pattern Execution via PaymentProcessor Context
        PaymentStrategy activeStrategy = (paymentStrategy != null) ? paymentStrategy : PaymentStrategyFactory.getStrategy(paymentMethod);
        PaymentProcessor processor = new PaymentProcessor(activeStrategy);

        Payment tempPayment = new Payment(newId, txnId, orderId, amount, activeStrategy.getPaymentMethodName(), status, bankSlipUrl, transactionRef, "", now);
        Map<String, String> details = new HashMap<>();
        if (bankSlipUrl != null) details.put("bankSlipUrl", bankSlipUrl);
        if (transactionRef != null) details.put("transactionRef", transactionRef);

        PaymentResult result = processor.process(tempPayment, details);
        status = result.getPaymentStatus();
        String ref = (result.getTransactionReference() != null && !result.getTransactionReference().isEmpty())
                ? result.getTransactionReference()
                : ((transactionRef != null && !transactionRef.trim().isEmpty()) ? transactionRef.trim() : ("REF-" + (System.currentTimeMillis() % 1000000)));

        // Ensure parent order exists in database so foreign key constraint succeeds in MySQL
        try (Connection conn = DatabaseUtil.getConnection()) {
            boolean orderExists = false;
            try (PreparedStatement checkOrder = conn.prepareStatement("SELECT order_id FROM orders WHERE order_id = ?")) {
                checkOrder.setString(1, orderId);
                try (ResultSet rs = checkOrder.executeQuery()) {
                    orderExists = rs.next();
                }
            }

            if (!orderExists) {
                String insOrder = "INSERT INTO orders (order_id, customer_name, customer_email, customer_phone, shipping_address, city, district, courier_name, tracking_number, subtotal, delivery_fee, discount_amount, total_amount, payment_method, payment_status, fulfillment_status, order_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement psOrder = conn.prepareStatement(insOrder)) {
                    psOrder.setString(1, orderId);
                    psOrder.setString(2, (customerName != null && !customerName.isEmpty()) ? customerName : "Customer (" + orderId + ")");
                    psOrder.setString(3, (customerEmail != null && !customerEmail.isEmpty()) ? customerEmail : "customer@melodymart.lk");
                    psOrder.setString(4, (customerPhone != null && !customerPhone.isEmpty()) ? customerPhone : "0770000000");
                    psOrder.setString(5, (billingAddress != null && !billingAddress.isEmpty()) ? billingAddress : "Colombo, Sri Lanka");
                    psOrder.setString(6, "Colombo");
                    psOrder.setString(7, "Colombo");
                    psOrder.setString(8, "Domex Courier");
                    psOrder.setString(9, "TRK-" + (System.currentTimeMillis() % 1000000));
                    psOrder.setDouble(10, amount);
                    psOrder.setDouble(11, 0.0);
                    psOrder.setDouble(12, 0.0);
                    psOrder.setDouble(13, amount);
                    psOrder.setString(14, paymentMethod);
                    psOrder.setString(15, status);
                    psOrder.setString(16, "PROCESSING");
                    psOrder.setString(17, now);
                    psOrder.executeUpdate();
                }
            }

            String sql = "INSERT INTO payments (transaction_id, order_id, amount, payment_method, payment_status, bank_slip_url, transaction_ref, refund_details, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, txnId);
                ps.setString(2, orderId);
                ps.setDouble(3, amount);
                ps.setString(4, paymentMethod);
                ps.setString(5, status);
                ps.setString(6, bankSlipUrl != null ? bankSlipUrl : "");
                ps.setString(7, ref);
                ps.setString(8, "");
                ps.setString(9, now);
                ps.executeUpdate();

                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) newId = gk.getInt(1);
                } catch (Exception ignored) {}

                System.out.println("[PaymentDAO] Saved payment transaction " + txnId + " to database.");
            }
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error inserting payment in DB: " + ex.getMessage());
        }

        Payment payment = new Payment(newId, txnId, orderId, amount, paymentMethod, status, bankSlipUrl, ref, "", now);
        paymentStore.put(txnId, payment);

        if (autoGenerateInvoice) {
            createOrUpdateInvoice(orderId, customerName, customerEmail, customerPhone, billingAddress, amount, paymentMethod, status);
        }

        return payment;
    }

    public Invoice createOrUpdateInvoice(String orderId, String customerName, String customerEmail,
                                          String customerPhone, String billingAddress, double totalAmount,
                                          String paymentMethod, String paymentStatus) {
        String invNo = "INV-2026-" + orderId.replace("ORD-2026-", "");
        Invoice inv = new Invoice();
        inv.setInvoiceNumber(invNo);
        inv.setOrderId(orderId);
        inv.setInvoiceDate(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
        inv.setCustomerName((customerName != null && !customerName.trim().isEmpty()) ? customerName : "Customer (" + orderId + ")");
        inv.setCustomerEmail(customerEmail != null ? customerEmail : "");
        inv.setCustomerPhone(customerPhone != null ? customerPhone : "");
        inv.setBillingAddress((billingAddress != null && !billingAddress.trim().isEmpty()) ? billingAddress : "Colombo, Sri Lanka");

        // 8% VAT tax calculation breakdown
        double vatRate = 0.08;
        double vat = totalAmount * (vatRate / (1.0 + vatRate));
        double subtotal = totalAmount - vat;

        inv.setSubtotal(Math.round(subtotal * 100.0) / 100.0);
        inv.setDeliveryFee(0.0);
        inv.setDiscount(0.0);
        inv.setVatRate(vatRate);
        inv.setVatAmount(Math.round(vat * 100.0) / 100.0);
        inv.setTotalAmount(totalAmount);
        inv.setPaymentStatus(paymentStatus);
        inv.setPaymentMethod(paymentMethod);

        List<String> items = new ArrayList<>();
        items.add("Musical Instruments & Accessories Package (" + orderId + ") | Qty: 1 | Net: LKR " + String.format("%,.2f", subtotal) + " + 8% VAT");
        inv.setLineItems(items);

        try (Connection conn = DatabaseUtil.getConnection()) {
            boolean exists = false;
            try (PreparedStatement check = conn.prepareStatement("SELECT invoice_number FROM invoices WHERE invoice_number = ?")) {
                check.setString(1, invNo);
                try (ResultSet rs = check.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String sql = "UPDATE invoices SET order_id=?, invoice_date=?, customer_name=?, billing_address=?, subtotal=?, delivery_fee=?, discount=?, vat_amount=?, total_amount=? WHERE invoice_number=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, orderId);
                    ps.setString(2, inv.getInvoiceDate());
                    ps.setString(3, inv.getCustomerName());
                    ps.setString(4, inv.getBillingAddress());
                    ps.setDouble(5, inv.getSubtotal());
                    ps.setDouble(6, inv.getDeliveryFee());
                    ps.setDouble(7, inv.getDiscount());
                    ps.setDouble(8, inv.getVatAmount());
                    ps.setDouble(9, inv.getTotalAmount());
                    ps.setString(10, invNo);
                    ps.executeUpdate();
                }
            } else {
                String sql = "INSERT INTO invoices (invoice_number, order_id, invoice_date, customer_name, billing_address, subtotal, delivery_fee, discount, vat_amount, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, invNo);
                    ps.setString(2, orderId);
                    ps.setString(3, inv.getInvoiceDate());
                    ps.setString(4, inv.getCustomerName());
                    ps.setString(5, inv.getBillingAddress());
                    ps.setDouble(6, inv.getSubtotal());
                    ps.setDouble(7, inv.getDeliveryFee());
                    ps.setDouble(8, inv.getDiscount());
                    ps.setDouble(9, inv.getVatAmount());
                    ps.setDouble(10, inv.getTotalAmount());
                    ps.executeUpdate();
                }
            }
            System.out.println("[PaymentDAO] Created/Updated itemized tax invoice " + invNo + " with 8% VAT in database.");
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error saving invoice to DB: " + ex.getMessage());
        }

        invoiceStore.put(invNo, inv);
        return inv;
    }

    public Invoice generateInvoice(Order order, Payment payment) {
        Invoice inv = new Invoice();
        String invNo = "INV-2026-" + (order.getOrderId().replace("ORD-2026-", ""));
        inv.setInvoiceNumber(invNo);
        inv.setOrderId(order.getOrderId());
        inv.setInvoiceDate(order.getOrderDate());
        inv.setCustomerName(order.getCustomerName());
        inv.setCustomerEmail(order.getCustomerEmail());
        inv.setCustomerPhone(order.getCustomerPhone());
        inv.setBillingAddress(order.getShippingAddress() + ", " + order.getCity() + ", " + order.getDistrict());
        inv.setSubtotal(order.getSubtotal());
        inv.setDeliveryFee(order.getDeliveryFee());
        inv.setDiscount(order.getDiscountAmount());

        double netAmount = order.getTotalAmount();
        double vatRate = 0.08;
        double vat = netAmount * (vatRate / (1.0 + vatRate)); // Included 8% VAT
        inv.setVatRate(vatRate);
        inv.setVatAmount(Math.round(vat * 100.0) / 100.0);
        inv.setTotalAmount(netAmount);

        inv.setPaymentStatus((payment != null) ? payment.getPaymentStatus() : order.getPaymentStatus());
        inv.setPaymentMethod((payment != null) ? payment.getPaymentMethod() : order.getPaymentMethod());

        List<String> items = new ArrayList<>();
        if (order.getItems() != null) {
            order.getItems().forEach(it -> {
                items.add(it.getProduct().getName() + " | Qty: " + it.getQuantity() + " | Price: LKR " + String.format("%,.2f", it.getSubtotal()));
            });
        }
        inv.setLineItems(items);

        try (Connection conn = DatabaseUtil.getConnection()) {
            boolean exists = false;
            try (PreparedStatement check = conn.prepareStatement("SELECT invoice_number FROM invoices WHERE invoice_number = ?")) {
                check.setString(1, invNo);
                try (ResultSet rs = check.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String sql = "UPDATE invoices SET order_id=?, invoice_date=?, customer_name=?, billing_address=?, subtotal=?, delivery_fee=?, discount=?, vat_amount=?, total_amount=? WHERE invoice_number=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, order.getOrderId());
                    ps.setString(2, inv.getInvoiceDate());
                    ps.setString(3, inv.getCustomerName());
                    ps.setString(4, inv.getBillingAddress());
                    ps.setDouble(5, inv.getSubtotal());
                    ps.setDouble(6, inv.getDeliveryFee());
                    ps.setDouble(7, inv.getDiscount());
                    ps.setDouble(8, inv.getVatAmount());
                    ps.setDouble(9, inv.getTotalAmount());
                    ps.setString(10, invNo);
                    ps.executeUpdate();
                }
            } else {
                String sql = "INSERT INTO invoices (invoice_number, order_id, invoice_date, customer_name, billing_address, subtotal, delivery_fee, discount, vat_amount, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, invNo);
                    ps.setString(2, order.getOrderId());
                    ps.setString(3, inv.getInvoiceDate());
                    ps.setString(4, inv.getCustomerName());
                    ps.setString(5, inv.getBillingAddress());
                    ps.setDouble(6, inv.getSubtotal());
                    ps.setDouble(7, inv.getDeliveryFee());
                    ps.setDouble(8, inv.getDiscount());
                    ps.setDouble(9, inv.getVatAmount());
                    ps.setDouble(10, inv.getTotalAmount());
                    ps.executeUpdate();
                }
            }
            System.out.println("[PaymentDAO] Saved VAT invoice " + invNo + " to database.");
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error saving invoice to DB: " + ex.getMessage());
        }

        invoiceStore.put(invNo, inv);
        return inv;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public Payment getPaymentByTxnId(String txnId) {
        return paymentStore.get(txnId);
    }

    public static Payment getPaymentByOrderId(String orderId) {
        for (Payment p : paymentStore.values()) {
            if (p.getOrderId().equalsIgnoreCase(orderId)) {
                return p;
            }
        }
        return null;
    }

    public List<Payment> getAllPayments() {
        return paymentStore.values().stream()
                .sorted(Comparator.comparing(Payment::getTimestamp).reversed())
                .collect(Collectors.toList());
    }

    public List<Payment> getPaymentsByStatus(String status) {
        if (status == null || status.trim().isEmpty() || "ALL".equalsIgnoreCase(status)) {
            return getAllPayments();
        }
        return paymentStore.values().stream()
                .filter(p -> status.equalsIgnoreCase(p.getPaymentStatus()))
                .sorted(Comparator.comparing(Payment::getTimestamp).reversed())
                .collect(Collectors.toList());
    }

    public List<Payment> getCustomerTransactionHistory(String query) {
        if (query == null || query.trim().isEmpty()) {
            return getAllPayments();
        }
        String q = query.trim().toLowerCase();
        return paymentStore.values().stream()
                .filter(p -> p.getTransactionId().toLowerCase().contains(q)
                        || p.getOrderId().toLowerCase().contains(q)
                        || (p.getTransactionRef() != null && p.getTransactionRef().toLowerCase().contains(q)))
                .sorted(Comparator.comparing(Payment::getTimestamp).reversed())
                .collect(Collectors.toList());
    }

    public List<Invoice> getAllInvoices() {
        return invoiceStore.values().stream()
                .sorted(Comparator.comparing(Invoice::getInvoiceNumber).reversed())
                .collect(Collectors.toList());
    }

    public Invoice getInvoiceByNumber(String invoiceNumber) {
        return invoiceStore.get(invoiceNumber);
    }

    public Invoice getInvoiceByOrderId(String orderId) {
        for (Invoice inv : invoiceStore.values()) {
            if (inv.getOrderId().equalsIgnoreCase(orderId)) {
                return inv;
            }
        }
        return null;
    }

    // ==========================================
    // UPDATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    /**
     * [UPDATE] Update transaction status following manual bank slip review or payment gateway webhooks.
     */
    public boolean updatePaymentStatus(String txnId, String newStatus, String notes) {
        Payment p = paymentStore.get(txnId);
        if (p == null) return false;

        String ref = p.getTransactionRef();
        if (notes != null && !notes.trim().isEmpty()) {
            ref = (ref != null && !ref.isEmpty() ? ref + " | " : "") + notes.trim();
        }

        String sql = "UPDATE payments SET payment_status=?, transaction_ref=? WHERE transaction_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, ref);
            ps.setString(3, txnId);
            ps.executeUpdate();
            System.out.println("[PaymentDAO] Updated status for " + txnId + " to " + newStatus + " in database.");
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error updating payment status in DB: " + ex.getMessage());
        }

        p.setPaymentStatus(newStatus);
        p.setTransactionRef(ref);

        // Synchronize corresponding invoice status
        Invoice inv = getInvoiceByOrderId(p.getOrderId());
        if (inv != null) {
            inv.setPaymentStatus(newStatus);
        }
        return true;
    }

    /**
     * [UPDATE] Record processed refund details.
     */
    public boolean recordRefund(String txnId, double refundAmount, String refundReason, String refundRef) throws Exception {
        utils.ValidationUtil.validateRefundReason(refundReason);
        Payment p = paymentStore.get(txnId);
        if (p == null) return false;

        double refAmt = (refundAmount > 0) ? refundAmount : p.getAmount();
        String refundDetails = "Refund LKR " + String.format("%,.2f", refAmt) + " on " +
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) +
                " | Reason: " + refundReason.trim() +
                (refundRef != null && !refundRef.trim().isEmpty() ? " | Ref: " + refundRef.trim() : "");

        String sql = "UPDATE payments SET payment_status='REFUNDED', refund_details=? WHERE transaction_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, refundDetails);
            ps.setString(2, txnId);
            ps.executeUpdate();
            System.out.println("[PaymentDAO] Recorded refund for " + txnId + " in database: " + refundDetails);
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error recording refund in DB: " + ex.getMessage());
        }

        p.setPaymentStatus("REFUNDED");
        p.setRefundDetails(refundDetails);

        Invoice inv = getInvoiceByOrderId(p.getOrderId());
        if (inv != null) {
            inv.setPaymentStatus("REFUNDED");
        }
        return true;
    }

    public boolean recordRefund(String txnId, String refundReason) throws Exception {
        return recordRefund(txnId, 0.0, refundReason, "");
    }

    // ==========================================
    // DELETE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    /**
     * [DELETE] Void failed or unverified payment attempts.
     */
    public boolean voidPayment(String txnId, String reason) {
        Payment p = paymentStore.get(txnId);
        if (p != null) {
            String details = "Voided on " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) +
                    (reason != null && !reason.trim().isEmpty() ? ": " + reason.trim() : " by Accounts Officer.");
            String sql = "UPDATE payments SET payment_status='VOIDED', refund_details=? WHERE transaction_id=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, details);
                ps.setString(2, txnId);
                ps.executeUpdate();
                System.out.println("[PaymentDAO] Voided payment " + txnId + " in database.");
            } catch (Exception ex) {
                System.err.println("[PaymentDAO] Error voiding payment in DB: " + ex.getMessage());
            }

            p.setPaymentStatus("VOIDED");
            p.setRefundDetails(details);

            Invoice inv = getInvoiceByOrderId(p.getOrderId());
            if (inv != null) {
                inv.setPaymentStatus("VOIDED");
            }
            return true;
        }
        return false;
    }

    public boolean voidPayment(String txnId) {
        return voidPayment(txnId, "Voided by Accounts Officer.");
    }

    /**
     * [DELETE] Archive obsolete billing records.
     */
    public boolean archivePayment(String txnId) {
        Payment p = paymentStore.get(txnId);
        if (p != null) {
            String sql = "UPDATE payments SET payment_status='ARCHIVED' WHERE transaction_id=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, txnId);
                ps.executeUpdate();
                System.out.println("[PaymentDAO] Archived billing record " + txnId + " in database.");
            } catch (Exception ex) {
                System.err.println("[PaymentDAO] Error archiving payment in DB: " + ex.getMessage());
            }

            p.setPaymentStatus("ARCHIVED");
            return true;
        }
        return false;
    }

    /**
     * [DELETE] Cancel invalidated draft invoices.
     */
    public boolean cancelDraftInvoice(String invoiceNumber, String reason) {
        Invoice inv = invoiceStore.get(invoiceNumber);
        if (inv != null) {
            inv.setPaymentStatus("CANCELLED");
            String newName = (inv.getCustomerName() != null ? inv.getCustomerName() : "") +
                    " [CANCELLED DRAFT" + (reason != null && !reason.trim().isEmpty() ? ": " + reason.trim() : "") + "]";
            inv.setCustomerName(newName);

            String sql = "UPDATE invoices SET customer_name=? WHERE invoice_number=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newName);
                ps.setString(2, invoiceNumber);
                ps.executeUpdate();
                System.out.println("[PaymentDAO] Cancelled draft invoice " + invoiceNumber + " in database.");
            } catch (Exception ex) {
                System.err.println("[PaymentDAO] Notice cancelling draft invoice in DB: " + ex.getMessage());
            }
            return true;
        }
        return false;
    }

    public boolean cancelDraftInvoice(String invoiceNumber) {
        return cancelDraftInvoice(invoiceNumber, "Invalidated Draft");
    }

    public boolean deletePayment(String txnId) {
        String sql = "DELETE FROM payments WHERE transaction_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, txnId);
            ps.executeUpdate();
            System.out.println("[PaymentDAO] Permanently removed payment " + txnId + " from database.");
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error deleting payment from DB: " + ex.getMessage());
        }

        paymentStore.remove(txnId);
        return true;
    }

    public boolean deleteInvoice(String invoiceNumber) {
        String sql = "DELETE FROM invoices WHERE invoice_number=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, invoiceNumber);
            ps.executeUpdate();
            System.out.println("[PaymentDAO] Permanently removed invoice " + invoiceNumber + " from database.");
        } catch (Exception ex) {
            System.err.println("[PaymentDAO] Error deleting invoice from DB: " + ex.getMessage());
        }

        invoiceStore.remove(invoiceNumber);
        return true;
    }
}
