# Bill Header Update - SalesFlo Format

## Summary
Updated the bill print header to match the SalesFlo format as shown in the provided sample invoice.

## Changes Made

### 1. Database Migration
**File:** `web-admin-panel/src/db/migrations/016_add_company_profile_fields.sql`

Added two new fields to `company_profile` table:
- `sales_tax` VARCHAR(50) - Sales Tax registration number
- `cnic` VARCHAR(20) - CNIC number of the distributor

**To run the migration:**
```sql
USE shakeel_traders;

ALTER TABLE `company_profile`
ADD COLUMN `sales_tax` VARCHAR(50) NULL DEFAULT NULL AFTER `gst_ntn`,
ADD COLUMN `cnic` VARCHAR(20) NULL DEFAULT NULL AFTER `sales_tax`;
```

### 2. Updated Print Formatter
**File:** `web-admin-panel/src/utils/printFormatter.js`

#### New Header Layout:
**Left Side (Distributor Info):**
- Company Name (underlined): "Shakeel Traders (Khurian Wala)"
- Address: From company_profile.address
- N.T.N No: From company_profile.gst_ntn
- Sales Tax #: From company_profile.sales_tax
- CNIC #: From company_profile.cnic
- M/S: Shop owner name or shop name
- Address: Shop address

**Right Side (Invoice Info):**
- Title: "CASH MEMO / INVOICE"
- Invoice No #: Bill number
- Date/Day: Formatted as "14 April 2026/Tuesday"
- Route: Route name
- Sales Tax No: "Not Available" (hardcoded for shop)
- N.T.N No: "Not Available" (hardcoded for shop)

### 3. Updated Database Query
**File:** `web-admin-panel/src/models/OrderModel.js`

Modified `findBillById()` method to fetch:
- `s.owner_name AS shop_owner_name` - Shop owner name
- `s.address AS shop_address` - Shop address
- `cp.sales_tax` - Company sales tax number
- `cp.cnic` - Company CNIC number

### 4. Updated Company Profile Form
**File:** `web-admin-panel/src/views/company-profile/index.ejs`

Added two new input fields:
- Sales Tax Number (with hash icon)
- CNIC Number (with person-badge icon)

### 5. Updated Company Profile Controller
**File:** `web-admin-panel/src/controllers/CompanyProfileController.js`

Modified `saveProfile()` method to save:
- `sales_tax` field
- `cnic` field

## Date Format
The bill now displays dates in the exact format shown in the sample:
- Format: "14 April 2026/Tuesday"
- Example: "14 April 2026/Tuesday"

## How to Use

### Step 1: Run the Database Migration
Execute the SQL migration to add the new fields to the company_profile table.

### Step 2: Update Company Profile
1. Navigate to **Company Profile** page in the web panel
2. Fill in the new fields:
   - **Sales Tax Number**: Your sales tax registration number
   - **CNIC Number**: Your CNIC in format xxxxx-xxxxxxx-x
3. Click **Save Profile**

### Step 3: Print Bills
Print any bill using the existing print button. The new header format will automatically be used.

## Field Mapping

### Distributor Information (from company_profile table):
| Field in Bill | Database Source |
|--------------|-----------------|
| Company Name | company_profile.company_name |
| Address | company_profile.address |
| N.T.N No | company_profile.gst_ntn |
| Sales Tax # | company_profile.sales_tax |
| CNIC # | company_profile.cnic |

### Shop Information (from shops table):
| Field in Bill | Database Source |
|--------------|-----------------|
| M/S | shops.owner_name or shops.name |
| Address | shops.address |
| Sales Tax No | "Not Available" (hardcoded) |
| N.T.N No | "Not Available" (hardcoded) |

### Invoice Information:
| Field in Bill | Database Source |
|--------------|-----------------|
| Invoice No # | bills.bill_number |
| Date/Day | bills.bill_date (formatted) |
| Route | routes.name |

## Files Modified

1. `web-admin-panel/src/db/migrations/016_add_company_profile_fields.sql` (NEW)
2. `web-admin-panel/src/utils/printFormatter.js` (MODIFIED)
3. `web-admin-panel/src/models/OrderModel.js` (MODIFIED)
4. `web-admin-panel/src/views/company-profile/index.ejs` (MODIFIED)
5. `web-admin-panel/src/controllers/CompanyProfileController.js` (MODIFIED)

## Testing Checklist

- [ ] Run database migration successfully
- [ ] Update company profile with Sales Tax and CNIC
- [ ] Print an Order Booker bill - verify header shows correctly
- [ ] Print a Direct Shop Sale bill - verify header shows correctly
- [ ] Verify distributor info displays correctly (left side)
- [ ] Verify shop info displays correctly (M/S and Address)
- [ ] Verify invoice info displays correctly (right side)
- [ ] Verify date format is "DD Month YYYY/Weekday"
- [ ] Verify "Not Available" shows for missing fields
- [ ] Test with missing company profile fields (should show "Not Available")

## Notes

- Shop Sales Tax and N.T.N are hardcoded as "Not Available" as per requirements
- If any company profile field is missing, it will display "Not Available"
- The header layout matches the SalesFlo format exactly as shown in the sample
- All existing functionality remains unchanged
- The same print button is used - no separate SalesFlo format option needed
