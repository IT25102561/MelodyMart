package controllers;

import dao.FulfillmentDAO;
import dao.OrderDAO;
import models.Fulfillment;
import models.Order;
import models.ReturnRequest;
import strategies.fulfillment.ReturnStrategyFactory;
import strategies.fulfillment.ReturnValidationStrategy;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 */
@WebServlet(name = "OrderFulfillmentServlet", urlPatterns = {"/fulfillment", "/track", "/returns"})
public class OrderFulfillmentServlet extends HttpServlet {
    private final FulfillmentDAO fulfillmentDAO = new FulfillmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/track".equalsIgnoreCase(servletPath)) {
            String trackingNo = req.getParameter("trackingNumber");
            if (trackingNo != null && !trackingNo.trim().isEmpty()) {
                Fulfillment f = fulfillmentDAO.getFulfillmentByTracking(trackingNo.trim());
                req.setAttribute("fulfillment", f);
                req.setAttribute("searchedCode", trackingNo.trim());
            }
            req.getRequestDispatcher("/order_tracking.jsp").forward(req, res);
            return;
        }

        if ("/returns".equalsIgnoreCase(servletPath)) {
            String ticketId = req.getParameter("ticketId");
            if (ticketId != null && !ticketId.trim().isEmpty()) {
                ReturnRequest r = fulfillmentDAO.getReturnById(ticketId.trim());
                req.setAttribute("returnRequest", r);
            }
            req.getRequestDispatcher("/returns.jsp").forward(req, res);
            return;
        }

        res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("createDispatch".equalsIgnoreCase(action)) {
                String orderId = req.getParameter("orderId");
                String customerName = req.getParameter("customerName");
                String shippingAddress = req.getParameter("shippingAddress");
                String courierName = req.getParameter("courierName");
                double codAmount = 0.0;
                try {
                    codAmount = Double.parseDouble(req.getParameter("codAmount"));
                } catch (Exception ignored) {}

                utils.ValidationUtil.validateDispatch(orderId);
                utils.ValidationUtil.validateUserName(customerName);
                utils.ValidationUtil.validateAddress(shippingAddress);
                if (codAmount < 0) {
                    throw new Exception("ERR_DISP_INVALID_COD: COD amount cannot be negative.");
                }

                fulfillmentDAO.createDispatchJob(orderId, customerName, shippingAddress, courierName, codAmount);
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=dispatch_created");

            } else if ("updateDeliveryStatus".equalsIgnoreCase(action)) {
                String trackingNumber = req.getParameter("trackingNumber");
                String newStatus = req.getParameter("status");
                String notes = req.getParameter("notes");
                String orderId = req.getParameter("orderId");

                fulfillmentDAO.updateDeliveryStatus(trackingNumber, newStatus, notes);
                if (orderId != null) {
                    orderDAO.updateFulfillmentStatus(orderId, newStatus);
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=status_updated");

            } else if ("recordCod".equalsIgnoreCase(action)) {
                String trackingNumber = req.getParameter("trackingNumber");
                boolean collected = "true".equalsIgnoreCase(req.getParameter("collected"));
                fulfillmentDAO.recordCodMilestone(trackingNumber, collected);
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=cod_updated");

            } else if ("cancelDispatch".equalsIgnoreCase(action)) {
                String trackingNumber = req.getParameter("trackingNumber");
                String orderId = req.getParameter("orderId");
                fulfillmentDAO.cancelDispatchOrder(trackingNumber);
                if (orderId != null) {
                    orderDAO.updateFulfillmentStatus(orderId, "CANCELLED");
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=dispatch_cancelled");

            } else if ("submitReturn".equalsIgnoreCase(action)) {
                String orderId = req.getParameter("orderId");
                String customerName = req.getParameter("customerName");
                String email = req.getParameter("email");
                String reason = req.getParameter("reason");
                String itemDetails = req.getParameter("itemDetails");

                utils.ValidationUtil.validateReturnRequest(orderId, reason, email);
                utils.ValidationUtil.validateUserName(customerName);
                if (itemDetails == null || itemDetails.trim().length() < 5) {
                    throw new Exception("ERR_RET_DETAILS_REQUIRED: Return item details must be at least 5 characters.");
                }

                // Strategy Pattern: Resolve return RMA validation strategy
                ReturnValidationStrategy returnStrategy = ReturnStrategyFactory.getStrategy(reason);
                ReturnRequest ret = fulfillmentDAO.submitReturnRequest(orderId, customerName, email, reason, itemDetails, returnStrategy);
                res.sendRedirect(req.getContextPath() + "/returns?ticketId=" + ret.getTicketId() + "&msg=return_submitted");

            } else if ("updateReturnStage".equalsIgnoreCase(action)) {
                String ticketId = req.getParameter("ticketId");
                String stage = req.getParameter("stage");
                String resolution = req.getParameter("resolutionNotes");

                fulfillmentDAO.updateReturnStage(ticketId, stage, resolution);
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=return_stage_updated");

            } else if ("deleteFulfillment".equalsIgnoreCase(action)) {
                // [DELETE] Permanently remove dispatch/fulfillment from database
                String trackingNumber = req.getParameter("trackingNumber");
                fulfillmentDAO.deleteFulfillment(trackingNumber);
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=dispatch_deleted");

            } else if ("deleteReturn".equalsIgnoreCase(action) || "deleteReturnRequest".equalsIgnoreCase(action)) {
                // [DELETE] Permanently remove return request ticket from database
                String ticketId = req.getParameter("ticketId");
                fulfillmentDAO.deleteReturnRequest(ticketId);
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments&msg=return_deleted");

            } else {
                res.sendRedirect(req.getContextPath() + "/admin?tab=fulfillments");
            }
        } catch (Exception ex) {
            req.setAttribute("errorMessage", ex.getMessage());
            if ("submitReturn".equalsIgnoreCase(action)) {
                req.getRequestDispatcher("/returns.jsp").forward(req, res);
            } else {
                req.setAttribute("activeTab", "fulfillments");
                req.getRequestDispatcher("/admin_dashboard.jsp").forward(req, res);
            }
        }
    }
}
