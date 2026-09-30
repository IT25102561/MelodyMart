package utils;

/**
 * MelodyMart - Centralized Validation & Error Handling Utility
 * Group: 2026-Y2-S1-MLB-B6G1-08 (Module: SE2030)
 * 
 * Provides unified validation rules and standard error codes for all 6 group members:
 * - Member 1: ERR_USER_DUPLICATE_EMAIL, ERR_USER_PASSWORD_STRENGTH, ERR_USER_INVALID_PHONE
 * - Member 2: ERR_PROD_INVALID_NAME, ERR_PROD_INVALID_PRICE, ERR_PROD_INVALID_DISCOUNT
 * - Member 3: ERR_CART_INVALID_QTY, ERR_CART_INSUFFICIENT_STOCK, ERR_CART_INVALID_VOUCHER
 * - Member 4: ERR_PAY_INVALID_AMOUNT, ERR_PAY_METHOD_REQUIRED, ERR_PAY_UNVERIFIED_SLIP
 * - Member 5: ERR_SUP_INVALID_NAME, ERR_SUP_INVALID_EMAIL, ERR_PO_INVALID_AMOUNTS
 * - Member 6: ERR_DISP_ORDER_REQUIRED, ERR_RET_ORDER_REQUIRED, ERR_RET_REASON_REQUIRED
 */
public class ValidationUtil {

    // =========================================================================
    // MEMBER 1 ERROR CODES (IT25101726 - Perera D. A. P. W.)
    // =========================================================================
    public static final String ERR_USER_DUPLICATE_EMAIL = "ERR_USER_DUPLICATE_EMAIL";
    public static final String ERR_USER_PASSWORD_STRENGTH = "ERR_USER_PASSWORD_STRENGTH";
    public static final String ERR_USER_INVALID_PHONE = "ERR_USER_INVALID_PHONE";
    public static final String ERR_USER_INVALID_NAME = "ERR_USER_INVALID_NAME";
    public static final String ERR_USER_INVALID_EMAIL = "ERR_USER_INVALID_EMAIL";
    public static final String ERR_USER_ADDRESS_REQUIRED = "ERR_USER_ADDRESS_REQUIRED";
    public static final String ERR_USER_POSTAL_CODE = "ERR_USER_POSTAL_CODE";

    // =========================================================================
    // MEMBER 2 ERROR CODES (IT25102561 - Senarathna U. G. S. P.)
    // =========================================================================
    public static final String ERR_PROD_INVALID_NAME = "ERR_PROD_INVALID_NAME";
    public static final String ERR_PROD_INVALID_PRICE = "ERR_PROD_INVALID_PRICE";
    public static final String ERR_PROD_INVALID_DISCOUNT = "ERR_PROD_INVALID_DISCOUNT";
    public static final String ERR_PROD_INVALID_STOCK = "ERR_PROD_INVALID_STOCK";
    public static final String ERR_PROD_INVALID_WARRANTY = "ERR_PROD_INVALID_WARRANTY";

    // =========================================================================
    // MEMBER 3 ERROR CODES (IT25103636 - Pavishanth K.)
    // =========================================================================
    public static final String ERR_CART_INVALID_QTY = "ERR_CART_INVALID_QTY";
    public static final String ERR_CART_INSUFFICIENT_STOCK = "ERR_CART_INSUFFICIENT_STOCK";
    public static final String ERR_CART_INVALID_VOUCHER = "ERR_CART_INVALID_VOUCHER";
    public static final String ERR_CHECKOUT_EMPTY_CART = "ERR_CHECKOUT_EMPTY_CART";

    // =========================================================================
    // MEMBER 4 ERROR CODES (IT25101556 - Ekanayaka E. A. T. T.)
    // =========================================================================
    public static final String ERR_PAY_INVALID_AMOUNT = "ERR_PAY_INVALID_AMOUNT";
    public static final String ERR_PAY_METHOD_REQUIRED = "ERR_PAY_METHOD_REQUIRED";
    public static final String ERR_PAY_UNVERIFIED_SLIP = "ERR_PAY_UNVERIFIED_SLIP";
    public static final String ERR_PAY_REFUND_REASON = "ERR_PAY_REFUND_REASON";
    public static final String ERR_PAY_INVALID_CARD = "ERR_PAY_INVALID_CARD";
    public static final String ERR_PAY_INVALID_EXPIRY = "ERR_PAY_INVALID_EXPIRY";
    public static final String ERR_PAY_INVALID_CVV = "ERR_PAY_INVALID_CVV";

