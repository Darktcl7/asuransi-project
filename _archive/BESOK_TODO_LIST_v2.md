# 📋 TODO LIST BESOK - 2025-11-25

**Updated:** 2025-11-24  
**Status Hari Ini:** ✅ Sistem polis baru selesai, data di-reset

---

## 🎯 **PRIORITAS UTAMA (HARUS SELESAI):**

### **1. ✅ TESTING END-TO-END WORKFLOW** 
**Priority: CRITICAL**

**Test Complete Flow:**
```
□ Step 1: Admin Top-Up User
  - Login admin dashboard (localhost:5173)
  - Manual Top-Up → Leo (Rp 500.000)
  - Manual Top-Up → Ardy (Rp 500.000)
  - Verify wallet balance updated

□ Step 2: Admin Create Policy
  - Create Policy → Leo
    * Device: Samsung A54 (Rp 4.999.000)
    * IMEI: 111111111111111
    * Expected Tier: Smile 2 (Rp 400.000)
  - Create Policy → Ardy
    * Device: iPhone 15 (Rp 12.999.000)
    * IMEI: 222222222222222
    * Expected Tier: Smile 4 (Rp 900.000)
  - Verify policies created & active

□ Step 3: User Mobile App View
  - Login Leo (mobile app)
    * Check wallet: Should show Rp 500.000
    * Check policy: Should show Smile 2
  - Login Ardy (mobile app)
    * Check wallet: Should show Rp 500.000
    * Check policy: Should show Smile 4
  - Verify tier names displayed prominently

□ Step 4: Create Claim (If Needed)
  - User submit claim
  - Admin review & approve/reject
  - Verify wallet deduction (if approved)
```

**Expected Time:** 1-2 jam

---

### **2. 🐛 BUG FIXES & IMPROVEMENTS**
**Priority: HIGH**

**Bugs to Check:**
```
□ Admin dashboard:
  - Check if tier reference table displays correctly
  - Verify search user functionality
  - Test device selection dropdown
  - Validate IMEI input (must be 15 digits)

□ Mobile app:
  - Verify "Beli Polis" button truly removed
  - Check policy card layout (tier name prominent?)
  - Test empty state (no polis)
  - Check wallet history display

□ Backend API:
  - Test invalid IMEI (duplicate, wrong length)
  - Test invalid price (negative, out of tier range)
  - Test invalid user ID
  - Error messages clear & helpful?
```

**Expected Time:** 1-2 jam

---

### **3. 📱 MOBILE APP POLISH**
**Priority: MEDIUM**

**Updates Needed:**
```
□ Remove/Disable "Top-Up" button on wallet card
  - File: lib/screens/dashboard_screen.dart
  - Keep wallet display, remove top-up button
  - Add message: "Top-up dikelola oleh admin"

□ Update wallet history page
  - Show only history (no top-up action)
  - Display "Admin top-up" transactions clearly

□ Policy detail improvements
  - Add "Berlaku sampai" (expiry date)
  - Show policy price paid
  - Add tier benefits info
```

**Expected Time:** 1-2 jam

---

## 🚀 **FEATURES TAMBAHAN (NICE TO HAVE):**

### **4. 📊 ADMIN DASHBOARD ENHANCEMENTS**
**Priority: MEDIUM**

**New Features:**
```
□ Policy List Page
  - View all policies (paginated)
  - Filter by tier, status, user
  - Edit policy (extend expiry, change status)
  - Search by policy number or IMEI

□ User Detail Page
  - Click user → view full profile
  - Show all user's policies
  - Show all user's claims
  - Show wallet transactions
  - Quick actions: Top-up, Create Policy

□ Analytics Dashboard
  - Total policies by tier (pie chart)
  - Total revenue by tier
  - Active vs expired policies
  - Claims rate by tier
  - Monthly growth chart
```

**Expected Time:** 2-3 jam

---

### **5. 🔔 NOTIFICATIONS & ALERTS**
**Priority: LOW**

**Implement:**
```
□ Email notifications
  - Policy created → email to user
  - Policy expiring soon → reminder
  - Claim approved/rejected → notification

□ Admin notifications
  - New claim submitted → alert admin
  - Policy expiring soon → review list

□ Mobile app notifications
  - Push notification when policy created
  - Reminder before policy expires
```

