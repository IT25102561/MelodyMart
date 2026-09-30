-- =============================================================================
-- SRI LANKA INSTITUTE OF INFORMATION TECHNOLOGY (SLIIT)
-- SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
-- Project: MelodyMart - Web-Based Musical Instrument Selling System
-- Organization: Harmony Lanka Musical Stores (Pvt) Ltd.
-- Group: 2026-Y2-S1-MLB-B6G1-08
-- Target Environment: Microsoft SQL Server Management Studio 22 (SSMS 22) / SQL Server 2025
-- Purpose: Complete 6 Members Database Schema, Constraints & Seed Data
-- =============================================================================

-- =============================================================================
-- STEP 1: CREATE DATABASE
-- =============================================================================
IF DB_ID(N'melodymart_db') IS NULL
BEGIN
    PRINT '>> Creating database [melodymart_db]...';
    CREATE DATABASE [melodymart_db];
END
GO

USE [melodymart_db];
GO

PRINT '>> Connected to database [melodymart_db] in SSMS.';
GO

-- =============================================================================
-- STEP 2: DROP EXISTING TABLES IN SAFE REVERSE DEPENDENCY ORDER
-- =============================================================================
IF OBJECT_ID(N'[dbo].[return_requests]', N'U') IS NOT NULL DROP TABLE [dbo].[return_requests];
IF OBJECT_ID(N'[dbo].[fulfillments]', N'U') IS NOT NULL DROP TABLE [dbo].[fulfillments];
IF OBJECT_ID(N'[dbo].[purchase_orders]', N'U') IS NOT NULL DROP TABLE [dbo].[purchase_orders];
IF OBJECT_ID(N'[dbo].[suppliers]', N'U') IS NOT NULL DROP TABLE [dbo].[suppliers];
IF OBJECT_ID(N'[dbo].[invoices]', N'U') IS NOT NULL DROP TABLE [dbo].[invoices];
IF OBJECT_ID(N'[dbo].[payments]', N'U') IS NOT NULL DROP TABLE [dbo].[payments];
IF OBJECT_ID(N'[dbo].[order_items]', N'U') IS NOT NULL DROP TABLE [dbo].[order_items];
IF OBJECT_ID(N'[dbo].[orders]', N'U') IS NOT NULL DROP TABLE [dbo].[orders];
IF OBJECT_ID(N'[dbo].[discount_vouchers]', N'U') IS NOT NULL DROP TABLE [dbo].[discount_vouchers];
IF OBJECT_ID(N'[dbo].[products]', N'U') IS NOT NULL DROP TABLE [dbo].[products];
IF OBJECT_ID(N'[dbo].[user_addresses]', N'U') IS NOT NULL DROP TABLE [dbo].[user_addresses];
IF OBJECT_ID(N'[dbo].[users]', N'U') IS NOT NULL DROP TABLE [dbo].[users];
GO

-- =============================================================================
-- 6.1 MEMBER 1: USER ACCOUNT & PROFILE MANAGEMENT
-- Student: Perera D. A. P. W. (IT25101726)
-- Role: Authentication, RBAC, Profile & Delivery Address Book
-- =============================================================================
PRINT '>> Creating Member 1 Tables: [users], [user_addresses]...';

CREATE TABLE [dbo].[users] (
    [id]            INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_users] PRIMARY KEY,
    [full_name]     NVARCHAR(100) NOT NULL,
    [email]         NVARCHAR(100) NOT NULL CONSTRAINT [UQ_users_email] UNIQUE,
    [password_hash] NVARCHAR(64)  NOT NULL,
    [phone]         NVARCHAR(20)  NOT NULL,
    [role]          NVARCHAR(30)  NOT NULL CONSTRAINT [DF_users_role] DEFAULT 'CUSTOMER',
    [status]        NVARCHAR(30)  NOT NULL CONSTRAINT [DF_users_status] DEFAULT 'ACTIVE',
    [created_at]    DATETIME2     NOT NULL CONSTRAINT [DF_users_created_at] DEFAULT GETDATE(),
    CONSTRAINT [CHK_users_role] CHECK ([role] IN ('CUSTOMER', 'SALES_STAFF', 'INVENTORY_STAFF', 'FINANCE_STAFF', 'ADMIN')),
    CONSTRAINT [CHK_users_status] CHECK ([status] IN ('ACTIVE', 'INACTIVE', 'DEACTIVATED'))
);
GO

CREATE TABLE [dbo].[user_addresses] (
    [id]          INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_user_addresses] PRIMARY KEY,
    [user_id]     INT           NOT NULL,
    [label]       NVARCHAR(50)  NOT NULL,
    [street]      NVARCHAR(200) NOT NULL,
    [city]        NVARCHAR(50)  NOT NULL,
    [district]    NVARCHAR(50)  NOT NULL,
    [postal_code] NVARCHAR(10)  NOT NULL,
    [is_primary]  BIT           NOT NULL CONSTRAINT [DF_user_addresses_is_primary] DEFAULT 0,
    CONSTRAINT [FK_user_addresses_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE
);
GO

