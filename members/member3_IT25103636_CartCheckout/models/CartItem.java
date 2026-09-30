package models;

import java.io.Serializable;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart, Checkout & Payment
 */
public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private Product product;
    private int quantity;

    public CartItem() {}

    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getSubtotal() {
        if (product != null) {
            return product.getEffectivePrice() * quantity;
        }
        return 0.0;
    }
}
