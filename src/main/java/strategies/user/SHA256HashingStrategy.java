package strategies.user;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Standard SHA-256 cryptographic hashing algorithm.
 * This is the default hashing strategy for MelodyMart user accounts.
 */
public class SHA256HashingStrategy implements PasswordHashingStrategy {

    @Override
    public String hashPassword(String plainPassword) {
        if (plainPassword == null) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
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
            return Integer.toHexString(plainPassword.hashCode());
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
        return "SHA-256";
    }
}
