package strategies.user;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 *
 * Factory utility to instantiate PasswordHashingStrategy implementations
 * based on configuration, request parameters, or security policies.
 */
public class PasswordHashingFactory {

    /**
     * Resolves and returns the corresponding PasswordHashingStrategy.
     *
     * @param strategyKey Strategy identifier (e.g. "sha256", "md5", "sha512", "salted").
     * @return Concrete PasswordHashingStrategy, defaulting to SHA256HashingStrategy.
     */
    public static PasswordHashingStrategy getStrategy(String strategyKey) {
        if (strategyKey == null || strategyKey.trim().isEmpty()) {
            return new SHA256HashingStrategy();
        }
        String key = strategyKey.trim().toLowerCase();
        switch (key) {
            case "md5":
            case "legacy":
                return new MD5HashingStrategy();
            case "sha512":
            case "salted":
            case "high_security":
                return new SaltedSHA512HashingStrategy();
            case "sha256":
            default:
                return new SHA256HashingStrategy();
        }
    }
}
