# Shakeel Traders Distribution Order System
# Complete Deployment Guide — v1.2
# For: Deployment Team / Client First-Time Setup

---

## PART A — EXPORT FROM DEVELOPER MACHINE

### Step 1 — Export the database dump

Open CMD on the developer machine and run:

```cmd
mysqldump -u root -p shakeel_traders > C:\shakeel-traders-backup\full_backup_v1.2.sql
```

Enter MySQL root password when prompted.
This creates a complete dump with all tables, data, and structure.

### Step 2 — Export the web app

Delete or exclude these folders before zipping (they are not needed):
- `web-admin-panel\node_modules\`
- `web-admin-panel\backups\`
- `web-admin-panel\.env`  ← NEVER send this (contains passwords)

Create the zip in PowerShell:

```powershell
Compress-Archive -Path "F:\shakeel-traders\web-admin-panel" `
  -DestinationPath "C:\shakeel-traders-backup\web-admin-panel-v1.2.zip" `
  -CompressionLevel Optimal
```

### Step 3 — Build the Android APK

Open CMD in the mobile-app folder:

```cmd
cd F:\shakeel-traders\mobile-app
flutter build apk --release
```

APK is generated at:
```
mobile-app\build\app\outputs\flutter-apk\app-release.apk
```

Copy it to the delivery folder and rename to `shakeel_traders_v1.2.apk`.

### Step 4 — Package everything for delivery

Send these files to the client/deployment team:

```
shakeel-traders-delivery/
├── web-admin-panel-v1.2.zip      ← web app source (no node_modules)
├── full_backup_v1.2.sql          ← complete database dump
├── shakeel_traders_v1.2.apk      ← Android app
└── DEPLOYMENT_GUIDE_v1.2.md      ← this file
```

---

## PART B — CLIENT MACHINE SETUP (Windows 10/11)

### Prerequisites — Install in this exact order

#### 1. Node.js v18 LTS

- Download: https://nodejs.org/en/download
- Choose: Windows Installer (.msi) — LTS version
- Install with all default settings
- Verify in CMD:
  ```cmd
  node --version
  ```
  Should show: `v18.x.x`

#### 2. MySQL 8.x Community Server

- Download: https://dev.mysql.com/downloads/installer/
- Choose: MySQL Installer for Windows (web installer)
- During setup select: **MySQL Server** + **MySQL Workbench**
- Set root password — write it down, you will need it
- Keep default port: `3306`
- Keep default service name: `MySQL80`
- Verify in CMD:
  ```cmd
  mysql --version
  ```

---

## PART C — DATABASE SETUP

### Step 1 — Create the database and user

Open **MySQL Workbench**, connect as root, then run:

```sql
CREATE DATABASE shakeel_traders
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER 'shakeel'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
GRANT ALL PRIVILEGES ON shakeel_traders.* TO 'shakeel'@'localhost';
FLUSH PRIVILEGES;
```

> Replace `YourStrongPassword123!` with a strong password. Write it down.

### Step 2 — Import the database dump

Open CMD (not PowerShell) and run:

```cmd
mysql -u root -p shakeel_traders < "C:\path\to\full_backup_v1.2.sql"
```

Enter root password when prompted.

Wait for it to complete (may take 30-60 seconds).

### Step 3 — Verify the import

In MySQL Workbench, run:

```sql
USE shakeel_traders;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM shops;
```

You should see all tables listed and row counts matching the source data.

---

## PART D — WEB APP SETUP

### Step 1 — Extract the web app

Extract `web-admin-panel-v1.2.zip` to:
```
C:\shakeel-traders\web-admin-panel\
```

### Step 2 — Create the .env file

Inside `C:\shakeel-traders\web-admin-panel\` create a new file named exactly `.env` (no other extension).

Open Notepad, paste this content, and save as `.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=shakeel
DB_PASS=YourStrongPassword123!
DB_NAME=shakeel_traders

# Session — change this to any long random text
SESSION_SECRET=shakeel_traders_secret_key_change_this_2026

# Server
PORT=3000

# Backup directory
BACKUP_DIR=./backups

