# 🧪 TESTING GUIDE - Step by Step

## 📌 INFORMASI PENTING

**Base URL:** `http://127.0.0.1:8000`

**Admin yang sudah ada:**
- Email: `chluik277@gmail.com`
- Password: `adminsmile277` (sesuai catatan Anda)

**Total Users:** 2 (1 admin + 1 user biasa mungkin)

---

## 🚀 STEP 1: Start Django Server

Buka **Command Prompt** atau **PowerShell**, lalu jalankan:

```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver
```

✅ **Berhasil jika muncul:**
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

⚠️ **JANGAN TUTUP TERMINAL INI!** Biarkan server tetap jalan.

---

## 🧪 STEP 2: Test Endpoints (Gunakan Browser atau Postman)

### **Test 2.1: Cek API Root (Browse API)**

Buka browser, masuk ke:
```
http://127.0.0.1:8000/api/
```

✅ **Berhasil:** Akan muncul halaman Django REST Framework dengan list endpoints:
- users
- wallet
- policy-tiers
- device-packages
- policies
- claims
- admin/claims

---

### **Test 2.2: GET Policy Tiers (Public - No Login)**

**Buka di browser:**
```
http://127.0.0.1:8000/api/policy-tiers/
```

✅ **Berhasil:** Akan muncul 3 tiers (Standar, Gold, Premium) dalam format JSON.

**Atau test dengan curl:**
```bash
curl http://127.0.0.1:8000/api/policy-tiers/
```

---

### **Test 2.3: GET Device Packages (Public - No Login)**

**Buka di browser:**
```
http://127.0.0.1:8000/api/device-packages/
```

✅ **Berhasil:** Akan muncul 19 devices (iPhone, Samsung, dll) dalam format JSON.

---

## 👤 STEP 3: Test User Registration

Sekarang kita akan buat user baru untuk testing.

### **Gunakan Postman atau curl:**

**Request:**
```http
POST http://127.0.0.1:8000/api/users/register/
Content-Type: application/json

{
  "email": "testuser@example.com",
  "password": "testing123",
  "first_name": "Test",
  "last_name": "User",
  "phone_number": "081234567890",
  "ktp_number": "3201234567890123",
  "birth_date": "1995-05-15",
  "address": "Jl. Testing No. 123, Jakarta"
}
```

**Dengan curl (copy-paste ke terminal baru):**
```bash
curl -X POST http://127.0.0.1:8000/api/users/register/ ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"testuser@example.com\",\"password\":\"testing123\",\"first_name\":\"Test\",\"last_name\":\"User\",\"phone_number\":\"081234567890\",\"ktp_number\":\"3201234567890123\",\"birth_date\":\"1995-05-15\",\"address\":\"Jl. Testing No. 123\"}"
```

✅ **Response yang diharapkan:**
```json
{
  "token": "abc123xyz...",
  "user": {
    "id": "uuid-here",
    "email": "testuser@example.com",
    "first_name": "Test",
    "last_name": "User",
    ...
  }
}
```

📝 **CATAT TOKEN INI!** Anda butuh untuk request selanjutnya.

---

## 🔐 STEP 4: Test Login (Alternatif)

Jika Anda ingin login dengan user yang sudah ada:

**Request:**
```http
POST http://127.0.0.1:8000/api/auth/login/
Content-Type: application/json

{
  "username": "testuser@example.com",
  "password": "testing123"
}
```

**Dengan curl:**
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser@example.com\",\"password\":\"testing123\"}"
```

✅ **Response:**
```json
{
  "token": "abc123xyz..."
}
```

---

## 💰 STEP 5: Test Wallet (Cek Auto-Create)

Sekarang cek apakah wallet otomatis dibuat saat register.

**Request (butuh token):**
```http
GET http://127.0.0.1:8000/api/wallet/
Authorization: Token YOUR_TOKEN_HERE
```

**Dengan curl (ganti YOUR_TOKEN):**
```bash
curl http://127.0.0.1:8000/api/wallet/ ^
  -H "Authorization: Token YOUR_TOKEN_HERE"
