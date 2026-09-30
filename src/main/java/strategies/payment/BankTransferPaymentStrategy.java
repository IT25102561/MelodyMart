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
 * Direct Bank Transfer / Deposit payment processing.
 * Requires verification of customer deposit receipt slip and sets status to
 * PENDING awaiting audit by MelodyMart finance staff.
 */
public class BankTransferPaymentStrategy implements PaymentStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public PaymentResult processPayment(Payment payment, Map<String, String> paymentDetails) throws Exception {
        if (payment == null) {
            throw new Exception("ERR_PAY_NULL: Payment entity cannot be null.");
        }
        if (payment.getAmount() <= 0) {
            throw new Exception("ERR_PAY_INVALID_AMOUNT: Payment amount must be greater than zero.");
        }

        String slipUrl = payment.getBankSlipUrl();
        if (slipUrl == null && paymentDetails != null) {
            slipUrl = paymentDetails.get("bankSlipUrl");
        }

        if (slipUrl == null || slipUrl.trim().isEmpty()) {
            throw new Exception(ValidationUtil.ERR_PAY_UNVERIFIED_SLIP + ": A valid bank deposit receipt slip or image reference is required.");
        }

        String refNo = "BNK-DEP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        payment.setPaymentMethod("BANK_TRANSFER");
        payment.setPaymentStatus("PENDING");
        payment.setBankSlipUrl(slipUrl.trim());
        payment.setTransactionRef(refNo);

        return new PaymentResult(true, refNo, "PENDING", "Bank slip submitted. Awaiting verification by MelodyMart finance team.");
    }

    @Override
    public String getPaymentMethodName() {
        return "BANK_TRANSFER";
    }

    @Override
    public boolean requiresManualVerification() {
        return true;
    }
}
