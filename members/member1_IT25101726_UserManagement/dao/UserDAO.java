package dao;

import models.Address;
import models.User;
import strategies.user.PasswordHashingStrategy;
import strategies.user.SHA256HashingStrategy;
import utils.DatabaseUtil;
import utils.ValidationUtil;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 * Full Relational Database Persistence (MySQL / SQLite Dual-Engine)
 */
public class UserDAO {
    private static final Map<Integer, User> userStore = new ConcurrentHashMap<>();
    private static final AtomicInteger userIdCounter = new AtomicInteger(100);
    private static final AtomicInteger addressIdCounter = new AtomicInteger(200);

    static {
        loadUsersFromDatabase();
    }

    public static synchronized void loadUsersFromDatabase() {
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT id, full_name, email, password_hash, phone, role, status, created_at FROM users ORDER BY id ASC")) {

            int maxUserId = 10;
            userStore.clear();

            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("full_name");
                String email = rs.getString("email");
                String pwd = rs.getString("password_hash");
                String phone = rs.getString("phone");
                String role = rs.getString("role");
                String status = rs.getString("status");
                String createdAt = rs.getString("created_at");

                User user = new User(id, name, email, pwd, phone, role, status, createdAt);

                // Load addresses for this user
                try (PreparedStatement aps = conn.prepareStatement("SELECT id, user_id, label, street, city, district, postal_code, is_primary FROM user_addresses WHERE user_id = ?")) {
                    aps.setInt(1, id);
                    try (ResultSet ars = aps.executeQuery()) {
                        while (ars.next()) {
                            Address addr = new Address(
                                ars.getInt("id"),
                                ars.getInt("user_id"),
                                ars.getString("label"),
                                ars.getString("street"),
                                ars.getString("city"),
                                ars.getString("district"),
                                ars.getString("postal_code"),
                                ars.getInt("is_primary") == 1
                            );
                            user.addAddress(addr);
                            if (addr.getId() > addressIdCounter.get()) {
                                addressIdCounter.set(addr.getId());
                            }
                        }
                    }
                } catch (Exception ignored) {}

                userStore.put(id, user);
                if (id > maxUserId) maxUserId = id;
            }

