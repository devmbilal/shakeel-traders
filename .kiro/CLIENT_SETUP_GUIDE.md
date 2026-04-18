# Shakeel Traders — Complete Client Setup Guide
## v1.2 | Windows 10 Fresh Install

---

## PART A — WHAT TO SEND TO CLIENT

### Files to prepare and zip

```
shakeel-traders-v1.2/
├── web-admin-panel/          ← full project folder (see exclusions below)
├── full_backup_v1.2.sql      ← your DB dump (structure + data)
├── shakeel_traders_app.apk   ← compiled Android APK
└── CLIENT_SETUP_GUIDE.md     ← this file
```

### Step 1 — Export the web app

On your machine, delete or exclude these before zipping:

- `web-admin-panel/node_modules/` — too large, client installs fresh
- `web-admin-panel/.env` — contains your passwords, client creates their own
- `web-admin-panel/backups/` — your local backups, not needed

Create the zip (run in PowerShell from project root):

```powershell
Compress-Archive -Path web-admin-panel -DestinationPath shakeel-traders-webapp-v1.2.zip
```

### Step 2 — Export the database

You already have `full_backup_v1.2.sql`. This contains:
- All table structures
- All existing data (products, shops, users, etc.)

Copy it into the delivery folder.

### Step 3 — Build the Android APK

In your development machine, run:

```bash
cd mobile-app
flutter build apk --release
```

The APK is generated at:
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

Rename it to `shakeel_traders_app.apk` and add to delivery folder.

### Step 4 — Zip everything and send

```powershell
Compress-Archive -Path shakeel-traders-v1.2 -DestinationPath shakeel-traders-v1.2-DELIVERY.zip
```

Send `shakeel-traders-v1.2-DELIVERY.zip` to the client/deployment team.

---

## PART B — CLIENT MACHINE SETUP (Windows 10)

### Prerequisites to install on client PC

Install these in order:

#### 1. Node.js v18 LTS
- Download: https://nodejs.org/en/download
- Choose "Windows Installer (.msi)" — LTS version
- Install with default settings
- Verify: open CMD → `node --version` → should show `v18.x.x`

#### 2. MySQL 8.x Community Server
- Download: https://dev.mysql.com/downloads/mysql/
- Choose "MySQL Installer for Windows"
- During setup select: **MySQL Server** + **MySQL Workbench**
- Set root password — **write it down, you'll need it**
- Keep port as `3306`
- Verify: open CMD → `mysql --version`

---

## PART C — DATABASE SETUP

### Step 1 — Create the database

Open **MySQL Workbench**, connect as root, then run:

```sql
CREATE DATABASE shakeel_traders
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER 'shakeel'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON shakeel_traders.* TO 'shakeel'@'localhost';
FLUSH PRIVILEGES;
```

> Change `StrongPassword123!` to something secure. Write it down.

### Step 2 — Import the database dump

Open CMD and run:

```cmd
mysql -u root -p shakeel_traders < full_backup_v1.2.sql
```

Enter root password when prompted.

This imports all tables, columns, indexes, and existing data in one shot.

### Step 3 — Verify import

In MySQL Workbench run:

```sql
USE shakeel_traders;
SHOW TABLES;
```

You should see all tables listed (users, orders, bills, shops, products, etc.)

---

## PART D — WEB APP SETUP

### Step 1 — Extract the web app

Extract `shakeel-traders-webapp-v1.2.zip` to:
```
C:\shakeel-traders\web-admin-panel\
```

### Step 2 — Create the .env file

Inside `C:\shakeel-traders\web-admin-panel\` create a new file named `.env` (no extension):

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=shakeel
DB_PASS=StrongPassword123!
DB_NAME=shakeel_traders

SESSION_SECRET=replace_this_with_any_long_random_text_at_least_32_chars

PORT=3000

BACKUP_DIR=./backups

NODE_ENV=production
```

> Replace `StrongPassword123!` with the password you set in Step C-1.
> Replace `SESSION_SECRET` with any long random string.

### Step 3 — Install dependencies

Open CMD, navigate to the project:

```cmd
cd C:\shakeel-traders\web-admin-panel
npm install
```

### Step 4 — Test run

```cmd
npm start
```

Open browser → `http://localhost:3000`

Login with:
- Username: `admin`
- Password: `admin123`

**Change the password immediately** → Settings → Admin Profile

---

## PART E — AUTO-START ON WINDOWS (Run on Boot)

