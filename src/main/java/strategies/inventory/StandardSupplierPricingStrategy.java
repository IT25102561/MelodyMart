package strategies.inventory;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Standard wholesale pricing. No volume concessions applied (0% discount).
 */
public class StandardSupplierPricingStrategy implements SupplierPricingStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public double calculateTotalCost(int quantity, double unitPrice) {
        if (quantity <= 0 || unitPrice <= 0) return 0.0;
        return quantity * unitPrice;
    }

    @Override
    public double getDiscountRate(int quantity) {
        return 0.0;
    }

    @Override
    public String getPricingTierName() {
        return "STANDARD";
    }

    @Override
    public String getDescription() {
        return "Standard wholesale pricing with no bulk discounts applied.";
    }
}