```

✅ **Response yang diharapkan:**
```json
[
  {
    "id": "uuid-here",
    "balance": "0.00",
    "total_topup": "0.00",
    "total_spent": "0.00",
    "created_at": "2025-11-22T..."
  }
]
```

✅ **Ini membuktikan wallet OTOMATIS DIBUAT!** (karena signal yang baru kita buat)

---

## 💳 STEP 6: Test Top-Up Wallet

User perlu saldo untuk beli polis. Mari test top-up:

**Request:**
```http
POST http://127.0.0.1:8000/api/wallet/topup/
Authorization: Token YOUR_TOKEN_HERE
Content-Type: application/json

{
  "amount": 1000000,
  "payment_method": "Bank Transfer BCA",
  "payment_proof_url": "https://example.com/bukti.jpg"
}
```

**Dengan curl:**
```bash
curl -X POST http://127.0.0.1:8000/api/wallet/topup/ ^
  -H "Authorization: Token YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"amount\":1000000,\"payment_method\":\"Bank Transfer BCA\",\"payment_proof_url\":\"https://example.com/bukti.jpg\"}"
```

✅ **Response:**
```json
{
  "message": "Top up berhasil dibuat. Menunggu verifikasi admin.",
  "data": {
    "id": "uuid-here",
    "amount": "1000000.00",
    "status": "pending",
    ...
  }
}
```

⚠️ **PENTING:** Status masih **"pending"**. Saldo belum masuk ke wallet karena butuh approval admin.

---

## 👨‍💼 STEP 7: Approve Top-Up (Sebagai Admin)

Untuk test lengkap, kita perlu approve top-up sebagai admin.

### **7.1 Login sebagai Admin**

```bash
curl -X POST http://127.0.0.1:8000/api/auth/login/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"chluik277@gmail.com\",\"password\":\"adminsmile277\"}"
```

📝 **Catat token admin ini!**

### **7.2 Manual Approve di Django Shell**

Karena kita belum buat endpoint approve top-up, kita approve manual via Django shell:

```bash
# Di terminal baru (jangan tutup server!):
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py shell
```

Lalu jalankan di shell Python:
```python
from wallet.models import TopUpTransaction, Wallet, WalletHistory
from django.utils import timezone

# Ambil top-up terakhir yang pending
topup = TopUpTransaction.objects.filter(status='pending').last()
print(f"Top-up: {topup.transaction_id}, Amount: {topup.amount}")

# Approve
topup.status = 'success'
topup.verified_at = timezone.now()
topup.save()

# Update wallet balance
wallet = topup.user.wallet
balance_before = wallet.balance
wallet.balance += topup.amount
wallet.total_topup += topup.amount
wallet.save()

# Catat di history
WalletHistory.objects.create(
    wallet=wallet,
    transaction_type='topup',
    amount=topup.amount,
    balance_before=balance_before,
    balance_after=wallet.balance,
    description=f'Top up approved: {topup.transaction_id}'
)

print(f"✅ Approved! Balance sekarang: {wallet.balance}")

# Keluar dari shell
exit()
```

---

## 🛡️ STEP 8: Test Create Policy

Sekarang user punya saldo, mari beli polis.

### **8.1 Ambil Device Package ID**

Cek devices yang tersedia:
```bash
curl http://127.0.0.1:8000/api/device-packages/
```

Pilih salah satu device, catat **"id"** nya.

### **8.2 Create Policy**

```http
POST http://127.0.0.1:8000/api/policies/
Authorization: Token USER_TOKEN_HERE
Content-Type: application/json

{
  "device_package_id": "PASTE_DEVICE_UUID_HERE",
  "imei_number": "123456789012345",
  "purchase_price": 4999000
}
```

**Dengan curl (ganti TOKEN dan DEVICE_UUID):**
```bash
curl -X POST http://127.0.0.1:8000/api/policies/ ^
  -H "Authorization: Token USER_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"device_package_id\":\"DEVICE_UUID\",\"imei_number\":\"123456789012345\",\"purchase_price\":4999000}"
