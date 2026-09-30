package strategies.cart;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Promotional Free Delivery for premium / high-value musical instrument purchases.
 * Waives all shipping fees if the subtotal exceeds the promotional threshold (50,000 LKR);
 * otherwise falls back to standard regional courier pricing.
 */
public class FreeOverThresholdShippingStrategy implements ShippingCostStrategy {
    private static final long serialVersionUID = 1L;

    public static final double PROMO_THRESHOLD_LKR = 50000.0;
    private final StandardCourierShippingStrategy fallback = new StandardCourierShippingStrategy();

    @Override
    public double calculateShippingFee(String district, double orderSubtotal) {
        if (orderSubtotal >= PROMO_THRESHOLD_LKR) {
            return 0.0;
        }
        return fallback.calculateShippingFee(district, orderSubtotal);
    }

    @Override
    public String getMethodName() {
        return "Promotional Free Delivery (Orders > 50,000 LKR)";
    }

    @Override
    public int getEstimatedDeliveryDays() {
        return 3;
    }
}
