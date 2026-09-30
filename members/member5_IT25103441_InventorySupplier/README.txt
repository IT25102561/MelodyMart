================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Premasiri R. M. R. R.
IT Number: IT25103441
Module:    6.5 - Real-Time Inventory & Supplier Management

ASSIGNED CRUD OPERATIONS:
[CREATE]
Register new instrument suppliers, generate stock purchase orders (POs), and record incoming stock batches with warranty batches.

[READ]
Monitor live warehouse stock levels, review automated low-stock and reorder alerts, and inspect supplier performance records.

[UPDATE]
Automatically deduct available stock on checkout, adjust stock counts for returns or damages, and update supplier contract/contact details.

[DELETE]
Deactivate discontinued supplier profiles and cancel draft or invalid purchase order requisitions.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_SUPP_DUPLICATE_BRN
   Name:      Duplicate Supplier Business Registration Number
   Condition: Triggered when attempting to register a supplier with a Business Registration Number (BRN) already present in the database.
   Message:   Supplier with Business Registration Number "PV-10928/LK" is already registered in the system.

2. Error Code: ERR_INV_INVALID_PO_QTY
   Name:      Non-Positive Purchase Order Quantity Requisition
   Condition: Triggered when creating a purchase order requisition with a quantity less than or equal to zero.
   Message:   Purchase order quantity must be greater than zero. Received: 0

3. Error Code: ERR_INV_NEGATIVE_STOCK_DEFICIT
   Name:      Physical Stock Balance Deficit
   Condition: Triggered when a manual or damaged inventory adjustment causes warehouse stock to drop below zero.
   Message:   Stock adjustment rejected. Current stock is 4, deduction of 50 would result in negative stock balance (-46).

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- GET /api/inventory/status - Real-time warehouse balance, low stock alerts, stock valuation
- POST /api/inventory/adjust - Adjust stock for damages, returns, or manual audits
- POST /api/inventory/purchase-order - Create PO and record incoming stock batch
- GET /api/suppliers - List registered suppliers with ratings and contract statuses
- POST /api/suppliers - Register new musical equipment supplier
- PUT /api/suppliers/:id - Update supplier contracts and contact details
- DELETE /api/suppliers/:id - Suspend/deactivate supplier agreement

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 5: "Real-Time Inventory & Supplier Management"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
