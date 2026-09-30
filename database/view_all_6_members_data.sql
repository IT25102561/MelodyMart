-- =============================================================================
-- MELODYMART - VIEW ALL ADDED DATA ACROSS ALL 6 MEMBERS IN SSMS 22
-- Execute this script in SQL Server Management Studio (SSMS 22) or press F5
-- =============================================================================
USE [melodymart_db];
GO

-- -----------------------------------------------------------------------------
-- MEMBER 1: USER MANAGEMENT & ADDRESS BOOK (IT25101726 - Perera D. A. P. W.)
-- -----------------------------------------------------------------------------
PRINT '=== 1. MEMBER 1: REGISTERED USERS & SYSTEM ACCOUNTS ===';
SELECT 
    [id] AS [User ID],
    [full_name] AS [Full Name],
    [email] AS [Email Address],
    [phone] AS [Phone Number],
    [role] AS [System Role],
    [status] AS [Account Status],
    [created_at] AS [Registered Date]
FROM [dbo].[users]
ORDER BY [id] ASC;
GO

PRINT '=== 1. MEMBER 1: CUSTOMER DELIVERY ADDRESS BOOK ===';
SELECT 
    a.[id] AS [Address ID],
    u.[full_name] AS [Customer Name],
    a.[label] AS [Label],
    a.[street] AS [Street],
    a.[city] AS [City],
    a.[district] AS [District],
    a.[postal_code] AS [Postal Code],
    CASE WHEN a.[is_primary] = 1 THEN 'Yes (Default)' ELSE 'No' END AS [Is Default Shipping]
FROM [dbo].[user_addresses] a
JOIN [dbo].[users] u ON a.[user_id] = u.[id]
ORDER BY a.[id] ASC;
GO

-- -----------------------------------------------------------------------------
-- MEMBER 2: PRODUCT CATALOG & WARRANTY (IT25102561 - Senarathna U. G. S. P.)
-- -----------------------------------------------------------------------------
PRINT '=== 2. MEMBER 2: MUSICAL INSTRUMENT CATALOG & INVENTORY ===';
SELECT 
    [id] AS [Product ID],
    [code] AS [SKU Code],
    [name] AS [Instrument Title],
    [category] AS [Category],
    [brand] AS [Brand],
    FORMAT([price], 'N2') AS [Price (LKR)],
    [discount_percent] AS [Discount %],
    [stock_quantity] AS [Stock Available],
    [warranty_policy] AS [Warranty Period (Numbers Only)],
    [technical_specs] AS [Specifications]
FROM [dbo].[products]
ORDER BY [display_order] ASC;
GO

-- -----------------------------------------------------------------------------
-- MEMBER 3: CART, CHECKOUT & ORDERS (IT25103636 - Pavishanth K.)
-- -----------------------------------------------------------------------------
PRINT '=== 3. MEMBER 3: ACTIVE DISCOUNT VOUCHERS ===';
SELECT 
    [id] AS [Voucher ID],
    [code] AS [Voucher Promo Code],
    CAST(([discount_rate] * 100) AS VARCHAR(10)) + '%' AS [Discount Rate],
    [valid_until] AS [Expiry Date],
    CASE WHEN [is_active] = 1 THEN 'Active' ELSE 'Inactive' END AS [Status]
FROM [dbo].[discount_vouchers];
GO

PRINT '=== 3. MEMBER 3: CUSTOMER ORDERS ===';
SELECT 
    [order_id] AS [Order ID],
    [customer_name] AS [Customer Name],
    [customer_phone] AS [Phone],
    [city] AS [City],
    [courier_name] AS [Courier],
    [tracking_number] AS [Tracking Number],
    FORMAT([total_amount], 'N2') AS [Total Amount (LKR)],
    [payment_method] AS [Payment Method],
    [payment_status] AS [Payment Status],
    [fulfillment_status] AS [Order Status],
    [order_date] AS [Order Placed Time]
FROM [dbo].[orders]
ORDER BY [order_date] DESC;
GO

PRINT '=== 3. MEMBER 3: ORDER LINE ITEMS ===';
SELECT 
    oi.[id] AS [Item ID],
    oi.[order_id] AS [Order ID],
    p.[code] AS [Product SKU],
    oi.[product_name] AS [Instrument Purchased],
    oi.[quantity] AS [Quantity],
    FORMAT(oi.[unit_price], 'N2') AS [Unit Price (LKR)],
    FORMAT(oi.[subtotal], 'N2') AS [Line Total (LKR)]
FROM [dbo].[order_items] oi
LEFT JOIN [dbo].[products] p ON oi.[product_id] = p.[id]
ORDER BY oi.[id] ASC;
GO

