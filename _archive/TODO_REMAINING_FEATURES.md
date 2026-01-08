# 📋 TODO LIST - Fitur yang Belum Dibuat

**Project:** Phone Insurance App  
**Current Progress:** 82% Complete  
**Last Updated:** 22 November 2025

---

## 📊 STATUS OVERVIEW

```
✅ SELESAI (82%):
   ✅ Backend Django REST API - 100%
   ✅ Database & Models - 100%
   ✅ API Endpoints (14) - 100%
   ✅ Login Screen - 100%
   ✅ Register Screen - 100%
   ✅ Dashboard Screen - 80%
   ✅ Network Integration - 100%

⏳ BELUM SELESAI (18%):
   ⏳ Policy Screens - 0%
   ⏳ Claim Screens - 0%
   ⏳ Wallet History - 0%
   ⏳ Profile Screen - 0%
   ⏳ Image Upload - 0%
   ⏳ UI/UX Polish - 50%
```

---

## 🎯 PRIORITAS TINGGI - CORE FEATURES (Wajib Dibuat)

### **1. POLICY CREATION SCREENS** ⭐⭐⭐ **PALING PENTING**

**Estimasi Total: 3-4 jam**

#### **1.1 Device Selection Screen** 
**File:** `lib/screens/policy/device_selection_screen.dart`  
**Estimasi:** 1 jam

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: GET /api/device-packages/ (19 devices)

❌ Flutter perlu:
   - Screen untuk list 19 devices
   - Card untuk setiap device (brand, model, price)
   - Search/filter devices (optional)
   - Tap device → navigate ke form purchase
   - Loading state saat fetch data
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Pilih Device Anda              │
├─────────────────────────────────┤
│  🍎 Apple iPhone 15 Pro Max     │
│     Rp 21,999,000               │
├─────────────────────────────────┤
│  🍎 Apple iPhone 15 Pro         │
│     Rp 18,999,000               │
├─────────────────────────────────┤
│  📱 Samsung Galaxy S24 Ultra    │
│     Rp 18,999,000               │
└─────────────────────────────────┘
```

---

#### **1.2 Policy Purchase Form Screen**
**File:** `lib/screens/policy/policy_purchase_screen.dart`  
**Estimasi:** 1.5 jam

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: POST /api/policies/

❌ Flutter perlu:
   - Show selected device info
   - Input IMEI number (15 digits)
   - Input purchase price (auto-fill dari device value)
   - Tier auto-detection & display (berdasarkan harga)
   - Policy price display (dari tier)
   - Current balance display
   - Confirmation dialog sebelum submit
   - Loading state saat submit
   - Success/error handling
   
❌ Validasi:
   - IMEI must be 15 digits
   - Purchase price required
   - Balance must be sufficient
   - Policy price will be deducted
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Beli Polis Asuransi            │
├─────────────────────────────────┤
│  Device: iPhone 15 Pro Max      │
│  Harga Device: Rp 21,999,000    │
│                                 │
│  IMEI Number: [_______________] │
│  Purchase Price: [Rp 21,999,000]│
│                                 │
│  📊 Tier: Premium               │
│  💰 Harga Polis: Rp 500,000     │
│  🎯 Claim Gratis (0% potongan)  │
│  📅 Berlaku: 365 hari           │
│                                 │
│  Saldo Anda: Rp 1,000,000       │
│  Saldo Setelah: Rp 500,000      │
│                                 │
│  [    BELI POLIS SEKARANG   ]  │
└─────────────────────────────────┘
```

---

#### **1.3 Policy List/Detail Enhancement**
**File:** Update `lib/screens/dashboard_screen.dart`  
**Estimasi:** 30 menit

**Yang Perlu Ditambah:**
```dart
❌ Di Dashboard:
   - Tap policy card → show detail dialog/screen
   - Show more info: expiry date, tier name, claims left
   - Button "Buat Polis Baru" → navigate ke device selection

❌ Policy Detail Dialog (optional):
   - Full policy info
   - Device details
   - Tier benefits
   - Expiry date countdown
   - Button "Ajukan Klaim"
```

---

### **2. CLAIM CREATION SCREENS** ⭐⭐⭐ **PENTING**

**Estimasi Total: 3 jam**

#### **2.1 Active Policies Selection Screen**
**File:** `lib/screens/claim/select_policy_screen.dart`  
**Estimasi:** 45 menit

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: GET /api/policies/ (filter active)