-- =============================================================================
-- 6.2 MEMBER 2: PRODUCT CATALOG & ADVANCED SEARCH/FILTERING
-- Student: Senarathna U. G. S. P. (IT25102561)
-- Role: Catalog Browsing, Search/Filters & Instrument CRUD
-- =============================================================================
PRINT '>> Creating Member 2 Table: [products]...';

CREATE TABLE [dbo].[products] (
    [id]               INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_products] PRIMARY KEY,
    [code]             NVARCHAR(30)  NOT NULL CONSTRAINT [UQ_products_code] UNIQUE,
    [name]             NVARCHAR(150) NOT NULL,
    [category]         NVARCHAR(50)  NOT NULL,
    [brand]            NVARCHAR(50)  NOT NULL,
    [price]            DECIMAL(10,2) NOT NULL,
    [discount_percent] DECIMAL(5,2)  NOT NULL CONSTRAINT [DF_products_discount_percent] DEFAULT 0.00,
    [description]      NVARCHAR(MAX) NOT NULL,
    [technical_specs]  NVARCHAR(MAX) NOT NULL,
    [warranty_policy]  NVARCHAR(150) NOT NULL, -- Warranty period in years (Numbers Only, e.g. 1 Year Warranty, 2 Years Warranty)
    [image_url]        NVARCHAR(500) NOT NULL,
    [stock_quantity]   INT           NOT NULL CONSTRAINT [DF_products_stock_quantity] DEFAULT 0,
    [display_order]    INT           NOT NULL CONSTRAINT [DF_products_display_order] DEFAULT 0,
    [is_archived]      BIT           NOT NULL CONSTRAINT [DF_products_is_archived] DEFAULT 0,
    [created_at]       DATETIME2     NOT NULL CONSTRAINT [DF_products_created_at] DEFAULT GETDATE(),
    CONSTRAINT [CHK_products_price] CHECK ([price] > 0.00),
    CONSTRAINT [CHK_products_discount] CHECK ([discount_percent] >= 0.00 AND [discount_percent] <= 100.00),
    CONSTRAINT [CHK_products_stock] CHECK ([stock_quantity] >= 0)
);
GO

-- =============================================================================
-- 6.3 MEMBER 3: SHOPPING CART, CHECKOUT & DISCOUNT VOUCHERS
-- Student: Pavishanth K. (IT25103636)
-- Role: Cart Persistence, Vouchers, Checkout & Customer Orders
-- =============================================================================
PRINT '>> Creating Member 3 Tables: [discount_vouchers], [orders], [order_items]...';

CREATE TABLE [dbo].[discount_vouchers] (
    [id]            INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_discount_vouchers] PRIMARY KEY,
    [code]          NVARCHAR(30) NOT NULL CONSTRAINT [UQ_discount_vouchers_code] UNIQUE,
    [discount_rate] DECIMAL(5,2) NOT NULL,
    [valid_until]   DATE         NOT NULL,
    [is_active]     BIT          NOT NULL CONSTRAINT [DF_discount_vouchers_is_active] DEFAULT 1,
    CONSTRAINT [CHK_voucher_rate] CHECK ([discount_rate] > 0.00 AND [discount_rate] <= 1.00)
);
GO

CREATE TABLE [dbo].[orders] (
    [order_id]           NVARCHAR(30)  NOT NULL CONSTRAINT [PK_orders] PRIMARY KEY,
    [user_id]            INT           NULL,
    [customer_name]      NVARCHAR(100) NOT NULL,
    [customer_email]     NVARCHAR(100) NOT NULL,
    [customer_phone]     NVARCHAR(20)  NOT NULL,
    [shipping_address]   NVARCHAR(255) NOT NULL,
    [city]               NVARCHAR(50)  NOT NULL,
    [district]           NVARCHAR(50)  NOT NULL,
    [courier_name]       NVARCHAR(50)  NOT NULL,
    [tracking_number]    NVARCHAR(50)  NOT NULL,
    [subtotal]           DECIMAL(10,2) NOT NULL,
    [delivery_fee]       DECIMAL(10,2) NOT NULL,
    [discount_amount]    DECIMAL(10,2) NOT NULL CONSTRAINT [DF_orders_discount_amount] DEFAULT 0.00,
    [total_amount]       DECIMAL(10,2) NOT NULL,
    [payment_method]     NVARCHAR(30)  NOT NULL,
    [payment_status]     NVARCHAR(20)  NOT NULL CONSTRAINT [DF_orders_payment_status] DEFAULT 'PENDING',
    [fulfillment_status] NVARCHAR(20)  NOT NULL CONSTRAINT [DF_orders_fulfillment_status] DEFAULT 'PROCESSING',
    [voucher_code]       NVARCHAR(30)  NULL CONSTRAINT [DF_orders_voucher_code] DEFAULT '',
    [order_date]         DATETIME2     NOT NULL CONSTRAINT [DF_orders_order_date] DEFAULT GETDATE(),
    CONSTRAINT [FK_orders_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([id]) ON DELETE SET NULL,
    CONSTRAINT [CHK_orders_totals] CHECK ([total_amount] >= 0.00)
);
GO

CREATE TABLE [dbo].[order_items] (
    [id]           INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_order_items] PRIMARY KEY,
    [order_id]     NVARCHAR(30)  NOT NULL,
    [product_id]   INT           NOT NULL,
    [product_name] NVARCHAR(150) NULL,
    [quantity]     INT           NOT NULL,
    [unit_price]   DECIMAL(10,2) NOT NULL,
    [subtotal]     DECIMAL(10,2) NOT NULL,
    CONSTRAINT [FK_order_items_orders] FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id]) ON DELETE CASCADE,
    CONSTRAINT [FK_order_items_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products]([id]),
    CONSTRAINT [CHK_order_items_qty] CHECK ([quantity] >= 1)
);
GO

