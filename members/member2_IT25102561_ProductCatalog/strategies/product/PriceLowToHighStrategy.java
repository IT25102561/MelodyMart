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
 * Sorts products ascending by their effective retail price (after discounts).
 */
public class PriceLowToHighStrategy implements ProductSortStrategy {

    @Override
    public List<Product> sort(List<Product> products) {
        if (products == null) {
            return new ArrayList<>();
        }
        List<Product> sortedList = new ArrayList<>(products);
        sortedList.sort(Comparator.comparingDouble(Product::getEffectivePrice));
        return sortedList;
    }

    @Override
    public String getStrategyName() {
        return "Price: Low to High";
    }
}
