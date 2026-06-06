# Admin User Exclusion from Attendance & Payroll

## Problem Statement
The **admin** user is a software account used for system access, not a real employee. It should NOT appear in:
- Attendance marking lists
- Payroll generation
- HR reports

Only **real employees** should be tracked:
- ✅ Order Bookers (role = 'order_booker')
- ✅ Salesmen (role = 'salesman')
- ✅ Delivery Men (separate table)

---

## Solution Implemented ✅

### 1. **AttendanceModel.js** - Exclude Admin from Staff Lists

**File:** `web-admin-panel/src/models/AttendanceModel.js`

**Change in `getAllStaffWithAttendance()` method:**

```javascript
// BEFORE (included all users)
const users = await query(
  `SELECT id, full_name, role as staff_type, contact, base_salary
   FROM users
   WHERE is_active = 1
   ORDER BY full_name ASC`
);

// AFTER (excludes admin)
const users = await query(
  `SELECT id, full_name, role as staff_type, contact, base_salary
   FROM users
   WHERE is_active = 1 AND role != 'admin'
   ORDER BY full_name ASC`
);
```

**Impact:**
- ✅ Admin will NOT appear in daily attendance marking page (`/attendance`)
- ✅ Admin will NOT appear in attendance reports (`/attendance/report`)
- ✅ Admin will NOT be included in attendance summary calculations

---

### 2. **PayrollModel.js** - Exclude Admin from Payroll Generation

**File:** `web-admin-panel/src/models/PayrollModel.js`

**Change in `generateMonthly()` method:**

```javascript
// BEFORE (included all users with base_salary)
const users = await conn.query(
  `SELECT id, full_name, role as staff_type, base_salary
   FROM users
   WHERE is_active = 1 AND base_salary IS NOT NULL`
);

// AFTER (excludes admin even if base_salary is set)
const users = await conn.query(
  `SELECT id, full_name, role as staff_type, base_salary
   FROM users
   WHERE is_active = 1 AND base_salary IS NOT NULL AND role != 'admin'`
);
```

**Impact:**
- ✅ Admin will NOT be included when generating monthly payroll
- ✅ Even if admin has a base_salary set, no payroll record will be created
- ✅ Payroll dashboard will only show real employees

---

## How It Works

### User Form Behavior
- Admin users **can still have** a `base_salary` field filled in (in case you need it for other purposes)
- However, the system will **automatically ignore** admin users in:
  - Attendance marking
  - Attendance reports
  - Payroll generation

### Database Query Filter
All staff-fetching queries now include:
```sql
WHERE role != 'admin'
```

This ensures admin is excluded at the **database level**, making the system robust and preventing any accidental inclusion.

---

## Verification

After running migration 020 and testing:

### ✅ Test 1: Attendance Marking Page
1. Navigate to `/attendance`
2. **Expected:** Only Order Bookers, Salesmen, and Delivery Men appear in the list
3. **Expected:** Admin user is NOT in the list

### ✅ Test 2: Attendance Report
1. Navigate to `/attendance/report`
2. Select any month/year
3. **Expected:** Admin does not appear in the report table

### ✅ Test 3: Payroll Generation
1. Navigate to `/payroll`
2. Click "Generate Payroll" for current month
3. **Expected:** Only real employees (Order Bookers, Salesmen, Delivery Men) are included
4. **Expected:** Admin is NOT included, even if base_salary is set

---

## Alternative: User Type Flag (Not Implemented)

If you want more flexibility in the future, you could add a `is_system_user` flag to the users table:

```sql
ALTER TABLE users ADD COLUMN is_system_user TINYINT(1) DEFAULT 0;
UPDATE users SET is_system_user = 1 WHERE role = 'admin';
```

Then filter queries with:
```sql
WHERE is_active = 1 AND is_system_user = 0
```

This approach allows you to mark other system accounts (bots, automated processes) as non-employees.

**Current implementation is simpler and sufficient for now** since only admin is a system account.

---

## Summary

| Feature | Before | After |
|---------|--------|-------|
| Attendance List | Included admin | ✅ Excludes admin |
| Attendance Reports | Included admin | ✅ Excludes admin |
| Payroll Generation | Included admin | ✅ Excludes admin |
| User Form | No base_salary field | ✅ Has base_salary field |
| Admin base_salary | N/A | Can be set but ignored |

**Status:** ✅ Complete  
**Files Modified:** 2 (AttendanceModel.js, PayrollModel.js)  
**Database Changes:** None required (logic-level exclusion)

---

## Files Modified in This Update

✅ `web-admin-panel/src/models/AttendanceModel.js` - Added `AND role != 'admin'` filter
✅ `web-admin-panel/src/models/PayrollModel.js` - Added `AND role != 'admin'` filter

**No migration needed** - this is a logic-level change only.
