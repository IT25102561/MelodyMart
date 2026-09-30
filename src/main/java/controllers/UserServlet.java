package controllers;

import dao.UserDAO;
import models.Address;
import models.User;
import strategies.user.PasswordHashingFactory;
import strategies.user.PasswordHashingStrategy;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Member 1: IT25101726 - Perera D. A. P. W.
 * Module 6.1: User Account & Profile Management
 * Handles registration, authentication, address book, and profile updates.
 */
@WebServlet(name = "UserServlet", urlPatterns = {"/user"})
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "profile";

        HttpSession session = req.getSession();
        User loggedUser = (User) session.getAttribute("currentUser");

        switch (action) {
            case "login":
                req.getRequestDispatcher("/login.jsp").forward(req, res);
                break;
            case "register":
                req.getRequestDispatcher("/register.jsp").forward(req, res);
                break;
            case "logout":
                session.invalidate();
                res.sendRedirect(req.getContextPath() + "/index.jsp?msg=logged_out");
                break;
            case "profile":
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login&redirect=profile");
                    return;
                }
                User freshUser = userDAO.getUserById(loggedUser.getId());
                req.setAttribute("user", freshUser);
                req.getRequestDispatcher("/profile.jsp").forward(req, res);
                break;
            default:
                res.sendRedirect(req.getContextPath() + "/index.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        try {
            if ("register".equalsIgnoreCase(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String password = req.getParameter("password");
                String phone = req.getParameter("phone");

                // Strategy Pattern: Resolve password hashing strategy (default SHA-256)
                String hashStrategyKey = req.getParameter("hashStrategy");
                if (hashStrategyKey == null || hashStrategyKey.trim().isEmpty()) {
                    hashStrategyKey = req.getParameter("hashingStrategy");
                }
                PasswordHashingStrategy hashingStrategy = PasswordHashingFactory.getStrategy(hashStrategyKey);

                User newUser = userDAO.registerUser(fullName, email, password, phone, "CUSTOMER", hashingStrategy);
                session.setAttribute("currentUser", newUser);
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=registered_successfully");

            } else if ("login".equalsIgnoreCase(action)) {
                String email = req.getParameter("email");
                String password = req.getParameter("password");

                // Strategy Pattern: Resolve authentication strategy
                String hashStrategyKey = req.getParameter("hashStrategy");
                if (hashStrategyKey == null || hashStrategyKey.trim().isEmpty()) {
                    hashStrategyKey = req.getParameter("hashingStrategy");
                }
                PasswordHashingStrategy hashingStrategy = PasswordHashingFactory.getStrategy(hashStrategyKey);

                User auth = userDAO.authenticate(email, password, hashingStrategy);
                if (auth != null) {
                    session.setAttribute("currentUser", auth);
                    if ("ADMIN".equalsIgnoreCase(auth.getRole()) || "SALES_STAFF".equalsIgnoreCase(auth.getRole())
                            || "INVENTORY_STAFF".equalsIgnoreCase(auth.getRole()) || "FINANCE_STAFF".equalsIgnoreCase(auth.getRole())) {
                        res.sendRedirect(req.getContextPath() + "/admin");
                    } else {
                        res.sendRedirect(req.getContextPath() + "/index.jsp?msg=welcome");
                    }
                } else {
                    req.setAttribute("errorMessage", "Invalid email or password. Please check your credentials.");
                    req.getRequestDispatcher("/login.jsp").forward(req, res);
                }

            } else if ("updateProfile".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login");
                    return;
                }
                String fullName = req.getParameter("fullName");
                String phone = req.getParameter("phone");
                userDAO.updateProfile(loggedUser.getId(), fullName, phone);

                // Refresh session user
                session.setAttribute("currentUser", userDAO.getUserById(loggedUser.getId()));
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=profile_updated");

            } else if ("addAddress".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login");
                    return;
                }
                String label = req.getParameter("label");
                String street = req.getParameter("street");
                String city = req.getParameter("city");
                String district = req.getParameter("district");
                String postalCode = req.getParameter("postalCode");
                boolean isPrimary = req.getParameter("isPrimary") != null;

                userDAO.addAddress(loggedUser.getId(), label, street, city, district, postalCode, isPrimary);
                session.setAttribute("currentUser", userDAO.getUserById(loggedUser.getId()));
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=address_added");

            } else if ("updatePassword".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login");
                    return;
                }
                String oldPassword = req.getParameter("oldPassword");
                String newPassword = req.getParameter("newPassword");

                String hashStrategyKey = req.getParameter("hashStrategy");
                if (hashStrategyKey == null || hashStrategyKey.trim().isEmpty()) {
                    hashStrategyKey = req.getParameter("hashingStrategy");
                }
                PasswordHashingStrategy hashingStrategy = PasswordHashingFactory.getStrategy(hashStrategyKey);

                userDAO.updatePassword(loggedUser.getId(), oldPassword, newPassword, hashingStrategy);
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=password_updated");

            } else if ("setPrimaryAddress".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login");
                    return;
                }
                int addressId = Integer.parseInt(req.getParameter("addressId"));
                userDAO.setPrimaryAddress(loggedUser.getId(), addressId);
                session.setAttribute("currentUser", userDAO.getUserById(loggedUser.getId()));
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=primary_address_updated");

            } else if ("removeAddress".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser == null) {
                    res.sendRedirect(req.getContextPath() + "/user?action=login");
                    return;
                }
                int addressId = Integer.parseInt(req.getParameter("addressId"));
                userDAO.removeAddress(loggedUser.getId(), addressId);
                session.setAttribute("currentUser", userDAO.getUserById(loggedUser.getId()));
                res.sendRedirect(req.getContextPath() + "/user?action=profile&msg=address_removed");

            } else if ("adminCreateUser".equalsIgnoreCase(action)) {
                // [CREATE] Register new customer and staff user accounts with secure password hashing
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String password = req.getParameter("password");
                String phone = req.getParameter("phone");
                String role = req.getParameter("role");

                utils.ValidationUtil.validateUserName(fullName);
                utils.ValidationUtil.validateEmail(email);
                utils.ValidationUtil.validatePasswordStrength(password);
                utils.ValidationUtil.validateSriLankanPhone(phone);

                userDAO.registerUser(fullName, email, password, phone, role);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=user_registered");
                return;

            } else if ("adminUpdateUser".equalsIgnoreCase(action)) {
                // [UPDATE] Edit personal details & modify assigned staff roles
                int userId = Integer.parseInt(req.getParameter("userId"));
                String fullName = req.getParameter("fullName");
                String phone = req.getParameter("phone");
                String role = req.getParameter("role");
                String status = req.getParameter("status");

                utils.ValidationUtil.validateUserName(fullName);
                utils.ValidationUtil.validateSriLankanPhone(phone);

                userDAO.adminUpdateUser(userId, fullName, phone, role, status);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=user_updated");
                return;

            } else if ("adminUpdatePassword".equalsIgnoreCase(action)) {
                // [UPDATE] Update account passwords with secure hashing
                int userId = Integer.parseInt(req.getParameter("userId"));
                String newPassword = req.getParameter("newPassword");

                utils.ValidationUtil.validatePasswordStrength(newPassword);

                userDAO.updatePasswordAdmin(userId, newPassword);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=password_updated");
                return;

            } else if ("adminDeleteUser".equalsIgnoreCase(action) || "deleteUser".equalsIgnoreCase(action)) {
                // [DELETE] Permanently remove user account and addresses from database
                int userId = Integer.parseInt(req.getParameter("userId"));
                userDAO.deleteUser(userId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=user_deleted");
                return;

            } else if ("adminDeactivateUser".equalsIgnoreCase(action)) {
                // [DELETE] Deactivate customer accounts upon request or terminate staff access records
                int userId = Integer.parseInt(req.getParameter("userId"));
                userDAO.deactivateUser(userId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=user_deactivated");
                return;

            } else if ("adminReactivateUser".equalsIgnoreCase(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                userDAO.reactivateUser(userId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=user_reactivated");
                return;

            } else if ("adminAddAddress".equalsIgnoreCase(action)) {
                // [CREATE] Add new shipping, billing, and contact addresses to the user's address book
                int userId = Integer.parseInt(req.getParameter("userId"));
                String label = req.getParameter("label");
                String street = req.getParameter("street");
                String city = req.getParameter("city");
                String district = req.getParameter("district");
                String postalCode = req.getParameter("postalCode");
                boolean isPrimary = "true".equalsIgnoreCase(req.getParameter("isPrimary")) || req.getParameter("isPrimary") != null;

                utils.ValidationUtil.validateAddress(street, city, district, postalCode);

                userDAO.addAddress(userId, label, street, city, district, postalCode, isPrimary);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=address_added");
                return;

            } else if ("adminSetPrimaryAddress".equalsIgnoreCase(action)) {
                // [UPDATE] Set primary shipping destinations
                int userId = Integer.parseInt(req.getParameter("userId"));
                int addressId = Integer.parseInt(req.getParameter("addressId"));

                userDAO.setPrimaryAddress(userId, addressId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=primary_address_updated");
                return;

            } else if ("adminRemoveAddress".equalsIgnoreCase(action)) {
                // [DELETE] Remove saved addresses from the profile
                int userId = Integer.parseInt(req.getParameter("userId"));
                int addressId = Integer.parseInt(req.getParameter("addressId"));

                userDAO.removeAddress(userId, addressId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=users&msg=address_removed");
                return;

            } else if ("deactivateAccount".equalsIgnoreCase(action)) {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser != null) {
                    userDAO.deactivateUser(loggedUser.getId());
                    session.invalidate();
                }
                res.sendRedirect(req.getContextPath() + "/index.jsp?msg=account_deactivated");

            } else {
                res.sendRedirect(req.getContextPath() + "/user?action=profile");
            }
        } catch (Exception ex) {
            if (action != null && action.startsWith("admin")) {
                req.getSession().setAttribute("errorMessage", ex.getMessage());
                res.sendRedirect(req.getContextPath() + "/admin?tab=users");
                return;
            }
            req.setAttribute("errorMessage", ex.getMessage());
            if ("register".equalsIgnoreCase(action)) {
                req.setAttribute("regFullName", req.getParameter("fullName"));
                req.setAttribute("regEmail", req.getParameter("email"));
                req.setAttribute("regPhone", req.getParameter("phone"));
                req.getRequestDispatcher("/register.jsp").forward(req, res);
            } else if ("login".equalsIgnoreCase(action)) {
                req.getRequestDispatcher("/login.jsp").forward(req, res);
            } else {
                User loggedUser = (User) session.getAttribute("currentUser");
                if (loggedUser != null) {
                    req.setAttribute("user", userDAO.getUserById(loggedUser.getId()));
                }
                req.getRequestDispatcher("/profile.jsp").forward(req, res);
            }
        }
    }
}
