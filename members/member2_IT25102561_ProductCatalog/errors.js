/**
 * MelodyMart - Module 6.2: Product Catalog & Advanced Search/Filtering
 * Member: Senarathna U. G. S. P. (IT25102561)
 * Group: 2026-Y2-S1-MLB-B6G1-08 | Module: SE2030
 * 
 * Assigned Error Validations (3 Errors):
 */

module.exports = {
  ERR_PROD_INVALID_PRICE: {
    code: 'ERR_PROD_INVALID_PRICE',
    name: 'Invalid Price or Discount Boundary',
    condition: 'Triggered when retail price is non-numeric, zero, or negative, or when promotional discount price exceeds the retail price.',
    sampleMessage: 'Retail price must be greater than zero, and discount price cannot be negative or exceed the retail price.'
  },
  ERR_PROD_MISSING_SPECS: {
    code: 'ERR_PROD_MISSING_SPECS',
    name: 'Missing Mandatory Technical Specifications',
    condition: 'Triggered when adding or updating an instrument without required technical specifications (material, dimensions, pickups, voices, or tuning).',
    sampleMessage: 'Technical specifications are mandatory for musical instruments (e.g., material, dimensions, voices, or pickup setup).'
  },
  ERR_PROD_COMPARE_LIMIT: {
    code: 'ERR_PROD_COMPARE_LIMIT',
    name: 'Comparison Matrix Capacity Exceeded',
    condition: 'Triggered when a user requests a side-by-side comparison of more than 4 musical instruments concurrently.',
    sampleMessage: 'Instrument comparison is limited to a maximum of 4 instruments side-by-side.'
  }
};
