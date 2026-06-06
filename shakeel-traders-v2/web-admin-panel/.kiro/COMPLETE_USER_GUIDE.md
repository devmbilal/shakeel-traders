# Complete User Guide: HR & Payroll System

## 🎯 Overview
This guide explains how to use the HR & Payroll system from start to finish.

---

## 📋 System Flow (Step by Step)

### Step 1: Set Up Staff Members (REQUIRED FIRST)
Before you can use attendance or payroll, you need to set up your staff members properly.

#### 1.1 Go to Users Page
1. Click **"Users"** in the sidebar
2. You'll see a list of all users

#### 1.2 Edit Each Staff Member
1. Click the **Edit** button (pencil icon) for each user
2. Fill in the following **REQUIRED** fields:

   **a) Base Salary:**
   - Enter the monthly salary (e.g., 30000)
   - This is used for payroll calculation
   - **If this is not set, user will show "Not set" in payroll page**

   **b) Include in Payroll:**
   - ✅ **CHECK** this box for staff who should appear in attendance/payroll
   - ❌ **UNCHECK** for admin users or software-only users
   - Example: Admin users don't need attendance, so uncheck this

3. Click **Save**

#### 1.3 Verify Staff Setup
- Go to **Attendance** page
- You should see all staff members with "Include in Payroll" checked
- Each should show their base salary

---

### Step 2: Mark Daily Attendance

#### 2.1 Go to Attendance Page
1. Click **"Attendance"** in the sidebar
2. Select the date you want to mark attendance for
3. You'll see all staff members with payroll enabled

#### 2.2 Mark Attendance for Each Staff
You have 4 options for each staff member:

- 🟢 **Present** - Staff came to work
- 🔴 **Absent** - Staff didn't come (will deduct salary)
- 🔵 **Off** - Staff's weekly off (Friday)
- 🟡 **Holiday** - Public holiday

#### 2.3 Quick Actions
- **Mark All Present** - Marks everyone present at once
- **Mark All Absent** - Marks everyone absent
- **Mark All Off** - Marks everyone off (use on Fridays)
- **Mark All Holiday** - Marks everyone on holiday

#### 2.4 Save Attendance
1. After marking everyone, click **"Save Attendance"** button at the bottom
2. You'll see a success message

