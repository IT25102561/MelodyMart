package strategies.inventory;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Tiered volume discount model for bulk procurement batches:
 * - Quantity < 20 units: 0% discount
 * - Quantity 20 - 49 units: 5% discount
 * - Quantity 50 - 99 units: 10% discount
 * - Quantity 100+ units: 15% discount
 */
public class BulkDiscountSupplierPricingStrategy implements SupplierPricingStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public double calculateTotalCost(int quantity, double unitPrice) {
        if (quantity <= 0 || unitPrice <= 0) return 0.0;
        double subtotal = quantity * unitPrice;
        double discount = getDiscountRate(quantity);
        return subtotal * (1.0 - discount);
    }

    @Override
    public double getDiscountRate(int quantity) {
        if (quantity >= 100) {
            return 0.15; // 15% discount
        } else if (quantity >= 50) {
            return 0.10; // 10% discount
        } else if (quantity >= 20) {
            return 0.05; // 5% discount
        }
        return 0.0;
    }

    @Override
    public String getPricingTierName() {
        return "BULK_TIERED";
    }

    @Override
    public String getDescription() {
        return "Progressive volume tiered discount (5% for 20+, 10% for 50+, 15% for 100+ units).";
    }
}
