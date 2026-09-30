/**
 * MelodyMart - Module 6.1: User Account & Profile Management
 * Member: Perera D. A. P. W. (IT25101726)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_USER_DUPLICATE_EMAIL: {
    code: 'ERR_USER_DUPLICATE_EMAIL',
    name: 'Duplicate Email Registration Conflict',
    condition: 'Triggered when a user attempts to register with an email address that already exists in the system database.',
    sampleMessage: 'An account with email "kasun.perera@gmail.com" is already registered. Please login or use a different email.'
  },
  ERR_USER_PASSWORD_STRENGTH: {
    code: 'ERR_USER_PASSWORD_STRENGTH',
    name: 'Password Complexity Policy Violation',
    condition: 'Triggered when a password submitted during registration or profile update contains fewer than 8 characters or fails to include both alphabetic letters and numbers.',
    sampleMessage: 'Password is too weak. It must be at least 8 characters long and include both letters and numbers.'
  },
  ERR_USER_INVALID_PHONE: {
    code: 'ERR_USER_INVALID_PHONE',
    name: 'Invalid Sri Lankan Mobile Format',
    condition: 'Triggered when the provided phone number does not conform to Sri Lankan mobile telecommunication network standards (07X-XXXXXXX or +947XXXXXXXX).',
    sampleMessage: 'Invalid Sri Lankan mobile number format. Expected 07XXXXXXXX (e.g., 0771234567 or +94771234567).'
  }
};