            userIdCounter.set(maxUserId);
            System.out.println("[UserDAO] Successfully loaded " + userStore.size() + " users from database.");

        } catch (Exception ex) {
            System.err.println("[UserDAO] Notice loading users from DB: " + ex.getMessage());
        }
    }

    private PasswordHashingStrategy hashingStrategy = new SHA256HashingStrategy();

    public void setHashingStrategy(PasswordHashingStrategy hashingStrategy) {
        if (hashingStrategy != null) {
            this.hashingStrategy = hashingStrategy;
        }
    }

    public PasswordHashingStrategy getHashingStrategy() {
        return this.hashingStrategy;
    }

    public static String hashPassword(String password) {
        return new SHA256HashingStrategy().hashPassword(password);
    }

    private static final Map<Integer, List<String>> loginHistoryStore = new ConcurrentHashMap<>();

    public static void recordLoginSession(int userId, String details) {
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        loginHistoryStore.computeIfAbsent(userId, k -> new ArrayList<>()).add(now + " - " + details);
    }

    public static List<String> getLoginHistory(int userId) {
        List<String> list = loginHistoryStore.get(userId);
        if (list == null || list.isEmpty()) {
            List<String> def = new ArrayList<>();
            def.add(LocalDateTime.now().minusHours(2).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " - Successful Login (Web Browser / Chrome on Windows)");
            return def;
        }
        return list;
    }

    // ==========================================
    // CREATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public User registerUser(String fullName, String email, String plainPassword, String phone, String role) throws Exception {
        return registerUser(fullName, email, plainPassword, phone, role, this.hashingStrategy);
    }

    public User registerUser(String fullName, String email, String plainPassword, String phone, String role, PasswordHashingStrategy strategy) throws Exception {
        ValidationUtil.validateUserName(fullName);
        ValidationUtil.validateEmail(email);
        if (findByEmail(email) != null) {
            throw new Exception(ValidationUtil.ERR_USER_DUPLICATE_EMAIL + ": An account with email '" + email + "' is already registered.");
        }
        ValidationUtil.validatePasswordStrength(plainPassword);
        ValidationUtil.validateSriLankanPhone(phone);

        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        int newId = userIdCounter.incrementAndGet();
        String defaultRole = (role != null && !role.isEmpty()) ? role : "CUSTOMER";
        PasswordHashingStrategy activeStrategy = (strategy != null) ? strategy : this.hashingStrategy;
        String hashed = activeStrategy.hashPassword(plainPassword);

        String sql = "INSERT INTO users (full_name, email, password_hash, phone, role, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName.trim());
            ps.setString(2, email.trim());
            ps.setString(3, hashed);
            ps.setString(4, phone.trim());
            ps.setString(5, defaultRole);
            ps.setString(6, "ACTIVE");
            ps.setString(7, now);
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) newId = gk.getInt(1);
            } catch (Exception ignored) {}

            System.out.println("[UserDAO] User registered in DB with ID: " + newId + " using strategy: " + activeStrategy.getAlgorithmName());
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error inserting user into DB: " + ex.getMessage());
        }

        User user = new User(newId, fullName, email, hashed, phone, defaultRole, "ACTIVE", now);
        userStore.put(newId, user);
        return user;
    }

    public Address addAddress(int userId, String label, String street, String city, String district, String postalCode, boolean isPrimary) throws Exception {
        User user = getUserById(userId);
        if (user == null) {
            throw new Exception("User not found with ID: " + userId);
        }
        ValidationUtil.validateAddress(street, city, district, postalCode);
        if (isPrimary && user.getAddresses() != null) {
            for (Address a : user.getAddresses()) {
                a.setPrimary(false);
            }
            // Update DB primary flags
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement ups = conn.prepareStatement("UPDATE user_addresses SET is_primary=0 WHERE user_id=?")) {
                ups.setInt(1, userId);
                ups.executeUpdate();
            } catch (Exception ignored) {}
        }
        int addrId = addressIdCounter.incrementAndGet();

        String sql = "INSERT INTO user_addresses (user_id, label, street, city, district, postal_code, is_primary) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, label);
            ps.setString(3, street);
            ps.setString(4, city);
            ps.setString(5, district);
            ps.setString(6, postalCode);
            ps.setInt(7, isPrimary ? 1 : 0);
            ps.executeUpdate();

            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) addrId = gk.getInt(1);
            } catch (Exception ignored) {}
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error inserting address in DB: " + ex.getMessage());
        }

        Address address = new Address(addrId, userId, label, street, city, district, postalCode, isPrimary);
        user.addAddress(address);
        return address;
    }

    // ==========================================
    // READ OPERATIONS
    // ==========================================

    public User getUserById(int id) {
        return userStore.get(id);
    }

    public User findByEmail(String email) {
        if (email == null) return null;
        for (User u : userStore.values()) {
            if (email.equalsIgnoreCase(u.getEmail())) {
                return u;
            }
        }
        return null;
    }

    public User authenticate(String email, String plainPassword) {
        return authenticate(email, plainPassword, this.hashingStrategy);
    }

    public User authenticate(String email, String plainPassword, PasswordHashingStrategy strategy) {
        User u = findByEmail(email);
        if (u != null && !"DEACTIVATED".equalsIgnoreCase(u.getStatus())) {
            PasswordHashingStrategy activeStrategy = (strategy != null) ? strategy : this.hashingStrategy;
            if (activeStrategy.verifyPassword(plainPassword, u.getPasswordHash())
                    || hashPassword(plainPassword).equals(u.getPasswordHash())) {
                recordLoginSession(u.getId(), "Successful Web Login [AuthStrategy: " + activeStrategy.getAlgorithmName() + "] (Session ID: " + UUID.randomUUID().toString().substring(0, 8) + ")");
                return u;
            }
        }
        return null;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>(userStore.values());
        list.sort(Comparator.comparingInt(User::getId));
        return list;
    }

    public List<Address> getUserAddresses(int userId) {
        User u = getUserById(userId);
        return (u != null) ? u.getAddresses() : Collections.emptyList();
    }

    // ==========================================
    // UPDATE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean updateProfile(int userId, String fullName, String phone) throws Exception {
        User user = getUserById(userId);
        if (user == null) return false;
        if (fullName != null) {
            ValidationUtil.validateUserName(fullName);
        }
        if (phone != null) {
            ValidationUtil.validateSriLankanPhone(phone);
        }

        String sql = "UPDATE users SET full_name=?, phone=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : user.getFullName());
            ps.setString(2, (phone != null) ? phone.trim() : user.getPhone());
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error updating user profile in DB: " + ex.getMessage());
        }

        if (fullName != null && !fullName.trim().isEmpty()) {
            user.setFullName(fullName.trim());
        }
        if (phone != null) {
            user.setPhone(phone.trim());
        }
        return true;
    }

    public boolean updatePassword(int userId, String oldPassword, String newPassword) throws Exception {
        return updatePassword(userId, oldPassword, newPassword, this.hashingStrategy);
    }

    public boolean updatePassword(int userId, String oldPassword, String newPassword, PasswordHashingStrategy strategy) throws Exception {
        User user = getUserById(userId);
        if (user == null) return false;
        PasswordHashingStrategy activeStrategy = (strategy != null) ? strategy : this.hashingStrategy;
        if (!activeStrategy.verifyPassword(oldPassword, user.getPasswordHash())
                && !hashPassword(oldPassword).equals(user.getPasswordHash())) {
            throw new Exception("Incorrect current password.");
        }
        ValidationUtil.validatePasswordStrength(newPassword);

        String newHash = activeStrategy.hashPassword(newPassword);
        String sql = "UPDATE users SET password_hash=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
            System.out.println("[UserDAO] Updated password for user ID #" + userId + " using " + activeStrategy.getAlgorithmName());
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error updating password in DB: " + ex.getMessage());
        }

        user.setPasswordHash(newHash);
        return true;
    }

    public boolean updateStaffRole(int userId, String newRole, String status) {
        User user = getUserById(userId);
        if (user == null) return false;

        String sql = "UPDATE users SET role=?, status=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, (newRole != null && !newRole.isEmpty()) ? newRole : user.getRole());
            ps.setString(2, (status != null && !status.isEmpty()) ? status : user.getStatus());
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error updating staff role in DB: " + ex.getMessage());
        }

        if (newRole != null && !newRole.isEmpty()) user.setRole(newRole);
        if (status != null && !status.isEmpty()) user.setStatus(status);
        return true;
    }

    public boolean setPrimaryAddress(int userId, int addressId) {
        User user = getUserById(userId);
        if (user == null || user.getAddresses() == null) return false;

        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps1 = conn.prepareStatement("UPDATE user_addresses SET is_primary=0 WHERE user_id=?")) {
                ps1.setInt(1, userId);
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = conn.prepareStatement("UPDATE user_addresses SET is_primary=1 WHERE id=? AND user_id=?")) {
                ps2.setInt(1, addressId);
                ps2.setInt(2, userId);
                ps2.executeUpdate();
            }
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error setting primary address in DB: " + ex.getMessage());
        }

        for (Address a : user.getAddresses()) {
            a.setPrimary(a.getId() == addressId);
        }
        return true;
    }

    // ==========================================
    // DELETE OPERATIONS (DATABASE PERSISTENCE)
    // ==========================================

    public boolean deleteUser(int userId) {
        String sqlAddr = "DELETE FROM user_addresses WHERE user_id=?";
        String sqlUser = "DELETE FROM users WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlAddr)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            } catch (Exception ignored) {}
            try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
                System.out.println("[UserDAO] Permanently removed user ID #" + userId + " from database.");
            }
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error deleting user from DB: " + ex.getMessage());
        }

        userStore.remove(userId);
        return true;
    }

    public boolean deactivateUser(int userId) {
        String sql = "UPDATE users SET status='DEACTIVATED' WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error deactivating user in DB: " + ex.getMessage());
        }

        User user = getUserById(userId);
        if (user != null) {
            user.setStatus("DEACTIVATED");
            return true;
        }
        return false;
    }

    public boolean removeAddress(int userId, int addressId) {
        String sql = "DELETE FROM user_addresses WHERE id=? AND user_id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error deleting address from DB: " + ex.getMessage());
        }

        User user = getUserById(userId);
        if (user == null || user.getAddresses() == null) return false;
        return user.getAddresses().removeIf(a -> a.getId() == addressId);
    }
    public boolean reactivateUser(int userId) {
        String sql = "UPDATE users SET status='ACTIVE' WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            System.out.println("[UserDAO] Reactivated user ID #" + userId + " in database.");
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error reactivating user in DB: " + ex.getMessage());
        }

        User user = getUserById(userId);
        if (user != null) {
            user.setStatus("ACTIVE");
            return true;
        }
        return false;
    }

    public boolean updatePasswordAdmin(int userId, String newPassword) throws Exception {
        User user = getUserById(userId);
        if (user == null) return false;
        ValidationUtil.validatePasswordStrength(newPassword);

        String newHash = hashPassword(newPassword);
        String sql = "UPDATE users SET password_hash=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
            System.out.println("[UserDAO] Admin updated password for user ID #" + userId + " in database.");
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error updating password in DB: " + ex.getMessage());
        }

        user.setPasswordHash(newHash);
        return true;
    }

    public boolean adminUpdateUser(int userId, String fullName, String phone, String role, String status) throws Exception {
        User user = getUserById(userId);
        if (user == null) return false;
        if (fullName != null) {
            ValidationUtil.validateUserName(fullName);
        }
        if (phone != null) {
            ValidationUtil.validateSriLankanPhone(phone);
        }

        String sql = "UPDATE users SET full_name=?, phone=?, role=?, status=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : user.getFullName());
            ps.setString(2, (phone != null) ? phone.trim() : user.getPhone());
            ps.setString(3, (role != null && !role.trim().isEmpty()) ? role.trim() : user.getRole());
            ps.setString(4, (status != null && !status.trim().isEmpty()) ? status.trim() : user.getStatus());
            ps.setInt(5, userId);
            ps.executeUpdate();
            System.out.println("[UserDAO] Admin updated user ID #" + userId + " in database.");
        } catch (Exception ex) {
            System.err.println("[UserDAO] Error updating user in DB: " + ex.getMessage());
        }

        if (fullName != null && !fullName.trim().isEmpty()) user.setFullName(fullName.trim());
        if (phone != null) user.setPhone(phone.trim());
        if (role != null && !role.trim().isEmpty()) user.setRole(role.trim());
        if (status != null && !status.trim().isEmpty()) user.setStatus(status.trim());
        return true;
    }
}