# Google Drive Backup (configure later — see Part F)
RCLONE_ENABLED=false
RCLONE_EXE=rclone
RCLONE_REMOTE=gdrive
RCLONE_DRIVE_PATH=Shakeel Traders Backups
RCLONE_CONFIG=

# Timezone — IMPORTANT: must be Pakistan time
TZ=Asia/Karachi

# Environment
NODE_ENV=production
```

> Replace `YourStrongPassword123!` with the password you set in Step C-1.

### Step 3 — Install dependencies

Open CMD and run:

```cmd
cd C:\shakeel-traders\web-admin-panel
npm install
```

Wait for all packages to download (requires internet, takes 1-3 minutes).

### Step 4 — Create required folders

```cmd
mkdir C:\shakeel-traders\web-admin-panel\backups
mkdir C:\shakeel-traders\web-admin-panel\src\public\uploads\logos
```

### Step 5 — Test run

```cmd
cd C:\shakeel-traders\web-admin-panel
npm start
```

Open browser and go to: `http://localhost:3000`

You should see the login page.

Login with:
- **Username:** `admin`
- **Password:** `admin123`

> **Change this password immediately** → Settings → Admin Profile

---

## PART E — AUTO-START ON WINDOWS BOOT

So the server starts automatically when the PC turns on without anyone opening CMD.

### Step 1 — Install PM2 globally

```cmd
npm install -g pm2
npm install -g pm2-windows-startup
```

### Step 2 — Register the app with PM2

```cmd
cd C:\shakeel-traders\web-admin-panel
pm2 start src/app.js --name "shakeel-traders"
pm2 save
```

### Step 3 — Enable Windows auto-start

```cmd
pm2-startup install
```

### Step 4 — Set MySQL to auto-start

1. Press `Win + R` → type `services.msc` → press Enter
2. Find **MySQL80** in the list
3. Right-click → Properties
4. Set **Startup type** to **Automatic**
5. Click OK

### Verify everything works

Restart the PC. After reboot, open browser and go to `http://localhost:3000` — it should load without opening any CMD window.

### Useful PM2 commands

```cmd
pm2 status                      # check if running
pm2 logs shakeel-traders        # view live logs
pm2 restart shakeel-traders     # restart after .env changes
pm2 stop shakeel-traders        # stop the server
pm2 start shakeel-traders       # start again
```

---

## PART F — GOOGLE DRIVE AUTO-BACKUP (Optional but Recommended)

Backups upload automatically to Google Drive after every backup (midnight cron + manual).

### Step 1 — Download Rclone

- Go to: https://rclone.org/downloads/
- Click **Windows** → download the zip
- Extract `rclone.exe` to a permanent location, e.g.:
  `C:\rclone\rclone.exe`

### Step 2 — Configure Google Drive

Open **Command Prompt** (cmd.exe — NOT PowerShell) and run:

```cmd
C:\rclone\rclone.exe config
```

Answer exactly as follows:

```
e/n/d/r/c/s/q> n
name> gdrive
Storage> [type the number shown for Google Drive]
client_id>              [press Enter — leave blank]
client_secret>          [press Enter — leave blank]
scope> 1
root_folder_id>         [press Enter — leave blank]
service_account_file>   [press Enter — leave blank]
Edit advanced config? n
Use auto config? y      [browser opens — sign in with Gmail — click Allow]
Configure as Shared Drive? n
y/e/d> y
e/n/d/r/c/s/q> q
```

### Step 3 — Verify configuration

```cmd
C:\rclone\rclone.exe config show
```

Note the exact remote name shown (e.g. `gdrive`).

### Step 4 — Create Google Drive folder

In your Google Drive, create a folder called `Shakeel Traders Backups`.

### Step 5 — Update .env

```env
RCLONE_ENABLED=true
RCLONE_EXE=C:\rclone\rclone.exe
RCLONE_REMOTE=gdrive
RCLONE_DRIVE_PATH=Shakeel Traders Backups
```

> `RCLONE_REMOTE` must exactly match the name shown in `rclone config show`.

### Step 6 — Restart and test

```cmd
pm2 restart shakeel-traders
```

