package strategies.cart;

import java.io.Serializable;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Context Class:
 * Maintains a reference to a ShippingCostStrategy object and delegates delivery fee
 * computation, decoupling Cart / Checkout modules from specific fee rules.
 */
public class ShippingCostContext implements Serializable {
    private static final long serialVersionUID = 1L;

    private ShippingCostStrategy strategy;

    public ShippingCostContext() {
        this.strategy = new StandardCourierShippingStrategy();
    }

    public ShippingCostContext(ShippingCostStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new StandardCourierShippingStrategy();
    }

    public void setStrategy(ShippingCostStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public ShippingCostStrategy getStrategy() {
        return this.strategy;
    }

    public double calculateFee(String district, double subtotal) {
        return this.strategy.calculateShippingFee(district, subtotal);
    }

    public String getMethodName() {
        return this.strategy.getMethodName();
    }

    public int getEstimatedDays() {
        return this.strategy.getEstimatedDeliveryDays();
    }
}
