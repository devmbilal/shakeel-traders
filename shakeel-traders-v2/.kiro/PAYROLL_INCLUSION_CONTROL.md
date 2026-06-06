# Payroll Inclusion Control - Admin Configuration

## ✅ FEATURE COMPLETE

Admin now has **full control** over which users appear in attendance and payroll systems through a checkbox in the user form.

---

## How It Works

### 1. **Database Field: `enable_payroll`**

**Added to `users` table:**
```sql
ALTER TABLE `users`
ADD COLUMN `enable_payroll` TINYINT(1) NOT NULL DEFAULT 1 
COMMENT '1=Include in attendance/payroll, 0=Exclude (e.g., admin/system users)';
```

**Default Values:**
- ✅ New users: `enable_payroll = 1` (INCLUDED by default)
- ⛔ Admin users: `enable_payroll = 0` (EXCLUDED by default - set during migration)
- ✅ Order Bookers: `enable_payroll = 1` (INCLUDED by default)
- ✅ Salesmen: `enable_payroll = 1` (INCLUDED by default)

**Admin can change this for ANY user at ANY time.**

---

### 2. **User Form Checkbox**

**File:** `web-admin-panel/src/views/users/form.ejs`

```html
<div class="form-check">
  <input type="checkbox" class="form-check-input" id="enable_payroll" 
         name="enable_payroll" value="1" 
         <%= isEdit && user.enable_payroll == 1 ? 'checked' : 
             (!isEdit && role !== 'admin' ? 'checked' : '') %>>
  <label class="form-check-label" for="enable_payroll">
    <strong>Include in Attendance & Payroll</strong>
  </label>
</div>
<div style="font-size:0.75rem;color:var(--text-muted);margin-top:4px;">
  Check this box to include this user in daily attendance marking and monthly payroll generation. 
  <span style="color:#EF4444;">Uncheck for system/software accounts.</span>
</div>
```

**Behavior:**
- ✅ **New Order Booker/Salesman**: Checkbox is **CHECKED** by default
- ⛔ **New Admin**: Checkbox is **UNCHECKED** by default
- ✅ **Edit existing user**: Shows current `enable_payroll` value
- ✅ **Admin can toggle** for any user at any time

---

### 3. **Attendance System - Filtered by `enable_payroll`**

**File:** `web-admin-panel/src/models/AttendanceModel.js`

```javascript
async getAllStaffWithAttendance(date) {
  // Only users with enable_payroll = 1 appear
  const users = await query(
    `SELECT id, full_name, role as staff_type, contact, base_salary
     FROM users
     WHERE is_active = 1 AND enable_payroll = 1
     ORDER BY full_name ASC`
  );
  
  // Delivery men always included (no enable_payroll field)
  const deliveryMen = await query(
    `SELECT id, full_name, 'delivery_man' as staff_type, contact, base_salary
     FROM delivery_men
     WHERE is_active = 1
     ORDER BY full_name ASC`
  );
  
  return [...users, ...deliveryMen];
}
```

**Impact:**
- ✅ Only users with `enable_payroll = 1` appear in `/attendance` marking page
- ✅ Only users with `enable_payroll = 1` appear in `/attendance/report`
- ⛔ Admin users (enable_payroll = 0) are automatically excluded

---

### 4. **Payroll System - Filtered by `enable_payroll`**

**File:** `web-admin-panel/src/models/PayrollModel.js`

```javascript
async generateMonthly(month, year, generatedBy) {
  // Only users with enable_payroll = 1 AND base_salary set
  const users = await conn.query(
    `SELECT id, full_name, role as staff_type, base_salary
     FROM users
     WHERE is_active = 1 
       AND base_salary IS NOT NULL 
       AND enable_payroll = 1`
  );
  
  // Delivery men with base_salary
  const deliveryMen = await conn.query(
    `SELECT id, full_name, 'delivery_man' as staff_type, base_salary
     FROM delivery_men
     WHERE is_active = 1 AND base_salary IS NOT NULL`
  );
  
  return [...users[0], ...deliveryMen[0]];
}
```

**Impact:**
- ✅ Only users with `enable_payroll = 1` AND `base_salary != NULL` are included in payroll generation
- ⛔ Admin users (enable_payroll = 0) are automatically excluded, even if they have base_salary set
- ⛔ Users without base_salary are excluded (no salary = no payroll)

---

## Use Cases

### ✅ Use Case 1: Admin User (Software Account)
**Scenario:** Admin is a system account, not a real person.

**Configuration:**
- Role: `admin`
- Base Salary: Leave empty or set to 0
- **Enable Payroll: ⛔ UNCHECKED** (default for admin)

**Result:**
- ⛔ Does NOT appear in attendance marking
- ⛔ Does NOT appear in payroll generation
- ✅ Can still log in and manage the system

---

### ✅ Use Case 2: Order Booker (Real Employee)
**Scenario:** Order booker is a real employee with salary.

**Configuration:**
- Role: `order_booker`
- Base Salary: `25000.00`
- **Enable Payroll: ✅ CHECKED** (default for non-admin)

**Result:**
- ✅ Appears in attendance marking (`/attendance`)
- ✅ Appears in payroll generation (`/payroll`)
- ✅ Monthly salary calculated with attendance deductions

---