Go to Backup page → Run Backup Now → success message will confirm Drive upload.

---

## PART G — MOBILE APP SETUP

### Step 1 — Install the APK

1. Copy `shakeel_traders_v1.2.apk` to the Android phone (via USB or WhatsApp)
2. On the phone: Settings → Security → enable **Install from Unknown Sources**
3. Open the APK file → Install

### Step 2 — Set a static IP on the server PC (important)

This prevents the server IP from changing when the router restarts.

1. Control Panel → Network and Internet → Network Connections
2. Right-click Wi-Fi adapter → Properties
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → Properties
4. Select **Use the following IP address**:
   - IP address: `192.168.1.100` (or any free IP on your network)
   - Subnet mask: `255.255.255.0`
   - Default gateway: your router IP (usually `192.168.1.1`)
   - Preferred DNS: `8.8.8.8`
5. Click OK

### Step 3 — Connect the mobile app

1. Make sure the phone is on the **same Wi-Fi** as the server PC
2. Open the app
3. On the **Connection Screen**:
   - Server IP: the static IP you set (e.g. `192.168.1.100`)
   - Port: `3000`
4. Tap **Test Connection** → should show "Connected"
5. Login with Order Booker or Salesman credentials

> The server IP is also shown on the Dashboard → hero card → "Mobile App Connection" section.

---

## PART H — FIRST-TIME CONFIGURATION CHECKLIST

After everything is running, complete this before handing to client:

- [ ] Login and change admin password → Settings → Admin Profile
- [ ] Set company profile → Company Profile (name, address, NTN, logo)
- [ ] Create routes → Routes → Add Route
- [ ] Add shops to routes (or CSV import via Products page)
- [ ] Add products with SKU codes and prices (or CSV import)
- [ ] Add initial warehouse stock → Stock → Manual Add
- [ ] Add suppliers → Suppliers
- [ ] Create Order Booker accounts → Users → Add User
- [ ] Create Salesman accounts → Users → Add User
- [ ] Add Delivery Men → Salaries → Delivery Men tab
- [ ] Test mobile app connection from each device
- [ ] Test morning sync on Order Booker phone
- [ ] Configure Google Drive backup (Part F)
- [ ] Verify backup runs → Backup page → Run Backup Now

---

## PART I — QUICK REFERENCE

| Item | Value |
|---|---|
| Web panel URL (local) | `http://localhost:3000` |
| Web panel URL (LAN) | `http://192.168.1.100:3000` |
| Default admin login | `admin` / `admin123` |
| Database name | `shakeel_traders` |
| Database port | `3306` |
| App port | `3000` |
| Timezone | `Asia/Karachi` (PKT UTC+5) |
| Backup folder | `C:\shakeel-traders\web-admin-panel\backups\` |
| PM2 app name | `shakeel-traders` |
| MySQL service name | `MySQL80` |

---

## PART J — TROUBLESHOOTING

| Problem | Solution |
|---|---|
| Browser shows "This site can't be reached" | Run `pm2 status` — if stopped, run `pm2 restart shakeel-traders` |
| MySQL connection error on startup | Check MySQL80 service is running in services.msc |
| "Access denied" DB error | Check DB_USER and DB_PASS in `.env` match what you created in MySQL |
| Mobile app "Connection failed" | Check both devices on same Wi-Fi, verify IP and port |
| Port 3000 already in use | Change `PORT=3001` in `.env`, restart PM2 |
| App not starting after reboot | Run `pm2 resurrect` then `pm2-startup install` again |
| Drive upload fails "didn't find section" | Remote name in `.env` doesn't match `rclone config show` — fix `RCLONE_REMOTE` |
| Drive upload fails in server but works in CMD | Set `RCLONE_CONFIG` in `.env` to full path of `rclone.conf` (usually `C:\Users\<name>\AppData\Roaming\rclone\rclone.conf`) |
| Dates showing wrong day | Verify `TZ=Asia/Karachi` is in `.env` and server was restarted |
| Logo not showing on dashboard | Upload via Company Profile page, then refresh dashboard |

---

**Version:** 1.2
**Date:** April 2026
**System:** Shakeel Traders Distribution Order System
