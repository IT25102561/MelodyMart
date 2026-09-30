/**
 * MelodyMart - Module 6.4: Payment Gateway & Invoice System
 * Member: Ekanayaka E. A. T. T. (IT25101556)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_PAY_CARD_DECLINED: {
    code: 'ERR_PAY_CARD_DECLINED',
    name: 'Credit/Debit Card Decline or Validation Failure',
    condition: 'Triggered when card number length is not 16 digits, contains non-numeric characters, or matches simulated declined test numbers (ending in \'0000\').',
    sampleMessage: 'Transaction declined by issuing bank (Insufficient funds or security block).'
  },
  ERR_PAY_SLIP_REQUIRED: {
    code: 'ERR_PAY_SLIP_REQUIRED',
    name: 'Missing Bank Deposit Slip or Reference Number',
    condition: 'Triggered when Bank Transfer channel is selected but either deposit transaction reference number or confirmation slip upload is missing.',
    sampleMessage: 'Bank transfer requires a valid deposit reference number and an uploaded deposit slip image.'
  },
  ERR_PAY_INVALID_REFUND_STATE: {
    code: 'ERR_PAY_INVALID_REFUND_STATE',
    name: 'Illegal Refund Attempt on Non-Paid Invoice',
    condition: 'Triggered when an administrator or staff attempts to refund an invoice that is not in \'Paid\' status (e.g., Pending, Voided, or already Refunded).',
    sampleMessage: 'Cannot refund invoice. Current payment state is "Pending". Only "Paid" transactions can be refunded.'
  }
};
