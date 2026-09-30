package strategies.cart;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Standard Islandwide Courier shipping with regional zoned pricing across Sri Lanka.
 * - Western Province (Colombo, Gampaha, Kalutara): 500 LKR
 * - Central & Southern Hubs (Kandy, Galle, Matara, Kurunegala): 750 LKR
 * - Remote / Northern / Eastern (Jaffna, Batticaloa, Anuradhapura, Badulla, etc.): 950 LKR
 */
public class StandardCourierShippingStrategy implements ShippingCostStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public double calculateShippingFee(String district, double orderSubtotal) {
        if (district == null || district.trim().isEmpty()) {
            return 500.0;
        }
        String d = district.trim().toLowerCase();
        if (d.contains("kandy") || d.contains("galle") || d.contains("matara") || d.contains("kurunegala")) {
            return 750.0;
        } else if (d.contains("jaffna") || d.contains("batticaloa") || d.contains("anuradhapura") || d.contains("badulla")) {
            return 950.0;
        }
        return 500.0; // Western Province / Default
    }

    @Override
    public String getMethodName() {
        return "Standard Islandwide Courier";
    }

    @Override
    public int getEstimatedDeliveryDays() {
        return 3;
    }
}
