# 🛡️ CLAIM CREATION - Testing Guide

**Date:** 22 November 2025  
**Feature:** Claim Creation Flow (Select Policy → Form → History)  
**Status:** ✅ **READY TO TEST**

---

## 🎯 WHAT'S BEEN IMPLEMENTED

### ✅ **Complete Claim Creation Flow:**

**3 New Screens:**
1. **Select Policy Screen** - Pilih polis mana yang mau di-claim
2. **Claim Form Screen** - Isi detail kerusakan & jumlah klaim
3. **Claim History Screen** - Lihat semua riwayat klaim

**Dashboard Updates:**
- Quick Actions: "Beli Polis" & "Ajukan Klaim"
- AppBar action: Icon "Riwayat Klaim"

---

## 📱 FEATURES DETAIL

### 1. **Select Policy Screen**
```
✅ List active policies only
✅ Show device info (brand, model, IMEI)
✅ Show tier badge with color coding
✅ Display remaining claims quota
✅ Display expiry date
✅ Disable policies with quota habis
✅ Empty state if no active policies
✅ Navigation to claim form
```

### 2. **Claim Form Screen**
```
✅ Display selected policy info
✅ Damage type dropdown (8 options):
   - Layar Pecah
   - LCD Rusak
   - Kerusakan Air
   - Baterai Rusak
   - Kamera Rusak
   - Port Charging Rusak
   - Kehilangan
   - Lainnya
✅ Description textarea (min 20 characters, max 500)
✅ Incident date picker (max today)
✅ Claim amount input (numeric only)
✅ Deduction calculation preview:
   - Standar: 10% deduction
   - Gold: 5% deduction
   - Premium: 0% deduction (FREE!)
✅ Wallet deduction warning
✅ Confirmation dialog before submit
✅ Form validation
✅ Success/error handling
```

### 3. **Claim History Screen**
```
✅ List all user claims (newest first)
✅ Filter by status: All, Pending, Approved, Rejected
✅ Status badge with color coding:
   - Pending: Orange
   - Approved: Green
   - Rejected: Red
✅ Display claim details:
   - Device name
   - Damage type
   - Claim amount
   - Deduction amount
   - Status
   - Dates
✅ Show admin notes (if rejected)
✅ Tap to show full detail (bottom sheet)
✅ Pull to refresh
✅ Empty state
```

---

## 🧪 TESTING SCENARIOS

### **Prerequisite: User Must Have Active Policy**

**If no active policy:**
1. Login to app
2. Dashboard → Tap "Beli Polis"
3. Select device (e.g., Samsung A54 - Rp 4.9jt)
4. Enter IMEI: `123456789012345`
5. Purchase policy (Rp 250k deducted)
6. Now you have 1 active policy ✅

---

### **Scenario 1: Create Claim - Gold Tier (5% Deduction)**

**Test User:** `testuser20251122124718@example.com` / `testing123`

**Steps:**
1. Login to dashboard
2. **Option A:** Tap "Ajukan Klaim" quick action card
   **Option B:** Tap appbar icon "Riwayat Klaim" → (if empty) → use back button → use quick action
3. Select policy screen shows: Samsung A54 (Gold tier, 5/5 claims)
4. Tap "Ajukan Klaim" button
5. Claim Form Screen:
   - **Damage Type:** Select "Layar Pecah"
   - **Description:** "Layar pecah karena terjatuh dari meja. Retak di bagian kiri atas layar. Touch screen masih berfungsi tapi ada goresan."
   - **Incident Date:** Select kemarin atau hari ini
   - **Claim Amount:** `1500000` (Rp 1.5 juta)
6. **Expected Calculation:**
   - Jumlah Klaim: Rp 1,500,000
   - Potongan (5%): Rp 75,000
   - Anda Bayar: Rp 75,000
7. Tap "AJUKAN KLAIM"
8. **Confirmation Dialog** shows breakdown
9. Confirm → Submit
10. **Expected Result:**
    - Success message: "Klaim berhasil diajukan! Menunggu persetujuan admin."
    - Navigate back to dashboard
    - Wallet deducted Rp 75,000 (5% of 1.5jt)
    - Claim status: **PENDING**