-- =============================================================================
-- 6.4 MEMBER 4: PAYMENT GATEWAY & INVOICING SYSTEM
-- Student: Ekanayaka E. A. T. T. (IT25101556)
-- Role: Card Processing, Bank Slip Verification, Refunds & Invoices
-- =============================================================================
PRINT '>> Creating Member 4 Tables: [payments], [invoices]...';

CREATE TABLE [dbo].[payments] (
    [id]              INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_payments] PRIMARY KEY,
    [transaction_id]  NVARCHAR(40)  NOT NULL CONSTRAINT [UQ_payments_transaction_id] UNIQUE,
    [order_id]        NVARCHAR(30)  NOT NULL,
    [amount]          DECIMAL(10,2) NOT NULL,
    [payment_method]  NVARCHAR(30)  NOT NULL,
    [payment_status]  NVARCHAR(30)  NOT NULL CONSTRAINT [DF_payments_payment_status] DEFAULT 'PENDING',
    [bank_slip_url]   NVARCHAR(255) NULL CONSTRAINT [DF_payments_bank_slip_url] DEFAULT '',
    [transaction_ref] NVARCHAR(100) NULL CONSTRAINT [DF_payments_transaction_ref] DEFAULT '',
    [refund_details]  NVARCHAR(MAX) NULL,
    [timestamp]       DATETIME2     NOT NULL CONSTRAINT [DF_payments_timestamp] DEFAULT GETDATE(),
    CONSTRAINT [FK_payments_orders] FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id]) ON DELETE CASCADE,
    CONSTRAINT [CHK_payments_status] CHECK ([payment_status] IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'VOIDED')),
    CONSTRAINT [CHK_payments_amount] CHECK ([amount] > 0.00)
);
GO

CREATE TABLE [dbo].[invoices] (
    [invoice_number]  NVARCHAR(40)  NOT NULL CONSTRAINT [PK_invoices] PRIMARY KEY,
    [order_id]        NVARCHAR(30)  NOT NULL,
    [invoice_date]    DATETIME2     NOT NULL CONSTRAINT [DF_invoices_invoice_date] DEFAULT GETDATE(),
    [customer_name]   NVARCHAR(100) NOT NULL,
    [billing_address] NVARCHAR(255) NOT NULL,
    [subtotal]        DECIMAL(10,2) NOT NULL,
    [delivery_fee]    DECIMAL(10,2) NOT NULL,
    [discount]        DECIMAL(10,2) NOT NULL CONSTRAINT [DF_invoices_discount] DEFAULT 0.00,
    [vat_amount]      DECIMAL(10,2) NOT NULL,
    [total_amount]    DECIMAL(10,2) NOT NULL,
    CONSTRAINT [FK_invoices_orders] FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id]) ON DELETE CASCADE
);
GO

-- =============================================================================
-- 6.5 MEMBER 5: REAL-TIME INVENTORY & SUPPLIER MANAGEMENT
-- Student: Premasiri R. M. R. R. (IT25103441)
-- Role: Supplier Directory, Stock Auditing & Purchase Orders
-- =============================================================================
PRINT '>> Creating Member 5 Tables: [suppliers], [purchase_orders]...';

CREATE TABLE [dbo].[suppliers] (
    [id]                  INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_suppliers] PRIMARY KEY,
    [supplier_code]       NVARCHAR(30)  NOT NULL CONSTRAINT [UQ_suppliers_code] UNIQUE,
    [company_name]        NVARCHAR(120) NOT NULL,
    [contact_person]      NVARCHAR(80)  NOT NULL,
    [email]               NVARCHAR(100) NOT NULL,
    [phone]               NVARCHAR(30)  NOT NULL,
    [address]             NVARCHAR(MAX) NOT NULL,
    [supplied_categories] NVARCHAR(200) NOT NULL,
    [is_active]           BIT           NOT NULL CONSTRAINT [DF_suppliers_is_active] DEFAULT 1
);
GO

