package strategies.fulfillment;

/**
 * Member 6: IT25100652 - Nellampitiya T. T.
 * Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 *
 * Factory utility to resolve ReturnValidationStrategy based on return reason code.
 */
public class ReturnStrategyFactory {

    /**
     * Returns the appropriate ReturnValidationStrategy based on the return reason code.
     *
     * @param reason Code e.g. "TRANSIT_DAMAGE", "DEFECTIVE_ON_ARRIVAL", "SOUND_DEFECT", "CHANGE_OF_MIND", "WRONG_ITEM_RECEIVED".
     * @return Matching ReturnValidationStrategy, defaulting to WarrantyDefectReturnStrategy.
     */
    public static ReturnValidationStrategy getStrategy(String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return new WarrantyDefectReturnStrategy();
        }
        String key = reason.trim().toUpperCase();
        switch (key) {
            case "TRANSIT_DAMAGE":
            case "DAMAGE":
            case "DAMAGED":
            case "COURIER_DAMAGE":
                return new DamagedInTransitReturnStrategy();
            case "CHANGE_OF_MIND":
            case "REMORSE":
            case "CANCELLED_MIND":
                return new ChangeOfMindReturnStrategy();
            case "WRONG_ITEM":
            case "WRONG_ITEM_RECEIVED":
            case "INCORRECT_ITEM":
                return new WrongItemDeliveredReturnStrategy();
            case "DEFECTIVE_ON_ARRIVAL":
            case "SOUND_DEFECT":
            case "WARRANTY":
            case "DEFECT":
            default:
                return new WarrantyDefectReturnStrategy();
        }
    }
}
