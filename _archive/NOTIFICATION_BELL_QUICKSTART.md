# NOTIFICATION BELL - QUICK START GUIDE
**Feature:** Real-time notification for pending claims

---

## ✅ WHAT'S NEW

**Notification Bell** di admin dashboard yang menampilkan:
- 🔔 Badge dengan jumlah pending claims
- 📋 Dropdown dengan 5 klaim terbaru
- ⏰ Auto-refresh setiap 30 detik
- 🎯 Klik untuk langsung ke Claims page

---

## 🚀 HOW TO USE

### **1. Open Admin Dashboard**
```
http://localhost:5174
```

### **2. Look at Top-Right Corner**
```
┌──────────────────────────┐
│ Dashboard           🔔 1 │  ← Bell icon with badge
└──────────────────────────┘
```

**Badge Colors:**
- 🔴 Red badge = Ada pending claims
- No badge = Semua klaim sudah diproses

### **3. Click Bell Icon**
```
┌────────────────────────────────┐
│ Notifikasi Klaim      [1 Pending]│
├────────────────────────────────┤
│ 🎫 Test User                   │
│    Samsung Galaxy A54          │
│    Kerusakan Air               │
│    CLM-20251124 • 5 menit lalu │
│                      [Pending] │
├────────────────────────────────┤
│   Lihat Semua Klaim Pending (1)│
└────────────────────────────────┘
```

### **4. Take Action**

**Option A:** Click pada klaim
- Langsung ke Claims page
- Process klaim seperti biasa

**Option B:** Click "Lihat Semua"
- Ke Claims page dengan filter pending
- Lihat semua pending claims

---

## 🎯 FEATURES

### **Real-Time Updates**
```
User submits claim
      ↓
Backend saves (status: pending)
      ↓
30 seconds later...
      ↓
Admin dashboard auto-refresh
      ↓
Badge shows: "1" 🔴
```

### **Smart Time Display**
- "Baru saja" (< 1 minute)
- "5 menit lalu"
- "2 jam lalu"
- "3 hari lalu"
- "24 Nov, 10:30" (> 7 days)

### **Auto-Refresh**
- ✅ Every 30 seconds
- ✅ No need to refresh page
- ✅ Badge updates automatically

---

## 📊 EXAMPLE WORKFLOW

```
09:00 - Admin opens dashboard
        Badge: "0" (no badge shown)

09:15 - User A submits claim (iPhone crash)
        Badge: Still "0" (waiting for refresh)

09:30 - Auto-refresh triggered
        Badge: "1" 🔴

09:35 - Admin clicks bell
        Sees: "John Doe - iPhone 15 Pro - Layar Pecah"

09:36 - Admin clicks claim
        Redirected to Claims page

09:40 - Admin approves claim
        Status: pending → approved

10:00 - Auto-refresh triggered
        Badge: "0" (disappears) ✅
```

---

## 🐛 TROUBLESHOOTING

### **Badge Not Showing?**

**Check 1:** Ada pending claims?
```bash
# Run this in Django project
python manage.py shell -c "from claims.models import Claim; print(Claim.objects.filter(status='pending').count())"
```

**Check 2:** API working?
```bash
# Run test script
python test_notification_api.py
```

**Check 3:** Browser console
```
F12 → Console → Check for errors
```

---

### **Badge Not Updating?**

**Solution:** Wait 30 seconds for auto-refresh

**OR manually refresh:**
```
Ctrl + F5 (force refresh)
```

---

### **Dropdown Not Opening?**

**Check:**
- Click the bell icon (not the badge)
- Check browser console for errors
- Make sure React is running

---

## 📝 API ENDPOINT

**URL:**
```
GET /api/admin/claims/notifications/
```

**Response:**
```json
{
  "pending_count": 1,
  "recent_claims": [
    {
      "id": "...",
      "claim_number": "CLM-20251124145840",
      "user_name": "Test User",
      "user_email": "test@example.com",
      "device": "Samsung Galaxy A54",
      "damage_type": "Kerusakan Air",
      "created_at": "2025-11-24T14:58:40Z"
    }
  ]
}
```

---

## ⚙️ CONFIGURATION

### **Change Refresh Interval:**

**File:** `admin-dashboard/src/components/NotificationBell.jsx`

**Line 14:**
```javascript
refetchInterval: 30000,  // 30 seconds (change this)
```

**Options:**
- 10 seconds: `10000`
- 1 minute: `60000`
- 5 minutes: `300000`

---

## ✅ TESTING

### **Test 1: Create Pending Claim**
```bash
# Reset claim to pending
cd "D:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\python.exe create_test_claim.py
```

### **Test 2: Check API**
```bash
# Verify API works
.\env\Scripts\python.exe test_notification_api.py
```

### **Test 3: Check Dashboard**
```
1. Open http://localhost:5174
2. Look at bell icon
3. Should show badge: "1" 🔴
4. Click bell → See claim details
```

---

## 🎉 SUCCESS CRITERIA

```
✅ Bell icon visible in header
✅ Badge shows when pending claims exist
✅ Badge shows correct count
✅ Dropdown opens on click
✅ Recent claims displayed correctly
✅ Time format shows "X menit lalu"
✅ Click claim navigates to Claims page
✅ Click "View All" filters by pending
✅ Auto-refresh works (30s)
✅ Badge disappears when no pending claims
```

---

## 📊 STATUS CHECK

**Quick Check:**
```bash
# Backend
curl http://127.0.0.1:8000/api/admin/claims/notifications/

# Expected response
{"pending_count": 1, "recent_claims": [...]}
```

**Visual Check:**
```
1. Open admin dashboard
2. Look at top-right corner
3. See bell icon with/without badge
4. Click to see dropdown
```

---

## 🚀 DEPLOYMENT STATUS

```
✅ Backend API: Working
   - Endpoint: /api/admin/claims/notifications/
   - Returns: pending_count + recent_claims

✅ Frontend Component: Integrated
   - Component: NotificationBell.jsx
   - Location: DashboardLayout header
   - Auto-refresh: Every 30 seconds

✅ Testing: Passed
   - API test: PASS
   - Badge display: PASS
   - Dropdown: PASS
   - Navigation: PASS

READY FOR PRODUCTION! 🎉
```

---

## 📞 SUPPORT

**If badge not showing:**
1. Check if Django server running (port 8000)
2. Check if React app running (port 5174)
3. Check browser console for errors
4. Run test script: `test_notification_api.py`
5. Force refresh: Ctrl + F5

**If auto-refresh not working:**
1. Keep dashboard tab open
2. Wait at least 30 seconds
3. Check network tab for API calls
4. Verify refetchInterval setting

---

**Happy Notifying! 🔔**
