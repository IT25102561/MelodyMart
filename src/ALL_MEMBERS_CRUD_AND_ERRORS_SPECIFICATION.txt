================================================================================
SLIIT - SRI LANKA INSTITUTE OF INFORMATION TECHNOLOGY
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
PROJECT FINAL SUBMISSION: MelodyMart Web-Based Musical Instrument Selling System
Client: Harmony Lanka Musical Stores (Pvt) Ltd.
Group:  2026-Y2-S1-MLB-B6G1-08
================================================================================

TABLE OF GROUP MEMBERS & ALLOCATED SUBSYSTEMS:
--------------------------------------------------------------------------------
No | IT Number   | Student Name          | Subsystem / Module
--------------------------------------------------------------------------------
1  | IT25101726  | Perera D. A. P. W.    | 6.1 User Account & Profile Management
2  | IT25102561  | Senarathna U. G. S. P.| 6.2 Product Catalog & Advanced Search/Filtering
3  | IT25103636  | Pavishanth K.         | 6.3 Shopping Cart, Checkout & Payment
4  | IT25101556  | Ekanayaka E. A. T. T. | 6.4 Payment Gateway & Invoice System
5  | IT25103441  | Premasiri R. M. R. R. | 6.5 Real-Time Inventory & Supplier Management
6  | IT25100652  | Nellampitiya T. T.    | 6.6 Order Fulfilment, Delivery Tracking & Returns
--------------------------------------------------------------------------------

TEN (10) FEATURED MUSICAL INSTRUMENTS IN STOCK (SRI LANKA MARKET):
1. PROD-001: Yamaha F310 Acoustic Guitar (LKR 48,500 / Disc: 45,000) - Strings
2. PROD-002: Ibanez GRX70QA Electric Guitar (LKR 89,000 / Disc: 82,000) - Strings
3. PROD-003: Traditional Sri Lankan Geta Bera (Kandyan Drum) (LKR 36,000) - Traditional Sri Lankan
4. PROD-004: Traditional Sri Lankan Yak Bera (Low Country Drum) (LKR 34,500 / Disc: 32,000) - Traditional Sri Lankan
5. PROD-005: Yamaha PSR-E373 61-Key Portable Keyboard (LKR 96,000 / Disc: 91,500) - Keyboards
6. PROD-006: Roland TD-02K V-Drums Electronic Drum Kit (LKR 185,000 / Disc: 178,000) - Drums
7. PROD-007: Yamaha YFL-222 Standard Student Flute (LKR 115,000 / Disc: 110,000) - Wind
8. PROD-008: Stentor Student I Violin Outfit 4/4 (LKR 42,000 / Disc: 39,500) - Strings
9. PROD-009: Bina 23B Deluxe 7-Stopper Indian Harmonium (LKR 68,000 / Disc: 65,000) - Traditional Eastern
10. PROD-010: Cort Action PJ 4-String Electric Bass Guitar (LKR 76,500 / Disc: 72,000) - Bass

================================================================================
ALL 18 ERROR SCENARIOS (3 PER MEMBER):
================================================================================
[MEMBER 1: IT25101726 - Perera D. A. P. W.]
- ERR_USER_DUPLICATE_EMAIL: Rejects duplicate email address during registration.
- ERR_USER_PASSWORD_STRENGTH: Enforces 8+ chars with letters & numbers.
- ERR_USER_INVALID_PHONE: Validates Sri Lankan telephone format (07X-XXXXXXX / +947XXXXXXXX).

[MEMBER 2: IT25102561 - Senarathna U. G. S. P.]
- ERR_PROD_INVALID_PRICE: Rejects zero/negative retail price or discount > retail price.
- ERR_PROD_MISSING_SPECS: Enforces mandatory instrument technical specifications.
- ERR_PROD_COMPARE_LIMIT: Restricts side-by-side comparison to a maximum of 4 instruments.

[MEMBER 3: IT25103636 - Pavishanth K.]
- ERR_CART_STOCK_EXCEEDED: Real-time stock check prevents purchasing beyond available warehouse units.
- ERR_CART_INVALID_VOUCHER: Validates coupon codes, active dates, and minimum spend thresholds.
- ERR_CART_EMPTY_CHECKOUT: Prevents initiating checkout with zero items in cart.

[MEMBER 4: IT25101556 - Ekanayaka E. A. T. T.]
- ERR_PAY_CARD_DECLINED: 16-digit card check and decline simulation on test card numbers.
- ERR_PAY_SLIP_REQUIRED: Requires reference number & slip attachment for bank transfers.
- ERR_PAY_INVALID_REFUND_STATE: Blocks refund requests on invoices not marked as 'Paid'.

[MEMBER 5: IT25103441 - Premasiri R. M. R. R.]
- ERR_SUPP_DUPLICATE_BRN: Prevents duplicate supplier Business Registration Numbers (BRN).
- ERR_INV_INVALID_PO_QTY: Enforces purchase order quantity > 0.
- ERR_INV_NEGATIVE_STOCK_DEFICIT: Prevents physical warehouse stock from dropping below zero.

[MEMBER 6: IT25100652 - Nellampitiya T. T.]
- ERR_DELIV_INVALID_TRACKING: Validates courier tracking format (Koombiyo, PromptX, Domex).
- ERR_DELIV_ILLEGAL_STATE_TRANSITION: Enforces sequential delivery states (Processing -> Shipped -> In-Transit -> Delivered).
- ERR_RET_WINDOW_EXPIRED: Restricts return/warranty tickets to delivered orders within 14 days.

================================================================================
HOW TO RUN MELODYMART:
================================================================================
1. Ensure Node.js (v18+) is installed.
2. Open terminal in the project root: `cd C:\Users\semal\Projects\MelodyMart`
3. Start server: `node src/server.js`
4. Access in web browser:
   - Storefront:       http://localhost:3000/
   - Catalog:          http://localhost:3000/catalog.html
   - Shopping Cart:    http://localhost:3000/cart.html
   - Checkout:         http://localhost:3000/checkout.html
   - Orders & Tracking:http://localhost:3000/orders.html
   - User Profile:     http://localhost:3000/profile.html
   - Staff Portal:     http://localhost:3000/admin.html
================================================================================
