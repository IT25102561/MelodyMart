package strategies.fulfillment;

import models.ReturnRequest;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Handles instruments damaged during courier transit.
 * Recommends 100% full refund or complimentary unit replacement, and initiates
 * logistics courier insurance claim.
 */
public class DamagedInTransitReturnStrategy implements ReturnValidationStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public boolean validateEligibility(ReturnRequest request) {
        if (request == null) return false;
        // Requires valid order ID and non-empty item details
        return request.getOrderId() != null && !request.getOrderId().trim().isEmpty()
                && request.getItemDetails() != null && request.getItemDetails().trim().length() >= 5;
    }

    @Override
    public double calculateRefundPercentage(ReturnRequest request) {
        return 1.0; // 100% refund
    }

    @Override
    public String getInitialStage(ReturnRequest request) {
        return "UNDER_REVIEW";
    }

    @Override
    public String getRecommendedResolution(ReturnRequest request) {
        return "Courier transit damage claim logged. Request package photos from customer, issue courier compensation ticket, and offer 100% refund or replacement.";
    }

    @Override
    public String getPolicyName() {
        return "Courier Transit Damage Protection Policy (100% Refund/Exchange)";
    }
}
