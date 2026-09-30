package strategies.cart;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Priority Express Delivery (e.g. Domex / Prompt Express) with guaranteed 24-48h dispatch.
 * Applies a 450 LKR speed surcharge over base zonal rates.
 */
public class ExpressDomexShippingStrategy implements ShippingCostStrategy {
    private static final long serialVersionUID = 1L;

    private final StandardCourierShippingStrategy baseStrategy = new StandardCourierShippingStrategy();
    private static final double EXPRESS_SURCHARGE = 450.0;

    @Override
    public double calculateShippingFee(String district, double orderSubtotal) {
        return baseStrategy.calculateShippingFee(district, orderSubtotal) + EXPRESS_SURCHARGE;
    }

    @Override
    public String getMethodName() {
        return "Express Domex Priority (1-2 Days)";
    }

    @Override
    public int getEstimatedDeliveryDays() {
        return 1;
    }
}
