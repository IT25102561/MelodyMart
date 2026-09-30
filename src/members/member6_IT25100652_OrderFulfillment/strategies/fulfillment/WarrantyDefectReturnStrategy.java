package strategies.fulfillment;

import models.ReturnRequest;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Concrete Strategy:
 * Handles manufacturer warranty claims and acoustic/electronic defects (e.g. DEFECTIVE_ON_ARRIVAL, SOUND_DEFECT).
 * Recommends free repair by MelodyMart certified luthiers/technicians or direct replacement.
 */
public class WarrantyDefectReturnStrategy implements ReturnValidationStrategy {
    private static final long serialVersionUID = 1L;

    @Override
    public boolean validateEligibility(ReturnRequest request) {
        if (request == null) return false;
        return request.getOrderId() != null && !request.getOrderId().trim().isEmpty()
                && request.getItemDetails() != null && !request.getItemDetails().trim().isEmpty();
    }

    @Override
    public double calculateRefundPercentage(ReturnRequest request) {
        // Direct warranty replacement or 100% refund if non-repairable
        return 1.0;
    }

    @Override
    public String getInitialStage(ReturnRequest request) {
        return "UNDER_REVIEW";
    }

    @Override
    public String getRecommendedResolution(ReturnRequest request) {
        return "Instrument defect verified under official warranty. Schedule workshop technician inspection for repair calibration or authorized exchange.";
    }

    @Override
    public String getPolicyName() {
        return "MelodyMart Comprehensive Instrument Warranty Policy";
    }
}
