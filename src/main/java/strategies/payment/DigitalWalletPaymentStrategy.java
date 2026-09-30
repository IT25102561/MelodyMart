package strategies.payment;

import models.Payment;
import java.util.Map;
import java.util.UUID;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Sri Lankan Digital Mobile Wallet payment processing (eZ Cash, Dialog Genie, FriMi).
 * Direct instant API confirmation simulating instant electronic funds clearance.
 */
public class DigitalWalletPaymentStrategy implements PaymentStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public PaymentResult processPayment(Payment payment, Map<String, String> paymentDetails) throws Exception {
        if (payment == null) {
            throw new Exception("ERR_PAY_NULL: Payment entity cannot be null.");
        }
        if (payment.getAmount() <= 0) {
            throw new Exception("ERR_PAY_INVALID_AMOUNT: Payment amount must be greater than zero.");
        }

        String walletTxn = "WLT-CLR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        payment.setPaymentMethod("DIGITAL_WALLET");
        payment.setPaymentStatus("PAID");
        payment.setTransactionRef(walletTxn);

        return new PaymentResult(true, walletTxn, "PAID", "Mobile digital wallet transaction cleared instantly.");
    }

    @Override
    public String getPaymentMethodName() {
        return "DIGITAL_WALLET";
    }

    @Override
    public boolean requiresManualVerification() {
        return false;
    }
}
