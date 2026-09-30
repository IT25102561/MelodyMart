package strategies.cart;

import java.io.Serializable;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Strategy Design Pattern - Strategy Interface:
 * Encapsulates delivery fee calculation algorithms across various Sri Lankan
 * distribution tiers (Standard Courier, Express Domex, Store Pickup, Promotional Free Shipping).
 */
public interface ShippingCostStrategy extends Serializable {

    /**
     * Calculates the delivery fee based on customer destination district and order subtotal.
     *
     * @param district Sri Lankan district (e.g. "Colombo", "Kandy", "Jaffna").
     * @param orderSubtotal Order subtotal in LKR.
     * @return Delivery fee in LKR.
     */
    double calculateShippingFee(String district, double orderSubtotal);

    /**
     * Returns the customer-facing shipping method title.
     *
     * @return Method name (e.g., "Standard Islandwide Courier", "Express Next-Day Air").
     */
    String getMethodName();

    /**
     * Returns the estimated delivery timeline in business days.
     *
     * @return Estimated delivery days (e.g. 0 for pickup, 1-2 for express, 3-5 for standard).
     */
    int getEstimatedDeliveryDays();
}
