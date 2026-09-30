/**
 * MelodyMart - Main JavaScript Client Helper
 * SLIIT SE2030 Group MLB-B6G1-08
 * Real-time client-side input validations & formatters for all 6 members
 */

document.addEventListener("DOMContentLoaded", function () {
    // 1. District change dynamic delivery fee preview
    const districtSelect = document.getElementById("districtSelect");
    const deliveryFeeDisplay = document.getElementById("deliveryFeeDisplay");
    const grandTotalDisplay = document.getElementById("grandTotalDisplay");

    if (districtSelect && deliveryFeeDisplay) {
        districtSelect.addEventListener("change", function () {
            const district = this.value;
            let fee = 500;
            if (["Kandy", "Galle", "Matara", "Kurunegala"].includes(district)) {
                fee = 750;
            } else if (["Jaffna", "Batticaloa", "Anuradhapura", "Badulla"].includes(district)) {
                fee = 950;
            }
            deliveryFeeDisplay.innerText = "LKR " + fee.toLocaleString() + ".00";

            // Update grand total if base subtotal is present
            const subtotalInput = document.getElementById("cartSubtotalHidden");
            const discountInput = document.getElementById("cartDiscountHidden");
            if (subtotalInput && grandTotalDisplay) {
                const sub = parseFloat(subtotalInput.value) || 0;
                const disc = parseFloat(discountInput ? discountInput.value : 0) || 0;
                const total = Math.max(0, sub - disc + fee);
                grandTotalDisplay.innerText = "LKR " + total.toLocaleString() + ".00";
            }
        });
    }

    // 2. Member 3: Auto-uppercase & sanitize voucher input
    const voucherInput = document.getElementById("voucherCodeInput");
    if (voucherInput) {
        voucherInput.addEventListener("input", function () {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9_-]/g, "");
        });
    }

    // 3. Member 4: Payment method toggle (Credit Card vs Bank Transfer vs COD)
    const paymentRadios = document.querySelectorAll('input[name="paymentMethod"]');
    const cardDetailsBox = document.getElementById("cardDetailsBox");
    const bankDetailsBox = document.getElementById("bankDetailsBox");

    function updatePaymentBoxes() {
        const checked = document.querySelector('input[name="paymentMethod"]:checked');
        if (!checked) return;
        if (cardDetailsBox) {
            cardDetailsBox.style.display = (checked.value === "CREDIT_CARD") ? "block" : "none";
        }
        if (bankDetailsBox) {
            bankDetailsBox.style.display = (checked.value === "BANK_TRANSFER") ? "block" : "none";
        }
    }

    if (paymentRadios.length > 0) {
        paymentRadios.forEach(radio => {
            radio.addEventListener("change", updatePaymentBoxes);
        });
        updatePaymentBoxes();
    }

    // 4. Member 4: Credit Card Number auto-formatter (XXXX XXXX XXXX XXXX)
    const cardNumberInput = document.getElementById("cardNumberInput");
    if (cardNumberInput) {
        cardNumberInput.addEventListener("input", function (e) {
            let val = this.value.replace(/\D/g, "");
            if (val.length > 16) val = val.substring(0, 16);
            let formatted = val.match(/.{1,4}/g);
            this.value = formatted ? formatted.join(" ") : "";
        });
    }

    // 5. Member 4: Card Expiry auto-formatter (MM/YY)
    const cardExpiryInput = document.getElementById("cardExpiryInput");
    if (cardExpiryInput) {
        cardExpiryInput.addEventListener("input", function (e) {
            let val = this.value.replace(/\D/g, "");
            if (val.length > 4) val = val.substring(0, 4);
            if (val.length >= 3) {
                this.value = val.substring(0, 2) + "/" + val.substring(2);
            } else {
                this.value = val;
            }
        });
    }

    // 6. Member 4: CVV numeric restrictor (3-4 digits)
    const cardCvvInput = document.getElementById("cardCvvInput");
    if (cardCvvInput) {
        cardCvvInput.addEventListener("input", function () {
            this.value = this.value.replace(/\D/g, "").substring(0, 4);
        });
    }

    // 7. Member 1: Postal code numeric restrictor (5 digits)
    document.querySelectorAll('input[name="postalCode"]').forEach(input => {
        input.addEventListener("input", function () {
            this.value = this.value.replace(/\D/g, "").substring(0, 5);
        });
    });

    // 8. Member 1: Sri Lankan mobile phone numeric/plus restrictor
    document.querySelectorAll('input[name="phone"], input[name="customerPhone"]').forEach(input => {
        input.addEventListener("input", function () {
            let val = this.value;
            let startsWithPlus = val.startsWith("+");
            let digits = val.replace(/\D/g, "");
            if (startsWithPlus) {
                this.value = "+" + digits.substring(0, 11);
            } else {
                this.value = digits.substring(0, 10);
            }
        });
    });

    // 9. Member 2: Product price & discount positive number restrictor
    document.querySelectorAll('input[name="discountPercent"]').forEach(input => {
        input.addEventListener("input", function () {
            let val = parseFloat(this.value);
            if (val < 0) this.value = 0;
            if (val > 100) this.value = 100;
        });
    });

    // 10. Member 6: Tracking Number auto-formatter (uppercase alphanumeric and dashes)
    document.querySelectorAll('input[name="trackingNumber"]').forEach(input => {
        input.addEventListener("input", function () {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, "");
        });
    });

    // 11. Member 2: Product warranty numeric restrictor (years: 0 to 25, numbers only)
    document.querySelectorAll('input[name="warrantyPolicy"]').forEach(input => {
        input.addEventListener("input", function () {
            this.value = this.value.replace(/\D/g, "");
            if (this.value !== "") {
                let val = parseInt(this.value, 10);
                if (val > 25) this.value = 25;
            }
        });
    });
});

function confirmAction(message) {
    return confirm(message || "Are you sure you want to perform this action?");
}