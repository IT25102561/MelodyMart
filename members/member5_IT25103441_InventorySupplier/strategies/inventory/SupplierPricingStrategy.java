package strategies.inventory;

import java.io.Serializable;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Strategy Interface:
 * Encapsulates supplier procurement costing models and bulk discount calculations
 * for inventory restocking purchase orders (POs).
 */
public interface SupplierPricingStrategy extends Serializable {

    /**
     * Computes the net total purchase order cost based on order quantity and base unit cost.
     *
     * @param quantity Total quantity of units being replenished.
     * @param unitPrice Base wholesale unit price in LKR.
     * @return Discounted net total purchase cost in LKR.
     */
    double calculateTotalCost(int quantity, double unitPrice);

    /**
     * Returns the discount rate applicable for the given volume.
     *
     * @param quantity Order batch size.
     * @return Discount fraction (e.g. 0.10 for 10%).
     */
    double getDiscountRate(int quantity);

    /**
     * Returns the name of the supplier pricing tier.
     *
     * @return Tier title (e.g. "Standard Wholesale", "Tiered Bulk Discount", "Contract Partner").
     */
    String getPricingTierName();

    /**
     * Returns a brief description of the pricing tier terms.
     *
     * @return Terms summary.
     */
    String getDescription();
}
