# Database Migration Required

## Add Sales Tax and CNIC fields to Company Profile

Run this SQL command in your MySQL database:

```sql
USE shakeel_traders;

ALTER TABLE `company_profile`
ADD COLUMN `sales_tax` VARCHAR(50) NULL DEFAULT NULL AFTER `gst_ntn`,
ADD COLUMN `cnic` VARCHAR(20) NULL DEFAULT NULL AFTER `sales_tax`;
```

Or run this command in PowerShell (from the project root):

```powershell
Get-Content web-admin-panel/src/db/migrations/016_add_company_profile_fields.sql | mysql -u root -p shakeel_traders
```

Then restart your Node.js server.

## Update Company Profile

After running the migration, go to the Company Profile page in the web panel and add:
- Sales Tax number
- CNIC number

These will appear on printed bills.