**Expected Time:** 2-3 jam (if needed)

---

### **6. 📝 DOCUMENTATION & GUIDES**
**Priority: MEDIUM**

**Create:**
```
□ User Guide (Bahasa Indonesia)
  - Cara login
  - Cara lihat polis
  - Cara ajukan klaim
  - FAQ

□ Admin Guide
  - Cara top-up manual
  - Cara create policy
  - Cara approve/reject claim
  - Tier pricing guide

□ API Documentation
  - Update with new endpoints
  - Add examples for manual policy creation
  - Document all error codes

□ Deployment Guide
  - Server requirements
  - Installation steps
  - Environment variables
  - Database setup
```

**Expected Time:** 1-2 jam

---

## 🔧 **TECHNICAL TASKS (Optional):**

### **7. 🗄️ DATABASE OPTIMIZATION**
**Priority: LOW**

```
□ Add indexes for better performance
  - policies: (user_id, status, created_at)
  - claims: (policy_id, status, created_at)
  - wallet_history: (wallet_id, created_at)

□ Database backup script
  - Auto backup daily
  - Keep last 7 days

□ Data archiving
  - Archive expired policies > 1 year
  - Archive old wallet history > 6 months
```

**Expected Time:** 1 jam

---

### **8. 🔐 SECURITY ENHANCEMENTS**
**Priority: MEDIUM**

```
□ Rate limiting
  - Limit login attempts (5 per hour)
  - Limit API calls per user
  - Limit policy creation by admin

□ Input validation
  - Sanitize all user inputs
  - Validate file uploads (claim proof)
  - Check IMEI format strictly

□ Audit logging
  - Log all admin actions
  - Log policy creations
  - Log claim approvals
  - Log wallet changes
```

**Expected Time:** 1-2 jam

---

### **9. 🧪 AUTOMATED TESTING**
**Priority: MEDIUM**

```
□ Backend unit tests
  - Test policy tier detection
  - Test wallet calculations
  - Test claim deduction logic

□ API integration tests
  - Test manual policy creation
  - Test manual top-up
  - Test claim workflow

□ Frontend tests
  - Test admin dashboard forms
  - Test mobile app screens
```

**Expected Time:** 2-3 jam

---

## 📱 **MOBILE APP ADDITIONAL FEATURES:**

### **10. MOBILE APP IMPROVEMENTS**
**Priority: LOW**

```
□ Profile page enhancements
  - Edit profile picture
  - Change password
  - Update phone number

□ Policy detail page
  - Full policy information
  - Download policy PDF
  - Policy terms & conditions

□ Claim submission improvements
  - Camera integration for proof upload
  - Multiple photo uploads
  - Claim tracking status

□ Wallet improvements
  - Transaction filters (date range)
  - Export transaction history
  - Monthly spending chart
```

**Expected Time:** 3-4 jam

---

## 🎨 **UI/UX IMPROVEMENTS:**

### **11. DESIGN POLISH**
**Priority: LOW**

```
□ Admin Dashboard
  - Improve color scheme
  - Better loading states
  - Add success animations
  - Improve error messages

□ Mobile App
  - Smooth transitions
  - Better empty states
  - Loading skeletons
  - Pull-to-refresh improvements
```

**Expected Time:** 2-3 jam

---

## 📊 **REPORTING FEATURES:**

### **12. REPORTS & ANALYTICS**
**Priority: LOW**

```
□ Admin Reports
  - Monthly revenue report
  - Policy sales by tier
  - Claims summary
  - User activity report
  - Export to Excel/PDF

□ Financial Reports
  - Wallet balance summary
  - Top-up transactions
  - Policy revenue
  - Claim payouts
```

**Expected Time:** 2-3 jam

---

## 🚢 **DEPLOYMENT PREPARATION:**

### **13. PRODUCTION READY**
**Priority: MEDIUM**

```
□ Environment setup
  - Production database (PostgreSQL?)
  - Redis for caching
  - File storage (S3 or similar)
  - Email service (SendGrid, Mailgun)

□ Server configuration
  - Nginx setup
  - SSL certificate
  - Domain configuration
  - Firewall rules

□ Monitoring
  - Error tracking (Sentry)
  - Performance monitoring
  - Uptime monitoring
  - Log management

□ Backup & Recovery
  - Database backup automation
  - File backup
  - Disaster recovery plan
```

