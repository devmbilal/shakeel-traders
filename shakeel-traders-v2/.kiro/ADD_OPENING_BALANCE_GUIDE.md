# Adding Opening Balance for Pre-Deployment Outstanding Bills

## Overview
This feature allows you to add outstanding bills that existed before the system was deployed. This ensures that all shop ledgers show the complete financial history including pre-deployment balances.

## How to Add Opening Balance

### Step 1: Navigate to Shop Ledger
1. Go to **Shop Management** (`/shops`)
2. Click on the shop name or "View Ledger" for the shop you want to add opening balance
3. You'll see the shop's ledger page

### Step 2: Click "Add Opening Balance" Button
- On the shop ledger page, click the yellow **"Add Opening Balance"** button
- This button is located in the top-right corner next to "Add Advance"

### Step 3: Fill in the Form
The form has the following fields:

1. **Bill Date** (Required)
   - Enter the original date of the bill (before deployment)
   - Format: YYYY-MM-DD

2. **Gross Amount** (Required)
   - Enter the total bill amount in Rs
   - This is the original amount the shop owed

3. **Amount Already Paid** (Optional, default: 0)
   - Enter any amount the shop has already paid
   - If nothing was paid, leave it as 0
   - The system will automatically calculate the outstanding amount

4. **Note** (Optional)
   - Add a reference note like "Opening balance from previous system" or "Pre-deployment outstanding"
   - Helps with record-keeping

### Step 4: Submit
- Click **"Add Opening Balance"** button
- The system will:
  - Create a bill with bill number `OPENING-{shop_id}-{timestamp}`
  - Add debit entry to shop ledger (for the bill amount)
  - Add credit entry if amount was already paid
  - Update the shop's outstanding balance
  - Set bill status:
    - `open` if no payment was made
    - `partially_paid` if some payment was made
    - `cleared` if fully paid

## What Happens After Adding

1. **Bill Record**: A new bill is created in the `bills` table with type `direct_shop`
2. **Ledger Entries**: Appropriate entries are added to `shop_ledger_entries`
3. **Outstanding Balance**: The shop's outstanding balance is updated
4. **Future Payments**: You can now record future payments against this bill normally through the cash recovery system

## Example Scenarios

### Scenario 1: Fully Outstanding Bill
- Bill Date: 2026-05-15
- Gross Amount: Rs 50,000
- Amount Paid: Rs 0
- **Result**: Rs 50,000 outstanding, bill status = `open`

### Scenario 2: Partially Paid Bill
- Bill Date: 2026-05-20
- Gross Amount: Rs 75,000
- Amount Paid: Rs 25,000
- **Result**: Rs 50,000 outstanding, bill status = `partially_paid`

### Scenario 3: Fully Paid Bill (for record keeping)
- Bill Date: 2026-05-10
- Gross Amount: Rs 30,000
- Amount Paid: Rs 30,000
- **Result**: Rs 0 outstanding, bill status = `cleared`

## Important Notes

1. **Admin Only**: Only admin users can add opening balances
2. **One-Time Entry**: This is meant for initial data migration. Don't use it for regular bills.
3. **Accurate Amounts**: Double-check amounts before submitting as this directly affects financial records
4. **Audit Trail**: All entries are logged with user ID and timestamp for audit purposes
5. **No Product Details**: Opening balance bills don't have line items (product details) - they're just for outstanding amounts

## Database Impact

### Tables Affected:
1. **bills**: New row added
2. **shop_ledger_entries**: 1-2 new rows (bill entry + optional payment entry)
3. **audit_logs**: Entry with action `ADD_OPENING_BALANCE`

### Ledger Balance Calculation:
```
Previous Balance + Bill Amount - Payment Amount = New Balance
```

## Access

**URL**: `/shops/{shop_id}/add-opening-balance`

**Permission**: Admin only

**Method**: GET (form) / POST (submit)

## Files Modified

1. `src/controllers/ShopController.js` - Added `addOpeningBalanceForm` and `addOpeningBalanceSubmit` methods
2. `src/routes/web/shops.js` - Added GET and POST routes
3. `src/views/shops/add-opening-balance.ejs` - New form view
4. `src/views/shops/ledger.ejs` - Added "Add Opening Balance" button

## Future Payments

After adding opening balance, future payments can be recorded normally:
- Through delivery man cash recovery
- Through admin recovery recording
- These will automatically update the bill status and outstanding amount
