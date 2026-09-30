package strategies.payment;

import models.Payment;
import java.util.Map;
import java.util.UUID;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Cash on Delivery (COD) payment processing.
 * Creates pending collection record for assigned courier delivery riders.
 */
public class CashOnDeliveryPaymentStrategy implements PaymentStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public PaymentResult processPayment(Payment payment, Map<String, String> paymentDetails) throws Exception {
        if (payment == null) {
            throw new Exception("ERR_PAY_NULL: Payment entity cannot be null.");
        }
        if (payment.getAmount() <= 0) {
            throw new Exception("ERR_PAY_INVALID_AMOUNT: Payment amount must be greater than zero.");
        }

        String codRef = "COD-REC-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        payment.setPaymentMethod("COD");
        payment.setPaymentStatus("PENDING");
        payment.setTransactionRef(codRef);

        return new PaymentResult(true, codRef, "PENDING", "Cash on Delivery booking logged. Payment to be collected upon doorstep delivery.");
    }

    @Override
    public String getPaymentMethodName() {
        return "COD";
    }

    @Override
    public boolean requiresManualVerification() {
        return false;
    }
}