CREATE TABLE [dbo].[purchase_orders] (
    [id]                     INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_purchase_orders] PRIMARY KEY,
    [po_number]              NVARCHAR(30)  NOT NULL CONSTRAINT [UQ_purchase_orders_po_number] UNIQUE,
    [supplier_id]            INT           NOT NULL,
    [supplier_name]          NVARCHAR(120) NOT NULL,
    [order_date]             DATE          NOT NULL,
    [expected_delivery_date] DATE          NOT NULL,
    [items_summary]          NVARCHAR(MAX) NOT NULL,
    [total_quantity]         INT           NOT NULL,
    [total_amount]           DECIMAL(10,2) NOT NULL,
    [status]                 NVARCHAR(30)  NOT NULL CONSTRAINT [DF_purchase_orders_status] DEFAULT 'ISSUED',
    CONSTRAINT [FK_purchase_orders_suppliers] FOREIGN KEY ([supplier_id]) REFERENCES [dbo].[suppliers]([id]),
    CONSTRAINT [CHK_po_status] CHECK ([status] IN ('DRAFT', 'ISSUED', 'RECEIVED', 'CANCELLED')),
    CONSTRAINT [CHK_po_quantity] CHECK ([total_quantity] >= 1),
    CONSTRAINT [CHK_po_amount] CHECK ([total_amount] > 0.00)
);
GO

-- =============================================================================
-- 6.6 MEMBER 6: ORDER FULFILLMENT, DELIVERY TRACKING & RETURNS
-- Student: Nellampitiya T. T. (IT25100652)
-- Role: Dispatch Logistics, Courier Milestones & RMA Returns
-- =============================================================================
PRINT '>> Creating Member 6 Tables: [fulfillments], [return_requests]...';

CREATE TABLE [dbo].[fulfillments] (
    [id]              INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_fulfillments] PRIMARY KEY,
    [fulfillment_id]  NVARCHAR(30)  NOT NULL CONSTRAINT [UQ_fulfillments_id] UNIQUE,
    [order_id]        NVARCHAR(30)  NOT NULL,
    [customer_name]   NVARCHAR(100) NOT NULL,
    [shipping_address] NVARCHAR(255) NOT NULL,
    [courier_name]    NVARCHAR(50)  NOT NULL,
    [tracking_number] NVARCHAR(50)  NOT NULL CONSTRAINT [UQ_fulfillments_tracking] UNIQUE,
    [delivery_status] NVARCHAR(30)  NOT NULL CONSTRAINT [DF_fulfillments_status] DEFAULT 'PROCESSING',
    [cod_amount]      DECIMAL(10,2) NOT NULL CONSTRAINT [DF_fulfillments_cod_amount] DEFAULT 0.00,
    [cod_collected]   BIT           NOT NULL CONSTRAINT [DF_fulfillments_cod_collected] DEFAULT 0,
    [dispatched_at]   DATETIME2     NOT NULL CONSTRAINT [DF_fulfillments_dispatched_at] DEFAULT GETDATE(),
    [delivered_at]    DATETIME2     NULL,
    [notes]           NVARCHAR(MAX) NULL,
    CONSTRAINT [FK_fulfillments_orders] FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id]) ON DELETE CASCADE,
    CONSTRAINT [CHK_fulfillments_status] CHECK ([delivery_status] IN ('PROCESSING', 'SHIPPED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'))
);
GO

CREATE TABLE [dbo].[return_requests] (
    [id]               INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_return_requests] PRIMARY KEY,
    [ticket_id]        NVARCHAR(30)  NOT NULL CONSTRAINT [UQ_return_requests_ticket] UNIQUE,
    [order_id]         NVARCHAR(30)  NOT NULL,
    [customer_name]    NVARCHAR(100) NOT NULL,
    [customer_email]   NVARCHAR(100) NOT NULL,
    [reason]           NVARCHAR(50)  NOT NULL,
    [item_details]     NVARCHAR(MAX) NOT NULL,
    [stage]            NVARCHAR(30)  NOT NULL CONSTRAINT [DF_return_requests_stage] DEFAULT 'UNDER_REVIEW',
    [resolution_notes] NVARCHAR(MAX) NULL,
    [created_at]       DATETIME2     NOT NULL CONSTRAINT [DF_return_requests_created_at] DEFAULT GETDATE(),
    CONSTRAINT [FK_return_requests_orders] FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id]) ON DELETE CASCADE,
    CONSTRAINT [CHK_return_requests_stage] CHECK ([stage] IN ('UNDER_REVIEW', 'APPROVED', 'REJECTED', 'COMPLETED'))
);
GO

-- =============================================================================
-- STEP 3: INSERT SEED DATA FOR ALL 6 MEMBERS
-- =============================================================================
PRINT '>> Seeding Member 1 Users & Addresses...';

