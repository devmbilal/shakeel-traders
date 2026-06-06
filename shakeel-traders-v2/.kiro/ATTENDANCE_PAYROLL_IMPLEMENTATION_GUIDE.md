# Attendance & Payroll System - Implementation Guide

## Status: ⚠️ PARTIALLY IMPLEMENTED

---

## What's Been Created

### ✅ Database Migration
**File:** `src/db/migrations/020_attendance_holidays.sql`

**Tables Created:**
1. `holidays` - System-wide holidays
2. `attendance` - Daily attendance tracking
3. `payroll_records` - Monthly payroll with deductions
4. **Modified:** `users` table - added `base_salary` column
5. **Modified:** `delivery_men` table - added `base_salary` column

### ✅ Models Created
1. **AttendanceModel.js** - Complete ✓
   - `getByDate()` - Get attendance for a date
   - `getAllStaffWithAttendance()` - Get all staff with attendance status
   - `mark()` - Mark single attendance
   - `bulkMark()` - Bulk mark attendance
   - `getMonthlySummary()` - Monthly attendance summary

2. **HolidayModel.js** - Complete ✓
   - `listAll()` - List all holidays
   - `listByYear()` - Holidays for specific year
   - `create()` - Create holiday
   - `update()` - Update holiday
   - `delete()` - Delete holiday
   - `isHoliday()` - Check if date is holiday

3. **PayrollModel.js** - Complete ✓
   - `generateMonthly()` - Generate payroll for month
   - `_calculatePayroll()` - Calculate deductions
   - `listPayroll()` - List payroll records
   - `markPaid()` - Mark payroll as paid

---

## What Needs to Be Created Next

### 🔨 Step 1: Run the Migration
**⚠️ CRITICAL - DO THIS FIRST**

```bash
# See instructions in RUN_MIGRATION_020.md
mysql -u root -p shakeel_traders < src/db/migrations/020_attendance_holidays.sql
```

### 🔨 Step 2: Create Controllers

#### AttendanceController.js
**Location:** `src/controllers/AttendanceController.js`

```javascript
const AttendanceController = {
  // GET /attendance - Mark attendance for today
  async index(req, res) { },
  
  // POST /attendance/mark - Mark/update attendance
  async markAttendance(req, res) { },
  
  // GET /attendance/report - Attendance report
  async report(req, res) { },
  
  // GET /attendance/staff/:id - Individual staff attendance
  async staffAttendance(req, res) { },
};
```

#### HolidayController.js
**Location:** `src/controllers/HolidayController.js`

```javascript
const HolidayController = {
  // GET /holidays - List all holidays
  async index(req, res) { },
  
  // GET /holidays/new - New holiday form
  async newForm(req, res) { },
  
  // POST /holidays - Create holiday
  async create(req, res) { },
  
  // POST /holidays/:id/delete - Delete holiday
  async delete(req, res) { },
};
```

#### PayrollController.js
**Location:** `src/controllers/PayrollController.js`

```javascript
const PayrollController = {
  // GET /payroll - List payroll records
  async index(req, res) { },
  
  // POST /payroll/generate - Generate monthly payroll
  async generate(req, res) { },
  
  // GET /payroll/:id - View payroll details
  async view(req, res) { },
  
  // POST /payroll/:id/pay - Mark as paid
  async markPaid(req, res) { },
};
```

### 🔨 Step 3: Create Routes

#### attendance.js
**Location:** `src/routes/web/attendance.js`

```javascript
const router = require('express').Router();
const AttendanceController = require('../../controllers/AttendanceController');

router.get('/', AttendanceController.index);
router.post('/mark', AttendanceController.markAttendance);
router.get('/report', AttendanceController.report);
router.get('/staff/:id', AttendanceController.staffAttendance);

module.exports = router;
```

#### holidays.js
**Location:** `src/routes/web/holidays.js`

```javascript
const router = require('express').Router();
const HolidayController = require('../../controllers/HolidayController');

router.get('/', HolidayController.index);
router.get('/new', HolidayController.newForm);
router.post('/', HolidayController.create);
router.post('/:id/delete', HolidayController.delete);

module.exports = router;
```

#### payroll.js
**Location:** `src/routes/web/payroll.js`

```javascript
const router = require('express').Router();
const PayrollController = require('../../controllers/PayrollController');

router.get('/', PayrollController.index);
router.post('/generate', PayrollController.generate);
router.get('/:id', PayrollController.view);
router.post('/:id/pay', PayrollController.markPaid);

module.exports = router;
```

### 🔨 Step 4: Register Routes in app.js

Add to `src/app.js`:

```javascript
// Attendance & Payroll Routes
const attendanceRouter = require('./routes/web/attendance');
const holidaysRouter = require('./routes/web/holidays');
const payrollRouter = require('./routes/web/payroll');

app.use('/attendance', ensureAuthenticated, attendanceRouter);
app.use('/holidays', ensureAuthenticated, ensureAdmin, holidaysRouter);
app.use('/payroll', ensureAuthenticated, ensureAdmin, payrollRouter);
```

### 🔨 Step 5: Create Views

#### 1. Mark Attendance Page
**File:** `src/views/attendance/index.ejs`

**Features:**
- Calendar view or date picker
- List all staff with checkboxes: Present / Absent
- Friday automatically marked as "Off"
- Holidays automatically marked as "Holiday"
- Bulk save button
- Show count: Present, Absent, Off, Holiday

#### 2. Attendance Report Page
**File:** `src/views/attendance/report.ejs`

