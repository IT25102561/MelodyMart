package strategies.inventory;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Emergency Rush Procurement order.
 * Incurs a 10% expedited freight and urgent manufacturing surcharge.
 */
public class EmergencyRushPricingStrategy implements SupplierPricingStrategy {
    private static final long serialVersionUID = 1L;

    private static final double RUSH_SURCHARGE = 0.10; // +10%

    @Override
    public double calculateTotalCost(int quantity, double unitPrice) {
        if (quantity <= 0 || unitPrice <= 0) return 0.0;
        return (quantity * unitPrice) * (1.0 + RUSH_SURCHARGE);
    }

    @Override
    public double getDiscountRate(int quantity) {
        return -RUSH_SURCHARGE; // Negative discount = surcharge
    }

    @Override
    public String getPricingTierName() {
        return "EMERGENCY_RUSH";
    }

    @Override
    public String getDescription() {
        return "Priority emergency replenishment with 10% expedite surcharge for 24h delivery.";
    }
}
