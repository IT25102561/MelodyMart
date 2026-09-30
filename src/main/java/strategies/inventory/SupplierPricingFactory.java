package strategies.inventory;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Factory utility to resolve SupplierPricingStrategy based on pricing tier or order context.
 */
public class SupplierPricingFactory {

    /**
     * Resolves the matching SupplierPricingStrategy.
     *
     * @param pricingTier Key e.g. "STANDARD", "BULK", "CONTRACT", "RUSH".
     * @return Matching SupplierPricingStrategy, defaulting to StandardSupplierPricingStrategy.
     */
    public static SupplierPricingStrategy getStrategy(String pricingTier) {
        if (pricingTier == null || pricingTier.trim().isEmpty()) {
            return new StandardSupplierPricingStrategy();
        }
        String key = pricingTier.trim().toUpperCase();
        switch (key) {
            case "BULK":
            case "BULK_TIERED":
            case "VOLUME":
                return new BulkDiscountSupplierPricingStrategy();
            case "CONTRACT":
            case "CONTRACT_PARTNER":
            case "PARTNER":
                return new ContractPartnerPricingStrategy();
            case "RUSH":
            case "EMERGENCY":
            case "EMERGENCY_RUSH":
                return new EmergencyRushPricingStrategy();
            case "STANDARD":
            default:
                return new StandardSupplierPricingStrategy();
        }
    }

    /**
     * Automatically resolves an optimal strategy based on order quantity.
     *
     * @param quantity Replenishment batch size.
     * @return BulkDiscountSupplierPricingStrategy if quantity >= 20, else StandardSupplierPricingStrategy.
     */
    public static SupplierPricingStrategy getStrategyForQuantity(int quantity) {
        if (quantity >= 20) {
            return new BulkDiscountSupplierPricingStrategy();
        }
        return new StandardSupplierPricingStrategy();
    }
}
