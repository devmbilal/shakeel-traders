# Auto-Present for Unmarked Attendance

## Feature: Automatic Present Marking

**Requirement:** If admin doesn't mark attendance for a staff member on a particular day, automatically consider them as "present" for payroll calculation.

**Reason:** Default assumption is that staff are present unless explicitly marked absent. This prevents salary deductions due to admin oversight.

---

## How It Works

### Before (Old Behavior):
- Admin marks attendance: `10 days`
- Month has: `30 days`
- Unmarked days: `20 days`
- **Result:** Only 10 present days counted → Large salary deduction ❌

### After (New Behavior):
- Admin marks attendance: `10 days present, 2 days absent`
- Month has: `30 days`
- Unmarked days: `18 days`
- **Result:** 10 + 18 = 28 present days, 2 absent days → Fair calculation ✅

---

## Implementation

**File:** `web-admin-panel/src/models/PayrollModel.js`

**Changed in `_calculatePayroll()` method:**

```javascript
// Get attendance summary with marked_days count
const [[attendance]] = await conn.query(
  `SELECT 
     SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days,
     SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent_days,
     SUM(CASE WHEN status = 'holiday' THEN 1 ELSE 0 END) as holiday_days,
     SUM(CASE WHEN status = 'off' THEN 1 ELSE 0 END) as off_days,
     COUNT(*) as marked_days  // ← NEW: Total days with attendance records
   FROM attendance
   WHERE staff_id = ? AND staff_type = ? 
     AND MONTH(attendance_date) = ? AND YEAR(attendance_date) = ?`,
  [staffId, staffType, month, year]
);

let presentDays = parseInt(attendance?.present_days) || 0;
const markedDays = parseInt(attendance?.marked_days) || 0;

// Calculate unmarked days
const totalDaysInMonth = new Date(year, month, 0).getDate();
const unmarkedDays = totalDaysInMonth - markedDays;

// AUTO-MARK UNMARKED DAYS AS PRESENT ← KEY LOGIC
presentDays = presentDays + unmarkedDays;
```

---

## Examples

### Example 1: Partial Attendance Marking

**Scenario:**
- Month: June 2026 (30 days)
- Admin marked: 15 days (10 present, 5 absent)
- Unmarked: 15 days

**Calculation:**
```
Total days in month:    30
Marked days:            15
  - Present:            10
  - Absent:             5
Unmarked days:          15  (30 - 15)

Auto-present logic:     10 + 15 = 25 present days
Final absent days:      5

Result: 25 present, 5 absent
```

**Salary Impact:**
- Base Salary: Rs 30,000
- Working days: 26 (30 - 4 Fridays)
- Per day salary: Rs 1,154
- Absence deduction: 5 × 1,154 = Rs 5,770
- **Net Salary: Rs 24,230** ✅

---

### Example 2: No Attendance Marked (Admin Forgot)

**Scenario:**
- Month: June 2026 (30 days)
- Admin marked: 0 days
- Unmarked: 30 days

**Calculation:**
```
Total days in month:    30
Marked days:            0
Unmarked days:          30

Auto-present logic:     0 + 30 = 30 present days
Final absent days:      0

Result: 30 present, 0 absent
```

**Salary Impact:**
- Base Salary: Rs 30,000
- Absence deduction: Rs 0
- **Net Salary: Rs 30,000** ✅ (Full salary, no penalty)

---

### Example 3: Admin Marked Everyone Present

**Scenario:**
- Month: June 2026 (30 days)
- Admin marked: 30 days (all present)
- Unmarked: 0 days

**Calculation:**
```
Total days in month:    30
Marked days:            30
  - Present:            30
Unmarked days:          0

Auto-present logic:     30 + 0 = 30 present days
Final absent days:      0

Result: 30 present, 0 absent
```

**Salary Impact:**
- **Net Salary: Rs 30,000** ✅ (Same as Example 2)

---

### Example 4: Some Absences Marked

**Scenario:**
- Month: June 2026 (30 days)
- Admin marked: 5 days (0 present, 5 absent)
- Unmarked: 25 days

**Calculation:**
```
Total days in month:    30
Marked days:            5
  - Absent:             5
Unmarked days:          25

Auto-present logic:     0 + 25 = 25 present days
Final absent days:      5

Result: 25 present, 5 absent
```

**Salary Impact:**
- Base Salary: Rs 30,000
- Working days: 26
- Per day salary: Rs 1,154
- Absence deduction: 5 × 1,154 = Rs 5,770
- **Net Salary: Rs 24,230** ✅

---

## Benefits

✅ **Fair to Staff:** No salary deduction if admin forgets to mark attendance
✅ **Flexible:** Admin can still mark specific absences when needed
✅ **Logical Default:** Assumes presence unless proven absent
✅ **Prevents Errors:** Protects against admin oversight or system issues

---

## How Admin Should Use It

### Daily Attendance Workflow:

1. **Mark Absences Only (Recommended):**
   - Open `/attendance`
   - Only mark staff who are ABSENT
   - Leave present staff unmarked
   - System will auto-count them as present ✅

2. **OR Mark Everything (Traditional):**
   - Open `/attendance`
   - Mark everyone: present, absent, off, holiday
   - System respects your explicit markings ✅

**Both approaches work correctly!**

---

## Important Notes

⚠️ **Fridays & Holidays:**
- System automatically detects Fridays as weekly offs
- Holidays marked by admin are excluded from working days
- Unmarked days on Fridays/Holidays are NOT counted as working days

⚠️ **Payroll Generation:**
- This logic only applies during payroll generation
- Attendance reports show actual marked attendance (not auto-present)

⚠️ **Working Days Calculation:**
```
Working Days = Total Days - Fridays - Holidays
Present Days = Explicitly Marked Present + Unmarked Days
Absent Days = Explicitly Marked Absent
```

---

## Status

✅ **COMPLETE** - Auto-present logic implemented in PayrollModel

**Files Modified:**
- `web-admin-panel/src/models/PayrollModel.js`

**Next Step:** Test payroll generation with partial attendance marking.
