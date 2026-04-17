# Print All Open Bills - Updated to 2 Bills Per Page

## Summary
Updated the "Print All Open Bills" functionality to display 2 bills per page in a single PDF, separated by a dashed divider line.

## Changes Made

### 1. Updated PDF Generator
**File:** `web-admin-panel/src/utils/pdfGenerator.js`

#### New Features:
- **2 Bills Per Page**: Each A4 page now contains 2 bills (top and bottom half)
- **Dashed Divider**: A dashed line separates the two bills on each page
- **SalesFlo Header Format**: Uses the same header layout as individual bill prints
- **Compact Layout**: Optimized spacing to fit 2 complete bills per page
- **Item Limit**: Shows up to 8 items per bill (with "...and X more items" if exceeded)

#### Layout Structure:
```
┌─────────────────────────────────────┐
│         Bill 1 (Top Half)           │
│  - Distributor Info (Left)          │
│  - Invoice Info (Right)             │
│  - Items Table                      │
│  - Totals                           │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤ (Dashed Divider)
│         Bill 2 (Bottom Half)        │
│  - Distributor Info (Left)          │
│  - Invoice Info (Right)             │
│  - Items Table                      │
│  - Totals                           │
└─────────────────────────────────────┘
```

#### Header Format (Same as Individual Bills):
**Left Side:**
- Company Name (underlined)
- Address
- N.T.N No
- Sales Tax #
- CNIC #
- M/S (Shop Name)
- Address (Shop Address)

**Right Side:**
- "CASH MEMO / INVOICE"
- Invoice No #
- Date/Day (formatted as "14 April 2026/Tuesday")
- Route
- Sales Tax No: Not Available
- N.T.N No: Not Available

### 2. Updated Database Query
**File:** `web-admin-panel/src/models/OrderModel.js`

Modified `listOpenBills()` method to fetch:
- `s.address AS shop_address` - Shop address for header
- `r.name AS route_name` - Route name for header

### 3. Font Sizes (Optimized for 2 per page):
- Company Name: 11pt (Bold, Underlined)
- Header Info: 7pt
- Invoice Title: 10pt (Bold)
- Table Headers: 7pt (Bold)
- Table Items: 6pt
- Totals: 7pt (Bold)
- Outstanding: 8pt (Bold)

## How It Works

### Bill Rendering Logic:
1. **Calculate Page Layout**:
   - A4 page height: 842 points
   - Each bill gets: (842 - 60) / 2 = 391 points
   - Divider at: 421 points from top

2. **Bill Positioning**:
   - Bill 1, 3, 5, ... → Top half (Y = 30)
   - Bill 2, 4, 6, ... → Bottom half (Y = 441)

3. **Page Management**:
   - New page added after every 2 bills
   - Divider drawn between bills (except last bill on page)

4. **Item Overflow**:
   - Maximum 8 items shown per bill
   - If more items exist, shows "...and X more items"

## Usage

### From Web Panel:
1. Navigate to **Orders → Converted Bills**
2. Click **"Print All Open Bills"** button
3. PDF will download with all open bills (2 per page)

### What Gets Included:
- All bills with `outstanding_amount > 0`
- Ordered by bill date (newest first)
- Complete bill details with items and totals

## Files Modified

1. `web-admin-panel/src/utils/pdfGenerator.js` (MODIFIED)
   - Completely rewrote `generateOpenBillsPDF()` function
   - Added 2-per-page layout logic
   - Added SalesFlo header format
   - Added dashed divider

2. `web-admin-panel/src/models/OrderModel.js` (MODIFIED)
   - Updated `listOpenBills()` query
   - Added shop_address and route_name fields

## Testing Checklist

- [ ] Restart server
- [ ] Create/ensure there are open bills (bills with outstanding amount)
- [ ] Click "Print All Open Bills" button
- [ ] Verify PDF downloads
- [ ] Check that 2 bills appear per page
- [ ] Verify dashed divider line between bills
- [ ] Verify header format matches individual bill print
- [ ] Verify all bill information displays correctly
- [ ] Test with odd number of bills (last page has 1 bill)
- [ ] Test with bills having many items (should show "...and X more")
- [ ] Verify date format is "DD Month YYYY/Weekday"

## Example Output

### Page 1:
```
┌──────────────────────────────────────────────┐
│ Shakeel Traders (Khurian Wala)              │
│ Address, NTN, Sales Tax, CNIC                │
│ M/S: Shop Name 1                             │
│                                              │
│ Items Table (up to 8 items)                 │
│ Totals: Gross, Net, Outstanding             │
├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
│ Shakeel Traders (Khurian Wala)              │
│ Address, NTN, Sales Tax, CNIC                │
│ M/S: Shop Name 2                             │
│                                              │
│ Items Table (up to 8 items)                 │
│ Totals: Gross, Net, Outstanding             │
└──────────────────────────────────────────────┘
```

### Page 2:
```
(Bills 3 and 4 in same format)
```

## Benefits

1. **Paper Saving**: Reduces paper usage by 50%
2. **Easier Distribution**: Delivery staff can carry fewer pages
3. **Professional Look**: Consistent with SalesFlo format
4. **Quick Overview**: See multiple bills at a glance
5. **Compact**: Fits more information in less space

## Notes

- The divider is a dashed line for easy cutting if needed
- Font sizes are optimized for readability at 2-per-page
- If a bill has more than 8 items, remaining items are indicated with "...and X more items"
- The layout automatically handles odd numbers of bills (last page will have 1 bill)
- All company profile fields (Sales Tax, CNIC) must be filled for complete header display
