
package utils;
import java.sql.*;

public class AlterPayments {
    public static void main(String[] args) throws Exception {
        Connection conn = DatabaseUtil.getConnection();
        if (DatabaseUtil.isMySQL()) {
            Statement stmt = conn.createStatement();
            try {
                stmt.executeUpdate("ALTER TABLE payments MODIFY COLUMN payment_status VARCHAR(30) NOT NULL DEFAULT 'PENDING'");
                System.out.println("Modified payments.payment_status to VARCHAR(30)");
            } catch (Exception e) {
                System.out.println("Alter failed: " + e.getMessage());
            }
        }
    }
}
