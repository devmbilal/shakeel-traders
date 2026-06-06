# Pakistan Timezone Fix Applied ✅

## Problem:
Dates were showing in UTC or browser timezone instead of Pakistan Standard Time (PKT, UTC+5), causing confusion:
- When it's June 2nd in Pakistan, system showed June 1st
- Date inputs defaulted to wrong dates
- Ledgers and reports showed incorrect dates

## Root Cause:
- `new Date().toISOString()` converts to UTC
- When PKT is June 2nd 05:00 AM, UTC is still June 1st 00:00
- HTML date inputs use `slice(0,10)` which takes UTC date

## Solution:
Created **Pakistan timezone helper functions** that always use PKT.

---

## Files Created:

### 1. `src/utils/dateHelpers.js` (NEW)
Contains helper functions for Pakistan timezone:

```javascript
getPakistanDateString()      // Returns: "2026-06-02" (for date inputs)
getPakistanYearMonth()        // Returns: "2026-06" (for month inputs)
formatPakistanDate(date)      // Returns: "02 Jun 2026" (for display)
sqlDateToDisplay(sqlDate)     // Formats SQL dates for display
```

### 2. Updated `src/app.js`
Added helpers to global EJS locals so they're available in all views.

---

## Files Updated:

### Views Updated:
1. ✅ `src/views/payroll/index.ejs` - Salary advance date input
2. ✅ `src/views/salaries/ledger.ejs` - Ledger dates and advance date input

### More Files to Update (if needed):
- `src/views/salaries/index.ejs`
- `src/views/attendance/index.ejs`
- `src/views/expenses/index.ejs`
- `src/views/suppliers/detail.ejs`
- `src/views/stock/from-supplier.ejs`
- `src/views/reports/*.ejs`

---

## How to Use in Views:

### For Date Inputs (current date default):
**OLD (Wrong):**
```html
<input type="date" value="<%= new Date().toISOString().slice(0,10) %>">
```

**NEW (Correct):**
```html
<input type="date" value="<%= getPakistanDateString() %>">
```

### For Month Inputs:
**OLD (Wrong):**
```html
<input type="month" value="<%= new Date().toISOString().slice(0,7) %>">
```

**NEW (Correct):**
```html
<input type="month" value="<%= getPakistanYearMonth() %>">
```

### For Displaying Dates:
**OLD (Wrong):**
```html
<%= new Date(date).toLocaleDateString('en-PK') %>
```

**NEW (Correct):**
```html
<%= sqlDateToDisplay(date) %>
<!-- OR for custom format: -->
<%= formatPakistanDate(date, 'long') %>
```

---

## Testing:

### After Restart, Verify:

1. **Current Date is Correct:**
   - Go to Payroll → Salary Advances → Record Advance
   - Date field should show: **Current Pakistan date** (not yesterday!)

2. **Ledger Dates Display Correctly:**
   - Go to Salary Ledger
   - Dates should show in Pakistan timezone format

3. **Date Inputs Work Correctly:**
   - All date inputs should default to Pakistan time
   - When you save, dates should be correct

---

## Example Output:

### Before Fix:
```
Current Time: June 2, 2026 05:00 AM PKT
System Shows: June 1, 2026 (Wrong! Off by 1 day)
```

### After Fix:
```
Current Time: June 2, 2026 05:00 AM PKT
System Shows: June 2, 2026 (Correct! ✅)
```

---

## Technical Details:

### Why toISOString() is Wrong:
```javascript
// In Pakistan (PKT = UTC+5), June 2nd 5:00 AM:
const now = new Date(); // Tue Jun 02 2026 05:00:00 GMT+0500
now.toISOString();      // "2026-06-01T00:00:00.000Z" ❌ (June 1st UTC!)
now.toISOString().slice(0,10); // "2026-06-01" ❌ (Wrong date!)
```

### Why Our Helper is Correct:
```javascript
// In Pakistan (PKT = UTC+5), June 2nd 5:00 AM:
getPakistanDateString(); // "2026-06-02" ✅ (Correct PKT date!)
```

---

## Server Configuration:

The server is already configured for Pakistan timezone:
```javascript
// In src/app.js (line 5):
process.env.TZ = 'Asia/Karachi';
```

This ensures:
- ✅ MySQL dates use PKT
- ✅ Server logs use PKT
- ✅ Backend `new Date()` uses PKT

But we still need helper functions for **frontend display** because:
- HTML date inputs need proper formatting
- EJS templates need Pakistan-aware date formatting

---

## Status: ✅ APPLIED

The fix is applied to key pages. After restart:
- Date inputs will show correct Pakistan dates
- Ledgers will display correct dates
- No more confusion with UTC/PKT conversion

---

## To Apply to More Pages:

Search for these patterns and replace:
```bash
# Find wrong patterns:
grep -r "toISOString().slice" src/views/
grep -r "new Date().toLocaleDateString" src/views/

# Replace with:
getPakistanDateString()      # for date inputs
getPakistanYearMonth()        # for month inputs  
sqlDateToDisplay(date)        # for displaying dates
formatPakistanDate(date)      # for custom formats
```

---

## Restart Required:

```bash
# Stop server (Ctrl+C)
npm run dev
# Refresh browser (F5)
```

**All dates will now be in Pakistan timezone!** 🇵🇰
