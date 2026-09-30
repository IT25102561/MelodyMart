================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Senarathna U. G. S. P.
IT Number: IT25102561
Module:    6.2 - Product Catalog & Advanced Search/Filtering

ASSIGNED CRUD OPERATIONS:
[CREATE]
Add new musical instruments with technical specifications, high-resolution media galleries, retail pricing (LKR), warranty policies, and brand taxonomy.

[READ]
Browse instruments by category, execute multi-faceted filters (brand, price bracket, specifications), and render side-by-side instrument comparison matrices.

[UPDATE]
Modify product descriptions, update prices and active promotional discounts, revise technical specs, and adjust display order/media.

[DELETE]
Delist discontinued musical gear, delete obsolete categories, or soft-delete archived products from public visibility.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_PROD_INVALID_PRICE
   Name:      Invalid Price or Discount Boundary
   Condition: Triggered when retail price is non-numeric, zero, or negative, or when promotional discount price exceeds the retail price.
   Message:   Retail price must be greater than zero, and discount price cannot be negative or exceed the retail price.

2. Error Code: ERR_PROD_MISSING_SPECS
   Name:      Missing Mandatory Technical Specifications
   Condition: Triggered when adding or updating an instrument without required technical specifications (material, dimensions, pickups, voices, or tuning).
   Message:   Technical specifications are mandatory for musical instruments (e.g., material, dimensions, voices, or pickup setup).

3. Error Code: ERR_PROD_COMPARE_LIMIT
   Name:      Comparison Matrix Capacity Exceeded
   Condition: Triggered when a user requests a side-by-side comparison of more than 4 musical instruments concurrently.
   Message:   Instrument comparison is limited to a maximum of 4 instruments side-by-side.

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- GET /api/products - Browse and search catalog with category, brand, price filters
- GET /api/products/:id - Retrieve full instrument details and specifications
- POST /api/products - Add new musical instrument to catalog
- PUT /api/products/:id - Update descriptions, pricing, discounts, and specs
- DELETE /api/products/:id - Delist/soft-delete instrument from public view
- POST /api/products/compare - Generate side-by-side comparison matrix (max 4)

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 2: "Product Catalog & Advanced Search/Filtering"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
