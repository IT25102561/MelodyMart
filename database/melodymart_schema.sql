-- =============================================================================
-- SRI LANKA INSTITUTE OF INFORMATION TECHNOLOGY (SLIIT)
-- SE2030 - Software Engineering (Year 2, Semester 1 - 2026)
-- Project: MelodyMart - Web-Based Musical Instrument Selling System
-- Organization: Harmony Lanka Musical Stores (Pvt) Ltd.
-- Group: 2026-Y2-S1-MLB-B6G1-08
-- Complete 6 Members Database Schema
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `melodymart_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `melodymart_db`;

-- -----------------------------------------------------------------------------
-- 6.1 USER ACCOUNT & PROFILE MANAGEMENT (IT25101726 - Perera D. A. P. W.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `user_addresses`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(64) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `role` ENUM('CUSTOMER', 'SALES_STAFF', 'INVENTORY_STAFF', 'FINANCE_STAFF', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
  `status` ENUM('ACTIVE', 'INACTIVE', 'DEACTIVATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `user_addresses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  `street` VARCHAR(200) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `district` VARCHAR(50) NOT NULL,
  `postal_code` VARCHAR(10) NOT NULL,
  `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6.2 PRODUCT CATALOG & SEARCH/FILTERING (IT25102561 - Senarathna U. G. S. P.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `products`;

CREATE TABLE `products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(30) NOT NULL UNIQUE,
  `name` VARCHAR(150) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `brand` VARCHAR(50) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `discount_percent` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `description` TEXT NOT NULL,
  `technical_specs` TEXT NOT NULL,
  `warranty_policy` VARCHAR(150) NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `stock_quantity` INT NOT NULL DEFAULT 0,
  `display_order` INT NOT NULL DEFAULT 0,
  `is_archived` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6.3 SHOPPING CART, CHECKOUT & DISCOUNTS (IT25103636 - Pavishanth K.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `discount_vouchers`;

CREATE TABLE `discount_vouchers` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(30) NOT NULL UNIQUE,
  `discount_rate` DECIMAL(5,2) NOT NULL,
  `valid_until` DATE NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE `orders` (
  `order_id` VARCHAR(30) PRIMARY KEY,
  `user_id` INT DEFAULT NULL,
  `customer_name` VARCHAR(100) NOT NULL,
  `customer_email` VARCHAR(100) NOT NULL,
  `customer_phone` VARCHAR(20) NOT NULL,
  `shipping_address` VARCHAR(255) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `district` VARCHAR(50) NOT NULL,
  `courier_name` VARCHAR(50) NOT NULL,
  `tracking_number` VARCHAR(50) NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `delivery_fee` DECIMAL(10,2) NOT NULL,
  `discount_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `payment_method` VARCHAR(30) NOT NULL,
  `payment_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  `fulfillment_status` VARCHAR(20) NOT NULL DEFAULT 'PROCESSING',
  `voucher_code` VARCHAR(30) DEFAULT '',
  `order_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` VARCHAR(30) NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6.4 PAYMENT GATEWAY & INVOICE SYSTEM (IT25101556 - Ekanayaka E. A. T. T.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `invoices`;

CREATE TABLE `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `transaction_id` VARCHAR(40) NOT NULL UNIQUE,
  `order_id` VARCHAR(30) NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `payment_method` VARCHAR(30) NOT NULL,
  `payment_status` ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
  `bank_slip_url` VARCHAR(255) DEFAULT '',
  `transaction_ref` VARCHAR(100) DEFAULT '',
  `refund_details` TEXT DEFAULT NULL,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `invoices` (
  `invoice_number` VARCHAR(40) PRIMARY KEY,
  `order_id` VARCHAR(30) NOT NULL,
  `invoice_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `customer_name` VARCHAR(100) NOT NULL,
  `billing_address` VARCHAR(255) NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `delivery_fee` DECIMAL(10,2) NOT NULL,
  `discount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6.5 REAL-TIME INVENTORY & SUPPLIER MANAGEMENT (IT25103441 - Premasiri R. M. R. R.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `purchase_orders`;
DROP TABLE IF EXISTS `suppliers`;

CREATE TABLE `suppliers` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `supplier_code` VARCHAR(30) NOT NULL UNIQUE,
  `company_name` VARCHAR(120) NOT NULL,
  `contact_person` VARCHAR(80) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(30) NOT NULL,
  `address` TEXT NOT NULL,
  `supplied_categories` VARCHAR(200) NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE `purchase_orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `po_number` VARCHAR(30) NOT NULL UNIQUE,
  `supplier_id` INT NOT NULL,
  `supplier_name` VARCHAR(120) NOT NULL,
  `order_date` DATE NOT NULL,
  `expected_delivery_date` DATE NOT NULL,
  `items_summary` TEXT NOT NULL,
  `total_quantity` INT NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('DRAFT', 'ISSUED', 'RECEIVED', 'CANCELLED') NOT NULL DEFAULT 'ISSUED',
  FOREIGN KEY (`supplier_id`) REFERENCES `suppliers`(`id`)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6.6 ORDER FULFILMENT, DELIVERY TRACKING & RETURNS (IT25100652 - Nellampitiya T. T.)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `fulfillments`;
DROP TABLE IF EXISTS `return_requests`;

CREATE TABLE `fulfillments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `fulfillment_id` VARCHAR(30) NOT NULL UNIQUE,
  `order_id` VARCHAR(30) NOT NULL,
  `customer_name` VARCHAR(100) NOT NULL,
  `shipping_address` VARCHAR(255) NOT NULL,
  `courier_name` VARCHAR(50) NOT NULL,
  `tracking_number` VARCHAR(50) NOT NULL UNIQUE,
  `delivery_status` ENUM('PROCESSING', 'SHIPPED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'PROCESSING',
  `cod_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `cod_collected` BOOLEAN NOT NULL DEFAULT FALSE,
  `dispatched_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `delivered_at` TIMESTAMP NULL DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `return_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `ticket_id` VARCHAR(30) NOT NULL UNIQUE,
  `order_id` VARCHAR(30) NOT NULL,
  `customer_name` VARCHAR(100) NOT NULL,
  `customer_email` VARCHAR(100) NOT NULL,
  `reason` VARCHAR(50) NOT NULL,
  `item_details` TEXT NOT NULL,
  `stage` ENUM('UNDER_REVIEW', 'APPROVED', 'REJECTED', 'COMPLETED') NOT NULL DEFAULT 'UNDER_REVIEW',
  `resolution_notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- SEED DATA: 10 MUSICAL INSTRUMENTS IN SRI LANKA (Member 2)
-- -----------------------------------------------------------------------------
INSERT INTO `products` (`id`, `code`, `name`, `category`, `brand`, `price`, `discount_percent`, `description`, `technical_specs`, `warranty_policy`, `image_url`, `stock_quantity`, `display_order`, `is_archived`) VALUES
(1, 'MM-GTR-001', 'Yamaha F310 Acoustic Guitar - Natural Wood', 'String Instruments', 'Yamaha', 48500.00, 5.00, 'The Yamaha F310 represents everything that you have come to expect from the world leader in musical instruments.', 'Top: Spruce | Back & Sides: Meranti | Fretboard: Rosewood | 20 Frets', '1 Year Official Harmony Lanka Warranty', 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&auto=format&fit=crop&q=80', 15, 1, 0),
(2, 'MM-KEY-002', 'Roland XPS-10 Expandable Synthesizer Keyboard', 'Keyboards & Pianos', 'Roland', 265000.00, 8.00, 'Features dedicated Sri Lankan ethnic & oriental patches with 61 velocity-sensitive keys.', 'Keys: 61 | Tones: 1500+ | Audio Pad: 6 pads | Pitch Bend/Mod lever', '2 Years Official Agent Warranty', 'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=600&auto=format&fit=crop&q=80', 8, 2, 0),
(3, 'MM-DRM-003', 'Pearl Roadshow 5-Piece Complete Drum Kit - Jet Black', 'Drums & Percussion', 'Pearl', 320000.00, 0.00, 'Built with 9-ply poplar shells for punchy tone, reinforced double-braced hardware and brass cymbals.', '22x16 Bass, 10x8 & 12x9 Toms, 16x16 Floor Tom, 14x5.5 Snare | Cymbals included', '1 Year Hardware Warranty', 'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=600&auto=format&fit=crop&q=80', 4, 3, 0),
(4, 'MM-GTR-004', 'Fender Player Stratocaster Electric Guitar - 3-Color Sunburst', 'String Instruments', 'Fender', 285000.00, 10.00, 'Alder body with 3 Player Series Alnico 5 single-coil pickups and 2-point synchronized tremolo.', 'Alder Body | Maple Modern C Neck | 3 Alnico 5 Pickups | 22 Medium Jumbo Frets', '2 Years Fender Warranty', 'https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=600&auto=format&fit=crop&q=80', 6, 4, 0),
(5, 'MM-TRD-005', 'Sri Lankan Traditional Geta Beraya (Kandyan Drum)', 'Traditional Sri Lankan', 'Hewisi Craft', 42000.00, 0.00, 'Authentic handcrafted Kandyan Geta Beraya carved by master artisans in Kurunegala from aged Jak wood.', 'Seasoned Kos Wood | Dahampadaya Deer Hide Treble | Braided Leather Cords', '1 Year Traditional Artisan Guarantee', 'https://images.unsplash.com/photo-1520523839898-507127053e14?w=600&auto=format&fit=crop&q=80', 12, 5, 0),
(6, 'MM-TRD-006', 'Sri Lankan Traditional Yak Beraya (Low Country Drum)', 'Traditional Sri Lankan', 'Ruhunu Kala', 38500.00, 0.00, 'Handcrafted Ruhunu Yak Beraya made from solid hollowed Kithul trunk with dual cow stomach skin heads.', 'Solid Kithul Trunk | Varapata Cow Stomach Heads | Length: 68cm', '1 Year Artisan Warranty', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80', 7, 6, 0),
(7, 'MM-WND-007', 'Yamaha YFL-222 Standard Flute - Silver-Plated', 'Wind Instruments', 'Yamaha', 85000.00, 5.00, 'Favourite among students with closed-hole keys, offset G, and split E mechanism.', 'Nickel Silver Silver-Plated | Closed-hole | Offset G | Split E | Case included', '1 Year Agent Warranty', 'https://images.unsplash.com/photo-1527718641255-324f8e2d0421?w=600&auto=format&fit=crop&q=80', 9, 7, 0),
(8, 'MM-BAS-008', 'Ibanez GSR200 4-String Active Bass Guitar - Walnut Flat', 'String Instruments', 'Ibanez', 115000.00, 7.00, 'Okoume body with versatile P/J pickup configuration and Phat II active bass EQ boost.', 'Okoume Body | Maple Neck | Jatoba Fretboard | Dynamix P/J Pickups | Phat II EQ', '1 Year Manufacturer Warranty', 'https://images.unsplash.com/photo-1550985616-10810253b84d?w=600&auto=format&fit=crop&q=80', 10, 8, 0),
(9, 'MM-VLN-009', 'Stentor Student I Violin 4/4 Full Outfit with Bow & Case', 'String Instruments', 'Stentor', 54000.00, 0.00, 'Solid spruce top and maple back with wooden bow and lightweight padded carrying case.', 'Carved Solid Spruce Top | Solid Maple Back | Hardwood Pegs | Integrated Fine Adjusters', '1 Year Warranty', 'https://images.unsplash.com/photo-1612225330812-01a9c6b355ec?w=600&auto=format&fit=crop&q=80', 11, 9, 0),
(10, 'MM-WND-010', 'Sri Lankan Handcrafted Bamboo Flute (Bansuri / Puluwa)', 'Wind Instruments', 'Lanka Laya', 6500.00, 0.00, 'Native seasoned bamboo flute tuned to 440Hz concert pitch in the Key of E natural medium.', 'Natural Seasoned Bamboo | Key of E Natural Medium | 440 Hz standard', '6 Months Craft Guarantee', 'https://images.unsplash.com/photo-1541689592655-f5f52825a3b8?w=600&auto=format&fit=crop&q=80', 25, 10, 0);

-- Vouchers
INSERT INTO `discount_vouchers` (`code`, `discount_rate`, `valid_until`, `is_active`) VALUES
('MELODY10', 0.10, '2026-12-31', 1),
('AVURUDU15', 0.15, '2026-05-01', 1),
('SLIIT2026', 0.12, '2026-12-31', 1);