❌ Flutter perlu:
   - List active policies user
   - Show device name, tier, claims used/max
   - Disable policy jika claims habis
   - Tap policy → navigate ke claim form
   - Empty state jika no active policies
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Pilih Polis untuk Klaim        │
├─────────────────────────────────┤
│  ✅ iPhone 15 Pro Max           │
│     Tier: Premium               │
│     Klaim: 2/10 terpakai        │
│     [AJUKAN KLAIM]              │
├─────────────────────────────────┤
│  ⚠️ Samsung A54 (LIMIT HABIS)   │
│     Tier: Gold                  │
│     Klaim: 5/5 terpakai         │
│     [TIDAK BISA KLAIM]          │
└─────────────────────────────────┘
```

---

#### **2.2 Claim Form Screen**
**File:** `lib/screens/claim/claim_form_screen.dart`  
**Estimasi:** 1.5 jam

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: POST /api/claims/

❌ Flutter perlu:
   - Show selected policy info
   - Dropdown: Damage type (Layar Pecah, LCD Rusak, dll)
   - TextArea: Damage description
   - DatePicker: Incident date
   - Input: Claim amount (Rp)
   - Show deduction calculation
   - Show wallet deduction amount
   - Confirmation before submit
   - Success/error handling
   
❌ Validasi:
   - All fields required
   - Incident date can't be future
   - Claim amount must be reasonable
   - Show warning if wallet will be deducted
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Ajukan Klaim Kerusakan         │
├─────────────────────────────────┤
│  Polis: iPhone 15 Pro Max       │
│  Tier: Premium (0% potongan)    │
│                                 │
│  Jenis Kerusakan:               │
│  [▼ Pilih jenis kerusakan]      │
│                                 │
│  Deskripsi:                     │
│  [________________________]     │
│  [________________________]     │
│  [________________________]     │
│                                 │
│  Tanggal Kejadian:              │
│  [📅 21/11/2025]                │
│                                 │
│  Jumlah Klaim: [Rp 2,000,000]   │
│                                 │
│  💡 Potongan: Rp 0 (0%)         │
│  💰 Anda Bayar: Rp 0            │
│                                 │
│  [     AJUKAN KLAIM      ]      │
└─────────────────────────────────┘
```

---

#### **2.3 Claim History Screen**
**File:** `lib/screens/claim/claim_history_screen.dart`  
**Estimasi:** 45 menit

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: GET /api/claims/

❌ Flutter perlu:
   - List all user claims
   - Show status (pending, approved, rejected)
   - Show claim amount, deduction
   - Color coding by status (yellow/green/red)
   - Tap claim → show detail
   - Pull to refresh
   - Empty state
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Riwayat Klaim Anda             │
├─────────────────────────────────┤
│  ✅ APPROVED                     │
│  iPhone 15 - Layar Pecah        │
│  Rp 2,000,000 (Potongan: Rp 0)  │
│  21 Nov 2025                    │
├─────────────────────────────────┤
│  ⏳ PENDING                      │
│  Samsung A54 - LCD Rusak        │
│  Rp 1,500,000 (Potongan: Rp 75k)│
│  22 Nov 2025                    │
└─────────────────────────────────┘
```

---

### **3. WALLET HISTORY SCREEN** ⭐⭐ **PENTING**

**File:** `lib/screens/wallet/wallet_history_screen.dart`  
**Estimasi:** 1.5 jam

**Yang Perlu Dibuat:**
```dart
✅ Backend sudah siap: GET /api/wallet/history/

❌ Flutter perlu:
   - List all transactions (topup, policy, claim)
   - Show type, amount, date, description
   - Color code: green (topup), red (debit), blue (refund)
   - Filter by type (optional)
   - Show running balance (optional)
   - Pull to refresh
   - Pagination (if needed)
```

**Contoh UI:**
```
┌─────────────────────────────────┐
│  Riwayat Transaksi              │
├─────────────────────────────────┤
│  🟢 TOP UP                       │
│  + Rp 1,000,000                 │
│  22 Nov 2025 - Approved         │
├─────────────────────────────────┤
│  🔴 BELI POLIS                  │
│  - Rp 500,000                   │
│  iPhone 15 Pro Max - Premium    │
│  22 Nov 2025                    │
├─────────────────────────────────┤
│  🔴 POTONGAN KLAIM              │
│  - Rp 0                         │
│  Claim #CLM-123 Approved        │
│  21 Nov 2025                    │
└─────────────────────────────────┘
```

---

### **4. TOP-UP SCREEN COMPLETION** ⭐⭐ **MEDIUM**

**File:** Update `lib/screens/topup_screen.dart`  
**Estimasi:** 1 jam

**Yang Perlu Ditambah:**
```dart
✅ Backend sudah siap: POST /api/wallet/topup/

