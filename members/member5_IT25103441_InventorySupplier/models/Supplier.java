package models;

import java.io.Serializable;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 */
public class Supplier implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String supplierCode;
    private String companyName;
    private String contactPerson;
    private String email;
    private String phone;
    private String address;
    private String suppliedCategories;
    private boolean isActive;

    public Supplier() {}

    public Supplier(int id, String supplierCode, String companyName, String contactPerson,
                    String email, String phone, String address, String suppliedCategories, boolean isActive) {
        this.id = id;
        this.supplierCode = supplierCode;
        this.companyName = companyName;
        this.contactPerson = contactPerson;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.suppliedCategories = suppliedCategories;
        this.isActive = isActive;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSupplierCode() { return supplierCode; }
    public void setSupplierCode(String supplierCode) { this.supplierCode = supplierCode; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getSuppliedCategories() { return suppliedCategories; }
    public void setSuppliedCategories(String suppliedCategories) { this.suppliedCategories = suppliedCategories; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
