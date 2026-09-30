package strategies.user;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * High-Security Salted SHA-512 cryptographic hashing strategy.
 * Enhances entropy by appending an application-specific cryptographic salt,
 * ideal for administrative and privileged user roles.
 */
public class SaltedSHA512HashingStrategy implements PasswordHashingStrategy {

    // Internal salt component for MelodyMart system hardening
    private static final String SYSTEM_SALT = "MelodyMart_SLIIT_Sec2026_SaltKey$";

    @Override
    public String hashPassword(String plainPassword) {
        if (plainPassword == null) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            String saltedInput = SYSTEM_SALT + plainPassword + SYSTEM_SALT;
            byte[] hash = digest.digest(saltedInput.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            return Integer.toHexString((plainPassword + SYSTEM_SALT).hashCode());
        }
    }

    @Override
    public boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        String calculated = hashPassword(plainPassword);
        return calculated.equalsIgnoreCase(hashedPassword);
    }

    @Override
    public String getAlgorithmName() {
        return "Salted SHA-512";
    }
}
