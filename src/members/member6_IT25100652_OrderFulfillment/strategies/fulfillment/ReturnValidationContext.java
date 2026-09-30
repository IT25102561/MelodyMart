package strategies.fulfillment;

import models.ReturnRequest;
import java.io.Serializable;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Context Class:
 * Context for executing return validation, RMA triaging, and refund estimation.
 */
public class ReturnValidationContext implements Serializable {
    private static final long serialVersionUID = 1L;

    private ReturnValidationStrategy strategy;

    public ReturnValidationContext() {
        this.strategy = new WarrantyDefectReturnStrategy();
    }

    public ReturnValidationContext(ReturnValidationStrategy strategy) {
        this.strategy = (strategy != null) ? strategy : new WarrantyDefectReturnStrategy();
    }

    public void setStrategy(ReturnValidationStrategy strategy) {
        if (strategy != null) {
            this.strategy = strategy;
        }
    }

    public ReturnValidationStrategy getStrategy() {
        return this.strategy;
    }

    public boolean validate(ReturnRequest request) {
        return this.strategy.validateEligibility(request);
    }

    public double calculateRefund(ReturnRequest request) {
        return this.strategy.calculateRefundPercentage(request);
    }

    public String resolveInitialStage(ReturnRequest request) {
        return this.strategy.getInitialStage(request);
    }

    public String generateResolution(ReturnRequest request) {
        return this.strategy.getRecommendedResolution(request);
    }
}
