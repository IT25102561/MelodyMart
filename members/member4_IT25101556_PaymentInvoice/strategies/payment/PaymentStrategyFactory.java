package strategies.payment;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 *
 * Factory utility to instantiate the correct PaymentStrategy based on paymentMethod string.
 */
public class PaymentStrategyFactory {

    /**
     * Returns the concrete PaymentStrategy corresponding to the given payment method identifier.
     *
     * @param paymentMethod Code e.g. "CREDIT_CARD", "BANK_TRANSFER", "COD", "DIGITAL_WALLET".
     * @return Matching PaymentStrategy, defaulting to CreditCardPaymentStrategy.
     */
    public static PaymentStrategy getStrategy(String paymentMethod) {
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            return new CreditCardPaymentStrategy();
        }
        String key = paymentMethod.trim().toUpperCase();
        switch (key) {
            case "BANK_TRANSFER":
            case "BANK":
            case "SLIP":
                return new BankTransferPaymentStrategy();
            case "COD":
            case "CASH_ON_DELIVERY":
                return new CashOnDeliveryPaymentStrategy();
            case "DIGITAL_WALLET":
            case "WALLET":
            case "EZCASH":
            case "FRIMI":
            case "GENIE":
                return new DigitalWalletPaymentStrategy();
            case "CREDIT_CARD":
            case "CARD":
            case "VISA":
            case "MASTERCARD":
            default:
                return new CreditCardPaymentStrategy();
        }
    }
}
