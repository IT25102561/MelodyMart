package strategies.user;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 *
 * Strategy Design Pattern - Context Class:
 * Maintains a reference to a PasswordHashingStrategy object and delegates
 * hashing and password verification operations to the active strategy.
 */
public class PasswordHashingContext {
    private PasswordHashingStrategy strategy;

    public PasswordHashingContext() {
        // Default strategy is standard SHA-256
        this.strategy = new SHA256HashingStrategy();
    }

    public PasswordHashingContext(PasswordHashingStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new SHA256HashingStrategy();
    }

    public void setStrategy(PasswordHashingStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public PasswordHashingStrategy getStrategy() {
        return this.strategy;
    }

    public String hash(String plainPassword) {
        return this.strategy.hashPassword(plainPassword);
    }

    public boolean verify(String plainPassword, String hashedPassword) {
        return this.strategy.verifyPassword(plainPassword, hashedPassword);
    }
}
