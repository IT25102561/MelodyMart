package models;

import java.io.Serializable;

/**
 * Member 2: IT25102561 - Senarathna U. G. S. P.
 * Module 6.2: Product Catalog & Advanced Search/Filtering
 */
public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private String name;
    private String category; // String Instruments, Keyboards, Drums & Percussion, Wind Instruments, Traditional Sri Lankan
    private String brand; // Yamaha, Roland, Pearl, Fender, Hewisi Craft, Ruhunu Kala, Ibanez, Stentor, Lanka Laya
    private double price; // in LKR
    private double discountPercent; // e.g., 5.0 for 5% off
    private String description;
    private String technicalSpecs;
    private String warrantyPolicy;
    private String imageUrl;
    private int stockQuantity;
    private int displayOrder;
    private boolean isArchived; // soft-delete

    public Product() {}

    public Product(int id, String code, String name, String category, String brand, double price,
                   double discountPercent, String description, String technicalSpecs,
                   String warrantyPolicy, String imageUrl, int stockQuantity, int displayOrder, boolean isArchived) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.category = category;
        this.brand = brand;
        this.price = price;
        this.discountPercent = discountPercent;
        this.description = description;
        this.technicalSpecs = technicalSpecs;
        this.warrantyPolicy = warrantyPolicy;
        this.imageUrl = imageUrl;
        this.stockQuantity = stockQuantity;
        this.displayOrder = displayOrder;
        this.isArchived = isArchived;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public double getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(double discountPercent) { this.discountPercent = discountPercent; }

    public double getEffectivePrice() {
        if (discountPercent > 0) {
            return price * (1.0 - (discountPercent / 100.0));
        }
        return price;
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTechnicalSpecs() { return technicalSpecs; }
    public void setTechnicalSpecs(String technicalSpecs) { this.technicalSpecs = technicalSpecs; }

    public String getWarrantyPolicy() { return warrantyPolicy; }
    public void setWarrantyPolicy(String warrantyPolicy) { this.warrantyPolicy = warrantyPolicy; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public boolean isArchived() { return isArchived; }
    public void setArchived(boolean archived) { isArchived = archived; }
}
