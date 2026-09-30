package strategies.payment;

import java.io.Serializable;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Outcome result DTO returned by PaymentStrategy execution.
 */
public class PaymentResult implements Serializable {
    private static final long serialVersionUID = 1L;

    private boolean successful;
    private String transactionReference;
    private String paymentStatus;
    private String message;

    public PaymentResult() {}

    public PaymentResult(boolean successful, String transactionReference, String paymentStatus, String message) {
        this.successful = successful;
        this.transactionReference = transactionReference;
        this.paymentStatus = paymentStatus;
        this.message = message;
    }

    public boolean isSuccessful() {
        return successful;
    }

    public void setSuccessful(boolean successful) {
        this.successful = successful;
    }

    public String getTransactionReference() {
        return transactionReference;
    }

    public void setTransactionReference(String transactionReference) {
        this.transactionReference = transactionReference;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
