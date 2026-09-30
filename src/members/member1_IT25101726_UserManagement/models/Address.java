package models;

import java.io.Serializable;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Delivery, billing, and contact address entity
 */
public class Address implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String label; // Home, Office, Studio
    private String street;
    private String city;
    private String district; // Colombo, Kandy, Gampaha, Galle, etc.
    private String postalCode;
    private boolean isPrimary;

    public Address() {}

    public Address(int id, int userId, String label, String street, String city, String district, String postalCode, boolean isPrimary) {
        this.id = id;
        this.userId = userId;
        this.label = label;
        this.street = street;
        this.city = city;
        this.district = district;
        this.postalCode = postalCode;
        this.isPrimary = isPrimary;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public boolean isPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    public String getFullAddress() {
        return street + ", " + city + ", " + district + " (" + postalCode + ")";
    }
}