    // =========================================================================
    // MEMBER 5 ERROR CODES (IT25103441 - Premasiri R. M. R. R.)
    // =========================================================================
    public static final String ERR_SUP_INVALID_NAME = "ERR_SUP_INVALID_NAME";
    public static final String ERR_SUP_INVALID_EMAIL = "ERR_SUP_INVALID_EMAIL";
    public static final String ERR_PO_INVALID_AMOUNTS = "ERR_PO_INVALID_AMOUNTS";
    public static final String ERR_PO_DATE_REQUIRED = "ERR_PO_DATE_REQUIRED";

    // =========================================================================
    // MEMBER 6 ERROR CODES (IT25100652 - Nellampitiya T. T.)
    // =========================================================================
    public static final String ERR_DISP_ORDER_REQUIRED = "ERR_DISP_ORDER_REQUIRED";
    public static final String ERR_DISP_TRACKING_INVALID = "ERR_DISP_TRACKING_INVALID";
    public static final String ERR_RET_ORDER_REQUIRED = "ERR_RET_ORDER_REQUIRED";
    public static final String ERR_RET_REASON_REQUIRED = "ERR_RET_REASON_REQUIRED";
    public static final String ERR_RET_EMAIL_INVALID = "ERR_RET_EMAIL_INVALID";

    // =========================================================================
    // MEMBER 1 VALIDATIONS: User & Profile Management
    // =========================================================================

    public static void validateUserName(String fullName) throws Exception {
        if (fullName == null || fullName.trim().isEmpty()) {
            throw new Exception(ERR_USER_INVALID_NAME + ": Full name cannot be blank.");
        }
        if (fullName.trim().length() < 2) {
            throw new Exception(ERR_USER_INVALID_NAME + ": Full name must be at least 2 characters.");
        }
        if (!fullName.trim().matches("^[A-Za-z\\s.'-]+$")) {
            throw new Exception(ERR_USER_INVALID_NAME + ": Full name must contain letters and spaces only.");
        }
    }