❌ Yang masih kurang di Flutter:
   - Validation: min Rp 100,000
   - Payment method selection (Transfer Bank, E-Wallet, dll)
   - Upload payment proof (image) - optional untuk sekarang
   - Show pending status after submit
   - Better UI/UX
   - Success message
```

---

## 🎨 PRIORITAS MEDIUM - UX IMPROVEMENTS

### **5. PROFILE/SETTINGS SCREEN** ⭐ **NICE TO HAVE**

**File:** `lib/screens/profile_screen.dart`  
**Estimasi:** 1 jam

**Yang Perlu Dibuat:**
```dart
❌ Profile Information:
   - Show user data (name, email, phone)
   - Show KTP number (jika ada)
   - Show verification status
   - Edit profile button (optional)

❌ App Settings:
   - About app
   - Terms & conditions
   - Privacy policy
   - Help/FAQ
   - Contact support

❌ Account Actions:
   - Change password
   - Logout button
   - Delete account (optional)
```

---

### **6. DASHBOARD IMPROVEMENTS** ⭐ **POLISH**

**File:** Update `lib/screens/dashboard_screen.dart`  
**Estimasi:** 1 jam

**Yang Perlu Ditambah:**
```dart
❌ Quick Actions:
   - Button "Top Up" di wallet card (sudah ada)
   - Button "Beli Polis" (tambahkan)
   - Button "Ajukan Klaim" (tambahkan)

❌ Statistics Cards (optional):
   - Total policies
   - Total claims
   - Total spent

❌ Notifications/Alerts:
   - Policy expiring soon
   - Claim status updates
   - Top-up approved
```

---

### **7. NAVIGATION & ROUTING** ⭐ **IMPROVEMENT**

**File:** Update `lib/main.dart`  
**Estimasi:** 30 menit

**Yang Perlu Ditambah:**
```dart
❌ Add routes untuk:
   - /device-selection
   - /policy-purchase
   - /select-policy-for-claim
   - /claim-form
   - /claim-history
   - /wallet-history
   - /profile

❌ Bottom Navigation Bar (optional):
   - Home (Dashboard)
   - Policies
   - Wallet
   - Profile
```

---

## 🔧 PRIORITAS LOW - TECHNICAL IMPROVEMENTS

### **8. IMAGE UPLOAD FEATURE** ⭐ **FUTURE**

**Estimasi:** 2-3 jam

**Yang Perlu:**
```dart
❌ Dependencies:
   - image_picker package
   - http multipart for upload

❌ Screens yang butuh image:
   - KTP upload (registration - optional)
   - Payment proof (top-up)
   - Damage photos (claim submission)

❌ Backend:
   - Already supports image URLs
   - Perlu storage (local/S3/Cloudinary)
```

---

### **9. ERROR HANDLING & VALIDATION** ⭐ **IMPROVEMENT**

**Estimasi:** 2 jam

**Yang Perlu Diperbaiki:**
```dart
❌ Better error messages:
   - Network errors
   - Validation errors
   - Server errors

❌ Loading states:
   - Skeleton loaders
   - Progress indicators
   - Shimmer effects

❌ Empty states:
   - No policies
   - No claims
   - No transactions

❌ Offline handling:
   - Detect offline
   - Show offline banner
   - Queue actions
```

---

### **10. FORM VALIDATION IMPROVEMENTS** ⭐ **POLISH**

**Estimasi:** 1 jam

**Yang Perlu:**
```dart
❌ Better validation messages
❌ Real-time validation
❌ Input formatters (phone, IMEI, currency)
❌ Prevent duplicate submissions
❌ Form state persistence
```

---

### **11. UI/UX POLISH** ⭐ **NICE TO HAVE**

**Estimasi:** 2-3 jam

**Yang Bisa Ditambah:**
```dart
❌ Animations:
   - Page transitions
   - Button animations
   - Loading animations

❌ Better Typography:
   - Custom fonts
   - Consistent sizing
   - Better hierarchy

❌ Color Scheme:
   - Define color palette
   - Dark mode support (optional)
   - Theme consistency

❌ Icons:
   - Custom icon set
   - Better icon usage
   - Icon animations
```

---

## 🚀 PRIORITAS FUTURE - ADVANCED FEATURES

### **12. PUSH NOTIFICATIONS** (Future)

**Estimasi:** 3-4 jam

**Yang Perlu:**
```dart
❌ Firebase Cloud Messaging
❌ Notification permissions
❌ Handle notification tap
❌ Backend notification triggers
```

---

### **13. DEEP LINKING** (Future)

**Estimasi:** 2 jam

**Yang Perlu:**
```dart
❌ App links configuration
❌ Handle deep links
❌ Share policy/claim links
```

---

### **14. ANALYTICS & TRACKING** (Future)

**Estimasi:** 2 hours

**Yang Perlu:**
```dart
❌ Firebase Analytics
❌ Track user events
❌ Track errors (Crashlytics)
❌ Performance monitoring
```

---

### **15. PRODUCTION DEPLOYMENT** (Future)

**Estimasi:** 1 hari

**Yang Perlu:**
```
❌ Django Backend:
   - Deploy ke Heroku/Railway/DigitalOcean
   - Setup production database
   - Configure environment variables
   - Setup domain & SSL