SET IDENTITY_INSERT [dbo].[users] ON;
INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [created_at]) VALUES
(1, N'Kasun Jayasinghe', N'admin@melodymart.lk', N'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7', N'0771234567', N'ADMIN', N'ACTIVE', '2026-01-10 09:00:00'),
(2, N'Nimal Perera', N'sales@melodymart.lk', N'b0131d869ccf6c9ae9c2d66a8ddb367c7022a554e8477f18068bfb81271ebd90', N'0712345678', N'SALES_STAFF', N'ACTIVE', '2026-01-15 10:30:00'),
(3, N'Ruwan Ekanayake', N'inventory@melodymart.lk', N'845007ea7e4c317db4675e0df8e3f685769a97858ea8f5d59791888176c78254', N'0763456789', N'INVENTORY_STAFF', N'ACTIVE', '2026-01-16 11:00:00'),
(4, N'Chathuri Wickramasinghe', N'finance@melodymart.lk', N'2d1e746e1e575b7c6a0b479d1ee3e410a4b5040da669a5c9fab62d80f65445bf', N'0754567890', N'FINANCE_STAFF', N'ACTIVE', '2026-01-17 14:00:00'),
(5, N'Amila Silva', N'amila.silva@gmail.com', N'10974c706dc45d2bdf31ef2163e1f6f1f0111b6ac1dda885f379c7b78bed26c8', N'0778899001', N'CUSTOMER', N'ACTIVE', '2026-02-01 16:20:00'),
(6, N'Dinuka Fernando', N'dinuka.f@yahoo.com', N'f17c82c6eaf684e1bb0a74f3ca9f9d9d541405c7f91efc7b1b95677a63c6afb1', N'0789900112', N'CUSTOMER', N'ACTIVE', '2026-02-10 11:15:00');
SET IDENTITY_INSERT [dbo].[users] OFF;
GO

SET IDENTITY_INSERT [dbo].[user_addresses] ON;
INSERT INTO [dbo].[user_addresses] ([id], [user_id], [label], [street], [city], [district], [postal_code], [is_primary]) VALUES
(1, 1, N'HQ Office', N'No. 45, Galle Road', N'Colombo 03', N'Colombo', N'00300', 1),
(2, 5, N'Home', N'12/A, Kandy Road', N'Kadawatha', N'Gampaha', N'11850', 1),
(3, 5, N'Music Studio', N'88, Peradeniya Road', N'Kandy', N'Kandy', N'20000', 0),
(4, 6, N'Residence', N'45, Matara Road', N'Galle', N'Galle', N'80000', 1);
SET IDENTITY_INSERT [dbo].[user_addresses] OFF;
GO

PRINT '>> Seeding Member 2 Musical Instruments (Warranty with Numbers Only)...';

