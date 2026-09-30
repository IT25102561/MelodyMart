/**
 * MelodyMart - Module 6.6: Order Fulfilment, Delivery Tracking & Returns
 * Member: Nellampitiya T. T. (IT25100652)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_DELIV_INVALID_TRACKING: {
    code: 'ERR_DELIV_INVALID_TRACKING',
    name: 'Invalid Courier Tracking Identifier Format',
    condition: 'Triggered when dispatch tracking identifier format is invalid or courier partner is unselected (Expected KB-LK-XXXXX, PX-LK-XXXXX, or DX-COL-XXXXX).',
    sampleMessage: 'Tracking identifier format invalid. Expected format: KB-LK-XXXXX, PX-LK-XXXXX, or DX-COL-XXXXX.'
  },
  ERR_DELIV_ILLEGAL_STATE_TRANSITION: {
    code: 'ERR_DELIV_ILLEGAL_STATE_TRANSITION',
    name: 'Illegal Delivery Lifecycle State Transition',
    condition: 'Triggered when attempting to transition an order status illegally (e.g., from \'Processing\' directly to \'Delivered\' without dispatch).',
    sampleMessage: 'Illegal delivery lifecycle transition from "Processing" to "Delivered". Lifecycle must follow: Processing -> Shipped -> In-Transit -> Delivered.'
  },
  ERR_RET_WINDOW_EXPIRED: {
    code: 'ERR_RET_WINDOW_EXPIRED',
    name: 'Expired Return Window or Unfulfilled Order Claim',
    condition: 'Triggered when a customer submits a return or warranty inspection for an order that has not yet been delivered or whose 14-day warranty claim window has elapsed.',
    sampleMessage: 'Cannot submit return/warranty claim for order "MM-2026-1003". The order status is currently "Processing". Returns are only permitted after successful delivery.'
  }
};
