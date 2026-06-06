# Enable Payroll Feature - Admin Control for Attendance & Payroll

## Overview

Added a new `enable_payroll` checkbox field that allows admins to **selectively control** which users appear in:
- ✅ Daily attendance marking
- ✅ Attendance reports  
- ✅ Monthly payroll generation

This gives admins **complete control** over who is tracked in the HR & Payroll system.

---

## What Changed

### 1. **Database Migration Updated**
**File:** `web-admin-panel/src/db/migrations/020_attendance_holidays.sql`

**Added:**
```sql
-- Add enable_payroll field to users table
ALTER TABLE `users`
ADD COLUMN `enable_payroll` TINYINT(1) NOT NULL DEFAULT 1 
COMMENT '1=Include in attendance/payroll, 0=Exclude (e.g., admin/system users)';

-- Set admin users to NOT appear in payroll by default
UPDATE `users` SET `enable_payroll` = 0 WHERE `role` = 'admin';
```

**What it does:**
- Adds `enable_payroll` column (defaults to `1` = enabled)
- Automatically sets `enable_payroll = 0` for existing admin users
- New users default to enabled (except admins)

---

### 2. **User Form Updated**
**File:** `web-admin-panel/src/views/users/form.ejs`

**Added checkbox field:**
```html
<div class="mb-3">
  <div class="form-check">
    <input type="checkbox" class="form-check-input" id="enable_payroll" 
           name="enable_payroll" value="1" 
           <%= isEdit && user.enable_payroll == 1 ? 'checked' : (!isEdit && role !== 'admin' ? 'checked' : '') %>>
    <label class="form-check-label" for="enable_payroll">
      <strong>Include in Attendance & Payroll</strong>
    </label>
  </div>
  <div style="font-size:0.75rem;color:var(--text-muted);margin-top:4px;">
    Check this box to include this user in daily attendance marking and monthly payroll generation. 
    <span style="color:#EF4444;">Uncheck for system/software accounts.</span>
  </div>
</div>
```

**Behavior:**
- **New Order Bookers/Salesmen**: Checkbox is **checked by default**
- **New Admin**: Checkbox is **unchecked by default**
- **Editing existing user**: Shows current `enable_payroll` value from database

---

### 3. **UserController Updated**
**File:** `web-admin-panel/src/controllers/UserController.js`

**Updated `create()` method:**
```javascript
const { full_name, username, password, contact, role, base_salary, enable_payroll } = req.body;
await UserModel.create({ 
  full_name, username, password, contact, role, 
  base_salary: base_salary || null,
  enable_payroll: enable_payroll === '1' ? 1 : 0  // Converts checkbox value to 0 or 1
});
```

**Updated `update()` method:**
```javascript
const { full_name, username, password, contact, base_salary, enable_payroll } = req.body;
await UserModel.update(req.params.id, { 
  full_name, username, password, contact, 
  base_salary: base_salary || null,
  enable_payroll: enable_payroll === '1' ? 1 : 0  // Converts checkbox value to 0 or 1
});
```

---

### 4. **UserModel Updated**
**File:** `web-admin-panel/src/models/UserModel.js`

**Updated `findById()`:**
```javascript
'SELECT id, full_name, username, contact, role, base_salary, enable_payroll, is_active 
 FROM users WHERE id = ? LIMIT 1'
```

**Updated `create()`:**
```javascript
'INSERT INTO users (full_name, username, password_hash, role, contact, base_salary, enable_payroll) 
 VALUES (?, ?, ?, ?, ?, ?, ?)'
```

**Updated `update()`:**
```javascript
const fields = ['full_name = ?', 'username = ?', 'contact = ?', 'base_salary = ?', 'enable_payroll = ?'];
const params = [data.full_name, data.username, data.contact || null, data.base_salary || null, 
                data.enable_payroll !== undefined ? data.enable_payroll : 1];
```

---

### 5. **AttendanceModel Updated**
**File:** `web-admin-panel/src/models/AttendanceModel.js`

**Updated `getAllStaffWithAttendance()` method:**
```javascript
// Before: WHERE is_active = 1
// After: WHERE is_active = 1 AND enable_payroll = 1

const users = await query(
  `SELECT id, full_name, role as staff_type, contact, base_salary
   FROM users
   WHERE is_active = 1 AND enable_payroll = 1  // ← FILTER ADDED
   ORDER BY full_name ASC`
);
```

**Impact:**
- Only users with `enable_payroll = 1` appear in attendance marking
- Admin users (or any user with checkbox unchecked) are excluded

---

### 6. **PayrollModel Updated**
**File:** `web-admin-panel/src/models/PayrollModel.js`

