package utils;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * MelodyMart - Enterprise Multi-Engine Database Utility
 * Target Environment: Microsoft SQL Server Management Studio 22 (SSMS 22) / SQL Server 2025
 * 
 * Implements Multi-Engine Persistence Architecture:
 * 1. Primary: Microsoft SQL Server (localhost:1433/melodymart_db)
 * 2. Secondary Fallback: MySQL Database (localhost:3306/melodymart_db)
 * 3. Offline Standalone Fallback: Embedded SQLite Database (database/melodymart.db)
 * 
 * Auto-initializes all tables for all 6 members and verifies connectivity.
 */
public class DatabaseUtil {

    // 1. Microsoft SQL Server (SSMS 22 / SQL Server on port 1433)
    private static final String MSSQL_HOST = "localhost:1433";
    private static final String MSSQL_DB = "melodymart_db";
    private static final String MSSQL_USER = "melodymart_user";
    private static final String MSSQL_PASS = "MelodyMart@2026";
    private static final String MSSQL_URL = "jdbc:sqlserver://" + MSSQL_HOST + ";databaseName=" + MSSQL_DB + ";user=" + MSSQL_USER + ";password=" + MSSQL_PASS + ";encrypt=true;trustServerCertificate=true;loginTimeout=5;";

    // 2. MySQL Database (localhost:3306)
    private static final String MYSQL_HOST = "localhost:3306";
    private static final String MYSQL_DB = "melodymart_db";
    private static final String MYSQL_URL = "jdbc:mysql://" + MYSQL_HOST + "/" + MYSQL_DB + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&connectTimeout=1500";
    private static final String MYSQL_SERVER_URL = "jdbc:mysql://" + MYSQL_HOST + "/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&connectTimeout=1500";
    private static final String MYSQL_USER = "root";
    private static final String MYSQL_PASS = "";

    private static boolean useMSSQL = false;
    private static boolean useMySQL = false;
    private static String sqlitePath = null;
    private static boolean initialized = false;

    static {
        determineDatabaseMode();
        initializeDatabase();
    }

