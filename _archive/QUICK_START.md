# ⚡ QUICK START - Testing Backend

## 🎯 Cara Paling Mudah Test Backend

### 1️⃣ Buka Terminal & Start Server

```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver
```

Tunggu sampai muncul: `Starting development server at http://127.0.0.1:8000/`

✅ **Server sudah jalan!** JANGAN tutup terminal ini.

---

### 2️⃣ Test di Browser (Paling Mudah!)

Buka browser (Chrome/Firefox/Edge), lalu kunjungi URL-URL ini:

#### **Test 1: API Root**
```
http://127.0.0.1:8000/api/
```
✅ Akan muncul halaman Django REST Framework dengan list endpoints.

#### **Test 2: Lihat Policy Tiers**
```
http://127.0.0.1:8000/api/policy-tiers/
```
✅ Akan muncul 3 tiers (Standar, Gold, Premium).

#### **Test 3: Lihat Device Packages**
```
http://127.0.0.1:8000/api/device-packages/
```
✅ Akan muncul 19 devices (iPhone, Samsung, dll).

---

### 3️⃣ Test Register User (Perlu Postman/Tool)

Untuk test register, Anda perlu:
- **Postman** (recommended) - Download: https://www.postman.com/downloads/
- Atau **curl** di terminal

**Detail lengkap ada di:** `TESTING_GUIDE.md`

---

## 📁 File Penting untuk Anda Baca:

1. **TESTING_GUIDE.md** ← Panduan lengkap step-by-step
2. **API_TESTING.md** ← Dokumentasi semua endpoints
3. **PROJECT_STATUS.md** ← Status project saat ini

---

## ✅ Yang Sudah Jalan:

- ✅ Database (PostgreSQL)
- ✅ 14 API endpoints
- ✅ Wallet auto-create saat register
- ✅ Business logic (wallet, policy, claim)
- ✅ 3 policy tiers + 19 devices

---

## 🚀 Next Steps:

1. Start server (command di atas)
2. Test 3 URL di browser
3. Baca TESTING_GUIDE.md untuk test lebih lanjut
4. Jika berhasil, lanjut test dengan Postman

---

**Jika ada error, screenshot dan tanyakan!** 😊
