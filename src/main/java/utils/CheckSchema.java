
package utils;
import java.sql.*;

public class CheckSchema {
    public static void main(String[] args) throws Exception {
        Connection conn = DatabaseUtil.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM payments LIKE 'payment_status'");
        if (rs.next()) {
            System.out.println("Type: " + rs.getString("Type"));
        }
    }
}
