package strategies.inventory;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Long-term contracted distributor partner pricing.
 * Applies a flat 12% preferred partner discount across all replenishment quantities.
 */
public class ContractPartnerPricingStrategy implements SupplierPricingStrategy {
    private static final long serialVersionUID = 1L;

    private static final double PARTNER_DISCOUNT = 0.12; // 12% flat

    @Override
    public double calculateTotalCost(int quantity, double unitPrice) {
        if (quantity <= 0 || unitPrice <= 0) return 0.0;
        return (quantity * unitPrice) * (1.0 - PARTNER_DISCOUNT);
    }

    @Override
    public double getDiscountRate(int quantity) {
        return PARTNER_DISCOUNT;
    }

    @Override
    public String getPricingTierName() {
        return "CONTRACT_PARTNER";
    }

    @Override
    public String getDescription() {
        return "Contracted preferred supplier agreement with fixed 12% wholesale concession.";
    }
}