**Updated `generateMonthly()` method:**
```javascript
// Before: WHERE is_active = 1 AND base_salary IS NOT NULL
// After: WHERE is_active = 1 AND base_salary IS NOT NULL AND enable_payroll = 1

const users = await conn.query(
  `SELECT id, full_name, role as staff_type, base_salary
   FROM users
   WHERE is_active = 1 AND base_salary IS NOT NULL AND enable_payroll = 1  // ← FILTER ADDED`
);
```

**Impact:**
- Only users with `enable_payroll = 1` are included in payroll generation
- Admin (or any user with checkbox unchecked) will NOT have payroll records created

---

## How It Works

### Default Behavior

| User Role | New User Default | Reason |
|-----------|------------------|--------|
| Admin | ❌ Unchecked (`enable_payroll = 0`) | Software account, not a real employee |
| Order Booker | ✅ Checked (`enable_payroll = 1`) | Real employee |
| Salesman | ✅ Checked (`enable_payroll = 1`) | Real employee |

### Admin Control

**Scenario 1: Exclude a specific user** (e.g., consultant, temporary software account)
1. Go to `/users`
2. Edit the user
3. **Uncheck** "Include in Attendance & Payroll"
4. Save
5. ✅ User will NO LONGER appear in attendance/payroll

**Scenario 2: Include admin in payroll** (e.g., admin is also a real employee)
1. Go to `/users`
2. Edit admin user
3. **Check** "Include in Attendance & Payroll"
4. Set base_salary (e.g., 50000)
5. Save
6. ✅ Admin will NOW appear in attendance/payroll

---

## Testing Checklist

### ✅ Test 1: Create New User
1. Navigate to `/users`
2. Click "Add User" (Order Booker or Salesman)
3. **Expected:** "Include in Attendance & Payroll" checkbox is **checked by default**
4. Fill form and create user
5. Navigate to `/attendance`
6. **Expected:** New user appears in the attendance list

### ✅ Test 2: Create New Admin
1. Navigate to `/users`
2. Manually create an admin user (if form allows, or via SQL)
3. **Expected:** "Include in Attendance & Payroll" checkbox is **unchecked by default**
4. Create the admin user
5. Navigate to `/attendance`
6. **Expected:** Admin does NOT appear in the attendance list

### ✅ Test 3: Exclude Existing User
1. Navigate to `/users`
2. Edit an existing Order Booker
3. **Uncheck** "Include in Attendance & Payroll"
4. Save
5. Navigate to `/attendance`
6. **Expected:** User NO LONGER appears in attendance list

### ✅ Test 4: Include Admin in Payroll
1. Navigate to `/users`
2. Edit admin user
3. **Check** "Include in Attendance & Payroll"
4. Set base_salary to 50000
5. Save
6. Navigate to `/attendance`
7. **Expected:** Admin NOW appears in attendance list
8. Navigate to `/payroll` and generate payroll
9. **Expected:** Admin has a payroll record

### ✅ Test 5: Payroll Generation
1. Mark attendance for several users (some with enable_payroll=1, some with enable_payroll=0)
2. Navigate to `/payroll`
3. Click "Generate Payroll"
4. **Expected:** Only users with `enable_payroll = 1` have payroll records created

---

## Migration Instructions

### Step 1: Run Updated Migration
```bash
cd web-admin-panel
npm run migrate
```

This will:
- Add `base_salary` column to users
- Add `enable_payroll` column to users (default = 1)
- Set `enable_payroll = 0` for all admin users automatically
- Create holidays, attendance, and payroll_records tables

### Step 2: Verify Database
```sql
-- Check enable_payroll column added
DESCRIBE users;

-- Check admin users have enable_payroll = 0
SELECT id, full_name, role, enable_payroll FROM users WHERE role = 'admin';

-- Check other users have enable_payroll = 1
SELECT id, full_name, role, enable_payroll FROM users WHERE role IN ('order_booker', 'salesman');
```

### Step 3: Test User Form
1. Navigate to `/users`
2. Click "Add User" 
3. Verify "Include in Attendance & Payroll" checkbox appears
4. Create a test user
5. Edit the test user
6. Verify checkbox reflects saved value

### Step 4: Test Attendance
1. Navigate to `/attendance`
2. Verify only users with `enable_payroll = 1` appear
3. Verify admin users do NOT appear (unless manually enabled)

---

## Summary

| Feature | Before | After |
|---------|--------|-------|
| Admin Control | ❌ Hard-coded role exclusion | ✅ Flexible checkbox control |
| Exclude Users | ❌ Not possible | ✅ Uncheck checkbox |
| Include Admin | ❌ Not possible | ✅ Check checkbox + set salary |
| Default Behavior | Excluded based on role | ✅ Smart defaults based on role |
| Database Field | None | ✅ `enable_payroll` column |

**Status:** ✅ Complete and Ready to Test

**Files Modified:** 6 files
1. Migration: `020_attendance_holidays.sql`
2. View: `users/form.ejs`
3. Controller: `UserController.js`
4. Model: `UserModel.js`
5. Model: `AttendanceModel.js`
6. Model: `PayrollModel.js`

**Next Step:** Run `npm run migrate` to apply the database changes.
