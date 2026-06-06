# CSV Import Preview Feature - Shop Management

## Overview
Enhanced the shop CSV import feature to include a preview/review screen where users can view, edit, and delete shops before they are actually imported into the database.

## How It Works

### Previous Flow (Direct Import):
1. Upload CSV file
2. ✅ Shops imported immediately
3. No chance to review or edit

### New Flow (Preview Before Import):
1. Upload CSV file
2. **📋 Review screen appears**
   - View all shops from CSV
   - Edit any field inline
   - Delete/undelete rows
   - Select/deselect shops for import
3. ✅ Confirm and import selected shops

## Features

### 1. **Preview Screen**
- Shows all parsed shops in a table
- Displays: Shop Name, Owner, Phone, Address, Route, Type
- Shows row numbers for easy reference
- Clean, professional interface

### 2. **Inline Editing**
- Edit any field directly in the table:
  - Shop Name (required)
  - Owner Name
  - Phone Number
  - Address
  - Route (dropdown with all routes)
  - Shop Type (dropdown: Retail/Wholesale/Distributor)
- Changes are saved when you click "Confirm & Import"

### 3. **Row Selection**
- Checkbox for each row
- "Select All" / "Deselect All" checkbox in header
- Only selected shops will be imported
- Live counter showing "X of Y shops selected"

### 4. **Delete/Undelete Rows**
- Trash icon button for each row
- Click once to mark for deletion (row becomes gray and crossed out)
- Click again to restore the row
- Deleted rows are automatically unchecked and disabled

### 5. **Validation**
- Shop name and route are required
- Form won't submit if no shops are selected
- Confirmation prompt before import: "Import X shop(s)?"

### 6. **Cancel Option**
- "Cancel Import" button at the top
- "Cancel" button at the bottom
- Clears the session and returns to shops list

## User Flow

### Step 1: Upload CSV
1. Go to **Shops** page
2. Use the CSV import form (existing)
3. Upload CSV file
4. Click "Import"

### Step 2: Review Screen
- Automatically redirected to `/shops/import/preview`
- See all shops from CSV in a table
- Summary shows: "Found X shops in CSV"

### Step 3: Review & Edit
Users can:
- ✏️ Edit any field by clicking on it
- ☑️ Uncheck shops they don't want to import
- 🗑️ Click trash icon to mark shops for deletion
- 🔄 Click trash icon again to restore deleted shops
- 📊 See live count of selected shops

### Step 4: Confirm or Cancel
- Click **"Confirm & Import"** to proceed
  - Confirmation prompt appears
  - Selected shops are imported
  - Success/error message shown
  - Redirected to shops list
  
- Click **"Cancel"** to abort
  - No data is imported
  - Session cleared
  - Redirected to shops list

## Technical Implementation

### Files Modified/Created:

1. **ShopController.js** - Updated with 4 new methods:
   - `importCSV()` - Parses CSV and stores in session
   - `importPreview()` - Displays preview screen
   - `importConfirm()` - Processes edited data and imports
   - `importCancel()` - Clears session and cancels

2. **shops.js (routes)** - Added 3 new routes:
   - `GET /shops/import/preview`
   - `POST /shops/import/confirm`
   - `POST /shops/import/cancel`

3. **import-preview.ejs** - New view file:
   - Editable table with all shops
   - JavaScript for select all/delete/count
   - Form submission handling

### Session Storage:
```javascript
req.session.csvPreviewData = {
  shops: [...],        // Array of parsed shop objects
  routeFilter: '',     // Route filter if applied
  timestamp: Date.now() // When uploaded
}
```

### Data Flow:

**Upload** → **Parse CSV** → **Store in Session** → **Preview Screen**
                                                      ↓
**Shops List** ← **Clear Session** ← **Import to DB** ← **User Edits & Confirms**

## Security & Data Safety

1. **Session-based**: Data is stored in user's session, not on disk
2. **Validation**: Required fields enforced before import
3. **Confirmation**: User must explicitly confirm before import
4. **No automatic import**: Nothing is saved until user clicks "Confirm"
5. **Cancellable**: User can cancel at any time without saving

## Benefits

### For Users:
✅ **Review before commit** - See all data before importing
✅ **Fix errors** - Edit typos and incorrect data
✅ **Quality control** - Remove duplicate or invalid entries
✅ **Flexible selection** - Import only the shops you want
✅ **Undo mistakes** - Cancel if something looks wrong

### For Business:
✅ **Data accuracy** - Reduces bad data in database
✅ **Less cleanup** - No need to delete wrongly imported shops
✅ **Confidence** - Users can verify before committing
✅ **Efficiency** - Edit in bulk before import

## Example Use Cases

### Use Case 1: Fixing Typos
- Upload CSV with 50 shops
- Notice "Jone" instead of "John" in owner name
- Edit directly on preview screen
- Import clean data

### Use Case 2: Selective Import
- Upload CSV with 100 shops
- Only want to import shops for Route #3
- Uncheck all others (or use route filter)
- Import only the 20 selected shops

### Use Case 3: Remove Duplicates
- Upload CSV with some duplicate shops
- Review and identify duplicates
- Click trash icon to remove them
- Import only unique shops

### Use Case 4: Wrong CSV File
- Upload wrong CSV file
- Realize mistake on preview screen
- Click "Cancel Import"
- Upload correct file

## CSV Format Reminder

CSV should have these columns:
```
name, owner_name, phone, address, route_id, shop_type
```

Example:
```csv
name,owner_name,phone,address,route_id,shop_type
Al Madina GS,Ahmed Ali,03001234567,Main Bazar,1,retail
Best Traders,Khan,03009876543,Adda Khurrianwala,2,wholesale
```

## Future Enhancements (Optional)

Possible additions:
- 📊 Bulk edit (change route for multiple selected shops)
- 🔍 Filter/search within preview table
- 📁 Save edited CSV for later
- 🔄 Duplicate detection with highlighting
- ✅ Validation warnings (e.g., phone format)
- 📱 Mobile-friendly preview table

## Testing Checklist

After restarting server, test:

1. **Upload CSV**
   - [ ] Valid CSV redirects to preview
   - [ ] Invalid CSV shows error
   - [ ] Empty CSV shows error

2. **Preview Screen**
   - [ ] All shops displayed correctly
   - [ ] Select All works
   - [ ] Individual checkboxes work
   - [ ] Counter updates correctly

3. **Editing**
   - [ ] Can edit shop name
   - [ ] Can change route
   - [ ] Can change shop type
   - [ ] Required fields enforced

4. **Delete/Undelete**
   - [ ] Trash icon marks row as deleted
   - [ ] Deleted row becomes gray/crossed
   - [ ] Click again to restore
   - [ ] Checkbox disabled when deleted

5. **Import Confirmation**
   - [ ] Only selected shops imported
   - [ ] Edited values saved correctly
   - [ ] Success message shown
   - [ ] Redirects to shops list

6. **Cancel**
   - [ ] Cancel button works
   - [ ] No data imported
   - [ ] Session cleared
   - [ ] Redirects to shops list

## Restart Required

**Important**: Restart the server to activate this feature!

```bash
# Stop the server (Ctrl+C)
# Restart:
npm start
```
