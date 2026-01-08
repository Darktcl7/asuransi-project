# 🚀 Flutter Testing Guide

## 📋 Prerequisites

### 1. Django Server Harus Jalan
```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver
```
✅ Server jalan di: `http://127.0.0.1:8000`

---

## 🧪 Cara Test Flutter App

### Opsi 1: Test di Chrome (Paling Mudah) ⭐

**1. Buka terminal baru (JANGAN tutup Django server!)**

**2. Jalankan Flutter:**
```bash
cd "D:\Django Project\Asuransi Project\phone_insurance_app"
flutter run -d chrome
```

**3. Tunggu sampai Chrome terbuka otomatis**

**4. Test Login:**
- Email: `testuser20251122124718@example.com`
- Password: `testing123`
- Klik **Login**

✅ **Berhasil jika:** Masuk ke Dashboard dan muncul:
- Saldo: Rp 750,000
- Policy: Samsung Galaxy A54

---

### Opsi 2: Test di Android Emulator

**1. Buka Android Studio → Device Manager → Start Emulator**

**2. Update base URL di `lib/services/api_service.dart`:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api'; // Untuk Emulator
```

**3. Jalankan:**
```bash
flutter run
```

---

### Opsi 3: Test di Android Device Fisik

**1. Enable USB Debugging di HP Android**

**2. Cek IP PC Anda:**
```bash
ipconfig
# Cari: IPv4 Address (contoh: 192.168.100.4)
```

**3. Update base URL di `lib/services/api_service.dart`:**
```dart
static const String baseUrl = 'http://192.168.100.4:8000/api'; // Ganti IP
```

**4. Pastikan HP dan PC dalam 1 WiFi**

**5. Jalankan:**
```bash
flutter run
```

---

## 🐛 Troubleshooting

### Error: "Connection refused" / "Failed to connect"

**Penyebab:** Flutter tidak bisa akses Django server

**Solusi:**

1. **Cek Django server jalan:**
   - Buka browser: `http://127.0.0.1:8000/api/`
   - Harus muncul Django REST Framework page

2. **Pastikan base URL benar:**
   - Chrome/Desktop: `http://127.0.0.1:8000/api`
   - Android Emulator: `http://10.0.2.2:8000/api`
   - Device Fisik: `http://192.168.X.X:8000/api`

3. **Cek firewall Windows:**
   - Windows Defender mungkin block port 8000
   - Allow Python dalam firewall

---

### Error: "Invalid credentials" / "Login failed"

**Solusi:**

1. Pastikan user test sudah dibuat (kita sudah buat di backend test)
2. Email: `testuser20251122124718@example.com`
3. Password: `testing123`

Atau buat user baru via Django:
```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py shell

# Di shell:
from django.contrib.auth import get_user_model
User = get_user_model()
user = User.objects.create_user(
    email='flutter@test.com',
    password='testing123',
    first_name='Flutter',
    last_name='Test'
)
print(f"Created: {user.email}")
exit()
```

---

### Error: "FormatException" / JSON parsing error

**Penyebab:** API response format tidak sesuai

**Solusi:** Kita sudah fix di `api_service.dart`:
- Wallet response: `List` langsung (bukan nested)
- Policy response: `List` langsung (bukan nested)

---

### Flutter tidak detect Chrome

```bash
flutter config --enable-web
flutter run -d chrome
```

---

## ✅ Test Checklist

```
[ ] Django server jalan di http://127.0.0.1:8000
[ ] Flutter run berhasil
[ ] Login screen muncul
[ ] Login berhasil dengan user test
[ ] Dashboard muncul dengan data:
    [ ] Nama user
    [ ] Saldo wallet
    [ ] List policies
[ ] Top-up screen bisa diakses
```

---

## 📱 Akun Test yang Tersedia

### User 1 (Punya Policy & Claim)
- Email: `testuser20251122124718@example.com`
- Password: `testing123`
- Balance: Rp 750,000
- Policy: 1 (Samsung Galaxy A54)
- Claim: 1 (approved)

### Admin
- Email: `chluik277@gmail.com`
- Password: `adminsmile277`

---

## 🎯 Next Steps After Login Works

1. Test Top-up screen
2. Test Wallet history
3. Implement Policy creation screen
4. Implement Claim creation screen
5. Add loading states
6. Add error handling
7. Improve UI/UX

---

**Good luck! 🚀**
