================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Nellampitiya T. T.
IT Number: IT25100652
Module:    6.6 - Order Fulfilment, Delivery Tracking & Returns

ASSIGNED CRUD OPERATIONS:
[CREATE]
Create fulfillment dispatch jobs, assign partner courier tracking identifiers, and submit customer return or warranty claim requests.

[READ]
Track real-time delivery lifecycle statuses (Processing, Shipped, In-Transit, Delivered), review courier logs, and inspect pending customer returns.

[UPDATE]
Update order fulfillment status, record Cash-on-Delivery (COD) collection milestones, and advance return ticket stages (Under Review, Approved, Completed).

[DELETE]
Cancel dispatch orders prior to courier handover and dismiss invalid or withdrawn customer return requests.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_DELIV_INVALID_TRACKING
   Name:      Invalid Courier Tracking Identifier Format
   Condition: Triggered when dispatch tracking identifier format is invalid or courier partner is unselected (Expected KB-LK-XXXXX, PX-LK-XXXXX, or DX-COL-XXXXX).
   Message:   Tracking identifier format invalid. Expected format: KB-LK-XXXXX, PX-LK-XXXXX, or DX-COL-XXXXX.

2. Error Code: ERR_DELIV_ILLEGAL_STATE_TRANSITION
   Name:      Illegal Delivery Lifecycle State Transition
   Condition: Triggered when attempting to transition an order status illegally (e.g., from 'Processing' directly to 'Delivered' without dispatch).
   Message:   Illegal delivery lifecycle transition from "Processing" to "Delivered". Lifecycle must follow: Processing -> Shipped -> In-Transit -> Delivered.

3. Error Code: ERR_RET_WINDOW_EXPIRED
   Name:      Expired Return Window or Unfulfilled Order Claim
   Condition: Triggered when a customer submits a return or warranty inspection for an order that has not yet been delivered or whose 14-day warranty claim window has elapsed.
   Message:   Cannot submit return/warranty claim for order "MM-2026-1003". The order status is currently "Processing". Returns are only permitted after successful delivery.

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- GET /api/orders - List persistent saved orders with customer and status filters
- POST /api/orders - Save new customer order, coordinate stock, invoices, and dispatch
- GET /api/fulfillments - List courier dispatch records (Koombiyo, PromptX, Domex)
- GET /api/fulfillments/:orderId - Fetch delivery checkpoints and live tracking timeline
- POST /api/fulfillments/dispatch - Assign courier partner and tracking identifier
- PUT /api/fulfillments/:dispatchId/status - Advance lifecycle (Shipped, In-Transit, Delivered)
- POST /api/returns - Submit customer return / warranty claim ticket
- GET /api/returns - View list of warranty inspection tickets
- PUT /api/returns/:ticketId - Advance ticket stage (Under Review -> Approved -> Completed)
- DELETE /api/returns/:ticketId - Dismiss invalid return ticket

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 6: "Order Fulfilment, Delivery Tracking & Returns"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