-- -----------------------------------------------------------------------------
-- MEMBER 4: PAYMENT GATEWAY & INVOICES (IT25101556 - Ekanayaka E. A. T. T.)
-- -----------------------------------------------------------------------------
PRINT '=== 4. MEMBER 4: PAYMENT TRANSACTIONS ===';
SELECT 
    [id] AS [Payment ID],
    [transaction_id] AS [Transaction ID],
    [order_id] AS [Order ID],
    FORMAT([amount], 'N2') AS [Amount (LKR)],
    [payment_method] AS [Method],
    [payment_status] AS [Status],
    [transaction_ref] AS [Reference / Auth Code],
    [timestamp] AS [Payment Time]
FROM [dbo].[payments]
ORDER BY [id] ASC;
GO

PRINT '=== 4. MEMBER 4: ITEMIZED BILLING INVOICES ===';
SELECT 
    [invoice_number] AS [Invoice No],
    [order_id] AS [Order ID],
    [customer_name] AS [Customer Billed],
    FORMAT([subtotal], 'N2') AS [Subtotal (LKR)],
    FORMAT([delivery_fee], 'N2') AS [Shipping (LKR)],
    FORMAT([vat_amount], 'N2') AS [VAT Tax (LKR)],
    FORMAT([total_amount], 'N2') AS [Grand Total (LKR)],
    [invoice_date] AS [Invoice Date]
FROM [dbo].[invoices]
ORDER BY [invoice_date] DESC;
GO

-- -----------------------------------------------------------------------------
-- MEMBER 5: REAL-TIME INVENTORY & SUPPLIERS (IT25103441 - Premasiri R. M. R. R.)
-- -----------------------------------------------------------------------------
PRINT '=== 5. MEMBER 5: SUPPLIER DIRECTORY ===';
SELECT 
    [id] AS [Supplier ID],
    [supplier_code] AS [Supplier Code],
    [company_name] AS [Company Name],
    [contact_person] AS [Contact Person],
    [phone] AS [Contact Phone],
    [email] AS [Email Address],
    [supplied_categories] AS [Supplied Categories],
    CASE WHEN [is_active] = 1 THEN 'Active Supplier' ELSE 'Inactive' END AS [Status]
FROM [dbo].[suppliers]
ORDER BY [id] ASC;
GO

PRINT '=== 5. MEMBER 5: PURCHASE ORDERS (PO) ===';
SELECT 
    [id] AS [PO ID],
    [po_number] AS [PO Number],
    [supplier_name] AS [Supplier],
    [order_date] AS [PO Issued Date],
    [expected_delivery_date] AS [Expected Delivery],
    [items_summary] AS [Items Summary],
    [total_quantity] AS [Units Ordered],
    FORMAT([total_amount], 'N2') AS [Total Amount (LKR)],
    [status] AS [PO Status]
FROM [dbo].[purchase_orders]
ORDER BY [id] ASC;
GO

-- -----------------------------------------------------------------------------
-- MEMBER 6: ORDER FULFILLMENT & RETURNS (IT25100652 - Nellampitiya T. T.)
-- -----------------------------------------------------------------------------
PRINT '=== 6. MEMBER 6: COURIER DISPATCHES & DELIVERY TRACKING ===';
SELECT 
    [id] AS [Job ID],
    [fulfillment_id] AS [Dispatch Job ID],
    [order_id] AS [Order ID],
    [customer_name] AS [Recipient],
    [courier_name] AS [Courier Service],
    [tracking_number] AS [Tracking Number],
    [delivery_status] AS [Current Status],
    FORMAT([cod_amount], 'N2') AS [COD Amount (LKR)],
    CASE WHEN [cod_collected] = 1 THEN 'Collected' ELSE 'Pending' END AS [COD Status],
    [dispatched_at] AS [Dispatched Time],
    [notes] AS [Courier Notes]
FROM [dbo].[fulfillments]
ORDER BY [id] ASC;
GO

PRINT '=== 6. MEMBER 6: CUSTOMER RMA RETURN REQUESTS ===';
SELECT 
    [id] AS [Ticket ID],
    [ticket_id] AS [RMA Ticket],
    [order_id] AS [Order ID],
    [customer_name] AS [Customer Name],
    [customer_email] AS [Email],
    [reason] AS [Return Reason Code],
    [item_details] AS [Reported Defect / Items],
    [stage] AS [Review Stage],
    [resolution_notes] AS [Resolution Notes],
    [created_at] AS [Submitted Time]
FROM [dbo].[return_requests]
ORDER BY [id] ASC;
GO
