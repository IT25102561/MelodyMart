package strategies.cart;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart & Order Checkout System
 *
 * Factory utility to resolve ShippingCostStrategy from checkout selections or shipping options.
 */
public class ShippingStrategyFactory {

    /**
     * Resolves the matching ShippingCostStrategy for the given shipping option key.
     *
     * @param shippingOption Key e.g., "STANDARD_COURIER", "EXPRESS_DOMEX", "STORE_PICKUP", "PROMO_FREE".
     * @return Concrete ShippingCostStrategy, defaulting to StandardCourierShippingStrategy.
     */
    public static ShippingCostStrategy getStrategy(String shippingOption) {
        if (shippingOption == null || shippingOption.trim().isEmpty()) {
            return new StandardCourierShippingStrategy();
        }
        String key = shippingOption.trim().toUpperCase();
        switch (key) {
            case "EXPRESS":
            case "EXPRESS_DOMEX":
            case "DOMEX":
            case "PROMPT":
                return new ExpressDomexShippingStrategy();
            case "PICKUP":
            case "STORE_PICKUP":
            case "SHOWROOM":
                return new StorePickupShippingStrategy();
            case "FREE":
            case "PROMO_FREE":
            case "FREE_SHIPPING":
                return new FreeOverThresholdShippingStrategy();
            case "STANDARD":
            case "STANDARD_COURIER":
            case "KOOMBIYO":
            default:
                return new StandardCourierShippingStrategy();
        }
    }
}