```

✅ **Response yang diharapkan:**
```json
{
  "message": "Polis berhasil dibuat dan diaktifkan",
  "data": {
    "policy_number": "POL-20251122...",
    "status": "active",
    "policy_price": "150000.00",
    "activation_date": "2025-11-22",
    "expiry_date": "2026-11-22",
    ...
  }
}
```

✅ **Cek saldo wallet berkurang Rp 150.000!**

---

## 📋 STEP 9: Test Create Claim

User sudah punya polis aktif, mari buat klaim.

### **9.1 Ambil Policy ID**

```bash
curl http://127.0.0.1:8000/api/policies/ ^
  -H "Authorization: Token USER_TOKEN_HERE"
```

Catat **"id"** dari policy yang aktif.

### **9.2 Create Claim**

```http
POST http://127.0.0.1:8000/api/claims/
Authorization: Token USER_TOKEN_HERE
Content-Type: application/json

{
  "policy_id": "POLICY_UUID_HERE",
  "damage_type": "Layar Pecah",
  "damage_description": "Layar ponsel pecah karena terjatuh dari meja",
  "incident_date": "2025-11-21",
  "claim_amount": 2000000
}
```

**Dengan curl:**
```bash
curl -X POST http://127.0.0.1:8000/api/claims/ ^
  -H "Authorization: Token USER_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"policy_id\":\"POLICY_UUID\",\"damage_type\":\"Layar Pecah\",\"damage_description\":\"Layar pecah\",\"incident_date\":\"2025-11-21\",\"claim_amount\":2000000}"
```

✅ **Response:**
```json
{
  "message": "Klaim berhasil dibuat. Menunggu review admin.",
  "data": {
    "claim_number": "CLM-20251122...",
    "status": "pending",
    "claim_amount": "2000000.00",
    "deduction_amount": "200000.00",
    ...
  }
}
```

---

## 🎯 STEP 10: Test Admin Approve Claim

### **10.1 Get Claim ID (Sebagai Admin)**

```bash
curl http://127.0.0.1:8000/api/admin/claims/ ^
  -H "Authorization: Token ADMIN_TOKEN_HERE"
```

Catat **"id"** dari claim yang pending.

### **10.2 Approve Claim**

```bash
curl -X POST http://127.0.0.1:8000/api/admin/claims/CLAIM_UUID/approve/ ^
  -H "Authorization: Token ADMIN_TOKEN_HERE"
```

✅ **Response:**
```json
{
  "message": "Klaim berhasil disetujui",
  "data": {
    "status": "approved",
    "wallet_deducted": "200000.00",
    ...
  }
}
```

✅ **Cek wallet user berkurang Rp 200.000 lagi!**

---

## ✅ CHECKLIST TESTING

```
[ ] Step 1: Server jalan
[ ] Step 2.1: API root accessible
[ ] Step 2.2: GET policy tiers berhasil
[ ] Step 2.3: GET devices berhasil
[ ] Step 3: Register user baru berhasil
[ ] Step 4: Login berhasil, dapat token
[ ] Step 5: Wallet auto-create (balance = 0)
[ ] Step 6: Top-up berhasil (status pending)
[ ] Step 7: Approve top-up, saldo masuk
[ ] Step 8: Beli polis berhasil, saldo potong
[ ] Step 9: Buat klaim berhasil
[ ] Step 10: Admin approve klaim, saldo potong lagi
```

---

## 🐛 TROUBLESHOOTING

### Error: "No module named 'django'"
```bash
# Pastikan virtual environment aktif:
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\activate
python manage.py runserver
```

### Error: "Authentication credentials were not provided"
- Pastikan header Authorization: Token YOUR_TOKEN sudah benar
- Token didapat dari register atau login

### Error: "Saldo tidak cukup"
- Pastikan top-up sudah di-approve (Step 7)
- Cek balance dengan GET /api/wallet/

---

## 📞 SUPPORT

Jika ada error atau pertanyaan, screenshot error message dan tanyakan! 😊
