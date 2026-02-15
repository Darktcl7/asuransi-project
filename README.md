# 📱 SMILE INSURANCE - PROJECT DOCUMENTATION
**Last Updated:** 18 Januari 2026

---

## 📋 DESKRIPSI PROJECT

**Smile Insurance** adalah sistem asuransi perangkat mobile (HP) dengan fitur:
- Multi-store management (setiap toko punya admin sendiri)
- Pembuatan polis asuransi per device
- Sistem klaim dengan approval admin
- Dashboard analytics untuk monitoring
- Customer portal & mobile app

---

## 🔐 AKUN LOGIN

### Super Admin (Full Access)
| Field | Value |
|-------|-------|
| Email | `admin@smile.com` |
| Password | `Admin123!` |
| Role | `super_admin` |
| Access | Semua fitur, semua store |

### Store Admin (Contoh)
| Field | Value |
|-------|-------|
| Email | `store1@smile.com` |
| Password | `Store123!` |
| Role | `store_admin` |
| Access | Hanya data store sendiri |

### Customer (Contoh)
| Field | Value |
|-------|-------|
| Email | `customer@gmail.com` |
| Password | `Customer123!` |
| Role | `customer` |
| Access | Lihat polis & klaim sendiri |

> ⚠️ **Note:** Jika akun belum ada, buat super admin baru dengan:
> ```bash
> python manage.py createsuperuser
> ```

---

## 🚀 CARA MENJALANKAN PROJECT

### Terminal 1 - Backend Django
```powershell
cd "D:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\activate
python manage.py runserver 0.0.0.0:8000
```
**URL:** http://localhost:8000

### Terminal 2 - Admin Dashboard
```powershell
cd "D:\Django Project\Asuransi Project\admin-dashboard"
npm run dev
```
**URL:** http://localhost:5173

### Terminal 3 - Customer Website
```powershell
cd "D:\Django Project\Asuransi Project\customer-website"
npm run dev
```
**URL:** http://localhost:5174

---

## 📂 STRUKTUR PROJECT

```
D:\Django Project\Asuransi Project\
├── Smile Project\              # Backend Django
│   ├── config\                 # Settings, URLs
│   ├── users\                  # User management
│   ├── policies\               # Polis asuransi
│   ├── claims\                 # Klaim
│   ├── wallet\                 # Wallet/saldo
│   ├── stores\                 # Multi-store
│   ├── notifications\          # Notifikasi
│   ├── admin_api\              # API untuk admin dashboard
│   └── .env                    # Environment variables (SECRET!)
│
├── admin-dashboard\            # Frontend Admin (React + Vite)
│   └── src\
│       ├── pages\              # Halaman-halaman
│       ├── components\         # Komponen UI
│       └── services\           # API services
│
├── customer-website\           # Frontend Customer (React + Vite)
│   └── src\
│       ├── pages\              # Halaman customer
│       └── services\           # API services
│
└── phone_insurance_app\        # Mobile App (Flutter)
    ├── lib\
    │   ├── screens\            # UI screens
    │   ├── services\           # API services
    │   └── models\             # Data models
    └── build\app\outputs\flutter-apk\
        └── app-release.apk     # APK PRODUCTION ✅
```

---

## 🔧 API ENDPOINTS UTAMA

### Authentication
| Endpoint | Method | Fungsi |
|----------|--------|--------|
| `/api/login/` | POST | Login (email/phone) |
| `/api/users/register/` | POST | Register customer |
| `/api/users/me/` | GET/PATCH | Get/Update profile |

### Admin API
| Endpoint | Method | Fungsi |
|----------|--------|--------|
| `/api/admin/dashboard/` | GET | Stats dashboard |
| `/api/admin/users/` | GET | List users |
| `/api/admin/users/{id}/` | DELETE | Hapus user |
| `/api/admin/users/{id}/reset_password/` | POST | Reset password |
| `/api/admin/claims/` | GET | List klaim |
| `/api/admin/claims/{id}/approve/` | POST | Approve klaim |
| `/api/admin/claims/{id}/reject/` | POST | Reject klaim |

### Customer API
| Endpoint | Method | Fungsi |
|----------|--------|--------|
| `/api/policies/` | GET | List polis user |
| `/api/claims/` | GET/POST | List/Submit klaim |
| `/api/notifications/` | GET | List notifikasi |

---

## ✅ FITUR YANG SUDAH SELESAI

- [x] Multi-store management
- [x] Role-based access (Super Admin, Store Admin, Customer)
- [x] Dashboard dengan analytics
- [x] CRUD User dengan validasi
- [x] CRUD Polis dengan tier (Standard, Gold, Premium)
- [x] Sistem klaim dengan foto upload
- [x] Approve/Reject klaim oleh admin
- [x] Notifikasi real-time
- [x] Activity log (audit trail)
- [x] Export data ke Excel
- [x] Input KTP (sekali saja, locked setelah input)
- [x] Verifikasi user oleh admin
- [x] Reset password oleh admin
- [x] Delete user (Super Admin only)
- [x] Customer website
- [x] Mobile app (Flutter APK)
- [x] Performance optimization (select_related, pagination, limits)
- [x] Environment variables untuk security

---

## 🔒 SECURITY CHECKLIST

- [x] SECRET_KEY di .env file
- [x] Database credentials di .env file
- [x] DEBUG=False untuk production
- [x] Rate limiting pada login
- [x] Token-based authentication
- [x] Role-based permissions
- [ ] HTTPS (perlu setup di production)
- [ ] Email verification (ditunda)

---

## 📱 BUILD APK

APK terbaru ada di:
```
D:\Django Project\Asuransi Project\phone_insurance_app\build\app\outputs\flutter-apk\app-release.apk
```

Untuk rebuild:
```powershell
cd "D:\Django Project\Asuransi Project\phone_insurance_app"
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🗄️ DATABASE

**PostgreSQL Configuration:**
```
Host: localhost
Port: 5432
Database: asuransi_db
User: postgres
Password: (lihat .env file)
```

---

## 📞 KONTAK

Jika ada pertanyaan atau butuh bantuan:
- Email: chluik277@gmail.com

---

**© 2026 Smile Insurance by SPC**
