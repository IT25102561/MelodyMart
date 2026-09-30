package controllers;

import dao.CartDAO;
import dao.OrderDAO;
import dao.UserDAO;
import models.Cart;
import models.Order;
import models.User;
import strategies.cart.ShippingStrategyFactory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Member 3 & Central Flow: Checkout & Customer Session
 */
@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {
    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Cart cart = cartDAO.getCart(session);
        if (cart.getItems().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/cart?msg=empty");
            return;
        }

        User loggedUser = (User) session.getAttribute("currentUser");
        req.setAttribute("cart", cart);
        req.setAttribute("user", loggedUser);
        req.getRequestDispatcher("/checkout.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Cart cart = cartDAO.getCart(session);

        if (cart.getItems().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/cart?msg=empty");
            return;
        }

        try {
            User loggedUser = (User) session.getAttribute("currentUser");
            int userId = (loggedUser != null) ? loggedUser.getId() : 0;

            String customerName = req.getParameter("customerName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("shippingAddress");
            String city = req.getParameter("city");
            String district = req.getParameter("district");
            String courierName = req.getParameter("courierName");
            String paymentMethod = req.getParameter("paymentMethod");
            String bankSlipUrl = req.getParameter("bankSlipUrl");

            // Comprehensive input validations
            utils.ValidationUtil.validateUserName(customerName);
            if (email != null && !email.trim().isEmpty()) {
                utils.ValidationUtil.validateEmail(email);
            }
            utils.ValidationUtil.validateSriLankanPhone(phone);
            if (address == null || address.trim().isEmpty() || city == null || city.trim().isEmpty()) {
                throw new Exception("ERR_USER_ADDRESS_REQUIRED: Complete delivery street address and city are required.");
            }
            String postalCode = req.getParameter("postalCode");
            if (postalCode != null && !postalCode.trim().isEmpty()) {
                utils.ValidationUtil.validatePostalCode(postalCode);
            }
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                throw new Exception(utils.ValidationUtil.ERR_PAY_METHOD_REQUIRED + ": Please select a valid Sri Lankan payment method.");
            }
            if ("CREDIT_CARD".equalsIgnoreCase(paymentMethod)) {
                String cardNumber = req.getParameter("cardNumber");
                String cardExpiry = req.getParameter("cardExpiry");
                String cardCvv = req.getParameter("cardCvv");
                utils.ValidationUtil.validateCardDetails(cardNumber, cardExpiry, cardCvv);
            }
            if ("BANK_TRANSFER".equalsIgnoreCase(paymentMethod)) {
                if (bankSlipUrl == null || bankSlipUrl.trim().isEmpty()) {
                    throw new Exception(utils.ValidationUtil.ERR_PAY_UNVERIFIED_SLIP + ": Please attach a bank deposit receipt slip reference.");
                }
            }

            if (district != null) cart.setDistrict(district);

            // Strategy Pattern: Resolve shipping delivery fee strategy
            String shippingMethod = req.getParameter("shippingMethod");
            if (shippingMethod == null || shippingMethod.trim().isEmpty()) {
                shippingMethod = req.getParameter("shippingOption");
            }
            if (shippingMethod == null || shippingMethod.trim().isEmpty()) {
                shippingMethod = courierName;
            }
            if (shippingMethod != null && !shippingMethod.trim().isEmpty()) {
                cart.setShippingStrategy(ShippingStrategyFactory.getStrategy(shippingMethod));
            }

            // Persistently creates and saves the order to database and orders.txt!
            Order placedOrder = orderDAO.createAndSaveOrder(
                    userId, customerName, email, phone, address, city, district,
                    courierName, paymentMethod, bankSlipUrl, cart
            );

            session.setAttribute("lastPlacedOrder", placedOrder);
            res.sendRedirect(req.getContextPath() + "/order_success.jsp?orderId=" + placedOrder.getOrderId());

        } catch (Exception ex) {
            User loggedUser = (User) session.getAttribute("currentUser");
            req.setAttribute("errorMessage", ex.getMessage());
            req.setAttribute("cart", cart);
            req.setAttribute("user", loggedUser);
            req.getRequestDispatcher("/checkout.jsp").forward(req, res);
        }
    }
}