---

### **Scenario 2: Create Claim - Premium Tier (0% Deduction)**

**Prerequisite:** User must have Premium tier policy (device > Rp 5jt)

**Steps:**
1. Buy policy for expensive device: iPhone 15 Pro Max (Rp 21.9jt)
   - Policy price: Rp 500k
   - Tier: Premium
2. Dashboard → "Ajukan Klaim"
3. Select iPhone policy
4. Claim Form:
   - Damage Type: "Kehilangan"
   - Description: "HP hilang di transportasi umum. Sudah coba lacak tapi tidak ketemu. Sudah lapor polisi."
   - Incident Date: Today
   - Claim Amount: `5000000` (Rp 5 juta)
5. **Expected Calculation:**
   - Jumlah Klaim: Rp 5,000,000
   - Potongan (0%): Rp 0
   - Anda Bayar: Rp 0
   - Info: "✓ Tier Premium - Klaim gratis tanpa potongan!"
6. Submit → Confirm
7. **Expected Result:**
   - Success message
   - Wallet: **NO DEDUCTION** (Premium tier)
   - Claim status: PENDING

---

### **Scenario 3: View Claim History**

**Steps:**
1. Dashboard → Tap icon "Riwayat Klaim" di appbar
2. **Expected:** List all claims
3. **Filter Test:**
   - Tap "Pending" chip → Shows only pending claims
   - Tap "Approved" chip → Shows only approved claims
   - Tap "Rejected" chip → Shows only rejected claims
   - Tap "Semua" chip → Shows all claims
4. **Detail Test:**
   - Tap any claim card
   - Bottom sheet shows full details
   - All info displayed correctly
   - Close button works

---

### **Scenario 4: Admin Approve Claim**

**Admin Portal Required (Django Admin or API)**

**Via Django Admin:**
1. Open browser: `http://192.168.100.4:8000/admin/`
2. Login: `chluik277@gmail.com` / `adminsmile277`
3. Go to: Claims
4. Click pending claim
5. Change status to "approved"
6. Add admin notes (optional): "Klaim disetujui. Silakan ke service center."
7. Save
8. **Expected in App:**
   - User refresh claim history
   - Status changes to APPROVED (green badge)
   - Admin notes displayed (if any)

**Via API (Postman/curl):**
```bash
POST http://192.168.100.4:8000/api/admin/claims/{claim_id}/approve/
Headers:
  Authorization: Token {admin_token}
  Content-Type: application/json
Body:
{
  "admin_notes": "Approved. Proceed to service center."
}
```

---

### **Scenario 5: Policy Quota Limit**

**Test Policy Limits:**

**Gold Tier:** Max 5 claims/year
1. Create 5 claims for same policy
2. Try to create 6th claim
3. **Expected:** Policy card shows:
   - "Kuota klaim sudah habis"
   - Button disabled (red warning)
   - Cannot click to create claim

**Standar Tier:** Max 3 claims/year
**Premium Tier:** Max 10 claims/year

---

### **Scenario 6: Form Validation**

**Test All Validations:**

1. **Empty Damage Type:**
   - Don't select damage type
   - Submit → Error: "Pilih jenis kerusakan terlebih dahulu"

2. **Empty Description:**
   - Leave description blank
   - Submit → Error: "Deskripsi wajib diisi"

3. **Short Description:**
   - Type only 10 characters
   - Submit → Error: "Deskripsi minimal 20 karakter"

4. **Empty Claim Amount:**
   - Leave amount blank
   - Submit → Error: "Jumlah klaim wajib diisi"

5. **Invalid Amount:**
   - Enter `0` or negative
   - Submit → Error: "Jumlah harus lebih dari 0"

6. **Excessive Amount:**
   - Enter amount > 2× device value
   - Submit → Error: "Jumlah klaim terlalu besar"

---

