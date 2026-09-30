package strategies.user;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 *
 * Strategy Design Pattern - Strategy Interface:
 * Defines a pluggable cryptographic hashing algorithm for secure credential storage
 * and verification within the MelodyMart authentication pipeline.
 */
public interface PasswordHashingStrategy {

    /**
     * Hashes the plain-text password using the underlying cryptographic algorithm.
     *
     * @param plainPassword Raw password entered by user.
     * @return Hexadecimal encoded hash string.
     */
    String hashPassword(String plainPassword);

    /**
     * Verifies whether a given plain-text password matches a previously hashed digest.
     *
     * @param plainPassword Raw password entered during login/verification.
     * @param hashedPassword Stored password hash from database/storage.
     * @return true if the passwords match; false otherwise.
     */
    boolean verifyPassword(String plainPassword, String hashedPassword);

    /**
     * Returns the human-readable identifier of the hashing algorithm.
     *
     * @return Algorithm name (e.g., "SHA-256", "MD5", "Salted-SHA-512").
     */
    String getAlgorithmName();
}
