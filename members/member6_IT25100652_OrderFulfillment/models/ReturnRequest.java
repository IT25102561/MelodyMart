package models;

import java.io.Serializable;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Return and Warranty Claim entity
 */
public class ReturnRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String ticketId;
    private String orderId;
    private String customerName;
    private String customerEmail;
    private String reason; // DEFECTIVE_ON_ARRIVAL, TRANSIT_DAMAGE, WRONG_ITEM_RECEIVED, SOUND_DEFECT
    private String itemDetails;
    private String stage; // UNDER_REVIEW, APPROVED, REJECTED, COMPLETED
    private String resolutionNotes;
    private String createdAt;

    public ReturnRequest() {}

    public ReturnRequest(int id, String ticketId, String orderId, String customerName,
                         String customerEmail, String reason, String itemDetails,
                         String stage, String resolutionNotes, String createdAt) {
        this.id = id;
        this.ticketId = ticketId;
        this.orderId = orderId;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.reason = reason;
        this.itemDetails = itemDetails;
        this.stage = stage;
        this.resolutionNotes = resolutionNotes;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTicketId() { return ticketId; }
    public void setTicketId(String ticketId) { this.ticketId = ticketId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getItemDetails() { return itemDetails; }
    public void setItemDetails(String itemDetails) { this.itemDetails = itemDetails; }

    public String getStage() { return stage; }
    public void setStage(String stage) { this.stage = stage; }

    public String getResolutionNotes() { return resolutionNotes; }
    public void setResolutionNotes(String resolutionNotes) { this.resolutionNotes = resolutionNotes; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
