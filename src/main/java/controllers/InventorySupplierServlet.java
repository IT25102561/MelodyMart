package controllers;

import dao.ProductDAO;
import dao.SupplierDAO;
import models.Product;
import models.PurchaseOrder;
import models.Supplier;
import strategies.inventory.SupplierPricingFactory;
import strategies.inventory.SupplierPricingStrategy;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Member 5: IT25103441 - Premasiri R. M. R. R.
 * Module 6.5: Real-Time Inventory & Supplier Management
 */
@WebServlet(name = "InventorySupplierServlet", urlPatterns = {"/inventory", "/suppliers"})
public class InventorySupplierServlet extends HttpServlet {
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/admin?tab=inventory");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("addSupplier".equalsIgnoreCase(action)) {
                // [CREATE] Register new instrument suppliers
                String companyName = req.getParameter("companyName");
                String contactPerson = req.getParameter("contactPerson");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address");
                String categories = req.getParameter("categories");

                utils.ValidationUtil.validateSupplier(companyName, contactPerson, email, phone);

                supplierDAO.addSupplier(companyName, contactPerson, email, phone, address, categories);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=supplier_registered");

            } else if ("updateSupplier".equalsIgnoreCase(action)) {
                // [UPDATE] Update supplier contract/contact details
                int id = Integer.parseInt(req.getParameter("id"));
                String companyName = req.getParameter("companyName");
                String contactPerson = req.getParameter("contactPerson");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address");
                String categories = req.getParameter("categories");

                utils.ValidationUtil.validateSupplier(companyName, contactPerson, email, phone);

                supplierDAO.updateSupplier(id, companyName, contactPerson, email, phone, address, categories);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=supplier_updated");

            } else if ("deactivateSupplier".equalsIgnoreCase(action)) {
                // [DELETE] Deactivate discontinued supplier profiles
                int id = Integer.parseInt(req.getParameter("id"));
                supplierDAO.deactivateSupplier(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=supplier_deactivated");

            } else if ("reactivateSupplier".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                supplierDAO.reactivateSupplier(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=supplier_reactivated");

            } else if ("createPO".equalsIgnoreCase(action)) {
                // [CREATE] Generate stock purchase orders (POs) and record incoming stock batches with warranty batches
                int supplierId = Integer.parseInt(req.getParameter("supplierId"));
                String itemsSummary = req.getParameter("itemsSummary");
                int quantity;
                double totalAmount;
                try {
                    quantity = Integer.parseInt(req.getParameter("quantity"));
                    totalAmount = Double.parseDouble(req.getParameter("totalAmount"));
                } catch (Exception e) {
                    throw new Exception("ERR_PO_INVALID_AMOUNTS: Quantity and total amount must be valid positive numbers.");
                }
                String expectedDate = req.getParameter("expectedDate");

                utils.ValidationUtil.validatePurchaseOrder(quantity, totalAmount, expectedDate);

                // Strategy Pattern: Resolve supplier procurement pricing strategy
                String pricingTier = req.getParameter("pricingTier");
                if (pricingTier == null || pricingTier.trim().isEmpty()) {
                    pricingTier = req.getParameter("pricingStrategy");
                }
                SupplierPricingStrategy pricingStrategy = (pricingTier != null && !pricingTier.trim().isEmpty())
                        ? SupplierPricingFactory.getStrategy(pricingTier)
                        : SupplierPricingFactory.getStrategyForQuantity(quantity);

                supplierDAO.createPurchaseOrder(supplierId, itemsSummary, quantity, totalAmount, expectedDate, pricingStrategy);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=po_issued");

            } else if ("updatePoStatus".equalsIgnoreCase(action)) {
                String poNumber = req.getParameter("poNumber");
                String status = req.getParameter("status");
                supplierDAO.updatePoStatus(poNumber, status);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=po_updated");

            } else if ("receiveBatch".equalsIgnoreCase(action)) {
                // [CREATE / UPDATE] Record incoming stock batches with warranty batches
                String poNumber = req.getParameter("poNumber");
                int productId = 0;
                int quantity = 0;
                try {
                    String pStr = req.getParameter("productId");
                    if (pStr != null && !pStr.isEmpty()) productId = Integer.parseInt(pStr);
                    String qStr = req.getParameter("quantity");
                    if (qStr != null && !qStr.isEmpty()) quantity = Integer.parseInt(qStr);
                } catch (Exception ignored) {}
                String warrantyBatch = req.getParameter("warrantyBatch");

                if (quantity < 1) {
                    throw new Exception("ERR_PO_INVALID_AMOUNTS: Received quantity must be at least 1.");
                }
                if (warrantyBatch == null || !warrantyBatch.matches("^[A-Za-z0-9_-]{3,50}$")) {
                    throw new Exception("ERR_PO_INVALID_AMOUNTS: Warranty batch code must be 3-50 alphanumeric characters.");
                }

                supplierDAO.receiveStockBatch(poNumber, productId, quantity, warrantyBatch);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=stock_batch_received");

            } else if ("deleteSupplier".equalsIgnoreCase(action)) {
                // [DELETE] Permanently remove supplier from database
                int id = Integer.parseInt(req.getParameter("id"));
                supplierDAO.deleteSupplier(id);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=supplier_deleted");

            } else if ("deletePO".equalsIgnoreCase(action) || "deletePurchaseOrder".equalsIgnoreCase(action)) {
                // [DELETE] Permanently remove purchase order from database
                String poNumber = req.getParameter("poNumber");
                supplierDAO.deletePurchaseOrder(poNumber);
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=po_deleted");

            } else if ("adjustStock".equalsIgnoreCase(action)) {
                // [UPDATE] Adjust stock counts for returns or damages
                int productId = Integer.parseInt(req.getParameter("productId"));
                int delta;
                try {
                    delta = Integer.parseInt(req.getParameter("delta"));
                } catch (Exception e) {
                    throw new Exception("ERR_PROD_INVALID_STOCK: Adjustment quantity must be a valid integer.");
                }
                Product prod = productDAO.getProductByIdAdmin(productId);
                utils.ValidationUtil.validateStockDelta(prod != null ? prod.getStockQuantity() : 0, delta);
                if (delta > 0) {
                    productDAO.addStock(productId, delta);
                } else {
                    productDAO.deductStock(productId, Math.abs(delta));
                }
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory&msg=stock_adjusted");

            } else {
                res.sendRedirect(req.getContextPath() + "/admin?tab=inventory");
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("errorMessage", ex.getMessage());
            res.sendRedirect(req.getContextPath() + "/admin?tab=inventory");
        }
    }
}
