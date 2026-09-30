package models;

import java.io.Serializable;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 */
public class Fulfillment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String fulfillmentId;
    private String orderId;
    private String customerName;
    private String shippingAddress;
    private String courierName; // Koombiyo, Domex, Pronto, Certis Lanka
    private String trackingNumber;
    private String deliveryStatus; // PROCESSING, SHIPPED, IN_TRANSIT, DELIVERED, CANCELLED
    private double codAmount;
    private boolean codCollected;
    private String dispatchedAt;
    private String deliveredAt;
    private String notes;

    public Fulfillment() {}

    public Fulfillment(int id, String fulfillmentId, String orderId, String customerName,
                       String shippingAddress, String courierName, String trackingNumber,
                       String deliveryStatus, double codAmount, boolean codCollected,
                       String dispatchedAt, String deliveredAt, String notes) {
        this.id = id;
        this.fulfillmentId = fulfillmentId;
        this.orderId = orderId;
        this.customerName = customerName;
        this.shippingAddress = shippingAddress;
        this.courierName = courierName;
        this.trackingNumber = trackingNumber;
        this.deliveryStatus = deliveryStatus;
        this.codAmount = codAmount;
        this.codCollected = codCollected;
        this.dispatchedAt = dispatchedAt;
        this.deliveredAt = deliveredAt;
        this.notes = notes;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFulfillmentId() { return fulfillmentId; }
    public void setFulfillmentId(String fulfillmentId) { this.fulfillmentId = fulfillmentId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getCourierName() { return courierName; }
    public void setCourierName(String courierName) { this.courierName = courierName; }

    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }

    public String getDeliveryStatus() { return deliveryStatus; }
    public void setDeliveryStatus(String deliveryStatus) { this.deliveryStatus = deliveryStatus; }

    public double getCodAmount() { return codAmount; }
    public void setCodAmount(double codAmount) { this.codAmount = codAmount; }

    public boolean isCodCollected() { return codCollected; }
    public void setCodCollected(boolean codCollected) { this.codCollected = codCollected; }

    public String getDispatchedAt() { return dispatchedAt; }
    public void setDispatchedAt(String dispatchedAt) { this.dispatchedAt = dispatchedAt; }

    public String getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(String deliveredAt) { this.deliveredAt = deliveredAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
