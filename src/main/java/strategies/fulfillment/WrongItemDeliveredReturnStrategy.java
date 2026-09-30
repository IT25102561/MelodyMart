package strategies.fulfillment;

import models.ReturnRequest;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Handles dispatch/warehouse packing errors where wrong instrument was delivered.
 * Grants immediate approval, free return courier pickup, and expedited priority re-dispatch.
 */
public class WrongItemDeliveredReturnStrategy implements ReturnValidationStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public boolean validateEligibility(ReturnRequest request) {
        if (request == null) return false;
        return request.getOrderId() != null && !request.getOrderId().trim().isEmpty();
    }

    @Override
    public double calculateRefundPercentage(ReturnRequest request) {
        return 1.0; // 100% refund or free direct swap
    }

    @Override
    public String getInitialStage(ReturnRequest request) {
        return "APPROVED";
    }

    @Override
    public String getRecommendedResolution(ReturnRequest request) {
        return "Warehouse picking error confirmed. Priority return courier dispatched for reverse logistics pickup; correct item dispatched immediately at zero cost.";
    }

    @Override
    public String getPolicyName() {
        return "MelodyMart 100% Accuracy Guarantee (Immediate Free Swap/Full Refund)";
    }
}
