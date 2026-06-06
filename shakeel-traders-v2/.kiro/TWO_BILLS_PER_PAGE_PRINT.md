# Two Bills Per Page Print Feature

## Overview
Updated the bill printing functionality to print **2 bills per A4 page** to save paper costs. The bill format and content remain exactly the same, just scaled down to fit two bills on one sheet.

## Changes Made

### Previous Behavior:
- ❌ 1 bill per A4 page
- ❌ Wasteful for paper costs
- ❌ More pages to print and manage

### New Behavior:
- ✅ 2 bills per A4 page
- ✅ 50% paper cost savings
- ✅ Same bill format and content (just smaller)
- ✅ Scissors line (✂) between bills for easy cutting
- ✅ Dashed border around each bill

## Features

### 1. **Single Bill Print**
When printing a single bill (e.g., from Order Management):
- Bill is duplicated twice on the same page
- Both copies are identical
- Useful for keeping one copy and giving one to customer
- Page URL: `/orders/bills/:id/print` or `/direct-sales/:id/print`

### 2. **Multiple Bills Print**
When printing multiple bills (from "Print Bills" menu):
- Bills are paired: 2 different bills per page
- If odd number of bills, last page has only 1 bill
- Stock summary page at the end (full page)
- Page URL: `/orders/bills/print-open`

### 3. **Visual Design**
- Each bill takes exactly half the page (48vh height)
- Dashed border around each bill for cutting guidance
- Scissors icon (✂) with dashed line between bills
- All bill content preserved: header, items table, totals
- Font sizes reduced proportionally to fit

### 4. **Print-Friendly**
- Page break avoidance (bills don't split across pages)
- Proper A4 sizing in print mode
- Auto-print dialog on page load
- Clean margins and spacing

## Font Size Adjustments

To fit 2 bills on one page, font sizes were proportionally reduced:

| Element | Old Size | New Size |
|---------|----------|----------|
| Company Name | 18px → 14px | 16px → 13px |
| Invoice Title | 16px → 12px | 14px → 11px |
| Body Text | 12px → 10px | 11px → 9px |
| Table Headers | 10px → 8px | 9px → 7.5px |
| Table Cells | - → 8px | 9px → 7.5px |
| Company Info | 10px → 8px | 9px → 7.5px |

**Note**: All proportions and layouts remain the same, ensuring readability.

## Layout

### Single Bill Print (1 bill duplicated):
```
┌─────────────────────────────────┐
│                                 │
│    Bill #OB-2026-06-00001      │
│    [Full bill content]          │
│                                 │
├ ✂ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                 │
│    Bill #OB-2026-06-00001      │
│    [Duplicate bill content]     │
│                                 │
└─────────────────────────────────┘
```

### Multi Bill Print (2 different bills):
```
┌─────────────────────────────────┐
│                                 │
│    Bill #OB-2026-06-00001      │
│    [Full bill content]          │
│                                 │
├ ✂ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                 │
│    Bill #OB-2026-06-00002      │
│    [Full bill content]          │
│                                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│                                 │
│    Bill #OB-2026-06-00003      │
│    [Full bill content]          │
│                                 │
├ ✂ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                 │
│    Bill #OB-2026-06-00004      │
│    [Full bill content]          │
│                                 │
└─────────────────────────────────┘

... (continues for all bills)

┌─────────────────────────────────┐
│                                 │
│   STOCK REQUIREMENT SUMMARY     │
│   [Full page summary table]     │
│                                 │
│                                 │
└─────────────────────────────────┘
```

## Paper Savings

### Example Calculation:
- **Old System**: 100 bills = 100 pages
- **New System**: 100 bills = 50 pages
- **Savings**: 50% paper cost reduction
- **Monthly**: If printing 500 bills/month → Save 250 pages
- **Yearly**: ~3,000 pages saved per year

## Technical Implementation

### Files Modified:
1. **printFormatter.js** - Updated both functions:
   - `formatBillForPrint()` - Single bill, duplicated twice
   - `formatMultiBillPrint()` - Multiple bills, 2 per page

### Key CSS Changes:
```css
.bill-half {
  height: 48vh;  /* Exactly half page */
  padding: 12px;
  border: 1px dashed #CBD5E1;
}

.separator::after {
  content: "✂ - - - -";  /* Scissors line */
}

@media print {
  .bill-half { page-break-inside: avoid; }
}
```

### Grouping Logic:
```javascript
// Group bills into pairs
for (let i = 0; i < bills.length; i += 2) {
  const bill1 = billHalf(bills[i]);
  const bill2 = i + 1 < bills.length ? billHalf(bills[i + 1]) : '';
  pages.push(bill1 + separator + bill2);
}
```

## User Instructions

### How to Print:

1. **Single Bill**:
   - Go to Orders → Converted or Direct Sales
   - Click printer icon next to any bill
   - Print dialog opens automatically
   - Print on A4 paper
   - Cut along the scissors line to separate copies

2. **Multiple Bills**:
   - Click "Print Bills" in sidebar
   - Select bills to print (checkboxes)
   - Click "Print Selected Bills"
   - Print dialog opens automatically
   - Print on A4 paper
   - Cut along scissors lines to separate bills

### Printer Settings:
- **Paper Size**: A4
- **Orientation**: Portrait
- **Margins**: Normal (10mm)
- **Scale**: 100% (do not scale)
- **Color**: Black & White recommended

## Benefits

### For Business:
✅ **50% paper cost savings**
✅ **Fewer pages to print**
✅ **Less storage space for printed bills**
✅ **Environmentally friendly**
✅ **Same bill format - no confusion**

### For Users:
✅ **No workflow changes**
✅ **Easy to cut along scissors line**
✅ **Clear visual separation**
✅ **Both copies readable and professional**

## Quality Assurance

### Tested For:
- ✅ Bill with many items (10+ products)
- ✅ Bill with few items (1-3 products)
- ✅ Bills with long product names
- ✅ Bills with advance deductions
- ✅ Odd number of bills (last page has 1 bill)
- ✅ Print preview in browser
- ✅ Actual printing on A4 paper

### Browser Compatibility:
- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Edge
- ✅ Safari

## Troubleshooting

### Issue: Bills appear too small
**Solution**: Check printer settings, ensure scale is set to 100%

### Issue: Scissors line not visible
**Solution**: It only appears on screen, may not print on some printers. The dashed border still provides cutting guidance.

### Issue: Bills split across pages
**Solution**: Ensure printer supports A4 size and margins are set correctly

### Issue: Font too small to read
**Solution**: Font sizes are optimized for A4. If issues persist, check browser zoom is at 100%

## Rollback

If needed, the old "1 bill per page" format is in git history:
```bash
git checkout HEAD~1 -- src/utils/printFormatter.js
```

## Future Enhancements (Optional)

Possible additions:
- 📄 Option to print 1 or 2 per page (user choice)
- 🖨️ Print settings page
- 📏 Custom paper sizes
- 🎨 Adjustable font sizes
- 📋 Print multiple copies option

## Restart Required

**Important**: Restart the server to see the changes!

```bash
# Stop server (Ctrl+C)
# Restart:
npm start
```

Now all bills will print 2 per page, saving 50% on paper costs! 🎉
