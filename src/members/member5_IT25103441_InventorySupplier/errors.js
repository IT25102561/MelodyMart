/**
 * MelodyMart - Module 6.5: Real-Time Inventory & Supplier Management
 * Member: Premasiri R. M. R. R. (IT25103441)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_SUPP_DUPLICATE_BRN: {
    code: 'ERR_SUPP_DUPLICATE_BRN',
    name: 'Duplicate Supplier Business Registration Number',
    condition: 'Triggered when attempting to register a supplier with a Business Registration Number (BRN) already present in the database.',
    sampleMessage: 'Supplier with Business Registration Number "PV-10928/LK" is already registered in the system.'
  },
  ERR_INV_INVALID_PO_QTY: {
    code: 'ERR_INV_INVALID_PO_QTY',
    name: 'Non-Positive Purchase Order Quantity Requisition',
    condition: 'Triggered when creating a purchase order requisition with a quantity less than or equal to zero.',
    sampleMessage: 'Purchase order quantity must be greater than zero. Received: 0'
  },
  ERR_INV_NEGATIVE_STOCK_DEFICIT: {
    code: 'ERR_INV_NEGATIVE_STOCK_DEFICIT',
    name: 'Physical Stock Balance Deficit',
    condition: 'Triggered when a manual or damaged inventory adjustment causes warehouse stock to drop below zero.',
    sampleMessage: 'Stock adjustment rejected. Current stock is 4, deduction of 50 would result in negative stock balance (-46).'
  }
};