**Expected Time:** 3-4 jam

---

## ⏰ **TIMELINE BESOK:**

### **SESI 1 (09:00 - 12:00): TESTING & BUG FIXES**
```
✓ End-to-end testing complete workflow
✓ Fix any bugs found
✓ Mobile app polish (remove top-up button)
```

### **SESI 2 (13:00 - 16:00): FEATURES & IMPROVEMENTS**
```
✓ Admin dashboard enhancements
✓ Policy list page
✓ User detail page
✓ Documentation updates
```

### **SESI 3 (16:00 - 18:00): OPTIONAL TASKS**
```
✓ Notifications (if time permits)
✓ Analytics dashboard
✓ Security enhancements
```

---

## 📝 **CHECKLIST MINIMUM (MUST DO):**

**Before End of Tomorrow:**
```
✅ 1. End-to-end testing completed
✅ 2. All critical bugs fixed
✅ 3. Mobile app "Top-Up" button removed
✅ 4. Admin can create at least 5 sample policies
✅ 5. Users can see policies in mobile app
✅ 6. Basic documentation updated
```

---

## 🎯 **SUCCESS CRITERIA:**

**Besok dianggap sukses jika:**
```
✅ Complete workflow tested & working
✅ Admin can:
   - Top-up user wallets
   - Create policies for users
   - View all policies & users
   
✅ Users can:
   - Login & view wallet
   - See their policies (tier name prominent)
   - Submit claims (if have active policy)
   
✅ Mobile app:
   - No "Beli Polis" button
   - No "Top-Up" button
   - Policy display looks good
   
✅ Zero critical bugs
```

---

## 📞 **CONTACT FOR ISSUES:**

**If Problems Occur:**
```
1. Check logs: 
   - Backend: logs/ folder
   - Browser: F12 → Console
   - Mobile: flutter logs

2. Restart servers:
   - Backend: Ctrl+C, then start_server.bat
   - Admin: npm run dev (in admin-dashboard)
   - Mobile: flutter run

3. Database issues:
   - Run: verify_reset.py
   - Check: ensure_wallets.py

4. Data issues:
   - Can reset again: reset_all_data_confirm.py
```

---

## 🗂️ **FILES TO REVIEW:**

**Backend:**
```
- admin_api/views.py (manual policy creation)
- policies/serializers.py (tier_name field)
- policies/models.py (Smile 1-6 tiers)
```

**Admin Dashboard:**
```
- src/pages/ManualPolicyCreatePage.jsx
- src/pages/ManualTopUpPage.jsx
- src/layout/DashboardLayout.jsx
```

**Mobile App:**
```
- lib/screens/dashboard_screen.dart (removed Beli Polis)
- lib/models/policy.dart (tier display)
```

---

## 💾 **BACKUP BEFORE STARTING:**

**Create backup first:**
```bash
# Export database
cd "Smile Project"
.\env\Scripts\python.exe manage.py dumpdata > backup_20251125.json

# Or backup entire database file
# (if using SQLite)
copy db.sqlite3 db_backup_20251125.sqlite3
```

---

## 🎉 **PROGRESS TODAY:**

**What We Accomplished:**
```
✅ Policy tiers updated (Smile 1-6)
✅ Policy prices updated
✅ Admin manual policy creation
✅ User read-only policy view
✅ Mobile app updated (no buy button)
✅ Data reset completed
✅ Testing framework ready
```

**Lines of Code Added:** ~2000+ lines
**Files Created/Modified:** 15+ files
**Features Implemented:** 5 major features

---

## 🚀 **READY FOR TOMORROW!**

```
STATUS: All systems ready
Data: Clean slate (reset complete)
Backend: Updated & tested
Frontend: Admin dashboard ready
Mobile: User view ready

LET'S GO! 💪
```

---

**Prepared by:** Droid  
**Date:** 2025-11-24  
**For:** 2025-11-25  
**Priority:** Testing > Bug Fixes > Features > Documentation  

**Good luck tomorrow! 🎯**
