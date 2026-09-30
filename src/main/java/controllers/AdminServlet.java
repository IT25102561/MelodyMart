package controllers;

import dao.*;
import models.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * MelodyMart - Admin & Staff Management Servlet
 * Central dashboard coordinating all 6 Group Members' modules
 */
@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final FulfillmentDAO fulfillmentDAO = new FulfillmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User loggedUser = (User) session.getAttribute("currentUser");

        // Allow demo view if user hasn't logged in yet, or pre-login as admin
        if (loggedUser == null) {
            // Default to mock admin for presentation convenience if requested
            String mock = req.getParameter("demo");
            if ("admin".equalsIgnoreCase(mock)) {
                User demoAdmin = userDAO.getUserById(1);
                session.setAttribute("currentUser", demoAdmin);
                loggedUser = demoAdmin;
            }
        }

        String tab = req.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "overview";
        }

        // Fetch datasets for all 6 members
        List<User> users = userDAO.getAllUsers();
        List<Product> products = productDAO.getAllProductsAdmin();
        List<Order> orders = orderDAO.getAllOrders();
        List<Payment> payments = paymentDAO.getAllPayments();
        List<Invoice> invoices = paymentDAO.getAllInvoices();
        List<Supplier> suppliers = supplierDAO.getAllSuppliersAdmin();
        List<PurchaseOrder> purchaseOrders = supplierDAO.getAllPurchaseOrders();
        List<Fulfillment> fulfillments = fulfillmentDAO.getAllFulfillments();
        List<ReturnRequest> returns = fulfillmentDAO.getAllReturns();

        // Calculate business metrics
        double totalRevenue = 0.0;
        for (Order o : orders) {
            if (!"CANCELLED".equalsIgnoreCase(o.getFulfillmentStatus()) && !"FAILED".equalsIgnoreCase(o.getPaymentStatus())) {
                totalRevenue += o.getTotalAmount();
            }
        }

        req.setAttribute("activeTab", tab);
        req.setAttribute("users", users);
        req.setAttribute("products", products);
        req.setAttribute("orders", orders);
        req.setAttribute("payments", payments);
        req.setAttribute("invoices", invoices);
        req.setAttribute("suppliers", suppliers);
        req.setAttribute("purchaseOrders", purchaseOrders);
        req.setAttribute("fulfillments", fulfillments);
        req.setAttribute("returns", returns);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("currentUser", loggedUser);

        req.getRequestDispatcher("/admin_dashboard.jsp").forward(req, res);
    }
}