    public static void validateEmail(String email) throws Exception {
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            throw new Exception(ERR_USER_INVALID_EMAIL + ": Please enter a valid email address.");
        }
    }

    public static void validatePasswordStrength(String password) throws Exception {
        if (password == null || password.length() < 8 || !password.matches(".*[a-zA-Z].*") || !password.matches(".*[0-9].*")) {
            throw new Exception(ERR_USER_PASSWORD_STRENGTH + ": Password must be at least 8 characters long and contain both letters and numbers.");
        }
    }

    public static void validateSriLankanPhone(String phone) throws Exception {
        if (phone == null || !phone.matches("^(?:0|\\+94)?7[0-9]{8}$")) {
            throw new Exception(ERR_USER_INVALID_PHONE + ": Invalid Sri Lankan mobile format. Expected 07XXXXXXXX or +947XXXXXXXX.");
        }
    }

    public static void validateAddress(String street, String city, String district, String postalCode) throws Exception {
        if (street == null || street.trim().isEmpty() || city == null || city.trim().isEmpty() || district == null || district.trim().isEmpty()) {
            throw new Exception(ERR_USER_ADDRESS_REQUIRED + ": Street, city, and district are required.");
        }
        if (postalCode != null && !postalCode.trim().isEmpty()) {
            if (!postalCode.trim().matches("^[0-9]{5}$")) {
                throw new Exception(ERR_USER_POSTAL_CODE + ": Sri Lankan postal code must be a 5-digit number (e.g. 10115).");
            }
        }
    }

    public static void validateAddress(String address) throws Exception {
        if (address == null || address.trim().length() < 5) {
            throw new Exception(ERR_USER_ADDRESS_REQUIRED + ": Complete delivery address must be at least 5 characters.");
        }
    }

    public static void validateCity(String city) throws Exception {
        if (city == null || city.trim().length() < 2) {
            throw new Exception("City must be at least 2 characters.");
        }
    }

    public static void validatePostalCode(String postalCode) throws Exception {
        if (postalCode != null && !postalCode.trim().isEmpty()) {
            if (!postalCode.trim().matches("^[0-9]{5}$")) {
                throw new Exception(ERR_USER_POSTAL_CODE + ": Sri Lankan postal code must be a 5-digit number (e.g. 10115).");
            }
        }
    }

    public static void validateBrand(String brand) throws Exception {
        if (brand == null || brand.trim().length() < 2) {
            throw new Exception("Brand must be at least 2 characters.");
        }
    }

    // =========================================================================
    // MEMBER 2 VALIDATIONS: Product Catalog & Search
    // =========================================================================

    public static void validateProductName(String name) throws Exception {
        if (name == null || name.trim().isEmpty()) {
            throw new Exception(ERR_PROD_INVALID_NAME + ": Product name cannot be blank.");
        }
        if (name.trim().length() < 3) {
            throw new Exception(ERR_PROD_INVALID_NAME + ": Product name must be at least 3 characters.");
        }
    }

    public static void validateProductPrice(double price) throws Exception {
        if (price <= 0.0) {
            throw new Exception(ERR_PROD_INVALID_PRICE + ": Product retail price must be greater than zero.");
        }
    }

    public static void validateProductDiscount(double discountPercent) throws Exception {
        if (discountPercent < 0.0 || discountPercent > 100.0) {
            throw new Exception(ERR_PROD_INVALID_DISCOUNT + ": Promotional discount percentage must be between 0% and 100%.");
        }
    }

    public static void validateProductStock(int stockQuantity) throws Exception {
        if (stockQuantity < 0) {
            throw new Exception(ERR_PROD_INVALID_STOCK + ": Stock quantity cannot be negative.");
        }
    }

    public static void validateWarranty(String warranty) throws Exception {
        if (warranty == null || warranty.trim().isEmpty()) {
            throw new Exception(ERR_PROD_INVALID_WARRANTY + ": Product warranty must be specified using numbers only (e.g. 1, 2, 3).");
        }
        String trimmed = warranty.trim();
        if (!trimmed.matches("^[0-9]+$")) {
            throw new Exception(ERR_PROD_INVALID_WARRANTY + ": Product warranty must contain numbers only (e.g. 1, 2, 3, 5). Characters are not allowed.");
        }
        try {
            int val = Integer.parseInt(trimmed);
            if (val < 0 || val > 25) {
                throw new Exception(ERR_PROD_INVALID_WARRANTY + ": Product warranty must be between 0 and 25 years.");
            }
        } catch (NumberFormatException e) {
            throw new Exception(ERR_PROD_INVALID_WARRANTY + ": Product warranty must be a valid integer number.");
        }
    }

    // =========================================================================
    // MEMBER 3 VALIDATIONS: Shopping Cart & Checkout
    // =========================================================================

    public static void validateCartQuantity(int quantity, int availableStock) throws Exception {
        if (quantity < 1) {
            throw new Exception(ERR_CART_INVALID_QTY + ": Quantity must be at least 1.");
        }
        if (availableStock >= 0 && quantity > availableStock) {
            throw new Exception(ERR_CART_INSUFFICIENT_STOCK + ": Only " + availableStock + " units available in warehouse.");
        }
    }

    public static void validateVoucherCode(String voucherCode) throws Exception {
        if (voucherCode == null || !voucherCode.trim().matches("^[A-Za-z0-9_-]{3,20}$")) {
            throw new Exception(ERR_CART_INVALID_VOUCHER + ": Voucher code must be between 3 and 20 alphanumeric characters.");
        }
    }

    // =========================================================================
    // MEMBER 4 VALIDATIONS: Payment Gateway & Invoices
    // =========================================================================

    public static void validatePayment(double amount, String paymentMethod, String bankSlipUrl) throws Exception {
        if (amount <= 0.0) {
            throw new Exception(ERR_PAY_INVALID_AMOUNT + ": Payment amount must be positive.");
        }
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            throw new Exception(ERR_PAY_METHOD_REQUIRED + ": Please select a valid Sri Lankan payment method.");
        }
        if ("BANK_TRANSFER".equalsIgnoreCase(paymentMethod)) {
            if (bankSlipUrl == null || bankSlipUrl.trim().isEmpty()) {
                throw new Exception(ERR_PAY_UNVERIFIED_SLIP + ": Please attach a bank deposit receipt slip reference.");
            }
        }
    }

    public static void validateCardDetails(String cardNumber, String expiry, String cvv) throws Exception {
        if (cardNumber == null || !cardNumber.replaceAll("\\s+", "").matches("^[0-9]{16}$")) {
            throw new Exception(ERR_PAY_INVALID_CARD + ": Card number must be exactly 16 numeric digits.");
        }
        if (expiry == null || !expiry.trim().matches("^(0[1-9]|1[0-2])\\/[0-9]{2}$")) {
            throw new Exception(ERR_PAY_INVALID_EXPIRY + ": Card expiration must be in MM/YY format (e.g. 12/28).");
        }
        if (cvv == null || !cvv.trim().matches("^[0-9]{3,4}$")) {
            throw new Exception(ERR_PAY_INVALID_CVV + ": Security code (CVV) must be 3 or 4 numeric digits.");
        }
    }

    public static void validateRefundReason(String reason) throws Exception {
        if (reason == null || reason.trim().isEmpty()) {
            throw new Exception(ERR_PAY_REFUND_REASON + ": Refund reason is required.");
        }
    }

    // =========================================================================
    // MEMBER 5 VALIDATIONS: Inventory & Supplier Management
    // =========================================================================

    public static void validateSupplier(String companyName, String email) throws Exception {
        if (companyName == null || companyName.trim().isEmpty()) {
            throw new Exception(ERR_SUP_INVALID_NAME + ": Supplier company name is required.");
        }
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            throw new Exception(ERR_SUP_INVALID_EMAIL + ": Valid contact email is required.");
        }
    }

    public static void validateSupplier(String companyName, String contactPerson, String email, String phone) throws Exception {
        validateSupplier(companyName, email);
        if (contactPerson != null && !contactPerson.trim().isEmpty()) {
            if (contactPerson.trim().length() < 2 || !contactPerson.trim().matches("^[A-Za-z\\s.'-]+$")) {
                throw new Exception(ERR_SUP_INVALID_NAME + ": Contact person name must contain letters only (min 2 chars).");
            }
        }
        if (phone != null && !phone.trim().isEmpty()) {
            if (!phone.trim().matches("^(?:0|\\+94)?[0-9\\s-]{9,15}$")) {
                throw new Exception("Invalid phone number format for supplier.");
            }
        }
    }

    public static void validatePurchaseOrder(int quantity, double totalAmount, String expectedDate) throws Exception {
        if (quantity <= 0 || totalAmount <= 0.0) {
            throw new Exception(ERR_PO_INVALID_AMOUNTS + ": Quantity and total amount must be positive.");
        }
        if (expectedDate == null || expectedDate.trim().isEmpty()) {
            throw new Exception(ERR_PO_DATE_REQUIRED + ": Expected delivery date is required.");
        }
    }

    public static void validateStockDelta(int currentStock, int delta) throws Exception {
        if (delta == 0) {
            throw new Exception(ERR_PROD_INVALID_STOCK + ": Stock adjustment delta cannot be zero.");
        }
        if (currentStock + delta < 0) {
            throw new Exception(ERR_PROD_INVALID_STOCK + ": Resulting stock cannot be negative (current: " + currentStock + ", delta: " + delta + ").");
        }
    }

    // =========================================================================
    // MEMBER 6 VALIDATIONS: Order Fulfilment, Delivery & Returns
    // =========================================================================

    public static void validateDispatch(String orderId) throws Exception {
        if (orderId == null || orderId.trim().isEmpty()) {
            throw new Exception(ERR_DISP_ORDER_REQUIRED + ": Order ID is required for courier dispatch.");
        }
    }

    public static void validateTrackingNumber(String trackingNumber) throws Exception {
        if (trackingNumber == null || !trackingNumber.trim().matches("^[A-Za-z0-9-]+$")) {
            throw new Exception(ERR_DISP_TRACKING_INVALID + ": Tracking number must contain alphanumeric characters and dashes only.");
        }
    }

    public static void validateReturnRequest(String orderId, String reason, String email) throws Exception {
        if (orderId == null || orderId.trim().isEmpty()) {
            throw new Exception(ERR_RET_ORDER_REQUIRED + ": Order ID is required for return ticket.");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new Exception(ERR_RET_REASON_REQUIRED + ": Please select a return or warranty reason.");
        }
        if (email != null && !email.trim().isEmpty() && !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            throw new Exception(ERR_RET_EMAIL_INVALID + ": Please provide a valid contact email for return communications.");
        }
    }
}
