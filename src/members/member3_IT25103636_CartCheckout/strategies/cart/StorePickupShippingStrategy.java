package strategies.cart;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * In-store click & collect pickup at MelodyMart Colombo 03 Flagship Showroom.
 * Completely free of delivery charges (0 LKR).
 */
public class StorePickupShippingStrategy implements ShippingCostStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public double calculateShippingFee(String district, double orderSubtotal) {
        return 0.0;
    }

    @Override
    public String getMethodName() {
        return "Showroom Store Pickup (Colombo Flagship)";
    }

    @Override
    public int getEstimatedDeliveryDays() {
        return 0; // Same-day / Ready immediately
    }
}
