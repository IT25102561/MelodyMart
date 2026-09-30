package models;

import java.io.Serializable;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 */
public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String transactionId;
    private String orderId;
    private double amount;
    private String paymentMethod; // CREDIT_CARD, BANK_TRANSFER, DIGITAL_WALLET, COD
    private String paymentStatus; // PENDING, PAID, FAILED, REFUNDED
    private String bankSlipUrl;
    private String transactionRef;
    private String refundDetails;
    private String timestamp;

    public Payment() {}

    public Payment(int id, String transactionId, String orderId, double amount,
                   String paymentMethod, String paymentStatus, String bankSlipUrl,
                   String transactionRef, String refundDetails, String timestamp) {
        this.id = id;
        this.transactionId = transactionId;
        this.orderId = orderId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.bankSlipUrl = bankSlipUrl;
        this.transactionRef = transactionRef;
        this.refundDetails = refundDetails;
        this.timestamp = timestamp;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getBankSlipUrl() { return bankSlipUrl; }
    public void setBankSlipUrl(String bankSlipUrl) { this.bankSlipUrl = bankSlipUrl; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getRefundDetails() { return refundDetails; }
    public void setRefundDetails(String refundDetails) { this.refundDetails = refundDetails; }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
}