#### 2.5 Important Notes
- ⚠️ **Days not marked = Automatically counted as PRESENT** (Don't worry if you forget!)
- ⚠️ **Friday absences don't reduce salary** (Friday is a weekly off)
- ⚠️ You can mark attendance for past dates too

---

### Step 3: Record Salary Advances (Optional)

If a staff member asks for an advance payment, record it here:

#### 3.1 Go to HR & Payroll Page
1. Click **"HR & Payroll"** in the sidebar
2. Click the **"Salary Advances & Ledger"** tab
3. Select staff type: Salesmen / Order Bookers / Delivery Men

#### 3.2 Record Advance
1. Click **"+ Advance"** button next to the staff member
2. Fill in:
   - **Amount**: How much advance (e.g., 5000)
   - **Date**: When the advance was given
   - **Note**: Optional note (e.g., "Medical emergency")
3. Click **"Record Advance"**
4. The advance will be deducted from their next payroll

#### 3.3 View Ledger
1. Click **"Ledger"** button next to any staff member
2. You'll see complete history:
   - All salary records
   - All advances
   - Net balance (how much you owe them or they owe you)
3. Click **"Export"** to download Excel file

---

### Step 4: Generate Monthly Payroll

At the end of each month, generate payroll:

#### 4.1 Go to HR & Payroll Page
1. Click **"HR & Payroll"** in the sidebar
2. Default tab is **"Monthly Payroll"**

#### 4.2 Generate Payroll
1. Select **Month** (e.g., June)
2. Select **Year** (e.g., 2026)
3. Click **"Generate Payroll"** button
4. System will automatically calculate:
   - Working days (Total days - Fridays - Holidays)
   - Present days
   - Absent days (excluding Fridays)
   - Per day salary (Base Salary ÷ Working Days)
   - Absence deduction (Absent Days × Per Day Salary)
   - Net salary (Base Salary - Absence Deduction)
   - Advances paid during the month
   - **Final Payable** (Net Salary - Advances)

#### 4.3 View Payroll
1. You'll see a table with all staff members
2. Summary cards show:
   - Total Payable
   - Total Paid
   - Total Pending

#### 4.4 View Details
1. Click the **eye icon** to view full details for any staff
2. You'll see complete breakdown

#### 4.5 Mark as Paid
1. When you pay a staff member, click the **green checkmark**
2. Select payment method (Cash/Bank Transfer/Cheque)
3. Add optional note
4. Click **"Mark as Paid"**
5. Status will change to "Paid"

---

## 📊 Example Scenario

### Scenario: Kamran Deliveryman

**Setup (Step 1):**
- Base Salary: Rs 30,000
- Include in Payroll: ✅ Checked

**June 2026 Attendance (Step 2):**
- Total days: 30
- Fridays (offs): 4 days (June 6, 13, 20, 27)
- Holidays: 0
- Working days: 26 (30 - 4)
- You marked:
  - Absent: 2 days (June 5, June 12) **but June 5 is Friday so doesn't count**
  - All other days: Not marked (automatically counted as present)
- **Actual absent days**: 1 (only June 12, Friday excluded)

**Advance Given (Step 3):**
- June 10: Rs 5,000 advance
- Note: "Medical emergency"

**Payroll Calculation (Step 4):**
```
Base Salary:           Rs 30,000
Working Days:          26 days
Per Day Salary:        Rs 1,154 (30,000 ÷ 26)
Absent Days:           1 day (Friday excluded)
Absence Deduction:     Rs 1,154 (1 × 1,154)
Net Salary:            Rs 28,846 (30,000 - 1,154)
Advances Paid:         Rs 5,000
Final Payable:         Rs 23,846 (28,846 - 5,000)
```

Kamran will receive Rs 23,846 at the end of June.

---

## ❓ Common Questions

### Q1: Why does it say "Not set" for base salary?
**A:** You haven't set the base salary for that staff member yet.
- Go to **Users** page
- Edit the user
- Set **Base Salary** field
- Check **Include in Payroll** box
- Save

### Q2: Where is the Attendance page?
**A:** Click **"Attendance"** in the sidebar (left menu).

### Q3: I forgot to mark attendance for yesterday. What happens?
**A:** No problem! Days not marked are automatically counted as **Present**. So staff won't be marked absent unless you explicitly mark them absent.

### Q4: How do I mark attendance for a specific date in the past?
**A:** On the Attendance page, change the date selector to the date you want, then mark attendance and save.

### Q5: What if someone is absent on Friday?
**A:** Friday absences don't affect salary. Friday is a weekly off, so even if you mark someone absent on Friday, it won't deduct from their salary.

### Q6: How do I record an advance?
**A:** 
1. Go to **HR & Payroll** page
2. Click **"Salary Advances & Ledger"** tab
3. Click **"+ Advance"** button for the staff member
4. Fill amount, date, note → Submit

### Q7: Where can I see salary history?
**A:** 
1. Go to **HR & Payroll** page
2. Click **"Salary Advances & Ledger"** tab
3. Click **"Ledger"** button for any staff member
4. You'll see complete history with net balance

### Q8: How do I export salary ledger?
**A:** From the Ledger page, click the **"Export"** button. An Excel file will download.

### Q9: Can I regenerate payroll if I made a mistake?
**A:** Yes! Just click **"Generate Payroll"** again for the same month. It will update the existing records.

### Q10: What if I don't want a user to appear in attendance?
**A:** Edit that user and **UNCHECK** the "Include in Payroll" box. They won't appear in attendance or payroll anymore.

---

## 🎯 Quick Reference

### Menu Items:
- **Users** - Set up staff members (base salary, enable payroll)
- **Attendance** - Mark daily attendance
- **HR & Payroll** - View payroll, record advances, view ledgers

### Payroll Formula:
```
Final Payable = Base Salary - Absence Deduction - Advances
```

### Business Rules:
1. ✅ Unmarked days = Present
2. ✅ Friday absences = Don't deduct salary
3. ✅ Working Days = Total Days - Fridays - Holidays
4. ✅ Only staff with "Include in Payroll" appear

---

## ✅ Checklist for Month-End

- [ ] Mark attendance for all days of the month
- [ ] Record any advances given
- [ ] Generate payroll (select month/year → Generate)
- [ ] Review payroll for all staff
- [ ] Pay staff members
- [ ] Mark as paid in system

---

## 🚨 Troubleshooting

### Problem: Staff not appearing in Attendance page
**Solution:** 
1. Go to Users page
2. Edit the user
3. Check ✅ "Include in Payroll" box
4. Set Base Salary
5. Save

### Problem: Base Salary shows "Not set"
**Solution:** 
1. Go to Users page
2. Edit the user
3. Fill in "Base Salary" field
4. Save

### Problem: Buttons overlapping (UI glitch)
**Solution:** 
1. Refresh the page (F5)
2. Clear browser cache (Ctrl+Shift+Delete)
3. If still not fixed, restart the server

### Problem: Can't find old Salaries page
**Solution:** The Salaries page has been merged into HR & Payroll. Click "Salary Advances & Ledger" tab.

---

## 📞 Need Help?

If you still have questions or encounter issues, check:
1. Browser console for errors (Press F12 → Console tab)
2. Terminal/server logs for errors
3. Verify database is running: `npm run migrate`

---

**System is ready to use!** Follow the steps above and you'll have full control over attendance and payroll.
