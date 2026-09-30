package dao;

import models.Fulfillment;
import models.ReturnRequest;
import strategies.fulfillment.*;
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
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 */
public class FulfillmentDAO {
    private static final Map<String, Fulfillment> fulfillmentStore = new ConcurrentHashMap<>();
    private static final Map<String, ReturnRequest> returnStore = new ConcurrentHashMap<>();
    private static final AtomicInteger dispatchCounter = new AtomicInteger(200);
    private static final AtomicInteger returnCounter = new AtomicInteger(50);

    static {
        loadFulfillmentsFromDatabase();
    }

    public static synchronized void loadFulfillmentsFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 1. Load Fulfillments
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, fulfillment_id, order_id, customer_name, shipping_address, courier_name, tracking_number, delivery_status, cod_amount, cod_collected, dispatched_at, delivered_at, notes FROM fulfillments ORDER BY dispatched_at DESC")) {

                int maxDispatch = 200;
                fulfillmentStore.clear();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String fId = rs.getString("fulfillment_id");
                    String oId = rs.getString("order_id");
                    String cust = rs.getString("customer_name");
                    String addr = rs.getString("shipping_address");
                    String courier = rs.getString("courier_name");
                    String track = rs.getString("tracking_number");
                    String status = rs.getString("delivery_status");
                    double cod = rs.getDouble("cod_amount");
                    boolean collected = rs.getInt("cod_collected") == 1;
                    String dispAt = rs.getString("dispatched_at");
                    String delAt = rs.getString("delivered_at");
                    String notes = rs.getString("notes");

