package controllers;

import dao.CartDAO;
import dao.ProductDAO;
import models.Cart;
import models.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Member 3: IT25103636 - Pavishanth K.
 * Module 6.3: Shopping Cart, Checkout & Payment
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {
    private final CartDAO cartDAO = new CartDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Cart cart = cartDAO.getCart(session);
        req.setAttribute("cart", cart);
        req.getRequestDispatcher("/cart.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        try {
            if ("add".equalsIgnoreCase(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(req.getParameter("quantity"));
                } catch (Exception ignored) {}

                Product product = productDAO.getProductById(productId);
                cartDAO.addToCart(session, product, quantity);
                res.sendRedirect(req.getContextPath() + "/cart?msg=item_added");

            } else if ("update".equalsIgnoreCase(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                cartDAO.updateItemQuantity(session, productId, quantity);
                res.sendRedirect(req.getContextPath() + "/cart?msg=cart_updated");

            } else if ("remove".equalsIgnoreCase(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                cartDAO.removeItem(session, productId);
                res.sendRedirect(req.getContextPath() + "/cart?msg=item_removed");

            } else if ("applyVoucher".equalsIgnoreCase(action)) {
                String voucher = req.getParameter("voucherCode");
                cartDAO.applyVoucher(session, voucher);
                res.sendRedirect(req.getContextPath() + "/cart?msg=voucher_applied");

            } else if ("removeVoucher".equalsIgnoreCase(action)) {
                cartDAO.removeVoucher(session);
                res.sendRedirect(req.getContextPath() + "/cart?msg=voucher_removed");

            } else if ("setPreferences".equalsIgnoreCase(action)) {
                String district = req.getParameter("district");
                String shippingOption = req.getParameter("shippingOption");
                cartDAO.updateShippingPreferences(session, district, shippingOption);
                res.sendRedirect(req.getContextPath() + "/cart");

            } else if ("clear".equalsIgnoreCase(action)) {
                cartDAO.clearCart(session);
                res.sendRedirect(req.getContextPath() + "/cart?msg=cart_cleared");

            } else {
                res.sendRedirect(req.getContextPath() + "/cart");
            }
        } catch (Exception ex) {
            req.setAttribute("errorMessage", ex.getMessage());
            req.setAttribute("cart", cartDAO.getCart(session));
            req.getRequestDispatcher("/cart.jsp").forward(req, res);
        }
    }
}
