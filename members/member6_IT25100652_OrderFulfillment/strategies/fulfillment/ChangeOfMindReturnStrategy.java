package strategies.fulfillment;

import models.ReturnRequest;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Handles remorse / customer change of mind returns within 14-day policy window.
 * Requires pristine condition in original packaging. Deducts a 15% restocking and instrument
 * sanitization/re-tuning fee (customer receives 85% refund).
 */
public class ChangeOfMindReturnStrategy implements ReturnValidationStrategy {
    private static final long serialVersionUID = 1L;

    private static final double RESTOCKING_FEE_RATE = 0.15; // 15% deduction

    @Override
    public boolean validateEligibility(ReturnRequest request) {
        if (request == null) return false;
        return request.getOrderId() != null && !request.getOrderId().trim().isEmpty()
                && request.getItemDetails() != null && !request.getItemDetails().trim().isEmpty();
    }

    @Override
    public double calculateRefundPercentage(ReturnRequest request) {
        return 1.0 - RESTOCKING_FEE_RATE; // 85% net refund
    }

    @Override
    public String getInitialStage(ReturnRequest request) {
        return "UNDER_REVIEW";
    }

    @Override
    public String getRecommendedResolution(ReturnRequest request) {
        return "Customer change of mind return accepted subject to 15% restocking fee. Inspect seal integrity and condition upon warehouse receipt prior to releasing 85% net refund.";
    }

    @Override
    public String getPolicyName() {
        return "14-Day Customer Satisfaction Return Policy (85% Refund after 15% Restocking Fee)";
    }
}