    public static synchronized void determineDatabaseMode() {
        // Step 1: Attempt Microsoft SQL Server (SSMS 22 / localhost:1433)
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(MSSQL_URL)) {
                if (conn != null && !conn.isClosed()) {
                    useMSSQL = true;
                    useMySQL = false;
                    System.out.println("[MelodyMart DB] Connected successfully to Microsoft SQL Server: " + MSSQL_DB + " on port 1433 (SSMS 22 active)");
                    return;
                }
            } catch (SQLException sqle) {
                System.out.println("[MelodyMart DB] Microsoft SQL Server note: " + sqle.getMessage());
            }
        } catch (ClassNotFoundException e) {
            System.err.println("[MelodyMart DB] Microsoft SQL Server JDBC Driver not found in classpath: " + e.getMessage());
        }

        useMSSQL = false;

        // Step 2: Attempt MySQL
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(MYSQL_URL, MYSQL_USER, MYSQL_PASS)) {
                if (conn != null && !conn.isClosed()) {
                    useMySQL = true;
                    System.out.println("[MelodyMart DB] Connected successfully to MySQL database: " + MYSQL_DB);
                    return;
                }
            } catch (SQLException sqle) {
                // Database might not exist yet, try creating it on localhost
                try (Connection srvConn = DriverManager.getConnection(MYSQL_SERVER_URL, MYSQL_USER, MYSQL_PASS);
                     Statement stmt = srvConn.createStatement()) {
                    stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + MYSQL_DB + " DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                    useMySQL = true;
                    System.out.println("[MelodyMart DB] Created and connected to MySQL database: " + MYSQL_DB);
                    return;
                } catch (Exception ignored) {
                    // MySQL server not running or connection refused
                }
            }
        } catch (ClassNotFoundException ignored) {
        }

        useMySQL = false;

        // Step 3: Fallback to SQLite
        try {
            Class.forName("org.sqlite.JDBC");
            File dbDir = new File("database");
            if (!dbDir.exists()) {
                File baseDir = new File(FileStorageUtil.getBaseStoragePath(), "database");
                if (baseDir.exists()) {
                    dbDir = baseDir;
                } else {
                    dbDir.mkdirs();
                }
            }
            File dbFile = new File(dbDir, "melodymart.db");
            sqlitePath = dbFile.getAbsolutePath();
            System.out.println("[MelodyMart DB] MSSQL & MySQL not reachable. Activated SQLite Database: " + sqlitePath);
        } catch (Exception ex) {
            System.err.println("[MelodyMart DB] Warning: Could not initialize SQLite driver: " + ex.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        if (useMSSQL) {
            try {
                return DriverManager.getConnection(MSSQL_URL);
            } catch (SQLException e) {
                System.err.println("[MelodyMart DB] MSSQL connection lost: " + e.getMessage() + ". Re-evaluating database mode...");
                determineDatabaseMode();
            }
        }

        if (useMySQL) {
            try {
                return DriverManager.getConnection(MYSQL_URL, MYSQL_USER, MYSQL_PASS);
            } catch (SQLException e) {
                System.err.println("[MelodyMart DB] MySQL connection lost. Falling back to SQLite: " + e.getMessage());
                useMySQL = false;
            }
        }

        if (sqlitePath == null) {
            determineDatabaseMode();
        }
        return DriverManager.getConnection("jdbc:sqlite:" + sqlitePath);
    }

    public static boolean isMSSQL() {
        return useMSSQL;
    }

    public static boolean isMySQL() {
        return useMySQL;
    }

    public static String getDatabaseEngineName() {
        if (useMSSQL) {
            return "Microsoft SQL Server (localhost:1433/melodymart_db)";
        }
        return useMySQL ? "MySQL (localhost:3306/melodymart_db)" : "SQLite (" + sqlitePath + ")";
    }

    public static synchronized void initializeDatabase() {
        if (initialized) return;

        if (useMSSQL) {
            try (Connection conn = getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='users'")) {
                if (rs.next() && rs.getInt(1) > 0) {
                    initialized = true;
                    System.out.println("[MelodyMart DB] Microsoft SQL Server schema verified and active for all 6 members.");
                    return;
                }
            } catch (SQLException e) {
                System.err.println("[MelodyMart DB] Notice verifying MSSQL schema: " + e.getMessage());
            }

            try (Connection conn = getConnection()) {
                createMSSQLTables(conn);
                initialized = true;
                System.out.println("[MelodyMart DB] Microsoft SQL Server tables initialized successfully.");
                return;
            } catch (SQLException e) {
                System.err.println("[MelodyMart DB] Error creating MSSQL tables: " + e.getMessage());
            }
        }

        String pk = useMySQL ? "INT AUTO_INCREMENT PRIMARY KEY" : "INTEGER PRIMARY KEY AUTOINCREMENT";

        String[] ddlStatements = {
            // 1. Users
            "CREATE TABLE IF NOT EXISTS users (" +
                "id " + pk + ", " +
                "full_name VARCHAR(100) NOT NULL, " +
                "email VARCHAR(100) NOT NULL UNIQUE, " +
                "password_hash VARCHAR(64) NOT NULL, " +
                "phone VARCHAR(20) NOT NULL, " +
                "role VARCHAR(30) NOT NULL DEFAULT 'CUSTOMER', " +
                "status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE', " +
                "created_at VARCHAR(30) DEFAULT CURRENT_TIMESTAMP" +
            ")",

            // 2. User Addresses
            "CREATE TABLE IF NOT EXISTS user_addresses (" +
                "id " + pk + ", " +
                "user_id INT NOT NULL, " +
                "label VARCHAR(50) NOT NULL, " +
                "street VARCHAR(200) NOT NULL, " +
                "city VARCHAR(50) NOT NULL, " +
                "district VARCHAR(50) NOT NULL, " +
                "postal_code VARCHAR(10) NOT NULL, " +
                "is_primary INT NOT NULL DEFAULT 0" +
            ")",

            // 3. Products
            "CREATE TABLE IF NOT EXISTS products (" +
                "id " + pk + ", " +
                "code VARCHAR(30) NOT NULL UNIQUE, " +
                "name VARCHAR(150) NOT NULL, " +
                "category VARCHAR(50) NOT NULL, " +
                "brand VARCHAR(50) NOT NULL, " +
                "price DOUBLE NOT NULL, " +
                "discount_percent DOUBLE NOT NULL DEFAULT 0.0, " +
                "description TEXT NOT NULL, " +
                "technical_specs TEXT NOT NULL, " +
                "warranty_policy VARCHAR(150) NOT NULL, " +
                "image_url VARCHAR(255) NOT NULL, " +
                "stock_quantity INT NOT NULL DEFAULT 0, " +
                "display_order INT NOT NULL DEFAULT 0, " +
                "is_archived INT NOT NULL DEFAULT 0, " +
                "created_at VARCHAR(30) DEFAULT CURRENT_TIMESTAMP" +
            ")",

            // 4. Discount Vouchers
            "CREATE TABLE IF NOT EXISTS discount_vouchers (" +
                "id " + pk + ", " +
                "code VARCHAR(30) NOT NULL UNIQUE, " +
                "discount_rate DOUBLE NOT NULL, " +
                "valid_until VARCHAR(20) NOT NULL, " +
                "is_active INT NOT NULL DEFAULT 1" +
            ")",

            // 5. Orders
            "CREATE TABLE IF NOT EXISTS orders (" +
                "order_id VARCHAR(30) PRIMARY KEY, " +
                "user_id INT DEFAULT NULL, " +
                "customer_name VARCHAR(100) NOT NULL, " +
                "customer_email VARCHAR(100) NOT NULL, " +
                "customer_phone VARCHAR(20) NOT NULL, " +
                "shipping_address VARCHAR(255) NOT NULL, " +
                "city VARCHAR(50) NOT NULL, " +
                "district VARCHAR(50) NOT NULL, " +
                "courier_name VARCHAR(50) NOT NULL, " +
                "tracking_number VARCHAR(50) NOT NULL, " +
                "subtotal DOUBLE NOT NULL, " +
                "delivery_fee DOUBLE NOT NULL, " +
                "discount_amount DOUBLE NOT NULL DEFAULT 0.0, " +
                "total_amount DOUBLE NOT NULL, " +
                "payment_method VARCHAR(30) NOT NULL, " +
                "payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                "fulfillment_status VARCHAR(20) NOT NULL DEFAULT 'PROCESSING', " +
                "voucher_code VARCHAR(30) DEFAULT '', " +
                "order_date VARCHAR(30) DEFAULT CURRENT_TIMESTAMP" +
            ")",

            // 6. Order Items
            "CREATE TABLE IF NOT EXISTS order_items (" +
                "id " + pk + ", " +
                "order_id VARCHAR(30) NOT NULL, " +
                "product_id INT NOT NULL, " +
                "product_name VARCHAR(150), " +
                "quantity INT NOT NULL, " +
                "unit_price DOUBLE NOT NULL, " +
                "subtotal DOUBLE NOT NULL" +
            ")",

            // 7. Payments
            "CREATE TABLE IF NOT EXISTS payments (" +
                "id " + pk + ", " +
                "transaction_id VARCHAR(40) NOT NULL UNIQUE, " +
                "order_id VARCHAR(30) NOT NULL, " +
                "amount DOUBLE NOT NULL, " +
                "payment_method VARCHAR(30) NOT NULL, " +
                "payment_status VARCHAR(30) NOT NULL DEFAULT 'PENDING', " +
                "bank_slip_url VARCHAR(255) DEFAULT '', " +
                "transaction_ref VARCHAR(100) DEFAULT '', " +
                "refund_details TEXT, " +
                "timestamp VARCHAR(30) DEFAULT CURRENT_TIMESTAMP" +
            ")",

            // 8. Invoices
            "CREATE TABLE IF NOT EXISTS invoices (" +
                "invoice_number VARCHAR(40) PRIMARY KEY, " +
                "order_id VARCHAR(30) NOT NULL, " +
                "invoice_date VARCHAR(30) DEFAULT CURRENT_TIMESTAMP, " +
                "customer_name VARCHAR(100) NOT NULL, " +
                "billing_address VARCHAR(255) NOT NULL, " +
                "subtotal DOUBLE NOT NULL, " +
                "delivery_fee DOUBLE NOT NULL, " +
                "discount DOUBLE NOT NULL DEFAULT 0.0, " +
                "vat_amount DOUBLE NOT NULL, " +
                "total_amount DOUBLE NOT NULL" +
            ")",

            // 9. Suppliers
            "CREATE TABLE IF NOT EXISTS suppliers (" +
                "id " + pk + ", " +
                "supplier_code VARCHAR(30) NOT NULL UNIQUE, " +
                "company_name VARCHAR(120) NOT NULL, " +
                "contact_person VARCHAR(80) NOT NULL, " +
                "email VARCHAR(100) NOT NULL, " +
                "phone VARCHAR(30) NOT NULL, " +
                "address TEXT NOT NULL, " +
                "supplied_categories VARCHAR(200) NOT NULL, " +
                "is_active INT NOT NULL DEFAULT 1" +
            ")",

            // 10. Purchase Orders
            "CREATE TABLE IF NOT EXISTS purchase_orders (" +
                "id " + pk + ", " +
                "po_number VARCHAR(30) NOT NULL UNIQUE, " +
                "supplier_id INT NOT NULL, " +
                "supplier_name VARCHAR(120) NOT NULL, " +
                "order_date VARCHAR(20) NOT NULL, " +
                "expected_delivery_date VARCHAR(20) NOT NULL, " +
                "items_summary TEXT NOT NULL, " +
                "total_quantity INT NOT NULL, " +
                "total_amount DOUBLE NOT NULL, " +
                "status VARCHAR(30) NOT NULL DEFAULT 'ISSUED'" +
            ")",

            // 11. Fulfillments
            "CREATE TABLE IF NOT EXISTS fulfillments (" +
                "id " + pk + ", " +
                "fulfillment_id VARCHAR(30) NOT NULL UNIQUE, " +
                "order_id VARCHAR(30) NOT NULL, " +
                "customer_name VARCHAR(100) NOT NULL, " +
                "shipping_address VARCHAR(255) NOT NULL, " +
                "courier_name VARCHAR(50) NOT NULL, " +
                "tracking_number VARCHAR(50) NOT NULL UNIQUE, " +
                "delivery_status VARCHAR(30) NOT NULL DEFAULT 'PROCESSING', " +
                "cod_amount DOUBLE NOT NULL DEFAULT 0.0, " +
                "cod_collected INT NOT NULL DEFAULT 0, " +
                "dispatched_at VARCHAR(30) DEFAULT CURRENT_TIMESTAMP, " +
                "delivered_at VARCHAR(30), " +
                "notes TEXT" +
            ")",

            // 12. Return Requests
            "CREATE TABLE IF NOT EXISTS return_requests (" +
                "id " + pk + ", " +
                "ticket_id VARCHAR(30) NOT NULL UNIQUE, " +
                "order_id VARCHAR(30) NOT NULL, " +
                "customer_name VARCHAR(100) NOT NULL, " +
                "customer_email VARCHAR(100) NOT NULL, " +
                "reason VARCHAR(50) NOT NULL, " +
                "item_details TEXT NOT NULL, " +
                "stage VARCHAR(30) NOT NULL DEFAULT 'UNDER_REVIEW', " +
                "resolution_notes TEXT, " +
                "created_at VARCHAR(30) DEFAULT CURRENT_TIMESTAMP" +
            ")"
        };

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            for (String sql : ddlStatements) {
                try {
                    stmt.executeUpdate(sql);
                } catch (SQLException e) {
                    System.err.println("[MelodyMart DB] Error executing DDL: " + e.getMessage());
                }
            }

            if (useMySQL) {
                try {
                    stmt.executeUpdate("ALTER TABLE payments MODIFY COLUMN payment_status VARCHAR(30) NOT NULL DEFAULT 'PENDING'");
                } catch (Exception ignored) {}
            }

            seedInitialDataIfEmpty(conn);
            initialized = true;
            System.out.println("[MelodyMart DB] All tables verified and initialized successfully.");

        } catch (SQLException e) {
            System.err.println("[MelodyMart DB] Failed to initialize database schema: " + e.getMessage());
        }
    }

    private static void seedInitialDataIfEmpty(Connection conn) {
        try {
            // Check products
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM products")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedProducts(conn);
                }
            }

            // Check users
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedUsers(conn);
                }
            }

            // Check vouchers
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM discount_vouchers")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedVouchers(conn);
                }
            }

            // Check suppliers
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM suppliers")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedSuppliers(conn);
                }
            }

            // Check orders
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedOrders(conn);
                }
            }

            // Check payments
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM payments")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedPayments(conn);
                }
            }

            // Check fulfillments
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM fulfillments")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedFulfillments(conn);
                }
            }

        } catch (SQLException e) {
            System.err.println("[MelodyMart DB] Notice during data seeding: " + e.getMessage());
        }
    }

    private static void seedProducts(Connection conn) throws SQLException {
        String insertSql = "INSERT INTO products (id, code, name, category, brand, price, discount_percent, description, technical_specs, warranty_policy, image_url, stock_quantity, display_order, is_archived) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            Object[][] prods = {
                {1, "MM-GTR-001", "Yamaha F310 Acoustic Guitar - Natural Wood", "String Instruments", "Yamaha", 48500.0, 5.0, "The Yamaha F310 represents outstanding quality and tone at an affordable price.", "Top: Spruce | Back & Sides: Meranti | Fretboard: Rosewood | 20 Frets", "1 Year Official Harmony Lanka Warranty", "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&auto=format&fit=crop&q=80", 15, 1},
                {2, "MM-KEY-002", "Roland XPS-10 Expandable Synthesizer Keyboard", "Keyboards & Pianos", "Roland", 265000.0, 8.0, "Features dedicated Sri Lankan ethnic & oriental patches with 61 velocity-sensitive keys.", "Keys: 61 | Tones: 1500+ | Audio Pad: 6 sound pads | Pitch Bend/Modulation lever", "2 Years Official Agent Warranty", "https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=600&auto=format&fit=crop&q=80", 8, 2},
                {3, "MM-DRM-003", "Pearl Roadshow 5-Piece Complete Drum Kit - Jet Black", "Drums & Percussion", "Pearl", 320000.0, 0.0, "9-ply poplar shells for punchy tone, reinforced hardware and brass cymbals.", "22x16 Bass, 10x8 & 12x9 Toms, 16x16 Floor Tom, 14x5.5 Snare | Cymbals included", "1 Year Complete Hardware Warranty", "https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=600&auto=format&fit=crop&q=80", 4, 3},
                {4, "MM-GTR-004", "Fender Player Stratocaster Electric Guitar - 3-Color Sunburst", "String Instruments", "Fender", 285000.0, 10.0, "Alder body with 3 Player Series Alnico 5 pickups and 2-point synchronized tremolo.", "Alder Body | Maple Modern C Neck | 3 Alnico 5 Pickups | 22 Medium Jumbo Frets", "2 Years Fender International Warranty", "https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=600&auto=format&fit=crop&q=80", 6, 4},
                {5, "MM-TRD-005", "Sri Lankan Traditional Geta Beraya (Kandyan Drum)", "Traditional Sri Lankan", "Hewisi Craft", 42000.0, 0.0, "Authentic handcrafted Kandyan Geta Beraya carved by master artisans in Kurunegala from aged Jak wood.", "Seasoned Kos Wood | Dahampadaya Deer Hide Treble | Braided Leather Cords", "1 Year Traditional Artisan Guarantee", "https://images.unsplash.com/photo-1520523839898-507127053e14?w=600&auto=format&fit=crop&q=80", 12, 5},
                {6, "MM-TRD-006", "Sri Lankan Traditional Yak Beraya (Low Country Drum)", "Traditional Sri Lankan", "Ruhunu Kala", 38500.0, 0.0, "Solid hollowed Kithul trunk with dual cow stomach skin heads producing deep acoustics.", "Solid Kithul Trunk | Varapata Cow Stomach Heads | Length: ~68cm", "1 Year Artisan Warranty", "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80", 7, 6},
                {7, "MM-WND-007", "Yamaha YFL-222 Standard Flute - Silver-Plated", "Wind Instruments", "Yamaha", 85000.0, 5.0, "Closed-hole keys, offset G, and split E mechanism with hard case.", "Nickel Silver Silver-Plated | Closed-hole | Offset G | Split E | Hard Case", "1 Year Agent Warranty", "https://images.unsplash.com/photo-1527718641255-324f8e2d0421?w=600&auto=format&fit=crop&q=80", 9, 7},
                {8, "MM-BAS-008", "Ibanez GSR200 4-String Active Bass Guitar - Walnut Flat", "String Instruments", "Ibanez", 115000.0, 7.0, "Okoume body with versatile P/J pickup configuration and Phat II active bass boost.", "Okoume Body | Maple Neck | Jatoba Fretboard | Dynamix P/J Pickups | Phat II EQ", "1 Year Manufacturer Warranty", "https://images.unsplash.com/photo-1550985616-10810253b84d?w=600&auto=format&fit=crop&q=80", 10, 8},
                {9, "MM-VLN-009", "Stentor Student I Violin 4/4 Full Outfit with Bow & Case", "String Instruments", "Stentor", 54000.0, 0.0, "Solid spruce top and maple back with wooden bow and lightweight padded carrying case.", "Carved Solid Spruce Top | Solid Maple Back | Hardwood Pegs | Integrated Fine Adjusters", "1 Year Warranty", "https://images.unsplash.com/photo-1612225330812-01a9c6b355ec?w=600&auto=format&fit=crop&q=80", 11, 9},
                {10, "MM-WND-010", "Sri Lankan Handcrafted Bamboo Flute (Bansuri / Puluwa)", "Wind Instruments", "Lanka Laya", 6500.0, 0.0, "Native seasoned bamboo flute tuned to 440Hz concert pitch in the Key of E natural medium.", "Natural Seasoned Bamboo | Key of E Natural Medium | 440 Hz standard", "6 Months Craft Guarantee", "https://images.unsplash.com/photo-1541689592655-f5f52825a3b8?w=600&auto=format&fit=crop&q=80", 25, 10}
            };
            for (Object[] p : prods) {
                ps.setInt(1, (Integer) p[0]);
                ps.setString(2, (String) p[1]);
                ps.setString(3, (String) p[2]);
                ps.setString(4, (String) p[3]);
                ps.setString(5, (String) p[4]);
                ps.setDouble(6, (Double) p[5]);
                ps.setDouble(7, (Double) p[6]);
                ps.setString(8, (String) p[7]);
                ps.setString(9, (String) p[8]);
                ps.setString(10, (String) p[9]);
                ps.setString(11, (String) p[10]);
                ps.setInt(12, (Integer) p[11]);
                ps.setInt(13, (Integer) p[12]);
                ps.executeUpdate();
            }
        }
    }

    private static void seedUsers(Connection conn) throws SQLException {
        String insertUser = "INSERT INTO users (id, full_name, email, password_hash, phone, role, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertUser)) {
            Object[][] users = {
                {1, "Kasun Jayasinghe", "admin@melodymart.lk", "e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7", "0771234567", "ADMIN", "ACTIVE", "2026-01-10 09:00:00"},
                {2, "Nimal Perera", "sales@melodymart.lk", "b0131d869ccf6c9ae9c2d66a8ddb367c7022a554e8477f18068bfb81271ebd90", "0712345678", "SALES_STAFF", "ACTIVE", "2026-01-15 10:30:00"},
                {3, "Ruwan Ekanayake", "inventory@melodymart.lk", "845007ea7e4c317db4675e0df8e3f685769a97858ea8f5d59791888176c78254", "0763456789", "INVENTORY_STAFF", "ACTIVE", "2026-01-16 11:00:00"},
                {4, "Chathuri Wickramasinghe", "finance@melodymart.lk", "2d1e746e1e575b7c6a0b479d1ee3e410a4b5040da669a5c9fab62d80f65445bf", "0754567890", "FINANCE_STAFF", "ACTIVE", "2026-01-17 14:00:00"},
                {5, "Amila Silva", "amila.silva@gmail.com", "10974c706dc45d2bdf31ef2163e1f6f1f0111b6ac1dda885f379c7b78bed26c8", "0778899001", "CUSTOMER", "ACTIVE", "2026-02-01 16:20:00"},
                {6, "Dinuka Fernando", "dinuka.f@yahoo.com", "f17c82c6eaf684e1bb0a74f3ca9f9d9d541405c7f91efc7b1b95677a63c6afb1", "0789900112", "CUSTOMER", "ACTIVE", "2026-02-10 11:15:00"}
            };
            for (Object[] u : users) {
                ps.setInt(1, (Integer) u[0]);
                ps.setString(2, (String) u[1]);
                ps.setString(3, (String) u[2]);
                ps.setString(4, (String) u[3]);
                ps.setString(5, (String) u[4]);
                ps.setString(6, (String) u[5]);
                ps.setString(7, (String) u[6]);
                ps.setString(8, (String) u[7]);
                ps.executeUpdate();
            }
        }

        String insertAddr = "INSERT INTO user_addresses (id, user_id, label, street, city, district, postal_code, is_primary) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertAddr)) {
            Object[][] addrs = {
                {1, 1, "HQ Office", "No. 45, Galle Road", "Colombo 03", "Colombo", "00300", 1},
                {2, 5, "Home", "12/A, Kandy Road", "Kadawatha", "Gampaha", "11850", 1},
                {3, 5, "Music Studio", "88, Peradeniya Road", "Kandy", "Kandy", "20000", 0},
                {4, 6, "Residence", "45, Matara Road", "Galle", "Galle", "80000", 1}
            };
            for (Object[] a : addrs) {
                ps.setInt(1, (Integer) a[0]);
                ps.setInt(2, (Integer) a[1]);
                ps.setString(3, (String) a[2]);
                ps.setString(4, (String) a[3]);
                ps.setString(5, (String) a[4]);
                ps.setString(6, (String) a[5]);
                ps.setString(7, (String) a[6]);
                ps.setInt(8, (Integer) a[7]);
                ps.executeUpdate();
            }
        }
    }

    private static void seedVouchers(Connection conn) throws SQLException {
        String sql = "INSERT INTO discount_vouchers (id, code, discount_rate, valid_until, is_active) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, 1); ps.setString(2, "MELODY10"); ps.setDouble(3, 0.10); ps.setString(4, "2026-12-31"); ps.setInt(5, 1); ps.executeUpdate();
            ps.setInt(1, 2); ps.setString(2, "AVURUDU15"); ps.setDouble(3, 0.15); ps.setString(4, "2026-05-01"); ps.setInt(5, 1); ps.executeUpdate();
            ps.setInt(1, 3); ps.setString(2, "SLIIT2026"); ps.setDouble(3, 0.12); ps.setString(4, "2026-12-31"); ps.setInt(5, 1); ps.executeUpdate();
        }
    }

    private static void seedSuppliers(Connection conn) throws SQLException {
        String supSql = "INSERT INTO suppliers (id, supplier_code, company_name, contact_person, email, phone, address, supplied_categories, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(supSql)) {
            ps.setInt(1, 1); ps.setString(2, "SUP-LKA-001"); ps.setString(3, "Lanka Music Distributors Ltd."); ps.setString(4, "Sunil Shantha");
            ps.setString(5, "orders@lankamusic.lk"); ps.setString(6, "0112845678"); ps.setString(7, "No 120, High Level Road, Maharagama");
            ps.setString(8, "String Instruments, Keyboards"); ps.setInt(9, 1); ps.executeUpdate();

            ps.setInt(1, 2); ps.setString(2, "SUP-LKA-002"); ps.setString(3, "Upcountry Artisans Guild"); ps.setString(4, "K. B. Wijeratne");
            ps.setString(5, "hewisi@artisans.lk"); ps.setString(6, "0812384567"); ps.setString(7, "Hewisi Village, Kurunegala Road, Kandy");
            ps.setString(8, "Traditional Sri Lankan Drums, Flutes"); ps.setInt(9, 1); ps.executeUpdate();

            ps.setInt(1, 3); ps.setString(2, "SUP-SGP-003"); ps.setString(3, "Yamaha Asia Pacific Pte Ltd"); ps.setString(4, "David Tan");
            ps.setString(5, "supply@yamaha-sea.com"); ps.setString(6, "+6567409200"); ps.setString(7, "138 Robinson Road, Singapore");
            ps.setString(8, "Pianos, Keyboards, Brass & Flutes"); ps.setInt(9, 1); ps.executeUpdate();
        }

        String poSql = "INSERT INTO purchase_orders (id, po_number, supplier_id, supplier_name, order_date, expected_delivery_date, items_summary, total_quantity, total_amount, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(poSql)) {
            ps.setInt(1, 1); ps.setString(2, "PO-2026-001"); ps.setInt(3, 1); ps.setString(4, "Lanka Music Distributors Ltd.");
            ps.setString(5, "2026-02-01"); ps.setString(6, "2026-02-20"); ps.setString(7, "Yamaha F310 (x10), Ibanez GSR200 (x5)");
            ps.setInt(8, 15); ps.setDouble(9, 650000.0); ps.setString(10, "RECEIVED"); ps.executeUpdate();

            ps.setInt(1, 2); ps.setString(2, "PO-2026-002"); ps.setInt(3, 2); ps.setString(4, "Upcountry Artisans Guild");
            ps.setString(5, "2026-02-10"); ps.setString(6, "2026-02-28"); ps.setString(7, "Geta Beraya (x8), Yak Beraya (x6)");
            ps.setInt(8, 14); ps.setDouble(9, 480000.0); ps.setString(10, "ISSUED"); ps.executeUpdate();
        }
    }

    private static void seedOrders(Connection conn) throws SQLException {
        String ordSql = "INSERT INTO orders (order_id, user_id, customer_name, customer_email, customer_phone, shipping_address, city, district, courier_name, tracking_number, subtotal, delivery_fee, discount_amount, total_amount, payment_method, payment_status, fulfillment_status, voucher_code, order_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(ordSql)) {
            ps.setString(1, "ORD-2026-1001"); ps.setInt(2, 5); ps.setString(3, "Amila Silva"); ps.setString(4, "amila.silva@gmail.com");
            ps.setString(5, "0778899001"); ps.setString(6, "12/A, Kandy Road"); ps.setString(7, "Kadawatha"); ps.setString(8, "Gampaha");
            ps.setString(9, "Koombiyo Delivery"); ps.setString(10, "KB-COL-998821"); ps.setDouble(11, 46075.0); ps.setDouble(12, 500.0);
            ps.setDouble(13, 0.0); ps.setDouble(14, 46575.0); ps.setString(15, "CREDIT_CARD"); ps.setString(16, "PAID");
            ps.setString(17, "DELIVERED"); ps.setString(18, ""); ps.setString(19, "2026-02-14 14:30:00"); ps.executeUpdate();

            ps.setString(1, "ORD-2026-1002"); ps.setInt(2, 6); ps.setString(3, "Dinuka Fernando"); ps.setString(4, "dinuka.f@yahoo.com");
            ps.setString(5, "0789900112"); ps.setString(6, "45, Matara Road"); ps.setString(7, "Galle"); ps.setString(8, "Galle");
            ps.setString(9, "Domex Courier"); ps.setString(10, "DX-GAL-443312"); ps.setDouble(11, 243800.0); ps.setDouble(12, 1200.0);
            ps.setDouble(13, 0.0); ps.setDouble(14, 245000.0); ps.setString(15, "BANK_TRANSFER"); ps.setString(16, "PENDING");
            ps.setString(17, "IN_TRANSIT"); ps.setString(18, ""); ps.setString(19, "2026-02-15 09:10:00"); ps.executeUpdate();
        }

        String itmSql = "INSERT INTO order_items (id, order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(itmSql)) {
            ps.setInt(1, 1); ps.setString(2, "ORD-2026-1001"); ps.setInt(3, 1); ps.setString(4, "Yamaha F310 Acoustic Guitar - Natural Wood");
            ps.setInt(5, 1); ps.setDouble(6, 46075.0); ps.setDouble(7, 46075.0); ps.executeUpdate();

            ps.setInt(1, 2); ps.setString(2, "ORD-2026-1002"); ps.setInt(3, 2); ps.setString(4, "Roland XPS-10 Expandable Synthesizer Keyboard");
            ps.setInt(5, 1); ps.setDouble(6, 243800.0); ps.setDouble(7, 243800.0); ps.executeUpdate();
        }
    }

    private static void seedPayments(Connection conn) throws SQLException {
        String paySql = "INSERT INTO payments (id, transaction_id, order_id, amount, payment_method, payment_status, bank_slip_url, transaction_ref, refund_details, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(paySql)) {
            ps.setInt(1, 1); ps.setString(2, "TXN-2026-0001"); ps.setString(3, "ORD-2026-1001"); ps.setDouble(4, 46575.0);
            ps.setString(5, "CREDIT_CARD"); ps.setString(6, "PAID"); ps.setString(7, ""); ps.setString(8, "IPG-VISA-992144");
            ps.setString(9, ""); ps.setString(10, "2026-02-14 14:32:10"); ps.executeUpdate();

            ps.setInt(1, 2); ps.setString(2, "TXN-2026-0002"); ps.setString(3, "ORD-2026-1002"); ps.setDouble(4, 245000.0);
            ps.setString(5, "BANK_TRANSFER"); ps.setString(6, "PENDING"); ps.setString(7, "slip_boc_1002.jpg"); ps.setString(8, "SLIP-BOC-20260215");
            ps.setString(9, ""); ps.setString(10, "2026-02-15 09:12:44"); ps.executeUpdate();
        }

        String invSql = "INSERT INTO invoices (invoice_number, order_id, invoice_date, customer_name, billing_address, subtotal, delivery_fee, discount, vat_amount, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(invSql)) {
            ps.setString(1, "INV-2026-1001"); ps.setString(2, "ORD-2026-1001"); ps.setString(3, "2026-02-14 14:30:00");
            ps.setString(4, "Amila Silva"); ps.setString(5, "12/A, Kandy Road, Kadawatha, Gampaha");
            ps.setDouble(6, 46075.0); ps.setDouble(7, 500.0); ps.setDouble(8, 0.0); ps.setDouble(9, 3450.0); ps.setDouble(10, 46575.0);
            ps.executeUpdate();

            ps.setString(1, "INV-2026-1002"); ps.setString(2, "ORD-2026-1002"); ps.setString(3, "2026-02-15 09:10:00");
            ps.setString(4, "Dinuka Fernando"); ps.setString(5, "45, Matara Road, Galle, Galle");
            ps.setDouble(6, 243800.0); ps.setDouble(7, 1200.0); ps.setDouble(8, 0.0); ps.setDouble(9, 18148.15); ps.setDouble(10, 245000.0);
            ps.executeUpdate();
        }
    }

    private static void seedFulfillments(Connection conn) throws SQLException {
        String fulSql = "INSERT INTO fulfillments (id, fulfillment_id, order_id, customer_name, shipping_address, courier_name, tracking_number, delivery_status, cod_amount, cod_collected, dispatched_at, delivered_at, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(fulSql)) {
            ps.setInt(1, 1); ps.setString(2, "DSP-2026-0101"); ps.setString(3, "ORD-2026-1001"); ps.setString(4, "Amila Silva");
            ps.setString(5, "12/A, Kandy Road, Kadawatha, Gampaha"); ps.setString(6, "Koombiyo Delivery"); ps.setString(7, "KB-COL-998821");
            ps.setString(8, "DELIVERED"); ps.setDouble(9, 0.0); ps.setInt(10, 1); ps.setString(11, "2026-02-14 16:00:00");
            ps.setString(12, "2026-02-16 11:30:00"); ps.setString(13, "Delivered and signed by recipient."); ps.executeUpdate();

            ps.setInt(1, 2); ps.setString(2, "DSP-2026-0102"); ps.setString(3, "ORD-2026-1002"); ps.setString(4, "Dinuka Fernando");
            ps.setString(5, "45, Matara Road, Galle"); ps.setString(6, "Domex Courier"); ps.setString(7, "DX-GAL-443312");
            ps.setString(8, "IN_TRANSIT"); ps.setDouble(9, 0.0); ps.setInt(10, 0); ps.setString(11, "2026-02-15 11:00:00");
            ps.setString(12, ""); ps.setString(13, "Departed Southern distribution hub."); ps.executeUpdate();
        }

        String retSql = "INSERT INTO return_requests (id, ticket_id, order_id, customer_name, customer_email, reason, item_details, stage, resolution_notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(retSql)) {
            ps.setInt(1, 1); ps.setString(2, "RET-2026-051"); ps.setString(3, "ORD-2026-1001"); ps.setString(4, "Amila Silva");
            ps.setString(5, "amila.silva@gmail.com"); ps.setString(6, "SOUND_DEFECT"); ps.setString(7, "Yamaha F310 - Buzzing 3rd fret string");
            ps.setString(8, "UNDER_REVIEW"); ps.setString(9, "Inspecting audio recording submitted by customer.");
            ps.setString(10, "2026-02-17 10:15:00"); ps.executeUpdate();
        }
    }

    private static void createMSSQLTables(Connection conn) {
        String[] mssqlDDL = {
            "IF OBJECT_ID(N'users', N'U') IS NULL CREATE TABLE users (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "full_name NVARCHAR(100) NOT NULL, " +
                "email NVARCHAR(100) NOT NULL UNIQUE, " +
                "password_hash NVARCHAR(64) NOT NULL, " +
                "phone NVARCHAR(20) NOT NULL, " +
                "role NVARCHAR(30) NOT NULL DEFAULT 'CUSTOMER', " +
                "status NVARCHAR(30) NOT NULL DEFAULT 'ACTIVE', " +
                "created_at DATETIME2 NOT NULL DEFAULT GETDATE()" +
            ")",
            "IF OBJECT_ID(N'user_addresses', N'U') IS NULL CREATE TABLE user_addresses (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "user_id INT NOT NULL, " +
                "label NVARCHAR(50) NOT NULL, " +
                "street NVARCHAR(200) NOT NULL, " +
                "city NVARCHAR(50) NOT NULL, " +
                "district NVARCHAR(50) NOT NULL, " +
                "postal_code NVARCHAR(10) NOT NULL, " +
                "is_primary BIT NOT NULL DEFAULT 0" +
            ")",
            "IF OBJECT_ID(N'products', N'U') IS NULL CREATE TABLE products (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "code NVARCHAR(30) NOT NULL UNIQUE, " +
                "name NVARCHAR(150) NOT NULL, " +
                "category NVARCHAR(50) NOT NULL, " +
                "brand NVARCHAR(50) NOT NULL, " +
                "price DECIMAL(10,2) NOT NULL, " +
                "discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0.0, " +
                "description NVARCHAR(MAX) NOT NULL, " +
                "technical_specs NVARCHAR(MAX) NOT NULL, " +
                "warranty_policy NVARCHAR(150) NOT NULL, " +
                "image_url NVARCHAR(500) NOT NULL, " +
                "stock_quantity INT NOT NULL DEFAULT 0, " +
                "display_order INT NOT NULL DEFAULT 0, " +
                "is_archived BIT NOT NULL DEFAULT 0, " +
                "created_at DATETIME2 NOT NULL DEFAULT GETDATE()" +
            ")",
            "IF OBJECT_ID(N'discount_vouchers', N'U') IS NULL CREATE TABLE discount_vouchers (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "code NVARCHAR(30) NOT NULL UNIQUE, " +
                "discount_rate DECIMAL(5,2) NOT NULL, " +
                "valid_until DATE NOT NULL, " +
                "is_active BIT NOT NULL DEFAULT 1" +
            ")",
            "IF OBJECT_ID(N'orders', N'U') IS NULL CREATE TABLE orders (" +
                "order_id NVARCHAR(30) NOT NULL PRIMARY KEY, " +
                "user_id INT NULL, " +
                "customer_name NVARCHAR(100) NOT NULL, " +
                "customer_email NVARCHAR(100) NOT NULL, " +
                "customer_phone NVARCHAR(20) NOT NULL, " +
                "shipping_address NVARCHAR(255) NOT NULL, " +
                "city NVARCHAR(50) NOT NULL, " +
                "district NVARCHAR(50) NOT NULL, " +
                "courier_name NVARCHAR(50) NOT NULL, " +
                "tracking_number NVARCHAR(50) NOT NULL, " +
                "subtotal DECIMAL(10,2) NOT NULL, " +
                "delivery_fee DECIMAL(10,2) NOT NULL, " +
                "discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0, " +
                "total_amount DECIMAL(10,2) NOT NULL, " +
                "payment_method NVARCHAR(30) NOT NULL, " +
                "payment_status NVARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                "fulfillment_status NVARCHAR(20) NOT NULL DEFAULT 'PROCESSING', " +
                "voucher_code NVARCHAR(30) DEFAULT '', " +
                "order_date DATETIME2 NOT NULL DEFAULT GETDATE()" +
            ")",
            "IF OBJECT_ID(N'order_items', N'U') IS NULL CREATE TABLE order_items (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "order_id NVARCHAR(30) NOT NULL, " +
                "product_id INT NOT NULL, " +
                "product_name NVARCHAR(150) NULL, " +
                "quantity INT NOT NULL, " +
                "unit_price DECIMAL(10,2) NOT NULL, " +
                "subtotal DECIMAL(10,2) NOT NULL" +
            ")",
            "IF OBJECT_ID(N'payments', N'U') IS NULL CREATE TABLE payments (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "transaction_id NVARCHAR(40) NOT NULL UNIQUE, " +
                "order_id NVARCHAR(30) NOT NULL, " +
                "amount DECIMAL(10,2) NOT NULL, " +
                "payment_method NVARCHAR(30) NOT NULL, " +
                "payment_status NVARCHAR(30) NOT NULL DEFAULT 'PENDING', " +
                "bank_slip_url NVARCHAR(255) DEFAULT '', " +
                "transaction_ref NVARCHAR(100) DEFAULT '', " +
                "refund_details NVARCHAR(MAX) NULL, " +
                "timestamp DATETIME2 NOT NULL DEFAULT GETDATE()" +
            ")",
            "IF OBJECT_ID(N'invoices', N'U') IS NULL CREATE TABLE invoices (" +
                "invoice_number NVARCHAR(40) NOT NULL PRIMARY KEY, " +
                "order_id NVARCHAR(30) NOT NULL, " +
                "invoice_date DATETIME2 NOT NULL DEFAULT GETDATE(), " +
                "customer_name NVARCHAR(100) NOT NULL, " +
                "billing_address NVARCHAR(255) NOT NULL, " +
                "subtotal DECIMAL(10,2) NOT NULL, " +
                "delivery_fee DECIMAL(10,2) NOT NULL, " +
                "discount DECIMAL(10,2) NOT NULL DEFAULT 0.0, " +
                "vat_amount DECIMAL(10,2) NOT NULL, " +
                "total_amount DECIMAL(10,2) NOT NULL" +
            ")",
            "IF OBJECT_ID(N'suppliers', N'U') IS NULL CREATE TABLE suppliers (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "supplier_code NVARCHAR(30) NOT NULL UNIQUE, " +
                "company_name NVARCHAR(120) NOT NULL, " +
                "contact_person NVARCHAR(80) NOT NULL, " +
                "email NVARCHAR(100) NOT NULL, " +
                "phone NVARCHAR(30) NOT NULL, " +
                "address NVARCHAR(MAX) NOT NULL, " +
                "supplied_categories NVARCHAR(200) NOT NULL, " +
                "is_active BIT NOT NULL DEFAULT 1" +
            ")",
            "IF OBJECT_ID(N'purchase_orders', N'U') IS NULL CREATE TABLE purchase_orders (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "po_number NVARCHAR(30) NOT NULL UNIQUE, " +
                "supplier_id INT NOT NULL, " +
                "supplier_name NVARCHAR(120) NOT NULL, " +
                "order_date DATE NOT NULL, " +
                "expected_delivery_date DATE NOT NULL, " +
                "items_summary NVARCHAR(MAX) NOT NULL, " +
                "total_quantity INT NOT NULL, " +
                "total_amount DECIMAL(10,2) NOT NULL, " +
                "status NVARCHAR(30) NOT NULL DEFAULT 'ISSUED'" +
            ")",
            "IF OBJECT_ID(N'fulfillments', N'U') IS NULL CREATE TABLE fulfillments (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "fulfillment_id NVARCHAR(30) NOT NULL UNIQUE, " +
                "order_id NVARCHAR(30) NOT NULL, " +
                "customer_name NVARCHAR(100) NOT NULL, " +
                "shipping_address NVARCHAR(255) NOT NULL, " +
                "courier_name NVARCHAR(50) NOT NULL, " +
                "tracking_number NVARCHAR(50) NOT NULL UNIQUE, " +
                "delivery_status NVARCHAR(30) NOT NULL DEFAULT 'PROCESSING', " +
                "cod_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0, " +
                "cod_collected BIT NOT NULL DEFAULT 0, " +
                "dispatched_at DATETIME2 NOT NULL DEFAULT GETDATE(), " +
                "delivered_at DATETIME2 NULL, " +
                "notes NVARCHAR(MAX) NULL" +
            ")",
            "IF OBJECT_ID(N'return_requests', N'U') IS NULL CREATE TABLE return_requests (" +
                "id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "ticket_id NVARCHAR(30) NOT NULL UNIQUE, " +
                "order_id NVARCHAR(30) NOT NULL, " +
                "customer_name NVARCHAR(100) NOT NULL, " +
                "customer_email NVARCHAR(100) NOT NULL, " +
                "reason NVARCHAR(50) NOT NULL, " +
                "item_details NVARCHAR(MAX) NOT NULL, " +
                "stage NVARCHAR(30) NOT NULL DEFAULT 'UNDER_REVIEW', " +
                "resolution_notes NVARCHAR(MAX) NULL, " +
                "created_at DATETIME2 NOT NULL DEFAULT GETDATE()" +
            ")"
        };
        try (Statement stmt = conn.createStatement()) {
            for (String sql : mssqlDDL) {
                try {
                    stmt.executeUpdate(sql);
                } catch (SQLException e) {
                    System.err.println("[MelodyMart DB] Error executing MSSQL DDL: " + e.getMessage());
                }
            }
        } catch (SQLException e) {
            System.err.println("[MelodyMart DB] Error creating statement for MSSQL DDL: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        System.out.println("==================================================");
        System.out.println("MelodyMart Database Diagnostics & Health Check");
        System.out.println("==================================================");
        System.out.println("Active Engine: " + getDatabaseEngineName());
        System.out.println("Is Microsoft SQL Server Connected? " + isMSSQL());
        System.out.println("Is MySQL Connected? " + isMySQL());
        try (Connection conn = getConnection();
             Statement st = conn.createStatement()) {
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM products")) {
                if (rs.next()) System.out.println("Total products in database: " + rs.getInt(1));
            }
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rs.next()) System.out.println("Total orders in database: " + rs.getInt(1));
            }
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next()) System.out.println("Total users in database: " + rs.getInt(1));
            }
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM suppliers")) {
                if (rs.next()) System.out.println("Total suppliers in database: " + rs.getInt(1));
            }
            System.out.println("Database verification successful!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
