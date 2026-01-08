# 🚀 START ADMIN DASHBOARD - QUICK GUIDE

## 📋 **STEP-BY-STEP INSTRUCTIONS:**

---

### **STEP 1: Start Django Backend Server**

Open **PowerShell/CMD #1** dan jalankan:

```powershell
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver
```

**✅ Wait until you see:**
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

**Keep this terminal OPEN!** ⚠️

---

### **STEP 2: Start React Frontend**

Open **PowerShell/CMD #2** (NEW TERMINAL) dan jalankan:

```powershell
cd "D:\Django Project\Asuransi Project\admin-dashboard"
npm run dev
```

**✅ Wait until you see:**
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.100.4:5173/
```

---

### **STEP 3: Open Browser**

Buka browser dan akses:

```
http://localhost:5173
```

---

### **STEP 4: Login**

Masukkan kredensial admin:

```
Email:    chluik277@gmail.com
Password: admin123
```

**Click "Sign In"** 🔐

---

## ✅ **EXPECTED RESULT:**

Setelah login, Anda akan melihat:

1. **Dashboard Home** dengan:
   - 📊 4 Stat Cards (Users, Policies, Claims, Wallet)
   - 📈 2 Charts (User Stats, Policy Stats)
   - ⚡ Quick Actions
   - 💻 System Info

2. **Sidebar Menu:**
   - 📊 Dashboard (current page)
   - 👥 Users
   - 🎫 Claims
   - 📋 Policies
   - 💰 Wallets
   - 💳 Top-Ups

---

## 🧪 **TESTING CHECKLIST:**

### ✅ **Test 1: Dashboard Stats**
- Lihat 4 stat cards menampilkan angka
- Charts muncul dengan data
- Quick actions clickable

### ✅ **Test 2: User Management**
- Click "Users" di sidebar
- Search user by email
- Filter by verified/unverified
- Pagination works

### ✅ **Test 3: Claim Management**
- Click "Claims" di sidebar
- Filter by status (pending)
- Click "Review" pada pending claim
- Try approve/reject claim

---

## 🐛 **TROUBLESHOOTING:**

### **Problem: "Failed to fetch" atau "Network Error"**

**Solution:**
1. Pastikan Django backend running di terminal #1
2. Check URL: `http://192.168.100.4:8000` accessible?
3. Restart backend:
   ```
   Ctrl+C (stop)
   env\Scripts\python.exe manage.py runserver
   ```

---

### **Problem: "Login Failed" atau "401 Unauthorized"**

**Solution:**
1. Pastikan password benar: `admin123`
2. Reset admin password:
   ```powershell
   cd "D:\Django Project\Asuransi Project\Smile Project"
   env\Scripts\python.exe reset_admin_password.py
   ```

---

### **Problem: Dashboard stats showing zeros**

**Solution:**
1. Backend butuh seed data
2. Check database ada data:
   ```powershell
   env\Scripts\python.exe manage.py shell -c "from users.models import User; print(User.objects.count())"
   ```

---

### **Problem: CORS Error**

**Solution:**
Check `settings.py`:
```python
CORS_ALLOWED_ORIGINS = [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
]
```

---

## 📊 **PERFORMANCE EXPECTATIONS:**

| Page | Expected Load Time |
|------|-------------------|
| Login | < 500ms |
| Dashboard Home | < 800ms |
| User List (50 items) | < 800ms |
| Claim List (50 items) | < 800ms |

---

## 🎯 **WHAT'S WORKING:**

✅ Login & Authentication
✅ Dashboard Home (Stats + Charts)
✅ User Management (List, Search, Filter, Pagination)
✅ Claim Management (List, Filter, Approve, Reject)
✅ Responsive Design
✅ Optimized for Millions of Data

---

## 🔄 **WHAT'S COMING:**

⏳ Policy Management (approve/reject)
⏳ Wallet Management (view balances)
⏳ Top-Up Management (approve requests)
⏳ Advanced Analytics
⏳ Export Data

---

## 💬 **NEED HELP?**

If you encounter any issues:

1. **Check both terminals** are running
2. **Check browser console** for errors (F12)
3. **Check backend logs** for API errors
4. **Clear browser cache** and try again

---

## 🎉 **SUCCESS INDICATORS:**

You'll know it's working when:

✅ Login screen appears with gradient background
✅ After login, dashboard loads with stats
✅ Sidebar navigation works smoothly
✅ User list loads with data
✅ Claim list loads with data
✅ Approve/Reject claims works

---

**Ready? Let's GO!** 🚀

**Run STEP 1 and STEP 2 in separate terminals!**