## 📊 TEST DATA

### **Test User (Has Policy):**
```
Email: testuser20251122124718@example.com
Password: testing123
Current Balance: Rp 750,000 (after buying Samsung A54 policy)
Active Policies: 1 (Samsung Galaxy A54 - Gold Tier)
Policy Details:
  - Tier: Gold (5% deduction)
  - Price: Rp 250,000 (already paid)
  - Claims Quota: 5 per year
  - Claims Used: 0
```

### **Damage Type Options:**
```
1. 📱 Layar Pecah
2. 🖥️ LCD Rusak
3. 💧 Kerusakan Air
4. 🔋 Baterai Rusak
5. 📷 Kamera Rusak
6. 🔌 Port Charging Rusak
7. ❌ Kehilangan
8. ⚙️ Lainnya
```

### **Tier Deduction Logic:**
```
Standar (1.5jt-3jt):   10% deduction
Gold (3jt-5jt):        5% deduction
Premium (>5jt):        0% deduction (FREE!)
```

---

## 🔧 HOW TO TEST

### **Step 1: Start Django Server**
```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### **Step 2: Run Flutter App**

**Chrome:**
```bash
cd "D:\Django Project\Asuransi Project\phone_insurance_app"
flutter run -d chrome
```

**Android Device:**
```bash
flutter run -d 10DF9A05880001M
```

### **Step 3: Test Complete Flow**

**Full User Journey:**
```
1. Login
   ↓
2. (If no policy) Buy policy first
   ↓
3. Dashboard → "Ajukan Klaim"
   ↓
4. Select active policy
   ↓
5. Fill claim form
   ↓
6. Review calculation
   ↓
7. Confirm & submit
   ↓
8. Check claim in history
   ↓
9. (Admin) Approve claim
   ↓
10. User sees approved status
```

---

## 🎯 DEDUCTION CALCULATION LOGIC

**In Code: `claim_form_screen.dart`**

```dart
double get _deductionPercent {
  if (widget.policy.tierName?.toLowerCase() == 'standar') {
    return 10.0;
  } else if (widget.policy.tierName?.toLowerCase() == 'gold') {
    return 5.0;
  } else if (widget.policy.tierName?.toLowerCase() == 'premium') {
    return 0.0;
  }
  return 0.0;
}

double get _deductionAmount {
  return _claimAmount * (_deductionPercent / 100);
}
```

**Backend Logic (Django):**
```python
# When claim is created:
deduction_amount = claim_amount * (tier.claim_deduction_percent / 100)