**Features:**
- Month/Year selector
- Staff selector (all or specific)
- Table showing:
  - Staff Name
  - Total Working Days
  - Present Days
  - Absent Days
  - Holiday Days
  - Off Days
  - Attendance %
- Export to Excel button

#### 3. Holidays Management Page
**File:** `src/views/holidays/index.ejs`

**Features:**
- List all holidays with date, name, description
- Add Holiday button (opens modal or form)
- Delete button for each holiday
- Filter by year
- Upcoming holidays highlighted

#### 4. Payroll Dashboard
**File:** `src/views/payroll/index.ejs`

**Features:**
- Month/Year selector
- "Generate Payroll" button
- Table showing:
  - Staff Name
  - Base Salary
  - Working Days
  - Present Days
  - Absent Days
  - Absence Deduction
  - Net Salary
  - Advances Paid
  - Final Payable
  - Payment Status (Pending/Paid)
  - Actions: View Details, Mark Paid
- Summary cards: Total Payable, Total Paid, Total Pending

#### 5. Payroll Details Page
**File:** `src/views/payroll/view.ejs`

**Features:**
- Staff information
- Month/Year
- Salary breakdown table
- Attendance details
- Advances list
- Payment form (if pending)
- Print slip button

### 🔨 Step 6: Update Navigation

Add to `src/views/layout/header.ejs`:

```html
<% if (user.role === 'admin') { %>
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
      <i class="bi bi-calendar-check me-1"></i> HR & Payroll
    </a>
    <ul class="dropdown-menu">
      <li><a class="dropdown-item" href="/attendance">Mark Attendance</a></li>
      <li><a class="dropdown-item" href="/attendance/report">Attendance Report</a></li>
      <li><hr class="dropdown-divider"></li>
      <li><a class="dropdown-item" href="/holidays">Manage Holidays</a></li>
      <li><hr class="dropdown-divider"></li>
      <li><a class="dropdown-item" href="/payroll">Payroll</a></li>
    </ul>
  </li>
<% } %>
```

### 🔨 Step 7: Update User Forms

Add base salary field to:
1. **User Creation Form** (`src/views/users/form.ejs`)
2. **Delivery Man Form** (if exists)

```html
<div class="mb-3">
  <label class="form-label">Base Salary (Monthly)</label>
  <input type="number" name="base_salary" class="form-control" 
         step="0.01" min="0" value="<%= user ? user.base_salary : '' %>" 
         placeholder="30000.00">
  <div class="form-text">Leave empty if salary not applicable</div>
</div>
```

---

## Business Logic Summary

### Attendance Rules
1. **Friday = Automatic Off** for all staff
2. **Holidays** marked by admin apply to all staff
3. **Working Days** = Total Days in Month - Fridays - Holidays
4. Attendance can be: **Present**, **Absent**, **Holiday**, **Off**

### Salary Calculation
```
Base Salary = 30,000
Working Days = 26 (Total 30 days - 4 Fridays)
Per Day Salary = 30,000 / 26 = 1,153.85

Absent Days = 2
Absence Deduction = 2 × 1,153.85 = 2,307.70

Net Salary = 30,000 - 2,307.70 = 27,692.30
Advances Paid = 5,000

Final Payable = 27,692.30 - 5,000 = 22,692.30
```

### Workflow
1. **Daily:** Admin marks attendance for all staff
2. **Month End:** Admin generates payroll (auto-calculates deductions)
3. **Payment:** Admin reviews and marks each payroll as paid

---

## Testing Checklist

### Database
- [ ] Migration 020 executed successfully
- [ ] All 3 tables created
- [ ] base_salary columns added to users and delivery_men

### Models
- [x] AttendanceModel created and imported correctly
- [x] HolidayModel created and imported correctly
- [x] PayrollModel created and imported correctly

### Controllers
- [ ] AttendanceController created
- [ ] HolidayController created
- [ ] PayrollController created

### Routes
- [ ] Attendance routes registered
- [ ] Holidays routes registered
- [ ] Payroll routes registered
- [ ] Routes added to app.js

### Views
- [ ] Attendance marking page works
- [ ] Holidays management works
- [ ] Payroll generation works
- [ ] Salary calculation is correct

### Integration
- [ ] Set base salary for existing users
- [ ] Mark attendance for today
- [ ] Create a holiday
- [ ] Generate payroll for current month
- [ ] Verify calculations are correct
- [ ] Mark payroll as paid

---

## Next Steps

**Immediate:**
1. Run migration 020 (see RUN_MIGRATION_020.md)
2. Set base salaries for existing users via SQL or admin UI
3. Create controllers (AttendanceController, HolidayController, PayrollController)
4. Create routes and register in app.js
5. Create views (attendance, holidays, payroll)
6. Update navigation menu
7. Test the complete flow

**Future Enhancements:**
- Auto-mark Fridays as "off" on attendance generation
- Email payslips to staff
- Attendance reports by staff/month
- Late arrival tracking
- Leave management (paid leave, sick leave)
- Overtime tracking
- Bonus management

---

## Files Created So Far

✅ `src/db/migrations/020_attendance_holidays.sql`
✅ `src/models/AttendanceModel.js`
✅ `src/models/HolidayModel.js`
✅ `src/models/PayrollModel.js`
✅ `.kiro/RUN_MIGRATION_020.md`
✅ `.kiro/ATTENDANCE_PAYROLL_IMPLEMENTATION_GUIDE.md` (this file)

---

**Status:** Backend models complete, controllers/views/routes needed
**Estimated Time to Complete:** 2-3 hours for full implementation
**Priority:** High (required for payroll processing)