### ✅ Use Case 3: Special Admin with Salary
**Scenario:** You want to pay a special admin user (e.g., IT manager who also manages the system).

**Configuration:**
- Role: `admin`
- Base Salary: `40000.00`
- **Enable Payroll: ✅ CHECKED** (manually enabled)

**Result:**
- ✅ Can log in and manage system
- ✅ Appears in attendance marking
- ✅ Appears in payroll generation
- ✅ Gets monthly salary with attendance tracking

---

### ✅ Use Case 4: Salesman with No Attendance Tracking
**Scenario:** Salesman works on commission only, no fixed salary or attendance required.

**Configuration:**
- Role: `salesman`
- Base Salary: Leave empty
- **Enable Payroll: ⛔ UNCHECKED** (manually disabled)

**Result:**
- ⛔ Does NOT appear in attendance marking
- ⛔ Does NOT appear in payroll generation
- ✅ Can still use the system normally
- ✅ Commission tracked elsewhere (existing salary module)

---

## Admin Workflow

### Adding a New User

1. Navigate to **User Management** (`/users`)
2. Click **"Add User"**
3. Fill in basic details (name, username, password, contact)
4. Set **Base Salary** if applicable
5. **Check/Uncheck "Include in Attendance & Payroll"**:
   - ✅ **CHECK** for real employees (Order Bookers, Salesmen with salary)
   - ⛔ **UNCHECK** for system accounts (Admin, bots, automated users)
6. Click **"Create User"**

### Editing Existing User

1. Navigate to **User Management** (`/users`)
2. Click **"Edit"** on any user
3. Toggle **"Include in Attendance & Payroll"** checkbox
4. Click **"Save Changes"**

**Changes take effect immediately:**
- ✅ If checked → user appears in attendance/payroll
- ⛔ If unchecked → user is excluded from attendance/payroll

---

## Database Migration Impact

**Migration 020 will:**
1. Add `base_salary` column to `users` table
2. Add `enable_payroll` column to `users` table (default = 1)
3. **Set `enable_payroll = 0` for ALL existing admin users**
4. Add `base_salary` column to `delivery_men` table
5. Create `holidays` table
6. Create `attendance` table
7. Create `payroll_records` table

**After migration:**
- All existing Order Bookers and Salesmen: `enable_payroll = 1` (included)
- All existing Admins: `enable_payroll = 0` (excluded)
- Admin can manually change these values anytime

---

## Summary Table

| User Type | Default `enable_payroll` | Attendance Marking | Payroll Generation | Can Change? |
|-----------|-------------------------|--------------------|--------------------|-------------|
| **Admin** | ⛔ 0 (excluded) | No | No | ✅ Yes (if needed) |
| **Order Booker** | ✅ 1 (included) | Yes | Yes (if base_salary set) | ✅ Yes |
| **Salesman** | ✅ 1 (included) | Yes | Yes (if base_salary set) | ✅ Yes |
| **Delivery Man** | ✅ Always included | Yes | Yes (if base_salary set) | N/A (no field) |

---

## Files Modified

✅ `src/db/migrations/020_attendance_holidays.sql` - Added `enable_payroll` column and UPDATE statement
✅ `src/models/UserModel.js` - Added `enable_payroll` to create(), update(), findById()
✅ `src/models/AttendanceModel.js` - Filter by `enable_payroll = 1`
✅ `src/models/PayrollModel.js` - Filter by `enable_payroll = 1`
✅ `src/controllers/UserController.js` - Handle `enable_payroll` in create() and update()
✅ `src/views/users/form.ejs` - Added checkbox for "Include in Attendance & Payroll"

---

## Testing Checklist

After running migration:

### Test 1: Admin User Exclusion
- [ ] Navigate to `/users`
- [ ] Edit admin user
- [ ] Verify "Include in Attendance & Payroll" is **UNCHECKED**
- [ ] Navigate to `/attendance`
- [ ] Verify admin does NOT appear in staff list
- [ ] Generate payroll for current month
- [ ] Verify admin is NOT included in payroll

### Test 2: Order Booker Inclusion
- [ ] Create new Order Booker with base_salary = 25000
- [ ] Verify "Include in Attendance & Payroll" is **CHECKED** by default
- [ ] Navigate to `/attendance`
- [ ] Verify Order Booker appears in staff list
- [ ] Mark attendance as present
- [ ] Generate payroll for current month
- [ ] Verify Order Booker is included in payroll

### Test 3: Manual Toggle
- [ ] Edit any user
- [ ] **UNCHECK** "Include in Attendance & Payroll"
- [ ] Save changes
- [ ] Verify user does NOT appear in `/attendance`
- [ ] **CHECK** the box again
- [ ] Save changes
- [ ] Verify user now appears in `/attendance`

### Test 4: Admin with Payroll Enabled
- [ ] Edit admin user
- [ ] Set base_salary = 40000
- [ ] **CHECK** "Include in Attendance & Payroll"
- [ ] Save changes
- [ ] Navigate to `/attendance`
- [ ] Verify admin NOW appears in staff list
- [ ] Generate payroll
- [ ] Verify admin is included in payroll

---

## Status

✅ **COMPLETE** - Fully implemented and ready for testing after migration.

**Next Step:** Run `npm run migrate` to apply changes.
