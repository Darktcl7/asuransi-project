# 🛡️ POLICY CREATION - Testing Guide

**Date:** 22 November 2025  
**Feature:** Policy Creation Flow (Device Selection → Purchase)  
**Status:** ✅ **READY TO TEST**

---

## 🎯 WHAT'S NEW

### ✅ **Updated Tier Pricing Logic:**

**OLD Logic:**
- Standar: 1jt - 5jt → Rp 150k
- Gold: 5jt - 10jt → Rp 300k
- Premium: 10jt+ → Rp 500k

**NEW Logic (ACTIVE NOW):**
- **Standar**: Rp 1.5jt - 3jt → Policy: Rp 150k, Deduction: 10%
- **Gold**: Rp 3jt - 5jt → Policy: Rp 250k, Deduction: 5%
- **Premium**: Rp 5jt+ → Policy: Rp 500k, Deduction: 0%

---

## 📱 FEATURES IMPLEMENTED

### 1. **Device Selection Screen**
```
✅ List 19 devices (Apple, Samsung, Xiaomi, OPPO, Vivo)
✅ Search/filter devices
✅ Brand icons & colors
✅ Display device price
✅ Navigation to purchase screen
```

### 2. **Policy Purchase Screen**
```
✅ Device info display
✅ IMEI input (15 digits, validation)
✅ Purchase price input (auto-filled)
✅ Tier auto-detection based on price (NEW LOGIC)
✅ Tier benefits display
✅ Wallet balance check
✅ Balance calculation (before/after)
✅ Confirmation dialog
✅ Wallet deduction on purchase
✅ Success/error handling
```

### 3. **Dashboard Updates**
```
✅ Floating Action Button "Beli Polis"
✅ Navigation to device selection
✅ Auto-refresh after purchase
```

---

## 🧪 TESTING SCENARIOS

### **Scenario 1: Buy Policy - Standar Tier (1.5jt - 3jt)**

**Test Case:**
1. Start Django server
2. Login dengan user test
3. Tap "Beli Polis" button
4. Pilih device: **Xiaomi Redmi Note 13 Pro** (Rp 3,499,000)
5. Input IMEI: `123456789012345`
6. Price auto-filled: `3499000`
7. **Expected Tier:** Standar ❌ (seharusnya Gold karena 3,499,000 > 3jt)

**CORRECTION:** Xiaomi Redmi Note 13 Pro = Rp 3,499,000 → **Gold Tier** (3jt - 5jt)

Mari coba lagi:
- Pilih device: **Vivo V29** (Rp 4,499,000) → **Gold Tier** ✅
- Pilih device: **Samsung Galaxy A54** (Rp 4,999,000) → **Gold Tier** ✅

**Untuk Standar Tier, device yang cocok:**
- ⚠️ NONE! (Semua device di seed data > 3jt atau < 1.5jt)

**RECOMMENDATION:** Tambah device di range 1.5jt - 3jt untuk test Standar tier.

---

### **Scenario 2: Buy Policy - Gold Tier (3jt - 5jt)**

**Test Case:**
1. Login dengan user test
2. Tap "Beli Polis"
3. Pilih device: **Samsung Galaxy A54** (Rp 4,999,000)
4. Input IMEI: `123456789012345`
5. Price auto-filled: `4999000`
6. **Expected Tier:** Gold ✅
7. **Expected Policy Price:** Rp 250,000
8. **Expected Deduction:** 5%
9. Tap "BELI POLIS SEKARANG"
10. Confirm purchase
11. **Expected Result:**
    - Success message
    - Wallet balance: -Rp 250,000
    - Policy created (visible in dashboard)
    - Navigate back to dashboard

---

### **Scenario 3: Buy Policy - Premium Tier (5jt+)**

**Test Case:**
1. Login dengan user test
2. Tap "Beli Polis"
3. Pilih device: **iPhone 15 Pro Max** (Rp 21,999,000)
4. Input IMEI: `999888777666555`
5. Price auto-filled: `21999000`
6. **Expected Tier:** Premium ✅
7. **Expected Policy Price:** Rp 500,000
8. **Expected Deduction:** 0% (gratis klaim!)
9. Check balance: Must have >= Rp 500,000
10. Tap "BELI POLIS SEKARANG"
11. Confirm purchase
12. **Expected Result:**
    - Success message
    - Wallet balance: -Rp 500,000
    - Policy created
    - Dashboard refreshed

---

### **Scenario 4: Insufficient Balance**

**Test Case:**
1. Login dengan user yang balance < policy price
2. Tap "Beli Polis"
3. Pilih device mahal: **Samsung Galaxy Z Fold 5** (Rp 24,999,000)
4. **Expected Tier:** Premium (Rp 500,000)
5. If balance < Rp 500,000:
   - Button shows: "SALDO TIDAK CUKUP - TOP UP DULU"
   - Button disabled (grey)
   - Red warning card: "Saldo tidak cukup! Kurang Rp XXX"
6. User cannot purchase

---

### **Scenario 5: IMEI Validation**

**Test Case:**
1. Try submit with empty IMEI
   - **Expected:** Error "IMEI wajib diisi"

2. Try submit with IMEI < 15 digits (e.g., `12345`)
   - **Expected:** Error "IMEI harus 15 digit"

3. Try submit with IMEI = 15 digits + letters (e.g., `12345678901234A`)
   - **Expected:** Input blocked (only digits allowed)

