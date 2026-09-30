package strategies.product;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 *
 * Factory utility to resolve ProductSortStrategy from HTTP request parameters (e.g. sortBy).
 */
public class ProductSortFactory {

    /**
     * Resolves and returns the corresponding ProductSortStrategy.
     *
     * @param sortBy Key indicating sort criterion (e.g. "price_asc", "price_desc", "name", "default").
     * @return Concrete ProductSortStrategy, defaulting to DefaultProductSortStrategy.
     */
    public static ProductSortStrategy getStrategy(String sortBy) {
        if (sortBy == null || sortBy.trim().isEmpty()) {
            return new DefaultProductSortStrategy();
        }
        String key = sortBy.trim().toLowerCase();
        switch (key) {
            case "price_asc":
            case "price_low":
            case "low_to_high":
                return new PriceLowToHighStrategy();
            case "price_desc":
            case "price_high":
            case "high_to_low":
                return new PriceHighToLowStrategy();
            case "name":
            case "name_asc":
            case "alpha":
                return new NameSortStrategy();
            case "default":
            case "featured":
            default:
                return new DefaultProductSortStrategy();
        }
    }
}
