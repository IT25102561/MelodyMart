package strategies.payment;

import models.Payment;
import java.io.Serializable;
import java.util.Map;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Strategy Design Pattern - Context Class:
 * The PaymentProcessor acts as the Context in GoF Strategy Pattern. It maintains
 * a reference to a PaymentStrategy and delegates payment processing requests to it,
 * allowing dynamic strategy swapping at runtime.
 */
public class PaymentProcessor implements Serializable {
    private static final long serialVersionUID = 1L;

    private PaymentStrategy strategy;

    public PaymentProcessor() {
        this.strategy = new CreditCardPaymentStrategy();
    }

    public PaymentProcessor(PaymentStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new CreditCardPaymentStrategy();
    }

    public void setPaymentStrategy(PaymentStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public PaymentStrategy getPaymentStrategy() {
        return this.strategy;
    }

    public PaymentResult process(Payment payment, Map<String, String> paymentDetails) throws Exception {
        if (this.strategy == null) {
            throw new IllegalStateException("ERR_PAY_NO_STRATEGY: No PaymentStrategy has been configured.");
        }
        return this.strategy.processPayment(payment, paymentDetails);
    }
}