❌ Flutter App:
   - Build release APK
   - Sign APK with keystore
   - Test on multiple devices
   - Submit to Play Store (optional)
```

---

## 📊 SUMMARY - ESTIMASI WAKTU

### **MINIMUM VIABLE PRODUCT (MVP):**
```
Core Features Only:
1. Policy Creation Screens:     3-4 hours
2. Claim Creation Screens:      3 hours
3. Wallet History Screen:       1.5 hours
4. Top-up Completion:           1 hour
                        TOTAL:  8.5-9.5 hours ≈ 2 hari kerja
```

### **COMPLETE APPLICATION:**
```
MVP Features:                   8.5-9.5 hours
+ UX Improvements:              3-4 hours
+ Technical Polish:             3-4 hours
+ Testing & Bug Fixes:          2-3 hours
                        TOTAL:  16.5-20.5 hours ≈ 3-4 hari kerja
```

### **PRODUCTION READY:**
```
Complete Application:           16.5-20.5 hours
+ Image Upload:                 2-3 hours
+ Advanced Features:            5-7 hours
+ Production Deployment:        8 hours
                        TOTAL:  31.5-38.5 hours ≈ 5-7 hari kerja
```

---

## 🎯 REKOMENDASI ROADMAP

### **HARI INI (Jika Lanjut - 3-4 jam):**
```
✅ 1. Device Selection Screen (1 jam)
✅ 2. Policy Purchase Form (1.5 jam)
✅ 3. Dashboard Enhancement (30 menit)
✅ 4. Testing & Bug Fixes (1 jam)

Result: User bisa beli polis! 🎉
```

### **BESOK (Session 3 - 4-5 jam):**
```
✅ 1. Select Policy for Claim (45 menit)
✅ 2. Claim Form Screen (1.5 jam)
✅ 3. Claim History Screen (45 menit)
✅ 4. Wallet History Screen (1.5 jam)
✅ 5. Testing (1 jam)

Result: Complete user journey! 🎊
```

### **LUSA (Session 4 - 3-4 jam):**
```
✅ 1. Profile Screen (1 jam)
✅ 2. UI/UX Polish (2 jam)
✅ 3. Error Handling (1 jam)
✅ 4. Testing (1 jam)

Result: Production-ready app! 🚀
```

---

## ✅ QUICK CHECKLIST

Centang yang sudah selesai:

**CORE FEATURES:**
- [x] Backend API
- [x] Login Screen
- [x] Register Screen
- [x] Dashboard Screen (basic)
- [ ] Device Selection Screen
- [ ] Policy Purchase Screen
- [ ] Policy Detail View
- [ ] Select Policy for Claim
- [ ] Claim Form Screen
- [ ] Claim History Screen
- [ ] Wallet History Screen
- [ ] Top-up Screen (complete)

**UX FEATURES:**
- [ ] Profile Screen
- [ ] Settings
- [ ] Bottom Navigation
- [ ] Better Loading States
- [ ] Empty States
- [ ] Error Messages

**TECHNICAL:**
- [x] Network Integration
- [x] Token Auth
- [ ] Image Upload
- [ ] Offline Mode
- [ ] Form Validation
- [ ] Error Logging

**DEPLOYMENT:**
- [ ] Backend Production
- [ ] Build Release APK
- [ ] Play Store (optional)

---

## 💡 DECISION HELPER

**Mau lanjut hari ini? Pilih salah satu:**

### **Option A: Quick Win (1-2 jam)** ⚡
```
✅ Buat Device Selection Screen only
✅ User bisa lihat 19 devices available
✅ Foundation untuk policy creation
```

### **Option B: Complete Policy Flow (3-4 jam)** ⭐ **RECOMMENDED**
```
✅ Device Selection Screen
✅ Policy Purchase Form
✅ Dashboard enhancement
✅ User bisa beli polis complete!
```

### **Option C: Cukup Dulu, Lanjut Besok** 😊
```
✅ Progress sudah 82%
✅ Register & Login complete
✅ Tinggal core features (policy & claim)
✅ Bisa lanjut fresh besok
```

---

**Mau pilih yang mana?** 😊

**Last Updated:** 22 November 2025, 14:20 WITA
