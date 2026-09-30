package strategies.fulfillment;

import models.ReturnRequest;
import java.io.Serializable;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Strategy Design Pattern - Strategy Interface:
 * Encapsulates return RMA validation, refund percentage computation,
 * initial triage staging, and resolution recommendations based on specific return reasons.
 */
public interface ReturnValidationStrategy extends Serializable {

    /**
     * Validates whether the return claim meets minimum eligibility requirements.
     *
     * @param request The customer's ReturnRequest ticket.
     * @return true if valid and acceptable for processing; false otherwise.
     */
    boolean validateEligibility(ReturnRequest request);

    /**
     * Calculates the refund percentage payable to the customer (0.0 to 1.0, where 1.0 = 100%).
     *
     * @param request The ReturnRequest entity.
     * @return Refund fraction (e.g. 1.0 for 100% full refund, 0.85 for 15% restocking fee deduction).
     */
    double calculateRefundPercentage(ReturnRequest request);

    /**
     * Determines the initial workflow triage stage (e.g., "UNDER_REVIEW", "APPROVED", "INSPECTION_PENDING").
     *
     * @param request The ReturnRequest entity.
     * @return Initial lifecycle stage.
     */
    String getInitialStage(ReturnRequest request);

    /**
     * Produces standard resolution recommendations and action instructions.
     *
     * @param request The ReturnRequest entity.
     * @return Recommendation notes for operations and customer service staff.
     */
    String getRecommendedResolution(ReturnRequest request);

    /**
     * Returns the policy name of this strategy.
     *
     * @return Policy title.
     */
    String getPolicyName();
}
