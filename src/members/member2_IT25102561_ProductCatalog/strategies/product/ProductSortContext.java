package strategies.product;

import models.Product;
import java.util.List;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 *
 * Strategy Design Pattern - Context Class:
 * Holds a reference to a ProductSortStrategy and provides a unified interface
 * for the catalog controller/DAO to execute sorting without coupling to concrete classes.
 */
public class ProductSortContext {
    private ProductSortStrategy strategy;

    public ProductSortContext() {
        this.strategy = new DefaultProductSortStrategy();
    }

    public ProductSortContext(ProductSortStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new DefaultProductSortStrategy();
    }

    public void setStrategy(ProductSortStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public ProductSortStrategy getStrategy() {
        return this.strategy;
    }

    public List<Product> executeSort(List<Product> products) {
        return this.strategy.sort(products);
    }
}
