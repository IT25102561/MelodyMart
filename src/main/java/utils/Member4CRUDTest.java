package utils;

import dao.PaymentDAO;
import models.Invoice;
import models.Payment;
import utils.DatabaseUtil;

import java.util.List;

/**
 * Member 4 Automated CRUD Verification Test
 * IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 */
public class Member4CRUDTest {
    public static void main(String[] args) {
        System.out.println("================================================================================");
        System.out.println("Member 4 (IT25101556) Payment Gateway & Invoice System Automated CRUD Test");
        System.out.println("================================================================================");

        try {
            PaymentDAO dao = new PaymentDAO();

            // 1. [CREATE]
            System.out.println("\n[TEST 1: CREATE] Initiating Transaction across Payment Channels & Generating E-Invoice...");
            Payment cardPayment = dao.initiateTransaction(
                "ORD-2026-M4-001", "Kamal Perera", "kamal@test.lk", "0771234567",
                "No. 12, Flower Road, Colombo 07", 54000.00, "CREDIT_CARD",
                "", "AUTH-VISA-992144", true
            );
            System.out.println("  -> Created Card Payment: " + cardPayment.getTransactionId() + " | Status: " + cardPayment.getPaymentStatus());
            assert "PAID".equals(cardPayment.getPaymentStatus()) : "Card payment should be auto-paid!";

            Payment bankPayment = dao.initiateTransaction(
                "ORD-2026-M4-002", "Sunil Silva", "sunil@test.lk", "0719876543",
                "No. 45, Kandy Road, Kiribathgoda", 42000.00, "BANK_TRANSFER",
                "SLIP-BOC-2026-9812.jpg", "REF-BOC-7712", true
            );
            System.out.println("  -> Created Bank Slip Payment: " + bankPayment.getTransactionId() + " | Status: " + bankPayment.getPaymentStatus() + " | Slip: " + bankPayment.getBankSlipUrl());
            assert "PENDING".equals(bankPayment.getPaymentStatus()) : "Bank transfer payment should be pending slip review!";

            // Verify Auto-generated E-Invoices
            Invoice inv1 = dao.getInvoiceByOrderId("ORD-2026-M4-001");
            assert inv1 != null : "Invoice should be auto-generated!";
            System.out.println("  -> [DB VERIFIED] E-Invoice Auto-Generated: " + inv1.getInvoiceNumber() +
                " | Subtotal: LKR " + inv1.getSubtotal() + " | 8% VAT: LKR " + inv1.getVatAmount() + " | Total: LKR " + inv1.getTotalAmount());
            assert inv1.getVatAmount() > 0 : "VAT breakdown must be calculated!";

            // 2. [READ]
            System.out.println("\n[TEST 2: READ] Tracking Real-Time States, Tax Invoices & Customer Histories...");
            List<Payment> all = dao.getAllPayments();
            System.out.println("  -> Total payments in store: " + all.size());
            assert all.size() >= 2 : "Should have at least 2 payments!";

            List<Payment> pending = dao.getPaymentsByStatus("PENDING");
            System.out.println("  -> Pending verification count: " + pending.size());

            List<Invoice> invoices = dao.getAllInvoices();
            System.out.println("  -> Total tax e-invoices: " + invoices.size());
            assert invoices.size() >= 2 : "Should have at least 2 invoices!";

            List<Payment> history = dao.getCustomerTransactionHistory("Kamal");
            System.out.println("  -> Customer history search count: " + history.size());

            // 3. [UPDATE]
            System.out.println("\n[TEST 3: UPDATE] Updating Transaction Status & Processing Refund Details...");
            // Update bank payment status following manual review
            boolean updated = dao.updatePaymentStatus(bankPayment.getTransactionId(), "PAID", "Verified BOC branch deposit slip #9812");
            Payment bankAfter = dao.getPaymentByTxnId(bankPayment.getTransactionId());
            System.out.println("  -> [DB VERIFIED] Bank Payment Status Updated: " + bankAfter.getPaymentStatus() + " | Ref: " + bankAfter.getTransactionRef());
            assert "PAID".equals(bankAfter.getPaymentStatus()) : "Bank payment should now be PAID!";

            // Process refund
            boolean refunded = dao.recordRefund(cardPayment.getTransactionId(), 54000.00, "Customer returned violin under warranty", "REV-VISA-5501");
            Payment cardAfter = dao.getPaymentByTxnId(cardPayment.getTransactionId());
            System.out.println("  -> [DB VERIFIED] Refund Processed: " + cardAfter.getPaymentStatus() + " | Details: " + cardAfter.getRefundDetails());
            assert "REFUNDED".equals(cardAfter.getPaymentStatus()) : "Payment should now be REFUNDED!";

            // 4. [DELETE]
            System.out.println("\n[TEST 4: DELETE] Voiding Failed Attempts, Archiving Records & Cancelling Draft Invoices...");
            // Create a failed/unverified attempt to void
            Payment unverified = dao.initiateTransaction(
                "ORD-2026-M4-003", "Test User", "test@test.lk", "0700000000",
                "Test Address", 15000.00, "BANK_TRANSFER", "TEMP-SLIP-INVALID", "UNVERIFIED", true
            );
            boolean voided = dao.voidPayment(unverified.getTransactionId(), "Unverified bank slip timeout");
            Payment voidedPay = dao.getPaymentByTxnId(unverified.getTransactionId());
            System.out.println("  -> [DB VERIFIED] Payment Voided: " + voidedPay.getPaymentStatus() + " | Details: " + voidedPay.getRefundDetails());
            assert "VOIDED".equals(voidedPay.getPaymentStatus()) : "Payment should be VOIDED!";

            // Archive billing record
            boolean archived = dao.archivePayment(unverified.getTransactionId());
            Payment archPay = dao.getPaymentByTxnId(unverified.getTransactionId());
            System.out.println("  -> [DB VERIFIED] Record Archived: " + archPay.getPaymentStatus());
            assert "ARCHIVED".equals(archPay.getPaymentStatus()) : "Payment should be ARCHIVED!";

            // Cancel draft invoice
            Invoice inv3 = dao.getInvoiceByOrderId("ORD-2026-M4-003");
            boolean cancelled = dao.cancelDraftInvoice(inv3.getInvoiceNumber(), "Cancelled test draft");
            Invoice inv3After = dao.getInvoiceByNumber(inv3.getInvoiceNumber());
            System.out.println("  -> [DB VERIFIED] Draft Invoice Cancelled: " + inv3After.getPaymentStatus() + " | Name: " + inv3After.getCustomerName());
            assert "CANCELLED".equals(inv3After.getPaymentStatus()) : "Invoice should be CANCELLED!";

            System.out.println("\n================================================================================");
            System.out.println(">>> ALL 4 CRUD OPERATIONS FOR MEMBER 4 VERIFIED SUCCESSFULLY! <<<");
            System.out.println("================================================================================");

        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
