# 💰 WALLET HISTORY - Testing Guide

**Date:** 22 November 2025  
**Feature:** Wallet Transaction History  
**Status:** ✅ **READY TO TEST**

---

## 🎯 WHAT'S BEEN IMPLEMENTED

### ✅ **Wallet History Screen Complete:**

**Features:**
- ✅ List all wallet transactions (newest first)
- ✅ Filter by type: All / Top Up / Beli Polis / Potongan
- ✅ Show transaction details:
  - Type (icon + color coded)
  - Amount (+ green for credit, - red for debit)
  - Description
  - Date & time
  - Balance before/after
- ✅ Tap transaction → Full detail bottom sheet
- ✅ Pull to refresh
- ✅ Empty state
- ✅ Color coding:
  - 🟢 Green: Top Up (credit)
  - 🔴 Red: Deduction, Policy Purchase (debit)
  - 🔵 Blue: Refund
  - 🟠 Orange: Adjustment

**Navigation:**
- ✅ Wallet card (tap anywhere) → History
- ✅ Wallet card shows history icon hint

---

## 📱 TRANSACTION TYPES

### **1. Top Up (Credit)**
```
Icon: ➕ Add Circle (Green)
Amount: + Rp 1,000,000
Description: "Top up approved"
Type: CREDIT
```

### **2. Policy Purchase (Debit)**
```
Icon: 🛒 Shopping Cart (Red)
Amount: - Rp 250,000
Description: "Pembelian polis POL-..."
Type: DEBIT
```

### **3. Claim Deduction (Debit)**
```
Icon: ➖ Remove Circle (Red)
Amount: - Rp 75,000
Description: "Deduksi klaim CLM-..."
Type: DEBIT
```

### **4. Refund (Credit)**
```
Icon: 🔄 Refresh (Blue)
Amount: + Rp 100,000
Description: "Refund untuk..."
Type: CREDIT
```

### **5. Adjustment (Either)**
```
Icon: 🎛️ Tune (Orange)
Amount: +/- Rp xxx
Description: "Penyesuaian saldo..."
Type: CREDIT/DEBIT
```

---

## 🧪 TESTING SCENARIOS

### **Prerequisite: Have Some Transactions**

User should have already done:
1. ✅ Top-up at least once (Rp 1,000,000)
2. ✅ Buy policy (Samsung A54 - Rp 250,000)
3. ✅ Submit claim (optional)

Expected transactions in history:
- Top Up: + Rp 1,000,000
- Policy Purchase: - Rp 250,000
- Current balance: Rp 750,000

---

### **Scenario 1: View All Transactions**

**Test User:** `testuser20251122124718@example.com` / `testing123`

**Steps:**
1. Login to dashboard
2. **Tap wallet card** (anywhere on purple gradient)
3. Wallet History Screen opens
4. **Expected to see:**
   - Filter chips: Semua (2), Top Up (1), Beli Polis (1), Potongan (0)
   - 2 transactions:
     - 🛒 Policy Purchase: -Rp 250,000 (red)
     - ➕ Top Up: +Rp 1,000,000 (green)
   - Sorted newest first

---

### **Scenario 2: Filter Transactions**

**Steps:**
1. On Wallet History Screen
2. **Test Filters:**
   - Tap "Semua" → Shows all transactions
   - Tap "Top Up" → Shows only top-up (green)
   - Tap "Beli Polis" → Shows only policy purchases (red)
   - Tap "Potongan" → Shows only deductions (red)
3. **Expected:**
   - Filter chip changes color when selected (indigo)
   - Transaction list updates
   - Empty state if no transactions for that type

---

### **Scenario 3: View Transaction Detail**

**Steps:**
1. Wallet History Screen
2. **Tap any transaction card**
3. **Bottom sheet opens** showing:
   - Large icon (top)
   - Transaction type label
   - Jumlah: +/- amount
   - Saldo Sebelum: balance before
   - Saldo Setelah: balance after (indigo color)
   - Tanggal: full date & time
   - Deskripsi: full description
   - Reference ID (if any)
   - Reference Type (if any)
4. **Drag down or tap "Tutup"** to close

---

### **Scenario 4: Pull to Refresh**

**Steps:**
1. Wallet History Screen
2. **Pull down** from top
3. Loading indicator appears
4. Transaction list refreshes
5. **Expected:** Latest transactions shown

---

### **Scenario 5: Empty State**

**Test with new user** (no transactions yet):

**Steps:**
1. Create new user or test with fresh account
2. Navigate to Wallet History
3. **Expected:**
   - Empty state icon (history clock)
   - "Belum Ada Transaksi"
   - "Riwayat transaksi Anda akan muncul di sini"
   - All filter chips show (0)

---

### **Scenario 6: Transaction Flow Tracking**

**Full Flow Test:**

1. **Start:** Check current balance (e.g., Rp 750,000)
2. **Action:** Buy another policy
   - Device: Xiaomi Redmi Note 13 Pro (Rp 3.4jt - Gold tier)
   - Policy price: Rp 250,000
3. **Check History:**
   - New transaction appears: "Pembelian polis POL-xxx"
   - Amount: -Rp 250,000
   - Balance Before: Rp 750,000
   - Balance After: Rp 500,000 ✅
4. **Dashboard:** Balance updated to Rp 500,000 ✅

---

## 📊 EXPECTED DATA STRUCTURE