SET IDENTITY_INSERT [dbo].[products] ON;
INSERT INTO [dbo].[products] ([id], [code], [name], [category], [brand], [price], [discount_percent], [description], [technical_specs], [warranty_policy], [image_url], [stock_quantity], [display_order], [is_archived], [created_at]) VALUES
(1, N'MM-GTR-001', N'Yamaha F310 Acoustic Guitar - Natural Wood', N'String Instruments', N'Yamaha', 48500.00, 5.00, N'The Yamaha F310 represents outstanding quality, rich warm acoustics and craftsmanship at an affordable price.', N'Top: Spruce | Back & Sides: Meranti | Fretboard: Rosewood | 20 Frets', N'1 Year Warranty', N'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&auto=format&fit=crop&q=80', 15, 1, 0, '2026-01-01 10:00:00'),
(2, N'MM-KEY-002', N'Roland XPS-10 Expandable Synthesizer Keyboard', N'Keyboards & Pianos', N'Roland', 265000.00, 8.00, N'Features dedicated Sri Lankan ethnic & oriental patches with 61 velocity-sensitive synth-action keys.', N'Keys: 61 | Tones: 1500+ | Audio Pad: 6 sound pads | Pitch Bend/Modulation lever', N'2 Years Warranty', N'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=600&auto=format&fit=crop&q=80', 8, 2, 0, '2026-01-02 11:30:00'),
(3, N'MM-DRM-003', N'Pearl Roadshow 5-Piece Complete Drum Kit - Jet Black', N'Drums & Percussion', N'Pearl', 320000.00, 0.00, N'9-ply poplar shells for punchy tone, reinforced double-braced hardware and brass cymbals package included.', N'22x16 Bass, 10x8 & 12x9 Toms, 16x16 Floor Tom, 14x5.5 Snare | Double Braced Stands | Cymbals Included', N'1 Year Warranty', N'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=600&auto=format&fit=crop&q=80', 4, 3, 0, '2026-01-03 12:00:00'),
(4, N'MM-GTR-004', N'Fender Player Stratocaster Electric Guitar - 3-Color Sunburst', N'String Instruments', N'Fender', 285000.00, 10.00, N'Alder body with 3 Player Series Alnico 5 single-coil pickups, modern C maple neck and 2-point tremolo.', N'Alder Body | Maple Modern C Neck | 3 Alnico 5 Pickups | 22 Medium Jumbo Frets', N'2 Years Warranty', N'https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=600&auto=format&fit=crop&q=80', 6, 4, 0, '2026-01-04 14:15:00'),
(5, N'MM-TRD-005', N'Sri Lankan Traditional Geta Beraya (Kandyan Drum)', N'Traditional Sri Lankan', N'Hewisi Craft', 42000.00, 0.00, N'Authentic handcrafted Kandyan Geta Beraya carved by master artisans in Kurunegala from aged Jak wood.', N'Seasoned Kos Wood | Dahampadaya Deer Hide Treble | Braided Leather Cords | Traditional Red Strap', N'1 Year Warranty', N'https://images.unsplash.com/photo-1520523839898-507127053e14?w=600&auto=format&fit=crop&q=80', 12, 5, 0, '2026-01-05 09:45:00'),
(6, N'MM-TRD-006', N'Sri Lankan Traditional Yak Beraya (Low Country Drum)', N'Traditional Sri Lankan', N'Ruhunu Kala', 38500.00, 0.00, N'Solid hollowed Kithul trunk with dual cow stomach skin heads producing deep acoustics for Shanthikarma rituals.', N'Solid Kithul Trunk | Varapata Cow Stomach Heads | Length: ~68cm | Hand-tuned tension laces', N'1 Year Warranty', N'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80', 7, 6, 0, '2026-01-06 10:20:00'),
(7, N'MM-WND-007', N'Yamaha YFL-222 Standard Flute - Silver-Plated', N'Wind Instruments', N'Yamaha', 85000.00, 5.00, N'Favourite among conservatory students with closed-hole keys, offset G, and split E mechanism with hard case.', N'Nickel Silver Silver-Plated | Closed-hole | Offset G | Split E | Hard Carrying Case Included', N'1 Year Warranty', N'https://images.unsplash.com/photo-1527718641255-324f8e2d0421?w=600&auto=format&fit=crop&q=80', 9, 7, 0, '2026-01-07 13:10:00'),
(8, N'MM-BAS-008', N'Ibanez GSR200 4-String Active Bass Guitar - Walnut Flat', N'String Instruments', N'Ibanez', 115000.00, 7.00, N'Okoume body with versatile P/J pickup configuration and Phat II active bass EQ boost for punchy low-end.', N'Okoume Body | Maple Neck | Jatoba Fretboard | Dynamix P/J Pickups | Phat II Active EQ', N'1 Year Warranty', N'https://images.unsplash.com/photo-1550985616-10810253b84d?w=600&auto=format&fit=crop&q=80', 10, 8, 0, '2026-01-08 15:40:00'),
(9, N'MM-VLN-009', N'Stentor Student I Violin 4/4 Full Outfit with Bow & Case', N'String Instruments', N'Stentor', 54000.00, 0.00, N'Solid spruce top and maple back with wooden bow and lightweight padded carrying case.', N'Carved Solid Spruce Top | Solid Maple Back | Hardwood Pegs | Integrated Fine Adjusters Tailpiece', N'1 Year Warranty', N'https://images.unsplash.com/photo-1612225330812-01a9c6b355ec?w=600&auto=format&fit=crop&q=80', 11, 9, 0, '2026-01-09 16:30:00'),
(10, N'MM-WND-010', N'Sri Lankan Handcrafted Bamboo Flute (Bansuri / Puluwa)', N'Wind Instruments', N'Lanka Laya', 6500.00, 0.00, N'Native seasoned bamboo flute tuned to 440Hz concert pitch in the Key of E natural medium.', N'Natural Seasoned Bamboo | Key of E Natural Medium | 440 Hz standard concert tuning | 7 finger holes', N'1 Year Warranty', N'https://images.unsplash.com/photo-1541689592655-f5f52825a3b8?w=600&auto=format&fit=crop&q=80', 25, 10, 0, '2026-01-10 11:00:00');
SET IDENTITY_INSERT [dbo].[products] OFF;
GO

PRINT '>> Seeding Member 3 Vouchers, Orders & Order Items...';

SET IDENTITY_INSERT [dbo].[discount_vouchers] ON;
INSERT INTO [dbo].[discount_vouchers] ([id], [code], [discount_rate], [valid_until], [is_active]) VALUES
(1, N'MELODY10', 0.10, '2026-12-31', 1),
(2, N'AVURUDU15', 0.15, '2026-05-01', 1),
(3, N'SLIIT2026', 0.12, '2026-12-31', 1);
SET IDENTITY_INSERT [dbo].[discount_vouchers] OFF;
GO

INSERT INTO [dbo].[orders] ([order_id], [user_id], [customer_name], [customer_email], [customer_phone], [shipping_address], [city], [district], [courier_name], [tracking_number], [subtotal], [delivery_fee], [discount_amount], [total_amount], [payment_method], [payment_status], [fulfillment_status], [voucher_code], [order_date]) VALUES
(N'ORD-2026-1001', 5, N'Amila Silva', N'amila.silva@gmail.com', N'0778899001', N'12/A, Kandy Road', N'Kadawatha', N'Gampaha', N'Koombiyo Delivery', N'KB-COL-998821', 46075.00, 500.00, 0.00, 46575.00, N'CREDIT_CARD', N'PAID', N'DELIVERED', N'', '2026-02-14 14:30:00'),
(N'ORD-2026-1002', 6, N'Dinuka Fernando', N'dinuka.f@yahoo.com', N'0789900112', N'45, Matara Road', N'Galle', N'Galle', N'Domex Courier', N'DX-GAL-443312', 243800.00, 1200.00, 0.00, 245000.00, N'BANK_TRANSFER', N'PENDING', N'IN_TRANSIT', N'', '2026-02-15 09:10:00');
GO

