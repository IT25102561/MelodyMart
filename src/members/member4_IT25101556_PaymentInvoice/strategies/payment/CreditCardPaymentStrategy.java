package strategies.payment;

import models.Payment;
import utils.ValidationUtil;
import java.util.Map;
import java.util.UUID;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Online Credit / Debit Card payment processing (Visa, Mastercard, AMEX).
 * Validates card credentials via Luhn-compatible rules, contacts simulated
 * gateway API, and grants instant approval upon authorization.
 */
public class CreditCardPaymentStrategy implements PaymentStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public PaymentResult processPayment(Payment payment, Map<String, String> paymentDetails) throws Exception {
        if (payment == null) {
            throw new Exception("ERR_PAY_NULL: Payment entity cannot be null.");
        }
        if (payment.getAmount() <= 0) {
            throw new Exception("ERR_PAY_INVALID_AMOUNT: Payment amount must be greater than zero.");
        }

        // Validate card credentials if supplied in details map
        if (paymentDetails != null && paymentDetails.containsKey("cardNumber")) {
            String cardNo = paymentDetails.get("cardNumber");
            String expiry = paymentDetails.get("cardExpiry");
            String cvv = paymentDetails.get("cardCvv");
            ValidationUtil.validateCardDetails(cardNo, expiry, cvv);
        }

        String authCode = "CC-AUTH-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        payment.setPaymentMethod("CREDIT_CARD");
        payment.setPaymentStatus("PAID");
        payment.setTransactionRef(authCode);

        return new PaymentResult(true, authCode, "PAID", "Card transaction authorized successfully by Payment Gateway.");
    }

    @Override
    public String getPaymentMethodName() {
        return "CREDIT_CARD";
    }

    @Override
    public boolean requiresManualVerification() {
        return false;
    }
}
