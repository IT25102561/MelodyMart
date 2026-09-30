package controllers;

import dao.OrderDAO;
import dao.PaymentDAO;
import models.Invoice;
import models.Order;
import models.Payment;
import strategies.payment.PaymentStrategy;
import strategies.payment.PaymentStrategyFactory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Member 4: IT25101556 - Ekanayaka E. A. T. T.
 * Module 6.4: Payment Gateway & Invoice System
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment", "/invoice"})
public class PaymentServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/invoice".equalsIgnoreCase(servletPath)) {
            String invNo = req.getParameter("no");
            String orderId = req.getParameter("orderId");

            Invoice invoice = null;
            if (invNo != null && !invNo.trim().isEmpty()) {
                invoice = paymentDAO.getInvoiceByNumber(invNo);
            } else if (orderId != null && !orderId.trim().isEmpty()) {
                invoice = paymentDAO.getInvoiceByOrderId(orderId);
                if (invoice == null) {
                    Order o = orderDAO.getOrderById(orderId);
                    if (o != null) {
                        Payment p = paymentDAO.getPaymentByOrderId(orderId);
                        invoice = paymentDAO.generateInvoice(o, p);
                    }
                }
            }

            if (invoice != null) {
                req.setAttribute("invoice", invoice);
                req.getRequestDispatcher("/invoice.jsp").forward(req, res);
                return;
            }
            res.sendRedirect(req.getContextPath() + "/admin?tab=payments");
            return;
        }

        // /payment default
        String orderId = req.getParameter("orderId");
        Payment payment = paymentDAO.getPaymentByOrderId(orderId);
        req.setAttribute("payment", payment);
        req.getRequestDispatcher("/invoice.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("initiatePayment".equalsIgnoreCase(action)) {
                // [CREATE] Initiate transaction records across payment channels and auto-generate itemized e-invoices
                String orderId = req.getParameter("orderId");
                String customerName = req.getParameter("customerName");
                String customerEmail = req.getParameter("customerEmail");
                String customerPhone = req.getParameter("customerPhone");
                String billingAddress = req.getParameter("billingAddress");
                double amount = 0.0;
                try {
                    amount = Double.parseDouble(req.getParameter("amount"));
                } catch (Exception e) {
                    throw new Exception("ERR_PAY_INVALID_AMOUNT: Payment amount must be a valid positive number.");
                }

                String paymentMethod = req.getParameter("paymentMethod");
                String bankSlipUrl = req.getParameter("bankSlipUrl");
                String transactionRef = req.getParameter("transactionRef");
                boolean autoInvoice = "true".equalsIgnoreCase(req.getParameter("autoGenerateInvoice"))
                        || "on".equalsIgnoreCase(req.getParameter("autoGenerateInvoice"))
                        || req.getParameter("autoGenerateInvoice") == null;

                // Strategy Pattern: Resolve concrete payment processing strategy
                PaymentStrategy paymentStrategy = PaymentStrategyFactory.getStrategy(paymentMethod);
                Payment p = paymentDAO.initiateTransaction(orderId, customerName, customerEmail, customerPhone,
                        billingAddress, amount, paymentMethod, bankSlipUrl, transactionRef, autoInvoice, paymentStrategy);

                if (orderId != null && !orderId.trim().isEmpty()) {
                    Order ord = orderDAO.getOrderById(orderId.trim());
                    if (ord != null) {
                        orderDAO.updatePaymentStatus(orderId.trim(), p.getPaymentStatus());
                    }
                }

                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=transaction_initiated");

            } else if ("updateStatus".equalsIgnoreCase(action)) {
                // [UPDATE] Update transaction status following manual bank slip review or payment gateway webhooks
                String txnId = req.getParameter("txnId");
                String newStatus = req.getParameter("status");
                String notes = req.getParameter("notes");
                String orderId = req.getParameter("orderId");

                paymentDAO.updatePaymentStatus(txnId, newStatus, notes);
                if (orderId != null && !orderId.trim().isEmpty()) {
                    orderDAO.updatePaymentStatus(orderId, newStatus);
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=payment_status_updated");

            } else if ("refund".equalsIgnoreCase(action)) {
                // [UPDATE] Record processed refund details
                String txnId = req.getParameter("txnId");
                String reason = req.getParameter("refundReason");
                String refundRef = req.getParameter("refundRef");
                double refundAmt = 0.0;
                try {
                    String rStr = req.getParameter("refundAmount");
                    if (rStr != null && !rStr.trim().isEmpty()) refundAmt = Double.parseDouble(rStr);
                } catch (Exception ignored) {}

                String orderId = req.getParameter("orderId");

                if (refundAmt <= 0.0) {
                    throw new Exception("ERR_PAY_INVALID_AMOUNT: Refund amount must be greater than zero.");
                }
                utils.ValidationUtil.validateRefundReason(reason);

                paymentDAO.recordRefund(txnId, refundAmt, reason, refundRef);
                if (orderId != null && !orderId.trim().isEmpty()) {
                    orderDAO.updatePaymentStatus(orderId, "REFUNDED");
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=refund_recorded");

            } else if ("voidPayment".equalsIgnoreCase(action)) {
                // [DELETE] Void failed or unverified payment attempts
                String txnId = req.getParameter("txnId");
                String reason = req.getParameter("voidReason");
                String orderId = req.getParameter("orderId");

                if (reason == null || reason.trim().length() < 3) {
                    throw new Exception("ERR_PAY_INVALID_VOID: Reason for voiding must be at least 3 characters.");
                }

                paymentDAO.voidPayment(txnId, reason);
                if (orderId != null && !orderId.trim().isEmpty()) {
                    orderDAO.updatePaymentStatus(orderId, "FAILED");
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=payment_voided");

            } else if ("archivePayment".equalsIgnoreCase(action)) {
                // [DELETE] Archive obsolete billing records
                String txnId = req.getParameter("txnId");
                paymentDAO.archivePayment(txnId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=payment_archived");

            } else if ("cancelDraftInvoice".equalsIgnoreCase(action)) {
                // [DELETE] Cancel invalidated draft invoices
                String invoiceNo = req.getParameter("invoiceNumber");
                String reason = req.getParameter("cancelReason");
                paymentDAO.cancelDraftInvoice(invoiceNo, reason);
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=invoice_cancelled");

            } else if ("deletePayment".equalsIgnoreCase(action)) {
                String txnId = req.getParameter("txnId");
                if (txnId != null && !txnId.trim().isEmpty()) {
                    paymentDAO.deletePayment(txnId.trim());
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=payment_deleted");
                return;

            } else if ("deleteInvoice".equalsIgnoreCase(action)) {
                String invoiceNo = req.getParameter("invoiceNumber");
                if (invoiceNo != null && !invoiceNo.trim().isEmpty()) {
                    paymentDAO.deleteInvoice(invoiceNo.trim());
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments&msg=invoice_deleted");
                return;

            } else {
                res.sendRedirect(req.getContextPath() + "/admin?tab=payments");
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("errorMessage", ex.getMessage());
            res.sendRedirect(req.getContextPath() + "/admin?tab=payments");
        }
    }
}
