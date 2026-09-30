================================================================================
SLIIT - FACULTY OF COMPUTING
SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
MelodyMart: Web-Based Musical Instrument Selling System
Harmony Lanka Musical Stores (Pvt) Ltd.
Group: 2026-Y2-S1-MLB-B6G1-08
================================================================================

STUDENT DETAILS:
Name:      Perera D. A. P. W.
IT Number: IT25101726
Module:    6.1 - User Account & Profile Management

ASSIGNED CRUD OPERATIONS:
[CREATE]
Register new customer and staff user accounts with secure password hashing (SHA-256); add new shipping, billing, and contact addresses to the user's address book.

[READ]
View customer profiles, fetch stored address books, view login session history, and retrieve role-based access permissions for internal staff.

[UPDATE]
Edit personal details (name, phone, email preferences), update account passwords, set primary shipping destinations, and modify assigned staff roles.

[DELETE]
Remove saved addresses from the profile, deactivate customer accounts upon request, or terminate staff access records.

--------------------------------------------------------------------------------
ASSIGNED 3 VALIDATION & BUSINESS ERRORS:
--------------------------------------------------------------------------------
1. Error Code: ERR_USER_DUPLICATE_EMAIL
   Name:      Duplicate Email Registration Conflict
   Condition: Triggered when a user attempts to register with an email address that already exists in the system database.
   Message:   An account with email "kasun.perera@gmail.com" is already registered. Please login or use a different email.

2. Error Code: ERR_USER_PASSWORD_STRENGTH
   Name:      Password Complexity Policy Violation
   Condition: Triggered when a password submitted during registration or profile update contains fewer than 8 characters or fails to include both alphabetic letters and numbers.
   Message:   Password is too weak. It must be at least 8 characters long and include both letters and numbers.

3. Error Code: ERR_USER_INVALID_PHONE
   Name:      Invalid Sri Lankan Mobile Format
   Condition: Triggered when the provided phone number does not conform to Sri Lankan mobile telecommunication network standards (07X-XXXXXXX or +947XXXXXXXX).
   Message:   Invalid Sri Lankan mobile number format. Expected 07XXXXXXXX (e.g., 0771234567 or +94771234567).

--------------------------------------------------------------------------------
API ENDPOINTS & WEB PAGES:
--------------------------------------------------------------------------------
- POST /api/users/register - Register customer or staff user with hashed password
- POST /api/users/login - Authenticate credentials and log session history
- GET /api/users - List all users (Admin view)
- GET /api/users/:id - Fetch single profile with addresses
- PUT /api/users/:id - Update name, phone, role, or status
- POST /api/users/:id/addresses - Add new address to address book
- DELETE /api/users/:id/addresses/:addrId - Remove saved address
- DELETE /api/users/:id - Deactivate user account

VIVA DEMONSTRATION INSTRUCTIONS:
1. Start server: `node src/server.js`
2. Open browser at: http://localhost:3000/admin.html
3. Switch to Tab 1: "User Account & Profile Management"
4. Click the 3 error testing buttons to show live triggers of each error in real-time.
5. Perform Create, Read, Update, and Delete actions using the table controls.
================================================================================