SET IDENTITY_INSERT [dbo].[order_items] ON;
INSERT INTO [dbo].[order_items] ([id], [order_id], [product_id], [product_name], [quantity], [unit_price], [subtotal]) VALUES
(1, N'ORD-2026-1001', 1, N'Yamaha F310 Acoustic Guitar - Natural Wood', 1, 46075.00, 46075.00),
(2, N'ORD-2026-1002', 2, N'Roland XPS-10 Expandable Synthesizer Keyboard', 1, 243800.00, 243800.00);
SET IDENTITY_INSERT [dbo].[order_items] OFF;
GO

PRINT '>> Seeding Member 4 Payments & Invoices...';

SET IDENTITY_INSERT [dbo].[payments] ON;
INSERT INTO [dbo].[payments] ([id], [transaction_id], [order_id], [amount], [payment_method], [payment_status], [bank_slip_url], [transaction_ref], [refund_details], [timestamp]) VALUES
(1, N'TXN-2026-0001', N'ORD-2026-1001', 46575.00, N'CREDIT_CARD', N'PAID', N'', N'IPG-VISA-992144', N'', '2026-02-14 14:32:10'),
(2, N'TXN-2026-0002', N'ORD-2026-1002', 245000.00, N'BANK_TRANSFER', N'PENDING', N'slip_boc_1002.jpg', N'SLIP-BOC-20260215', N'', '2026-02-15 09:12:44');
SET IDENTITY_INSERT [dbo].[payments] OFF;
GO

INSERT INTO [dbo].[invoices] ([invoice_number], [order_id], [invoice_date], [customer_name], [billing_address], [subtotal], [delivery_fee], [discount], [vat_amount], [total_amount]) VALUES
(N'INV-2026-1001', N'ORD-2026-1001', '2026-02-14 14:30:00', N'Amila Silva', N'12/A, Kandy Road, Kadawatha, Gampaha', 46075.00, 500.00, 0.00, 3450.00, 46575.00),
(N'INV-2026-1002', N'ORD-2026-1002', '2026-02-15 09:10:00', N'Dinuka Fernando', N'45, Matara Road, Galle, Galle', 243800.00, 1200.00, 0.00, 18148.15, 245000.00);
GO

PRINT '>> Seeding Member 5 Suppliers & Purchase Orders...';

SET IDENTITY_INSERT [dbo].[suppliers] ON;
INSERT INTO [dbo].[suppliers] ([id], [supplier_code], [company_name], [contact_person], [email], [phone], [address], [supplied_categories], [is_active]) VALUES
(1, N'SUP-LKA-001', N'Lanka Music Distributors Ltd.', N'Sunil Shantha', N'orders@lankamusic.lk', N'0112845678', N'No 120, High Level Road, Maharagama', N'String Instruments, Keyboards', 1),
(2, N'SUP-LKA-002', N'Upcountry Artisans Guild', N'K. B. Wijeratne', N'hewisi@artisans.lk', N'0812384567', N'Hewisi Village, Kurunegala Road, Kandy', N'Traditional Sri Lankan Drums, Flutes', 1),
(3, N'SUP-SGP-003', N'Yamaha Asia Pacific Pte Ltd', N'David Tan', N'supply@yamaha-sea.com', N'+6567409200', N'138 Robinson Road, Singapore', N'Pianos, Keyboards, Brass & Flutes', 1);
SET IDENTITY_INSERT [dbo].[suppliers] OFF;
GO

SET IDENTITY_INSERT [dbo].[purchase_orders] ON;
INSERT INTO [dbo].[purchase_orders] ([id], [po_number], [supplier_id], [supplier_name], [order_date], [expected_delivery_date], [items_summary], [total_quantity], [total_amount], [status]) VALUES
(1, N'PO-2026-001', 1, N'Lanka Music Distributors Ltd.', '2026-02-01', '2026-02-20', N'Yamaha F310 (x10), Ibanez GSR200 (x5)', 15, 650000.00, N'RECEIVED'),
(2, N'PO-2026-002', 2, N'Upcountry Artisans Guild', '2026-02-10', '2026-02-28', N'Geta Beraya (x8), Yak Beraya (x6)', 14, 480000.00, N'ISSUED');
SET IDENTITY_INSERT [dbo].[purchase_orders] OFF;
GO

PRINT '>> Seeding Member 6 Fulfillments & Return Requests...';

