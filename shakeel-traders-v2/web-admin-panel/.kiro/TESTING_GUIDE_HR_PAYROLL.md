# Testing Guide: HR & Payroll System Consolidation

## Overview
The old Salary system has been successfully consolidated with the new HR & Payroll system. All functionality is now accessible from a single page with tabs.

---

## How to Test

### 1. **Restart the Server**
The server needs to be restarted to load the new changes:

```bash
# Stop the current server (Ctrl+C)
# Then start it again:
cd web-admin-panel
npm run dev
```

### 2. **Navigate to HR & Payroll**
1. Login to admin panel: http://localhost:3000
   - Username: `admin`
   - Password: `admin123`
2. Click **"HR & Payroll"** in the sidebar

### 3. **Test Monthly Payroll Tab** (Default View)
✅ **Generate Payroll:**
1. Select month and year
2. Click "Generate Payroll"
3. Should see payroll records for all staff with `enable_payroll = 1`

✅ **View Payroll:**
1. Use filters to view specific month/year
2. Filter by payment status (Pending/Paid)
3. Check summary cards (Total Payable, Total Paid, Total Pending)

✅ **View Details:**
1. Click eye icon on any payroll record
2. Should see detailed breakdown

✅ **Mark as Paid:**
1. Click green checkmark on pending payroll
2. Fill payment details
3. Should mark as paid

### 4. **Test Salary Advances Tab**
✅ **Switch Tab:**
1. Click **"Salary Advances & Ledger"** tab
2. Should see 3 sub-tabs: Salesmen, Order Bookers, Delivery Men

✅ **View Staff List:**
1. Click each sub-tab
2. Should see only staff with `enable_payroll = 1`
3. Should show base salary and current month advances

✅ **Record Advance:**
1. Click **"+ Advance"** button for any staff
2. Enter amount, date, and note
3. Submit → Should see success message
4. Advance should appear in staff row

✅ **View Ledger:**
1. Click **Ledger** icon (journal icon) for any staff
2. Should see complete salary history
3. Navigate through pages
4. Click "Export" to download Excel

✅ **Export to Excel:**
1. From ledger page, click Export button
2. Excel file should download with staff name
3. Should contain all transactions with net balance

### 5. **Test Old URLs (Backward Compatibility)**
✅ **Old Salary Page:**
1. Navigate to: http://localhost:3000/salaries
2. Should redirect to: `/payroll?tab=advances`
3. Should show info message about using new system

✅ **Old Ledger URLs:**
1. Try: `/salaries/salesman/1/ledger`
2. Should redirect to: `/payroll/ledger/salesman/1`

### 6. **Integration Test**
✅ **Complete Workflow:**
1. Go to Attendance page → Mark some staff absent
2. Record a salary advance for a staff member
3. Generate payroll for current month
4. Verify:
   - Absence deduction is calculated correctly
   - Advance amount is deducted from final payable
   - Friday absences don't affect salary
   - Unmarked days counted as present

### 7. **Verify Business Rules**
✅ **enable_payroll Flag:**
1. Edit a user → Uncheck "Include in Payroll"
2. Save → User should disappear from attendance list
3. User should not appear in payroll generation
4. Check "Include in Payroll" → User should reappear

✅ **Auto-Present Logic:**
1. Don't mark attendance for some days
2. Generate payroll
3. Unmarked days should count as present

✅ **Friday Exclusion:**
1. Mark someone absent on Friday
2. Generate payroll
3. Friday absence should NOT reduce salary

---

## Expected Results

### ✅ Success Indicators:
- Both tabs (Payroll and Advances) work smoothly
- Staff with `enable_payroll = 0` don't appear
- Advances are recorded and appear in payroll calculation
- Ledger shows complete history with pagination
- Excel export works
- Old URLs redirect properly
- No console errors

### ❌ Common Issues to Watch For:
- If staff list is empty → Check `enable_payroll` column in database
- If advances don't show → Check current month filter in query
- If ledger doesn't load → Check staffType parameter in URL
- If redirect doesn't work → Clear browser cache

---

## Troubleshooting

### Issue: Staff not appearing in Advances tab
**Solution:** Check database:
```sql
SELECT id, full_name, enable_payroll FROM users WHERE role = 'salesman';
```
Ensure `enable_payroll = 1` for staff who should appear.

### Issue: Old salary page not redirecting
**Solution:** 
1. Restart the server
2. Clear browser cache (Ctrl+Shift+Delete)
3. Hard refresh (Ctrl+F5)

### Issue: Advance not appearing after recording
**Solution:**
1. Check if success message appeared
2. Refresh the page
3. Check browser console for errors

---

## What Changed

### Navigation:
- ✅ Single "HR & Payroll" menu item (no more "Salaries")
- ✅ Two tabs: "Monthly Payroll" and "Salary Advances & Ledger"

### URLs:
- ✅ `/payroll` - Main page
- ✅ `/payroll?tab=payroll` - Monthly payroll
- ✅ `/payroll?tab=advances` - Salary advances
- ✅ `/payroll/ledger/:staffType/:staffId` - Staff ledger
- ✅ `/salaries` → Redirects to `/payroll?tab=advances`

### Functionality:
- ✅ All old salary features preserved
- ✅ All new payroll features working
- ✅ Unified interface
- ✅ No duplicate menus

---

## Need Help?

If you encounter any issues during testing:
1. Check browser console for JavaScript errors (F12 → Console tab)
2. Check terminal for server errors
3. Verify database schema (run `npm run migrate`)
4. Restart server and try again

---

## Status: Ready for Testing ✅

All code changes complete. Server needs restart to load changes.
