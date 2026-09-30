package controllers;

import dao.OrderDAO;
import models.Order;
import models.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * MelodyMart - Order History & View Servlet
 * Connects customer order tracking with saved orders
 * Supports full Order Update operations
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders"})
public class OrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User loggedUser = (User) session.getAttribute("currentUser");

        String orderId = req.getParameter("id");
        if (orderId != null && !orderId.trim().isEmpty()) {
            Order order = orderDAO.getOrderById(orderId.trim());
            req.setAttribute("order", order);
            req.getRequestDispatcher("/order_details.jsp").forward(req, res);
            return;
        }

        List<Order> orders;
        if (loggedUser != null && ("ADMIN".equalsIgnoreCase(loggedUser.getRole()) || "SALES_STAFF".equalsIgnoreCase(loggedUser.getRole())
                || "FINANCE_STAFF".equalsIgnoreCase(loggedUser.getRole()))) {
            orders = orderDAO.getAllOrders();
        } else if (loggedUser != null) {
            orders = orderDAO.getOrdersByCustomerEmail(loggedUser.getEmail());
        } else {
            orders = orderDAO.getAllOrders(); // Allow preview demo in educational context
        }

        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/order_history.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("updateOrder".equalsIgnoreCase(action)) {
                String orderId = req.getParameter("orderId");
                String customerName = req.getParameter("customerName");
                String customerPhone = req.getParameter("customerPhone");
                String address = req.getParameter("shippingAddress");
                String city = req.getParameter("city");
                String district = req.getParameter("district");
                String courierName = req.getParameter("courierName");
                String paymentStatus = req.getParameter("paymentStatus");
                String fulfillmentStatus = req.getParameter("fulfillmentStatus");

                utils.ValidationUtil.validateUserName(customerName);
                utils.ValidationUtil.validateSriLankanPhone(customerPhone);
                utils.ValidationUtil.validateAddress(address);
                utils.ValidationUtil.validateCity(city);
                utils.ValidationUtil.validateCity(district);

                orderDAO.updateOrderDetails(orderId, customerName, customerPhone, address, city, district, courierName);
                if (paymentStatus != null && !paymentStatus.isEmpty()) {
                    orderDAO.updatePaymentStatus(orderId, paymentStatus);
                }
                if (fulfillmentStatus != null && !fulfillmentStatus.isEmpty()) {
                    orderDAO.updateFulfillmentStatus(orderId, fulfillmentStatus);
                }

                res.sendRedirect(req.getContextPath() + "/admin?tab=orders&msg=order_updated");
            } else if ("deleteOrder".equalsIgnoreCase(action)) {
                String orderId = req.getParameter("orderId");
                if (orderId != null && !orderId.trim().isEmpty()) {
                    orderDAO.deleteOrder(orderId.trim());
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=orders&msg=order_deleted");
                return;
            } else {
                res.sendRedirect(req.getContextPath() + "/orders");
            }
        } catch (Exception ex) {
            req.setAttribute("errorMessage", ex.getMessage());
            req.getRequestDispatcher("/admin_dashboard.jsp").forward(req, res);
        }
    }
}