So the server starts automatically when the PC turns on, without anyone opening CMD.

### Step 1 — Install PM2

```cmd
npm install -g pm2
npm install -g pm2-windows-startup
```

### Step 2 — Start the app with PM2

```cmd
cd C:\shakeel-traders\web-admin-panel
pm2 start src/app.js --name "shakeel-traders"
pm2 save
```

### Step 3 — Enable auto-start on Windows boot

```cmd
pm2-startup install
```

Now the Node.js server starts automatically every time Windows boots — no manual action needed.

### Step 4 — Auto-start MySQL on boot

MySQL installs as a Windows Service by default. Verify it's set to auto-start:

1. Press `Win + R` → type `services.msc` → Enter
2. Find **MySQL80** in the list
3. Right-click → Properties
4. Set **Startup type** to **Automatic**
5. Click OK

MySQL will now start automatically on every boot before the Node.js app.

### Useful PM2 commands

```cmd
pm2 status                    # check if app is running
pm2 logs shakeel-traders      # view live logs
pm2 restart shakeel-traders   # restart after changes
pm2 stop shakeel-traders      # stop the server
```

---

## PART F — MOBILE APP SETUP

### Step 1 — Install the APK

1. Copy `shakeel_traders_app.apk` to the Android phone
2. On the phone: Settings → Security → enable **Install from Unknown Sources**
3. Open the APK file → Install

### Step 2 — Connect to the server

1. Make sure the phone is on the **same Wi-Fi network** as the server PC
2. Open the app
3. On the **Connection Screen**:
   - **Server IP**: find this on the Dashboard hero card ("Mobile App Connection" section) or run `ipconfig` on the server PC and use the IPv4 address
   - **Port**: `3000`
4. Tap **Test Connection** — should show "Connected ✓"
5. Login with Order Booker or Salesman credentials

> Every time the server PC's IP changes (e.g. router restart), update the IP in the app Connection Screen.

### Fix IP changing issue (recommended)

Set a **static IP** on the server PC:

1. Control Panel → Network → Change adapter settings
2. Right-click the Wi-Fi/Ethernet adapter → Properties
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → Properties
4. Select **Use the following IP address**:
   - IP: `192.168.1.100` (or any free IP on your network)
   - Subnet: `255.255.255.0`
   - Gateway: your router IP (usually `192.168.1.1`)
5. Click OK

Now the server always has the same IP — mobile app never needs reconfiguring.

---

## PART G — FIRST-TIME CONFIGURATION CHECKLIST

After everything is running, do this before handing to client:

- [ ] Login and change admin password → Settings → Admin Profile
- [ ] Set company profile → Company Profile (name, address, NTN, logo)
- [ ] Create routes → Routes
- [ ] Add shops to routes (or CSV import)
- [ ] Add products with SKU codes and prices
- [ ] Add initial warehouse stock → Stock → Manual Add
- [ ] Add suppliers → Suppliers
- [ ] Create Order Booker accounts → Users
- [ ] Create Salesman accounts → Users
- [ ] Test mobile app connection from each device
- [ ] Test morning sync on Order Booker phone
- [ ] Configure automatic backup time → Backup

---

## PART H — QUICK REFERENCE

| Item | Value |
|---|---|
| Web panel URL | `http://localhost:3000` or `http://<SERVER_IP>:3000` |
| Default admin login | `admin` / `admin123` |
| DB name | `shakeel_traders` |
| DB port | `3306` |
| App port | `3000` |
| Backup folder | `C:\shakeel-traders\web-admin-panel\backups\` |
| PM2 app name | `shakeel-traders` |
| MySQL service name | `MySQL80` |

---

## PART I — TROUBLESHOOTING

| Problem | Fix |
|---|---|
| Browser shows "This site can't be reached" | Run `pm2 status` — if stopped, run `pm2 restart shakeel-traders` |
| MySQL connection error on startup | Check MySQL80 service is running in services.msc |
| Mobile app "Connection failed" | Check both devices on same Wi-Fi, verify IP and port |
| "Access denied" DB error | Check `.env` DB_USER and DB_PASS match what you created in MySQL |
| Port 3000 already in use | Change `PORT=3001` in `.env` and update mobile app port |
| App not starting after reboot | Run `pm2 resurrect` then `pm2-startup install` again |

---

**Version:** 1.2
**Date:** April 2026
**System:** Shakeel Traders Distribution Order System
