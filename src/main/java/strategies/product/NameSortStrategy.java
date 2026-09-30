package strategies.product;

import models.Product;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Sorts products alphabetically by product name (A to Z).
 */
public class NameSortStrategy implements ProductSortStrategy {

    @Override
    public List<Product> sort(List<Product> products) {
        if (products == null) {
            return new ArrayList<>();
        }
        List<Product> sortedList = new ArrayList<>(products);
        sortedList.sort(Comparator.comparing(p -> (p.getName() != null ? p.getName() : ""), String.CASE_INSENSITIVE_ORDER));
        return sortedList;
    }

    @Override
    public String getStrategyName() {
        return "Name: A to Z";
    }
}
