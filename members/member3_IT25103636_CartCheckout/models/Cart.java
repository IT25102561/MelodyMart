package models;

import strategies.cart.ShippingCostStrategy;
import strategies.cart.ShippingStrategyFactory;
import strategies.cart.StandardCourierShippingStrategy;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Dynamic shopping cart with voucher application and delivery fee calculation
 */
public class Cart implements Serializable {
    private static final long serialVersionUID = 1L;

    private List<CartItem> items = new ArrayList<>();
    private String voucherCode = "";
    private double discountRate = 0.0; // e.g. 0.10 for 10%
    private String district = "Colombo";
    private String shippingOption = "STANDARD_COURIER"; // STANDARD_COURIER, EXPRESS_DOMEX, STORE_PICKUP
    private ShippingCostStrategy shippingStrategy = new StandardCourierShippingStrategy();

    public Cart() {
        this.items = new ArrayList<>();
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public void addItem(Product product, int qty) {
        if (product == null || qty <= 0) return;
        for (CartItem item : items) {
            if (item.getProduct().getId() == product.getId()) {
                item.setQuantity(item.getQuantity() + qty);
                return;
            }
        }
        items.add(new CartItem(product, qty));
    }

    public void updateQuantity(int productId, int qty) {
        if (qty <= 0) {
            removeItem(productId);
            return;
        }
        for (CartItem item : items) {
            if (item.getProduct().getId() == productId) {
                item.setQuantity(qty);
                return;
            }
        }
    }

    public void removeItem(int productId) {
        items.removeIf(item -> item.getProduct().getId() == productId);
    }

    public void clear() {
        items.clear();
        voucherCode = "";
        discountRate = 0.0;
    }

    public int getTotalItemCount() {
        int count = 0;
        for (CartItem item : items) {
            count += item.getQuantity();
        }
        return count;
    }

    public double getSubtotal() {
        double sub = 0.0;
        for (CartItem item : items) {
            sub += item.getSubtotal();
        }
        return sub;
    }

    public double getDiscountAmount() {
        return getSubtotal() * discountRate;
    }

    public double getDeliveryFee() {
        if (this.shippingStrategy != null) {
            return this.shippingStrategy.calculateShippingFee(this.district, getSubtotal());
        }
        return 500.0;
    }

    public ShippingCostStrategy getShippingStrategy() {
        return this.shippingStrategy;
    }

    public void setShippingStrategy(ShippingCostStrategy shippingStrategy) {
        if (shippingStrategy != null) {
            this.shippingStrategy = shippingStrategy;
        }
    }

    public double getGrandTotal() {
        return Math.max(0, getSubtotal() - getDiscountAmount() + getDeliveryFee());
    }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public double getDiscountRate() { return discountRate; }
    public void setDiscountRate(double discountRate) { this.discountRate = discountRate; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getShippingOption() { return shippingOption; }
    public void setShippingOption(String shippingOption) {
        this.shippingOption = shippingOption;
        this.shippingStrategy = ShippingStrategyFactory.getStrategy(shippingOption);
    }
}