SET IDENTITY_INSERT [dbo].[fulfillments] ON;
INSERT INTO [dbo].[fulfillments] ([id], [fulfillment_id], [order_id], [customer_name], [shipping_address], [courier_name], [tracking_number], [delivery_status], [cod_amount], [cod_collected], [dispatched_at], [delivered_at], [notes]) VALUES
(1, N'DSP-2026-0101', N'ORD-2026-1001', N'Amila Silva', N'12/A, Kandy Road, Kadawatha, Gampaha', N'Koombiyo Delivery', N'KB-COL-998821', N'DELIVERED', 0.00, 1, '2026-02-14 16:00:00', '2026-02-16 11:30:00', N'Delivered and signed by recipient.'),
(2, N'DSP-2026-0102', N'ORD-2026-1002', N'Dinuka Fernando', N'45, Matara Road, Galle', N'Domex Courier', N'DX-GAL-443312', N'IN_TRANSIT', 0.00, 0, '2026-02-15 11:00:00', NULL, N'Departed Southern distribution hub.');
SET IDENTITY_INSERT [dbo].[fulfillments] OFF;
GO

SET IDENTITY_INSERT [dbo].[return_requests] ON;
INSERT INTO [dbo].[return_requests] ([id], [ticket_id], [order_id], [customer_name], [customer_email], [reason], [item_details], [stage], [resolution_notes], [created_at]) VALUES
(1, N'RET-2026-051', N'ORD-2026-1001', N'Amila Silva', N'amila.silva@gmail.com', N'SOUND_DEFECT', N'Yamaha F310 - Buzzing 3rd fret string', N'UNDER_REVIEW', N'Inspecting audio recording submitted by customer.', '2026-02-17 10:15:00');
SET IDENTITY_INSERT [dbo].[return_requests] OFF;
GO

-- =============================================================================
-- STEP 4: CONFIGURE APPLICATION LOGIN FOR SQL SERVER & SSMS
-- =============================================================================
IF SUSER_ID(N'melodymart_user') IS NULL
BEGIN
    PRINT '>> Creating SQL Login [melodymart_user]...';
    EXEC('CREATE LOGIN [melodymart_user] WITH PASSWORD = N''MelodyMart@2026'', DEFAULT_DATABASE = [melodymart_db], CHECK_POLICY = OFF;');
END
ELSE
BEGIN
    PRINT '>> SQL Login [melodymart_user] already exists.';
END
GO

USE [melodymart_db];
GO

IF USER_ID(N'melodymart_user') IS NULL
BEGIN
    PRINT '>> Creating Database User [melodymart_user]...';
    EXEC('CREATE USER [melodymart_user] FOR LOGIN [melodymart_user];');
END
ELSE
BEGIN
    PRINT '>> Database User [melodymart_user] already exists.';
END
GO

IF IS_ROLEMEMBER(N'db_owner', N'melodymart_user') = 0
BEGIN
    ALTER ROLE [db_owner] ADD MEMBER [melodymart_user];
END
GO

-- =============================================================================
-- STEP 5: VERIFICATION & SUMMARY REPORT ACROSS ALL 6 MEMBERS
-- =============================================================================
PRINT '>> =====================================================================';
PRINT '>> MELODYMART DATABASE SETUP COMPLETED IN SQL SERVER MANAGEMENT STUDIO 22';
PRINT '>> =====================================================================';

SELECT 
    'Member 1: Users' AS [Module], 'users' AS [TableName], COUNT(*) AS [RecordCount] FROM [dbo].[users]
UNION ALL
SELECT 
    'Member 1: Addresses', 'user_addresses', COUNT(*) FROM [dbo].[user_addresses]
UNION ALL
SELECT 
    'Member 2: Catalog Products', 'products', COUNT(*) FROM [dbo].[products]
UNION ALL
SELECT 
    'Member 3: Discount Vouchers', 'discount_vouchers', COUNT(*) FROM [dbo].[discount_vouchers]
UNION ALL
SELECT 
    'Member 3: Customer Orders', 'orders', COUNT(*) FROM [dbo].[orders]
UNION ALL
SELECT 
    'Member 3: Order Line Items', 'order_items', COUNT(*) FROM [dbo].[order_items]
UNION ALL
SELECT 
    'Member 4: Payment Transactions', 'payments', COUNT(*) FROM [dbo].[payments]
UNION ALL
SELECT 
    'Member 4: Billing Invoices', 'invoices', COUNT(*) FROM [dbo].[invoices]
UNION ALL
SELECT 
    'Member 5: Suppliers', 'suppliers', COUNT(*) FROM [dbo].[suppliers]
UNION ALL
SELECT 
    'Member 5: Purchase Orders', 'purchase_orders', COUNT(*) FROM [dbo].[purchase_orders]
UNION ALL
SELECT 
    'Member 6: Order Fulfillments', 'fulfillments', COUNT(*) FROM [dbo].[fulfillments]
UNION ALL
SELECT 
    'Member 6: Return RMA Requests', 'return_requests', COUNT(*) FROM [dbo].[return_requests];
GO
