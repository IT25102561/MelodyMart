/**
 * MelodyMart - Module 6.3: Shopping Cart, Checkout & Payment
 * Member: Pavishanth K. (IT25103636)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_CART_STOCK_EXCEEDED: {
    code: 'ERR_CART_STOCK_EXCEEDED',
    name: 'Requested Quantity Exceeds Available Warehouse Stock',
    condition: 'Triggered when customer attempts to add or update an item quantity greater than live inventory balance.',
    sampleMessage: 'Only [X] unit(s) of "[Instrument Name]" available in stock. You requested [Y].'
  },
  ERR_CART_INVALID_VOUCHER: {
    code: 'ERR_CART_INVALID_VOUCHER',
    name: 'Invalid, Expired, or Sub-Threshold Coupon Code',
    condition: 'Triggered when an entered coupon code is not found in the active coupons database, has expired, or does not meet the minimum order subtotal requirement.',
    sampleMessage: 'Coupon code is invalid or has expired. Or minimum spend threshold (e.g. Rs. 20,000 for MELODY10) not reached.'
  },
  ERR_CART_EMPTY_CHECKOUT: {
    code: 'ERR_CART_EMPTY_CHECKOUT',
    name: 'Empty Cart Checkout Session Initiation Attempt',
    condition: 'Triggered when a checkout session is initiated with zero instrument items in the active cart.',
    sampleMessage: 'Cannot initiate checkout with an empty cart. Please add musical instruments before proceeding.'
  }
};