                    Fulfillment f = new Fulfillment(id, fId, oId, cust, addr, courier, track, status, cod, collected, dispAt, delAt, notes);
                    fulfillmentStore.put(track, f);
                    if (id > maxDispatch) maxDispatch = id;
                    if (fId != null && fId.startsWith("DSP-2026-")) {
                        try {
                            int dnum = Integer.parseInt(fId.substring("DSP-2026-".length()));
                            if (dnum > maxDispatch) maxDispatch = dnum;
                        } catch (Exception ignored) {}
                    }
                }
                dispatchCounter.set(Math.max(maxDispatch, 200));
            }

            // 2. Load Return Requests
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, ticket_id, order_id, customer_name, customer_email, reason, item_details, stage, resolution_notes, created_at FROM return_requests ORDER BY created_at DESC")) {

                int maxReturn = 50;
                returnStore.clear();

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String tId = rs.getString("ticket_id");
                    String oId = rs.getString("order_id");
                    String cName = rs.getString("customer_name");
                    String cEmail = rs.getString("customer_email");
                    String reason = rs.getString("reason");
                    String items = rs.getString("item_details");
                    String stage = rs.getString("stage");
                    String resNotes = rs.getString("resolution_notes");
                    String createdAt = rs.getString("created_at");

                    ReturnRequest r = new ReturnRequest(id, tId, oId, cName, cEmail, reason, items, stage, resNotes, createdAt);
                    returnStore.put(tId, r);
                    if (id > maxReturn) maxReturn = id;
                    if (tId != null && tId.startsWith("RET-2026-")) {
                        try {
                            int rnum = Integer.parseInt(tId.substring("RET-2026-".length()));
                            if (rnum > maxReturn) maxReturn = rnum;
                        } catch (Exception ignored) {}
                    }
                }
                returnCounter.set(Math.max(maxReturn, 50));
            }

            System.out.println("[FulfillmentDAO] Successfully loaded " + fulfillmentStore.size() + " fulfillments and " + returnStore.size() + " return tickets from database.");

        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Notice loading fulfillments/returns from DB: " + ex.getMessage());
        }
    }

    // ==========================================
    // CREATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public Fulfillment createDispatchJob(String orderId, String customerName, String shippingAddress,
                                         String courierName, double codAmount) throws Exception {
        utils.ValidationUtil.validateDispatch(orderId);
        int newId = dispatchCounter.incrementAndGet();
        String dispatchId = "DSP-2026-" + String.format("%04d", newId);
        String prefix = "KB-";
        if (courierName != null && courierName.toLowerCase().contains("domex")) prefix = "DX-";
        else if (courierName != null && courierName.toLowerCase().contains("pronto")) prefix = "PR-";
        String trackingNo = prefix + "LK-" + (System.currentTimeMillis() % 1000000);
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        String sql = "INSERT INTO fulfillments (fulfillment_id, order_id, customer_name, shipping_address, courier_name, tracking_number, delivery_status, cod_amount, cod_collected, dispatched_at, delivered_at, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dispatchId);
            ps.setString(2, orderId);
            ps.setString(3, customerName);
            ps.setString(4, shippingAddress);
            ps.setString(5, courierName != null ? courierName : "Koombiyo Delivery");
            ps.setString(6, trackingNo);
            ps.setString(7, "PROCESSING");
            ps.setDouble(8, codAmount);
            ps.setInt(9, 0);
            ps.setString(10, now);
            ps.setString(11, "");
            ps.setString(12, "Courier booking logged.");
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) newId = gk.getInt(1);
            } catch (Exception ignored) {}

            System.out.println("[FulfillmentDAO] Created dispatch job " + dispatchId + " in database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error inserting dispatch job into DB: " + ex.getMessage());
        }

        Fulfillment f = new Fulfillment(newId, dispatchId, orderId, customerName, shippingAddress,
                courierName, trackingNo, "PROCESSING", codAmount, false, now, "", "Courier booking logged.");
        fulfillmentStore.put(trackingNo, f);
        return f;
    }

    public ReturnRequest submitReturnRequest(String orderId, String customerName, String email,
                                             String reason, String itemDetails) throws Exception {
        return submitReturnRequest(orderId, customerName, email, reason, itemDetails, ReturnStrategyFactory.getStrategy(reason));
    }

    public ReturnRequest submitReturnRequest(String orderId, String customerName, String email,
                                             String reason, String itemDetails, ReturnValidationStrategy returnStrategy) throws Exception {
        utils.ValidationUtil.validateReturnRequest(orderId, reason, email);
        int newId = returnCounter.incrementAndGet();
        String ticketId = "RET-2026-" + String.format("%03d", newId);
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // Strategy Pattern Execution via ReturnValidationContext
        ReturnValidationStrategy activeStrategy = (returnStrategy != null) ? returnStrategy : ReturnStrategyFactory.getStrategy(reason);
        ReturnValidationContext context = new ReturnValidationContext(activeStrategy);

        ReturnRequest tempRequest = new ReturnRequest(newId, ticketId, orderId, customerName, email, reason, itemDetails, "UNDER_REVIEW", "", now);
        if (!context.validate(tempRequest)) {
            throw new Exception("ERR_RET_INELIGIBLE: Return claim is not eligible under policy: " + activeStrategy.getPolicyName());
        }

        String initialStage = context.resolveInitialStage(tempRequest);
        String initialNotes = context.generateResolution(tempRequest);

        String sql = "INSERT INTO return_requests (ticket_id, order_id, customer_name, customer_email, reason, item_details, stage, resolution_notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, ticketId);
            ps.setString(2, orderId);
            ps.setString(3, customerName);
            ps.setString(4, email);
            ps.setString(5, reason);
            ps.setString(6, itemDetails != null ? itemDetails : "");
            ps.setString(7, initialStage);
            ps.setString(8, initialNotes);
            ps.setString(9, now);
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) newId = gk.getInt(1);
            } catch (Exception ignored) {}

            System.out.println("[FulfillmentDAO] Created return ticket " + ticketId + " [Policy: " + activeStrategy.getPolicyName() + "] in database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error inserting return ticket into DB: " + ex.getMessage());
        }

        ReturnRequest r = new ReturnRequest(newId, ticketId, orderId, customerName, email, reason, itemDetails, initialStage, initialNotes, now);
        returnStore.put(ticketId, r);
        return r;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public Fulfillment getFulfillmentByTracking(String trackingNumber) {
        if (trackingNumber == null) return null;
        for (Fulfillment f : fulfillmentStore.values()) {
            if (trackingNumber.equalsIgnoreCase(f.getTrackingNumber()) || trackingNumber.equalsIgnoreCase(f.getOrderId())) {
                return f;
            }
        }
        return null;
    }

    public Fulfillment getFulfillmentByOrderId(String orderId) {
        for (Fulfillment f : fulfillmentStore.values()) {
            if (f.getOrderId().equalsIgnoreCase(orderId)) {
                return f;
            }
        }
        return null;
    }

    public List<Fulfillment> getAllFulfillments() {
        return fulfillmentStore.values().stream()
                .sorted(Comparator.comparing(Fulfillment::getDispatchedAt).reversed())
                .collect(Collectors.toList());
    }

    public List<ReturnRequest> getAllReturns() {
        return returnStore.values().stream()
                .sorted(Comparator.comparing(ReturnRequest::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    public ReturnRequest getReturnById(String ticketId) {
        return returnStore.get(ticketId);
    }

    // ==========================================
    // UPDATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean updateDeliveryStatus(String trackingNumber, String newStatus, String notes) {
        Fulfillment f = getFulfillmentByTracking(trackingNumber);
        if (f == null) return false;

        String deliveredAt = f.getDeliveredAt();
        if ("DELIVERED".equalsIgnoreCase(newStatus)) {
            deliveredAt = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }

        String noteVal = (notes != null && !notes.trim().isEmpty()) ? notes.trim() : f.getNotes();

        String sql = "UPDATE fulfillments SET delivery_status=?, notes=?, delivered_at=? WHERE tracking_number=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, noteVal);
            ps.setString(3, deliveredAt);
            ps.setString(4, trackingNumber);
            ps.executeUpdate();
            System.out.println("[FulfillmentDAO] Updated tracking " + trackingNumber + " to " + newStatus + " in database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error updating delivery status in DB: " + ex.getMessage());
        }

        f.setDeliveryStatus(newStatus);
        if (notes != null && !notes.trim().isEmpty()) f.setNotes(notes.trim());
        if ("DELIVERED".equalsIgnoreCase(newStatus)) f.setDeliveredAt(deliveredAt);
        return true;
    }

    public boolean recordCodMilestone(String trackingNumber, boolean collected) {
        Fulfillment f = getFulfillmentByTracking(trackingNumber);
        if (f == null) return false;

        String sql = "UPDATE fulfillments SET cod_collected=? WHERE tracking_number=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, collected ? 1 : 0);
            ps.setString(2, trackingNumber);
            ps.executeUpdate();
            System.out.println("[FulfillmentDAO] Recorded COD collection for " + trackingNumber + " in database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error updating COD in DB: " + ex.getMessage());
        }

        f.setCodCollected(collected);
        return true;
    }

    public boolean updateReturnStage(String ticketId, String newStage, String resolutionNotes) {
        ReturnRequest r = returnStore.get(ticketId);
        if (r == null) return false;

        String notes = (resolutionNotes != null && !resolutionNotes.trim().isEmpty()) ? resolutionNotes.trim() : r.getResolutionNotes();

        String sql = "UPDATE return_requests SET stage=?, resolution_notes=? WHERE ticket_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStage);
            ps.setString(2, notes);
            ps.setString(3, ticketId);
            ps.executeUpdate();
            System.out.println("[FulfillmentDAO] Updated return ticket " + ticketId + " stage to " + newStage + " in database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error updating return ticket in DB: " + ex.getMessage());
        }

        r.setStage(newStage);
        if (resolutionNotes != null && !resolutionNotes.trim().isEmpty()) {
            r.setResolutionNotes(resolutionNotes.trim());
        }
        return true;
    }

    // ==========================================
    // DELETE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean cancelDispatchOrder(String trackingNumber) {
        Fulfillment f = getFulfillmentByTracking(trackingNumber);
        if (f != null && "PROCESSING".equalsIgnoreCase(f.getDeliveryStatus())) {
            String sql = "UPDATE fulfillments SET delivery_status='CANCELLED', notes='Cancelled prior to courier handover.' WHERE tracking_number=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, trackingNumber);
                ps.executeUpdate();
            } catch (Exception ex) {
                System.err.println("[FulfillmentDAO] Error cancelling dispatch in DB: " + ex.getMessage());
            }

            f.setDeliveryStatus("CANCELLED");
            f.setNotes("Cancelled prior to courier handover.");
            return true;
        }
        return false;
    }

    public boolean dismissReturnRequest(String ticketId, String reason) {
        ReturnRequest r = returnStore.get(ticketId);
        if (r != null) {
            String notes = "Dismissed / Rejected: " + reason;
            String sql = "UPDATE return_requests SET stage='REJECTED', resolution_notes=? WHERE ticket_id=?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, notes);
                ps.setString(2, ticketId);
                ps.executeUpdate();
            } catch (Exception ex) {
                System.err.println("[FulfillmentDAO] Error rejecting return in DB: " + ex.getMessage());
            }

            r.setStage("REJECTED");
            r.setResolutionNotes(notes);
            return true;
        }
        return false;
    }

    public boolean deleteFulfillment(String trackingNumber) {
        String sql = "DELETE FROM fulfillments WHERE tracking_number=? OR fulfillment_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNumber);
            ps.setString(2, trackingNumber);
            ps.executeUpdate();
            System.out.println("[FulfillmentDAO] Permanently removed fulfillment " + trackingNumber + " from database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error deleting fulfillment from DB: " + ex.getMessage());
        }

        fulfillmentStore.entrySet().removeIf(entry -> 
            entry.getKey().equalsIgnoreCase(trackingNumber) || 
            (entry.getValue() != null && (trackingNumber.equalsIgnoreCase(entry.getValue().getTrackingNumber()) || trackingNumber.equalsIgnoreCase(entry.getValue().getFulfillmentId())))
        );
        return true;
    }

    public boolean deleteReturnRequest(String ticketId) {
        String sql = "DELETE FROM return_requests WHERE ticket_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketId);
            ps.executeUpdate();
            System.out.println("[FulfillmentDAO] Permanently removed return ticket " + ticketId + " from database.");
        } catch (Exception ex) {
            System.err.println("[FulfillmentDAO] Error deleting return ticket from DB: " + ex.getMessage());
        }

        returnStore.remove(ticketId);
        return true;
    }
}
