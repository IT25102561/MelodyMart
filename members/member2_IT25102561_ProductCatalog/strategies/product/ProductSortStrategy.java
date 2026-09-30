package strategies.product;

import models.Product;
import java.util.List;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 *
 * Strategy Design Pattern - Strategy Interface:
 * Encapsulates catalog sorting algorithms (Price Low-to-High, Price High-to-Low,
 * Name Alphabetical, Discount / Popularity, Default Order) allowing dynamic runtime selection.
 */
public interface ProductSortStrategy {

    /**
     * Sorts the given list of products according to the specific sorting criteria.
     *
     * @param products The original list of products.
     * @return A newly sorted list of products.
     */
    List<Product> sort(List<Product> products);

    /**
     * Returns the user-facing name of the sorting strategy.
     *
     * @return Display name (e.g. "Price: Low to High", "Alphabetical (A-Z)").
     */
    String getStrategyName();
}
