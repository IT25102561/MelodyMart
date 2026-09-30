package models;

import java.io.Serializable;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Purchase Order Requisition for Inventory Restocking
 */
public class PurchaseOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String poNumber;
    private int supplierId;
    private String supplierName;
    private String orderDate;
    private String expectedDeliveryDate;
    private String itemsSummary;
    private int totalQuantity;
    private double totalAmount;
    private String status; // DRAFT, ISSUED, RECEIVED, CANCELLED

    public PurchaseOrder() {}

    public PurchaseOrder(int id, String poNumber, int supplierId, String supplierName,
                         String orderDate, String expectedDeliveryDate, String itemsSummary,
                         int totalQuantity, double totalAmount, String status) {
        this.id = id;
        this.poNumber = poNumber;
        this.supplierId = supplierId;
        this.supplierName = supplierName;
        this.orderDate = orderDate;
        this.expectedDeliveryDate = expectedDeliveryDate;
        this.itemsSummary = itemsSummary;
        this.totalQuantity = totalQuantity;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPoNumber() { return poNumber; }
    public void setPoNumber(String poNumber) { this.poNumber = poNumber; }

    public int getSupplierId() { return supplierId; }
    public void setSupplierId(int supplierId) { this.supplierId = supplierId; }

    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }

    public String getOrderDate() { return orderDate; }
    public void setOrderDate(String orderDate) { this.orderDate = orderDate; }

    public String getExpectedDeliveryDate() { return expectedDeliveryDate; }
    public void setExpectedDeliveryDate(String expectedDeliveryDate) { this.expectedDeliveryDate = expectedDeliveryDate; }

    public String getItemsSummary() { return itemsSummary; }
    public void setItemsSummary(String itemsSummary) { this.itemsSummary = itemsSummary; }

    public int getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(int totalQuantity) { this.totalQuantity = totalQuantity; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