# Wallet is deducted immediately:
wallet.balance -= deduction_amount
wallet.save()
```

---

## 📝 API ENDPOINTS USED

### **1. GET /api/policies/**
- Returns: List of user's policies
- Filter: Active policies only in UI

### **2. POST /api/claims/**
**Request:**
```json
{
  "policy": "policy-uuid",
  "damage_type": "Layar Pecah",
  "damage_description": "Layar pecah karena...",
  "incident_date": "2025-11-22",
  "claim_amount": 1500000
}
```

**Response (Success 201):**
```json
{
  "id": "claim-uuid",
  "policy": "policy-uuid",
  "device_brand": "Samsung",
  "device_model": "Galaxy A54",
  "damage_type": "Layar Pecah",
  "damage_description": "...",
  "incident_date": "2025-11-22",
  "claim_amount": "1500000.00",
  "deduction_amount": "75000.00",
  "status": "pending",
  "created_at": "2025-11-22T10:30:00Z"
}
```

**Backend Logic:**
1. Validate policy is active
2. Check claims quota not exceeded
3. Calculate deduction based on tier
4. Check wallet balance >= deduction
5. Deduct wallet balance
6. Create claim with status "pending"
7. Create wallet history entry
8. Return claim data

### **3. GET /api/claims/**
- Returns: List of all user's claims
- Sorted by created_at descending

### **4. POST /api/admin/claims/{id}/approve/**
**Request:**
```json
{
  "admin_notes": "Approved. Proceed to service center."
}
```

**Response:** Claim with status "approved"

### **5. POST /api/admin/claims/{id}/reject/**
**Request:**
```json
{
  "admin_notes": "Bukti tidak valid."
}
```

**Response:** Claim with status "rejected"

---

## ✅ SUCCESS CRITERIA

### **Claim Creation Complete if:**
```
✅ User can select active policy
✅ User can fill claim form (8 damage types)
✅ Date picker works (max today)
✅ Amount input validation works
✅ Deduction calculation correct (10%/5%/0%)
✅ Confirmation dialog shows breakdown
✅ API call successful (POST /api/claims/)
✅ Wallet deducted correctly
✅ Claim appears in history with "pending" status
✅ Claim history displays all claims
✅ Status filter works (all/pending/approved/rejected)
✅ Claim detail bottom sheet works
✅ Pull to refresh works
✅ Policy quota limit enforced
```

---

## 🐛 KNOWN ISSUES / NOTES

### **1. Admin Approval Process:**
- Currently requires Django admin or API call
- Future: Can add admin mobile app or web portal

### **2. Image Upload:**
- Not implemented yet
- Future: Add photo upload for:
  - Damage photos
  - Police report (for theft/loss)
  - Repair invoice

### **3. Real-time Updates:**
- User needs to manually refresh claim history
- Future: Add push notifications or WebSocket

### **4. Wallet Insufficient Balance:**
- User must have balance >= deduction amount
- Otherwise claim creation will fail
- User should top-up first

---

## 💡 BUSINESS RULES

### **Claim Eligibility:**
```
✅ Policy must be active
✅ Policy not expired
✅ Claims quota not exceeded
✅ Wallet balance >= deduction amount
✅ Incident date cannot be future
✅ Incident date should be within policy period
```

### **Deduction Rules:**
```
Standar Tier:
  - Device: Rp 1.5jt - 3jt
  - Policy: Rp 150k
  - Deduction: 10%
  - Max Claims: 3/year

Gold Tier:
  - Device: Rp 3jt - 5jt
  - Policy: Rp 250k
  - Deduction: 5%
  - Max Claims: 5/year

Premium Tier:
  - Device: > Rp 5jt
  - Policy: Rp 500k
  - Deduction: 0% (FREE!)
  - Max Claims: 10/year
```

---

## 🎊 COMPLETION STATUS

**Claim Creation Flow:** ✅ **100% COMPLETE**

**Total Time:** ~3 hours

**Files Created:**
- `models/claim.dart` (1 model)
- `screens/claim/select_policy_screen.dart` (~300 lines)
- `screens/claim/claim_form_screen.dart` (~600 lines)
- `screens/claim/claim_history_screen.dart` (~550 lines)

**Total Lines of Code:** ~1,500+ lines

**API Integration:** ✅ Complete
- getClaims()
- createClaim()

**UI/UX:** ✅ Complete
- Material Design 3
- Color-coded status badges
- Form validation
- Confirmation dialogs
- Loading states
- Empty states
- Pull to refresh
- Bottom sheet detail

---

## 🚀 NEXT STEPS

**Current Progress:**
```
✅ Backend: 100%
✅ Login/Register: 100%
✅ Dashboard: 100%
✅ Policy Creation: 100%
✅ Claim Creation: 100%
⏳ Wallet History: 0%
⏳ Profile Screen: 0%
```

**Remaining Features (Optional):**
1. **Wallet History Screen** (~1.5 hours)
   - List all transactions
   - Filter by type

2. **Profile Screen** (~1 hour)
   - User info display
   - Logout button
   - Settings

3. **Image Upload** (~2-3 hours)
   - Damage photos
   - Payment proof
   - KTP photo

4. **Push Notifications** (~3-4 hours)
   - Claim status updates
   - Policy expiry reminder

5. **Production Deployment** (~1 day)
   - Backend to cloud
   - Build APK
   - Testing

---

**Happy Testing!** 🎉

**Last Updated:** 22 November 2025  
**Version:** 3.0.0
