package strategies.payment;

import models.Payment;
import java.io.Serializable;
import java.util.Map;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Strategy Design Pattern - Strategy Interface:
 * Encapsulates payment validation, gateway transmission, and transaction settlement
 * across distinct channels (Credit/Debit Card, Bank Deposit Transfer, Cash on Delivery, Mobile Wallets).
 */
public interface PaymentStrategy extends Serializable {

    /**
     * Executes the payment workflow for the specified transaction.
     *
     * @param payment The core Payment entity with order and amount details.
     * @param paymentDetails Contextual parameters (card number, slip reference, notes, etc.).
     * @return PaymentResult indicating transaction status and confirmation details.
     * @throws Exception If input validation or gateway communication fails.
     */
    PaymentResult processPayment(Payment payment, Map<String, String> paymentDetails) throws Exception;

    /**
     * Returns the payment method code.
     *
     * @return Method identifier (e.g. "CREDIT_CARD", "BANK_TRANSFER", "COD").
     */
    String getPaymentMethodName();

    /**
     * Indicates whether this payment method requires manual finance staff verification.
     *
     * @return true for manual audit (e.g. bank slip review); false for automated clearing.
     */
    boolean requiresManualVerification();
}
