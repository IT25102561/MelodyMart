================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Ekanayaka E. A. T. T.
IT Number: IT25101556
Module:    6.4 - Payment Gateway & Invoice System

ASSIGNED CRUD OPERATIONS:
[CREATE]
Initiate transaction records across payment channels (credit/debit cards, bank transfer slips, digital wallets, COD) and auto-generate itemized e-invoices with tax breakdowns.

[READ]
Track real-time payment states (Pending, Paid, Failed, Refunded), download official printable PDF tax invoices, and access customer transaction histories.

[UPDATE]
Update transaction status following manual bank slip review or payment gateway webhooks, and record processed refund details.

[DELETE]
Void failed or unverified payment attempts, archive obsolete billing records, and cancel invalidated draft invoices.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_PAY_CARD_DECLINED
   Name:      Credit/Debit Card Decline or Validation Failure
   Condition: Triggered when card number length is not 16 digits, contains non-numeric characters, or matches simulated declined test numbers (ending in '0000').
   Message:   Transaction declined by issuing bank (Insufficient funds or security block).

2. Error Code: ERR_PAY_SLIP_REQUIRED
   Name:      Missing Bank Deposit Slip or Reference Number
   Condition: Triggered when Bank Transfer channel is selected but either deposit transaction reference number or confirmation slip upload is missing.
   Message:   Bank transfer requires a valid deposit reference number and an uploaded deposit slip image.

3. Error Code: ERR_PAY_INVALID_REFUND_STATE
   Name:      Illegal Refund Attempt on Non-Paid Invoice
   Condition: Triggered when an administrator or staff attempts to refund an invoice that is not in 'Paid' status (e.g., Pending, Voided, or already Refunded).
   Message:   Cannot refund invoice. Current payment state is "Pending". Only "Paid" transactions can be refunded.

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- POST /api/payments/process - Authorize card, verify slip, or confirm COD
- GET /api/invoices - Retrieve all issued tax invoices
- GET /api/invoices/:invoiceNo - Fetch single official invoice with warranty and line items
- POST /api/invoices/:invoiceNo/refund - Process authorized refund on paid invoices
- DELETE /api/invoices/:invoiceNo/void - Void invalidated or draft invoices

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 4: "Payment Gateway & Invoice System"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
