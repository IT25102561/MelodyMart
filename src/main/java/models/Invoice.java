package models;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Official Tax e-Invoice with VAT breakdown
 */
public class Invoice implements Serializable {
    private static final long serialVersionUID = 1L;

    private String invoiceNumber;
    private String orderId;
    private String invoiceDate;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String billingAddress;
    private double subtotal;
    private double deliveryFee;
    private double discount;
    private double vatRate = 0.08; // 8% VAT
    private double vatAmount;
    private double totalAmount;
    private String paymentStatus;
    private String paymentMethod;
    private List<String> lineItems = new ArrayList<>();

    public Invoice() {}

    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(String invoiceDate) { this.invoiceDate = invoiceDate; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public String getBillingAddress() { return billingAddress; }
    public void setBillingAddress(String billingAddress) { this.billingAddress = billingAddress; }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public double getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(double deliveryFee) { this.deliveryFee = deliveryFee; }

    public double getDiscount() { return discount; }
    public void setDiscount(double discount) { this.discount = discount; }

    public double getVatRate() { return vatRate; }
    public void setVatRate(double vatRate) { this.vatRate = vatRate; }

    public double getVatAmount() { return vatAmount; }
    public void setVatAmount(double vatAmount) { this.vatAmount = vatAmount; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public List<String> getLineItems() { return lineItems; }
    public void setLineItems(List<String> lineItems) { this.lineItems = lineItems; }
}
