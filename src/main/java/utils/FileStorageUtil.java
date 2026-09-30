package utils;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MelodyMart - File Storage Utility
 * Manages text file persistence for orders (orders.txt), users, products, suppliers, etc.
 */
public class FileStorageUtil {

    private static String baseStoragePath = "";

    public static void setBaseStoragePath(String path) {
        baseStoragePath = path;
    }

    public static String getBaseStoragePath() {
        if (baseStoragePath == null || baseStoragePath.trim().isEmpty()) {
            // Default to working directory or user's project folder
            return System.getProperty("user.dir");
        }
        return baseStoragePath;
    }

    /**
     * Appends an order entry to orders.txt
     */
    public static synchronized void appendOrder(String orderRecord) {
        String[] targets = {
            Paths.get(getBaseStoragePath(), "orders.txt").toString(),
            Paths.get(getBaseStoragePath(), "WEB-INF", "data", "orders.txt").toString(),
            "orders.txt"
        };

        for (String targetPath : targets) {
            try {
                File file = new File(targetPath);
                if (file.getParentFile() != null && !file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, true), StandardCharsets.UTF_8))) {
                    writer.write(orderRecord);
                    writer.newLine();
                    writer.write("--------------------------------------------------------------------------------");
                    writer.newLine();
                }
            } catch (Exception ignored) {
            }
        }
    }

    /**
     * Reads all lines from a given text file
     */
    public static List<String> readLines(String fileName) {
        List<String> lines = new ArrayList<>();
        File file = new File(fileName);
        if (!file.exists()) {
            file = new File(getBaseStoragePath(), fileName);
        }
        if (!file.exists()) {
            return lines;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        } catch (IOException e) {
            System.err.println("Error reading " + fileName + ": " + e.getMessage());
        }
        return lines;
    }

    /**
     * Writes lines to a given text file
     */
    public static synchronized void writeLines(String fileName, List<String> lines) {
        File file = new File(fileName);
        if (file.getParentFile() != null && !file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }
        try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            System.err.println("Error writing to " + fileName + ": " + e.getMessage());
        }
    }
}
