# 🧪 PDF GENERATION - TEST GUIDE

> **Date:** December 16, 2025  
> **Status:** Fixed & Ready for Testing

---

## 🎯 WHAT WAS FIXED

### Problem

- Print dialog tidak muncul saat click "Export PDF"
- Error: "cannot print pdf"
- Format laporan tidak generate

### Root Cause

- Used `Printing.layoutPdf()` which only shows preview
- Tidak ada actual print/save dialog

### Solution

- Changed to `Printing.sharePdf()`
- Now opens native share/print dialog
- User dapat print, save, atau share PDF

---

## 🧪 HOW TO TEST

### Step 1: Build & Run App

```bash
flutter pub get
flutter run
```

### Step 2: Navigate to Tax Center

1. Login dengan credentials:

   - Email: `admin@toko.com`
   - Password: `admin123`

2. Go to **Admin Dashboard**

3. Click **Tax Center** (atau swipe ke Tax Center screen)

### Step 3: Export PDF

1. Go to **Laporan** tab (should be default)

2. Verify data displays:

   - ✅ Month selector
   - ✅ Profit/Loss card dengan:
     - Total Omset
     - Total HPP
     - Total Pengeluaran
     - Profit Bersih
     - Margin percentage
   - ✅ Tier breakdown section

3. Click **"Export PDF"** button (biru, dengan icon PDF)

### Step 4: Verify Print Dialog

**Expected Behavior:**

```
Click "Export PDF"
    ↓
Show "Generating PDF..." snackbar
    ↓
Native share/print dialog opens
    ↓
User dapat:
  - Print to printer
  - Save as PDF
  - Share via email
  - Open with other apps
    ↓
Success snackbar: "PDF berhasil dibuat"
```

### Step 5: Test Print/Save Options

#### Option A: Save as PDF

1. Click "Export PDF"
2. Dialog opens
3. Select "Save to Files" atau "Save as PDF"
4. Choose location
5. Verify file saved dengan nama: `Laporan_Laba_Rugi_12_2025.pdf`

#### Option B: Print

1. Click "Export PDF"
2. Dialog opens
3. Select printer
4. Click "Print"
5. Verify print job sent

#### Option C: Share

1. Click "Export PDF"
2. Dialog opens
3. Select "Share"
4. Choose app (Gmail, WhatsApp, etc.)
5. Verify PDF attached

---

## ✅ VERIFICATION CHECKLIST

### UI Elements

- [ ] "Export PDF" button visible di Laporan tab
- [ ] Button has PDF icon
- [ ] Button is clickable

### PDF Generation

- [ ] "Generating PDF..." snackbar shows
- [ ] No error messages
- [ ] Dialog opens within 2-3 seconds

### Print Dialog

- [ ] Native share/print dialog appears
- [ ] Dialog shows PDF preview (if available)
- [ ] Options visible:
  - [ ] Print
  - [ ] Save
  - [ ] Share
  - [ ] Cancel

### PDF Content (if saved)

- [ ] Header section:

  - [ ] Business name: "PosFELIX - Toko Suku Cadang Motor"
  - [ ] Title: "Laporan Laba/Rugi"
  - [ ] Period: "Desember 2025" (or current month)
  - [ ] Date: "16 Desember 2025" (or current date)

- [ ] Summary section:

  - [ ] Total Omset: Rp format
  - [ ] Total HPP: Rp format
  - [ ] Laba Kotor: Rp format
  - [ ] Total Pengeluaran: Rp format
  - [ ] LABA BERSIH: Rp format (bold)

- [ ] Tier breakdown table:

  - [ ] Header row (gray background)
  - [ ] Umum row
  - [ ] Bengkel row
  - [ ] Grossir row
  - [ ] TOTAL row (light gray background)
  - [ ] All values in Rp format
  - [ ] Proper alignment (right-aligned for numbers)

- [ ] Footer:
  - [ ] "Laporan ini dibuat secara otomatis oleh sistem PosFELIX"

### Error Handling

- [ ] Test with different months
- [ ] Test with zero data
- [ ] Test with large numbers
- [ ] Cancel dialog - no errors
- [ ] Network error - graceful handling

---

## 🐛 TROUBLESHOOTING

