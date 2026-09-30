================================================================================
SRI LANKA INSTITUTE OF INFORMATION TECHNOLOGY (SLIIT)
FACULTY OF COMPUTING | DEPARTMENT OF SOFTWARE ENGINEERING
MODULE: SE2030 - SOFTWARE ENGINEERING (YEAR 2, SEMESTER 1 - 2026)
PROJECT: MelodyMart - Web-Based Musical Instrument Selling System
ORGANIZATION: Harmony Lanka Musical Stores (Pvt) Ltd.
GROUP ID: 2026-Y2-S1-MLB-B6G1-08
================================================================================

PROJECT OVERVIEW:
MelodyMart is a comprehensive Java Web Application running on Apache Tomcat 9
designed for Harmony Lanka Musical Stores (Pvt) Ltd., enabling 24/7 online
browsing, purchasing, multi-channel payment processing, and courier tracking
for 10 authentic musical instruments across Sri Lanka.

GROUP MEMBERS & ASSIGNED CRUD MODULES:
1. IT25101726 - Perera D. A. P. W.
   Module 6.1: User Account & Profile Management
   Text Guide: MEMBER_1_IT25101726_Perera_DAPW.txt
   Files:      UserServlet.java, UserDAO.java, User.java, Address.java, profile.jsp

2. IT25102561 - Senarathna U. G. S. P.
   Module 6.2: Product Catalog & Advanced Search/Filtering
   Text Guide: MEMBER_2_IT25102561_Senarathna_UGSP.txt
   Files:      ProductServlet.java, ProductDAO.java, Product.java, catalog.jsp

3. IT25103636 - Pavishanth K.
   Module 6.3: Shopping Cart, Checkout & Payment
   Text Guide: MEMBER_3_IT25103636_Pavishanth_K.txt
   Files:      CartServlet.java, CheckoutServlet.java, CartDAO.java, Cart.java, cart.jsp, checkout.jsp

4. IT25101556 - Ekanayaka E. A. T. T.
   Module 6.4: Payment Gateway & Invoice System
   Text Guide: MEMBER_4_IT25101556_Ekanayaka_EATT.txt
   Files:      PaymentServlet.java, PaymentDAO.java, Payment.java, Invoice.java, invoice.jsp

5. IT25103441 - Premasiri R. M. R. R.
   Module 6.5: Real-Time Inventory & Supplier Management
   Text Guide: MEMBER_5_IT25103441_Premasiri_RMRR.txt
   Files:      InventorySupplierServlet.java, SupplierDAO.java, Supplier.java, PurchaseOrder.java

6. IT25100652 - Nellampitiya T. T.
   Module 6.6: Order Fulfilment, Delivery Tracking & Returns
   Text Guide: MEMBER_6_IT25100652_Nellampitiya_TT.txt
   Files:      OrderFulfillmentServlet.java, FulfillmentDAO.java, Fulfillment.java, ReturnRequest.java, order_tracking.jsp, returns.jsp

================================================================================
ORDER PERSISTENCE:
- "Save the orders for now."
- All orders placed via checkout are immediately appended to `orders.txt`
  and synchronized across the order history, payments, and courier dispatch logs.

PROJECT DIRECTORY STRUCTURE:
- src/main/java/controllers/  -> Servlets handling HTTP GET/POST for all 6 members
- src/main/java/dao/          -> Data Access Objects providing CRUD operations
- src/main/java/models/       -> POJO entities (User, Product, Cart, Payment, Supplier, Fulfillment)
- src/main/java/utils/        -> DatabaseUtil (MySQL JDBC) and FileStorageUtil (orders.txt writer)
- src/main/webapp/            -> JSP views, CSS styling, client JavaScript, and WEB-INF/web.xml
- members/                    -> Individual folders for each of the 6 group members
- documentation/              -> Individual .txt files for each member and master specification
- orders.txt                  -> Root text file preserving placed orders
- database/                   -> MySQL database schema & sample seeds

HOW TO RUN IN INTELLIJ IDEA / APACHE TOMCAT 9:
1. Open IntelliJ IDEA.
2. Select "Open" and choose the `MelodyMart` folder (or open pom.xml as project).
3. Ensure Apache Tomcat 9 is configured under Run/Debug Configurations.
4. Deploy `MelodyMart:war exploded` artifact to Tomcat 9.
5. Access the application in your browser: http://localhost:8080/MelodyMart/
================================================================================
