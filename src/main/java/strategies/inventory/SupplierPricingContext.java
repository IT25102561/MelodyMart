package strategies.inventory;

import java.io.Serializable;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 *
 * Strategy Design Pattern - Context Class:
 * Context for executing supplier costing and reorder financial calculations.
 */
public class SupplierPricingContext implements Serializable {
    private static final long serialVersionUID = 1L;

    private SupplierPricingStrategy strategy;

    public SupplierPricingContext() {
        this.strategy = new StandardSupplierPricingStrategy();
    }

    public SupplierPricingContext(SupplierPricingStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new StandardSupplierPricingStrategy();
    }

    public void setStrategy(SupplierPricingStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public SupplierPricingStrategy getStrategy() {
        return this.strategy;
    }

    public double calculateTotalCost(int quantity, double unitPrice) {
        return this.strategy.calculateTotalCost(quantity, unitPrice);
    }

    public double getDiscountRate(int quantity) {
        return this.strategy.getDiscountRate(quantity);
    }
}