4. Submit with valid IMEI (e.g., `123456789012345`)
   - **Expected:** Validation passed ✅

---

## 📊 TEST DATA

### **Test User (Has Balance):**
```
Email: testuser20251122124718@example.com
Password: testing123
Balance: Rp 750,000
```

**What can buy:**
- Gold tier devices (Rp 250k) ✅
- Standar tier devices (Rp 150k) ✅
- Premium tier (Rp 500k) ❌ Insufficient

### **New User (Fresh Account):**
```
Email: ardy@gamil.com
Password: 12345678
Balance: Rp 0
```

**Needs:**
- Top-up first before buy policy

---

## 🔧 HOW TO TEST

### **Step 1: Start Django Server**
```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### **Step 2: Run Flutter App**

**Option A: Chrome (Easiest)**
```bash
cd "D:\Django Project\Asuransi Project\phone_insurance_app"
flutter run -d chrome
```

**Option B: Android Device**
```bash
flutter run -d 10DF9A05880001M
```

### **Step 3: Login**
- Email: `testuser20251122124718@example.com`
- Password: `testing123`

### **Step 4: Test Policy Purchase**
1. Dashboard screen → Tap "Beli Polis" (FAB button)
2. Device selection → Browse/search devices
3. Tap device → Policy purchase screen
4. Fill IMEI (15 digits)
5. Verify tier auto-detection
6. Check balance sufficient
7. Tap "BELI POLIS SEKARANG"
8. Confirm dialog
9. Wait for success
10. Dashboard auto-refreshes

### **Step 5: Verify in Dashboard**
- Policy should appear in "Polis Aktif Anda"
- Wallet balance should decrease by policy price
- Pull-to-refresh to update

---

## 🎯 TIER AUTO-DETECTION LOGIC

**In Code: `policy_purchase_screen.dart`**

```dart
void _detectTier() {
  final price = double.parse(_priceController.text);
  
  _selectedTier = _tiers.firstWhere(
    (tier) => tier.canCoverDevice(price),
    orElse: () => _tiers.last,
  );
}
```

**In Model: `policy_tier.dart`**

```dart
bool canCoverDevice(double devicePrice) {
  return devicePrice >= minPrice && devicePrice <= maxPrice;
}
```

**Database Tiers (Updated):**
```
Standar:  1,500,000 - 3,000,000
Gold:     3,000,001 - 5,000,000
Premium:  5,000,001 - 99,999,999
```

---

## 🐛 KNOWN ISSUES

### **Issue 1: No Devices for Standar Tier (1.5jt - 3jt)**

**Problem:** Semua devices di seed data > 3jt atau < 1.5jt

**Workaround:**
- Manually edit purchase price ke range 1.5jt - 3jt
- Or add device di seed data (e.g., Redmi 12 = Rp 2,000,000)

**Devices Available:**
- **Gold (3jt-5jt):** A54 (4.9jt), V29 (4.4jt), Reno 11 (4.9jt), Redmi Note 13 Pro (3.4jt)
- **Premium (5jt+):** Semua iPhone, S24 series, Xiaomi 14 Pro, dll

---

## ✅ SUCCESS CRITERIA

### **Policy Creation Complete if:**
```
✅ User can browse 19 devices
✅ User can search/filter devices
✅ User can select device
✅ IMEI validation works (15 digits)
✅ Tier auto-detected correctly based on NEW logic
✅ Wallet balance checked
✅ Insufficient balance blocked
✅ Purchase confirmation works
✅ API call successful (POST /api/policies/)
✅ Wallet deducted correctly
✅ Policy appears in dashboard
✅ Dashboard auto-refreshes
```

---

## 📝 API ENDPOINTS USED

### **1. GET /api/device-packages/**
- Returns: List of 19 devices
- Auth: Not required (public)

### **2. GET /api/policy-tiers/**
- Returns: List of 3 tiers (with NEW pricing)
- Auth: Not required (public)

### **3. GET /api/wallet/**
- Returns: User wallet balance
- Auth: Required (Token)

### **4. POST /api/policies/**
**Request:**
```json
{
  "device_package": "uuid",
  "imei_number": "123456789012345",
  "purchase_price": 4999000
}
```

**Response (Success 201):**
```json
{
  "id": "uuid",
  "device_brand": "Samsung",
  "device_model": "Galaxy A54",
  "tier_name": "Gold",
  "policy_price": "250000.00",
  "status": "active",
  "expiry_date": "2026-11-22",
  "claims_used": 0,
  "claims_limit": 5
}
```

**Backend Logic:**
1. Validate IMEI (15 digits)
2. Validate purchase price (> 0)
3. Detect tier based on purchase price (NEW LOGIC)
4. Check wallet balance >= policy price
5. Deduct wallet balance
6. Create policy
7. Create wallet history entry
8. Return policy data

---

## 🎊 CONCLUSION

**Policy Creation Flow:** ✅ **COMPLETE**

**Total Time:** ~4 hours (including tier logic update)

**Lines of Code:** ~400+ lines (2 screens)

**Next Steps:**
1. Test on real device ✅
2. Add more devices for Standar tier (optional)
3. Move to Claim Creation feature 🚀

---

**Happy Testing!** 🎉

**Last Updated:** 22 November 2025  
**Version:** 2.0.0
