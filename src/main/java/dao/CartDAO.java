package dao;

import models.Cart;
import models.CartItem;
import models.Product;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart, Checkout & Payment
 */
public class CartDAO {
    private static final String SESSION_CART_KEY = "melodyMartCart";
    private static final Map<String, Double> VALID_VOUCHERS = new HashMap<>();

    static {
        VALID_VOUCHERS.put("MELODY10", 0.10); // 10% discount
        VALID_VOUCHERS.put("AVURUDU15", 0.15); // 15% discount
        VALID_VOUCHERS.put("WELCOME5", 0.05); // 5% discount
        VALID_VOUCHERS.put("SLIIT2026", 0.12); // 12% student discount
    }

    public Cart getCart(HttpSession session) {
        Cart cart = (Cart) session.getAttribute(SESSION_CART_KEY);
        if (cart == null) {
            cart = new Cart();
            session.setAttribute(SESSION_CART_KEY, cart);
        }
        return cart;
    }

    // ==========================================
    // CREATE OPERATIONS
    // ==========================================

    public void addToCart(HttpSession session, Product product, int quantity) throws Exception {
        if (product == null) {
            throw new Exception("Product does not exist.");
        }
        utils.ValidationUtil.validateCartQuantity(quantity, product.getStockQuantity());
        Cart cart = getCart(session);
        cart.addItem(product, quantity);
    }

    public boolean applyVoucher(HttpSession session, String code) throws Exception {
        if (code == null || code.trim().isEmpty()) {
            throw new Exception(utils.ValidationUtil.ERR_CART_INVALID_VOUCHER + ": Please enter a promo code.");
        }
        String normalized = code.trim().toUpperCase();
        if (!VALID_VOUCHERS.containsKey(normalized)) {
            throw new Exception(utils.ValidationUtil.ERR_CART_INVALID_VOUCHER + ": Promo voucher '" + code + "' is expired or invalid.");
        }
        Cart cart = getCart(session);
        cart.setVoucherCode(normalized);
        cart.setDiscountRate(VALID_VOUCHERS.get(normalized));
        return true;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public double calculatePreCheckoutTotal(HttpSession session, String district, String shippingOption) {
        Cart cart = getCart(session);
        if (district != null && !district.isEmpty()) {
            cart.setDistrict(district);
        }
        if (shippingOption != null && !shippingOption.isEmpty()) {
            cart.setShippingOption(shippingOption);
        }
        return cart.getGrandTotal();
    }

    // ==========================================
    // UPDATE OPERATIONS
    // ==========================================

    public void updateItemQuantity(HttpSession session, int productId, int newQty) throws Exception {
        if (newQty < 1) {
            throw new Exception(utils.ValidationUtil.ERR_CART_INVALID_QTY + ": Quantity must be at least 1.");
        }
        ProductDAO pDao = new ProductDAO();
        Product p = pDao.getProductById(productId);
        int available = (p != null) ? p.getStockQuantity() : 999;
        if (newQty > available) {
            throw new Exception(utils.ValidationUtil.ERR_CART_INSUFFICIENT_STOCK + ": Only " + available + " units available in warehouse.");
        }
        Cart cart = getCart(session);
        cart.updateQuantity(productId, newQty);
    }

    public void updateShippingPreferences(HttpSession session, String district, String shippingOption) {
        Cart cart = getCart(session);
        if (district != null && !district.trim().isEmpty()) cart.setDistrict(district);
        if (shippingOption != null && !shippingOption.trim().isEmpty()) cart.setShippingOption(shippingOption);
    }

    public void removeVoucher(HttpSession session) {
        Cart cart = getCart(session);
        cart.setVoucherCode("");
        cart.setDiscountRate(0.0);
    }

    // ==========================================
    // DELETE OPERATIONS
    // ==========================================

    public void removeItem(HttpSession session, int productId) {
        Cart cart = getCart(session);
        cart.removeItem(productId);
    }

    public void clearCart(HttpSession session) {
        Cart cart = getCart(session);
        cart.clear();
    }
}