### Issue: Dialog Still Not Appearing

**Symptoms:** Click button, nothing happens

**Solutions:**

1. Check device has print services enabled
2. Try on different device/emulator
3. Check device permissions (storage, print)
4. Restart app
5. Check logs for errors

### Issue: PDF Content Wrong

**Symptoms:** PDF shows wrong data or formatting

**Solutions:**

1. Verify data in Tax Center screen is correct
2. Check month/year selector
3. Verify currency formatting (should be Rp)
4. Check if data is loading (wait for data to load)

### Issue: File Not Saving

**Symptoms:** Save option selected but file not created

**Solutions:**

1. Check device storage space
2. Check file permissions
3. Try different save location
4. Check if file manager can access saved files

### Issue: Print Not Working

**Symptoms:** Print option selected but nothing prints

**Solutions:**

1. Verify printer is connected
2. Check printer is online
3. Try print to PDF instead
4. Check printer permissions

---

## 📊 TEST SCENARIOS

### Scenario 1: Happy Path

```
1. Login as admin
2. Go to Tax Center
3. View Laporan tab
4. Click Export PDF
5. Dialog opens
6. Save as PDF
7. Verify file created
8. Open PDF in reader
9. Verify content correct
```

**Expected Result:** ✅ PDF generated and saved successfully

### Scenario 2: Different Month

```
1. Login as admin
2. Go to Tax Center
3. Change month to "November 2025"
4. Click Export PDF
5. Dialog opens
6. Save as PDF
7. Verify filename: Laporan_Laba_Rugi_11_2025.pdf
8. Open PDF
9. Verify period shows "November 2025"
```

**Expected Result:** ✅ PDF generated with correct month

### Scenario 3: Print to Printer

```
1. Login as admin
2. Go to Tax Center
3. Click Export PDF
4. Dialog opens
5. Select printer
6. Click Print
7. Verify print job sent
```

**Expected Result:** ✅ Print job sent to printer

### Scenario 4: Share via Email

```
1. Login as admin
2. Go to Tax Center
3. Click Export PDF
4. Dialog opens
5. Select "Share"
6. Select Gmail
7. Verify PDF attached
8. Send email
```

**Expected Result:** ✅ PDF attached to email

---

## 📝 TEST RESULTS TEMPLATE

```
Date: _______________
Tester: _______________
Device: _______________
OS Version: _______________

Test Case 1: Export PDF Button
- Button visible: [ ] Yes [ ] No
- Button clickable: [ ] Yes [ ] No
- Result: _______________

Test Case 2: Print Dialog
- Dialog appears: [ ] Yes [ ] No
- Dialog shows options: [ ] Yes [ ] No
- Result: _______________

Test Case 3: Save PDF
- File saved: [ ] Yes [ ] No
- Filename correct: [ ] Yes [ ] No
- File location: _______________
- Result: _______________

Test Case 4: PDF Content
- Header correct: [ ] Yes [ ] No
- Summary correct: [ ] Yes [ ] No
- Table correct: [ ] Yes [ ] No
- Footer correct: [ ] Yes [ ] No
- Result: _______________

Overall Result: [ ] PASS [ ] FAIL

Issues Found:
1. _______________
2. _______________
3. _______________

Notes:
_______________
_______________
```

---

## 🚀 DEPLOYMENT CHECKLIST

Before deploying to production:

- [ ] All tests passed
- [ ] No console errors
- [ ] No console warnings
- [ ] Tested on multiple devices
- [ ] Tested on different Android versions
- [ ] Tested on iOS (if applicable)
- [ ] Print dialog works
- [ ] Save functionality works
- [ ] Share functionality works
- [ ] PDF content correct
- [ ] Currency formatting correct
- [ ] Error handling works
- [ ] User feedback messages clear
- [ ] Performance acceptable (< 3 sec to generate)

---

## 📞 SUPPORT

If you encounter issues:

1. Check this guide first
2. Check error logs in console
3. Try on different device
4. Check device permissions
5. Restart app
6. Clear app cache
7. Reinstall app if needed

---

_Test Guide Status: READY_  
_Last Updated: December 16, 2025_  
_Prepared by: Kiro AI Assistant_