### **Transaction Card Display:**
```
┌─────────────────────────────────────┐
│  [🛒]  Beli Polis                   │ +Rp 250,000
│        Pembelian polis POL-xxx      │ [DEBIT]
│        22 Nov 2025 18:18            │
└─────────────────────────────────────┘
```

### **Detail Bottom Sheet:**
```
┌─────────────────────────────────────┐
│         [🛒]                         │
│  Detail Transaksi                   │
│  Beli Polis                         │
├─────────────────────────────────────┤
│  Jumlah          : - Rp 250,000     │ (Red)
│  Saldo Sebelum   : Rp 1,000,000     │
│  Saldo Setelah   : Rp 750,000       │ (Indigo)
│  Tanggal         : 22 Nov 2025 18:18│
│                                     │
│  Deskripsi:                         │
│  Pembelian polis POL-20251122...    │
│                                     │
│  Reference ID    : policy-uuid      │
│  Reference Type  : policy           │
│                                     │
│  [        Tutup        ]            │
└─────────────────────────────────────┘
```

---

## 🔧 HOW TO TEST

### **Step 1: Ensure Backend Running**
```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### **Step 2: Hot Restart Flutter**
```
Press: R (uppercase)
```

Or restart app:
```bash
flutter run -d 10DF9A05880001M
```

### **Step 3: Test Wallet History**

**Quick Test Flow:**
1. Login → Dashboard
2. **Tap wallet card** (purple gradient)
3. Wallet History opens ✅
4. See transactions with colors
5. Tap transaction → Detail sheet
6. Test filters
7. Pull to refresh

---

## 📝 API ENDPOINT USED

### **GET /api/wallet/history/**

**Request:**
```
Headers:
  Authorization: Token {user-token}
```

**Response (Success 200):**
```json
[
  {
    "id": "uuid",
    "wallet": "wallet-uuid",
    "transaction_type": "policy_purchase",
    "amount": "-250000.00",
    "balance_before": "1000000.00",
    "balance_after": "750000.00",
    "description": "Pembelian polis POL-20251122...",
    "reference_id": "policy-uuid",
    "reference_type": "policy",
    "created_at": "2025-11-22T18:18:00Z"
  },
  {
    "id": "uuid",
    "wallet": "wallet-uuid",
    "transaction_type": "topup",
    "amount": "1000000.00",
    "balance_before": "0.00",
    "balance_after": "1000000.00",
    "description": "Top up approved",
    "reference_id": "topup-uuid",
    "reference_type": "topup",
    "created_at": "2025-11-22T12:30:00Z"
  }
]
```

---

## 🎨 UI/UX FEATURES

### **Color Coding:**
```
🟢 Green (Credit):
   - Top Up
   - Refund

🔴 Red (Debit):
   - Policy Purchase
   - Claim Deduction

🔵 Blue (Refund):
   - Refund transactions

🟠 Orange (Adjustment):
   - Admin adjustments
```

### **Typography:**
```
Transaction Type:   16px, Bold
Description:        13px, Grey 600
Date:               12px, Grey 500
Amount:             16px, Bold, Color-coded
Balance After:      14px, Bold, Indigo
```

### **Animations:**
```
✅ Card tap animation (InkWell ripple)
✅ Bottom sheet slide up
✅ Pull to refresh indicator
✅ List scroll physics
```

---

## ✅ SUCCESS CRITERIA

### **Wallet History Complete if:**
```
✅ User can view all transactions
✅ Transactions sorted newest first
✅ Color coding correct (green/red/blue/orange)
✅ Amount shows +/- correctly
✅ Filter by type works
✅ Filter count accurate
✅ Tap transaction shows detail
✅ Detail shows all info (amount, balances, description, reference)
✅ Pull to refresh works
✅ Empty state displays correctly
✅ Navigation from dashboard works
✅ Balance calculations accurate
```

---

## 💡 BUSINESS RULES

### **Transaction Recording:**
```
Every wallet change creates history:
✅ Top-up approved → + credit
✅ Policy purchase → - debit
✅ Claim deduction → - debit
✅ Refund → + credit
✅ Admin adjustment → +/- either
```

### **Balance Tracking:**
```
balance_after = balance_before + amount

Example:
Balance Before: Rp 1,000,000
Amount: -Rp 250,000 (policy)
Balance After: Rp 750,000 ✅
```

---

## 🎊 COMPLETION STATUS

**Wallet History Feature:** ✅ **100% COMPLETE**

**Files Created:**
- `models/wallet_transaction.dart` (~100 lines)
- `screens/wallet/wallet_history_screen.dart` (~550 lines)

**Files Modified:**
- `api_service.dart` - Added getWalletHistory()
- `dashboard_screen.dart` - Wallet card clickable with hint
- `main.dart` - Added /wallet-history route

**Total Lines of Code:** ~650+ lines

**Time Spent:** ~1.5 hours

---

## 🚀 NEXT STEPS (Optional)

**Features 100% Complete! 🎉**

**Remaining Optional Polish:**
1. Profile Screen (1 hour)
   - User info display
   - Settings
   - Logout button

2. UI/UX Polish (2-3 hours)
   - Loading animations
   - Error illustrations
   - Dark mode
   - Onboarding screens

3. Production Deployment (1 day)
   - Backend to cloud
   - Build release APK
   - Play Store submission

---

**Happy Testing!** 💰✨

**Last Updated:** 22 November 2025  
**Version:** 4.0.0 - WALLET HISTORY COMPLETE
