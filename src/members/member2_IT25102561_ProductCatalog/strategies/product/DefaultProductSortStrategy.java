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
 * Preserves the default catalog display order (by displayOrder or ID ascending).
 */
public class DefaultProductSortStrategy implements ProductSortStrategy {

    @Override
    public List<Product> sort(List<Product> products) {
        if (products == null) {
            return new ArrayList<>();
        }
        List<Product> sortedList = new ArrayList<>(products);
        sortedList.sort(Comparator.comparingInt(p -> p.getDisplayOrder() > 0 ? p.getDisplayOrder() : p.getId()));
        return sortedList;
    }

    @Override
    public String getStrategyName() {
        return "Featured / Default";
    }
}
