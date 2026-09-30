================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Pavishanth K.
IT Number: IT25103636
Module:    6.3 - Shopping Cart, Checkout & Payment

ASSIGNED CRUD OPERATIONS:
[CREATE]
Add instruments to the active shopping cart, create customer checkout sessions, and apply valid promotional vouchers or bundle discounts.

[READ]
Retrieve cart contents, inspect dynamic subtotal and delivery fee calculations (Western Province vs Outstation in LKR), and view pre-checkout order summaries.

[UPDATE]
Adjust product quantities in the cart, change selected shipping options, and modify or remove applied voucher codes before payment initiation.

[DELETE]
Remove individual instrument line items from the shopping cart or clear the entire cart upon order cancellation or checkout completion.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_CART_STOCK_EXCEEDED
   Name:      Requested Quantity Exceeds Available Warehouse Stock
   Condition: Triggered when customer attempts to add or update an item quantity greater than live inventory balance.
   Message:   Only [X] unit(s) of "[Instrument Name]" available in stock. You requested [Y].

2. Error Code: ERR_CART_INVALID_VOUCHER
   Name:      Invalid, Expired, or Sub-Threshold Coupon Code
   Condition: Triggered when an entered coupon code is not found in the active coupons database, has expired, or does not meet the minimum order subtotal requirement.
   Message:   Coupon code is invalid or has expired. Or minimum spend threshold (e.g. Rs. 20,000 for MELODY10) not reached.

3. Error Code: ERR_CART_EMPTY_CHECKOUT
   Name:      Empty Cart Checkout Session Initiation Attempt
   Condition: Triggered when a checkout session is initiated with zero instrument items in the active cart.
   Message:   Cannot initiate checkout with an empty cart. Please add musical instruments before proceeding.

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- POST /api/cart/validate-item - Real-time stock validation prior to cart addition/update
- POST /api/cart/validate-coupon - Verify and apply promo codes (MELODY10, NEWYEAR26)
- POST /api/cart/calculate - Dynamic subtotal, Sri Lanka delivery fee, tax calculation
- POST /api/cart/checkout-session - Initialize checkout session with active cart

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 3: "Shopping Cart, Checkout & Payment"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
