# 🚀 Future Roadmap & Project Status: Smile by SPC

**Last Updated:** 2026-01-08
**Project Name:** Smile by SPC (formerly PhoneGuard)
**Components:** Django Backend, React Admin Store, Flutter Mobile App

---

## 1. ✅ Status Terkini (Completed Items)

### 🎨 Rebranding ("Smile by SPC")
*   **Mobile App (Flutter)**: ✅ Semua layar (Login, Register, Dashboard, Profile, Claims, Claim Form) menggunakan branding "Smile by SPC", logo 😊, dan warna **Oranye**.
*   **Admin Store**: ✅ Login Page & Sidebar sudah menggunakan branding "Smile by SPC" dengan warna **Oranye**.
*   **Backend**: ✅ Setup aman.

### 🛠️ Fitur & Perbaikan Teknis
1.  **Sistem Saldo**: ✅ Migrasi total dari `Wallet` ke `Policy Balance`.
2.  **Claim Form (Flutter)**:
    *   ✅ Validasi deskripsi dihapus (tanpa min char).
    *   ✅ **Fitur Multi-Foto**: User bisa upload banyak foto kerusakan.
    *   ✅ Limit ukuran foto **10MB** per file.
    *   ✅ Image Picker dengan kompresi otomatis (maxWidth 1024, quality 85).
    *   ✅ Warna form sesuai tema Smile (Oranye).
3.  **Backend**:
    *   ✅ Model `ClaimPhoto` untuk menyimpan foto klaim.
    *   ✅ `ClaimSerializer` menyertakan URL foto dalam response API.
    *   ✅ `AdminClaimViewSet.list()` mengirim data photos dengan URL lengkap.
    *   ✅ Handle multipart upload di `claims/views.py`.
4.  **Upload Foto End-to-End**:
    *   ✅ Flutter mengirim foto via `MultipartRequest`.
    *   ✅ Django menerima dan menyimpan ke `ClaimPhoto`.
    *   ✅ Admin Store menampilkan foto di modal review.
5.  **Admin Store Enhancements**:
    *   ✅ **Click to Zoom foto** dengan lightbox modal.
    *   ✅ "Open Original" button untuk melihat foto ukuran penuh.

---

## 2. ✅ Testing Flow Klaim (Verified)

1.  ✅ Login User di HP.
2.  ✅ Submit Klaim + 3 Foto.
3.  ✅ Login Admin.
4.  ✅ Buka Klaim -> Foto Muncul.
5.  ⏳ Approve Klaim -> Cek pemotongan saldo Policy.

---

## 3. 📅 Tech Improvements (Completed)

### 📱 Offline Mode (Flutter)
*   ✅ `CacheService` - Menyimpan policies, user profile, claims ke local storage.
*   ✅ `ConnectivityService` - Mengecek koneksi internet.
*   ⏳ Integration dengan dashboard screen (future).

### ☁️ Cloud Storage (Django)
*   ✅ Konfigurasi AWS S3 sudah disiapkan di `settings.py` (commented out).
*   ⏳ Aktivasi: Perlu set environment variables dan uncomment config.
*   Requirements: `pip install django-storages boto3`

---

## 4. 🧹 Code Cleanup (Low Priority)

*   **Hapus Wallet**: Kode lama terkait `Wallet` (models, serializers, views, Flutter screens) yang sudah tidak dipakai.
*   **Unused Assets**: Hapus asset logo lama (PhoneGuard indigo).

---

## 5. � Planned Changes

### Devices Management → Super Admin Only
*   **Status**: 📋 Planned
*   **Description**: Fitur "Devices" akan dipindahkan dari Admin Store ke Super Admin saja
*   **Reason**: Super Admin yang bertanggung jawab untuk input dan manage data devices (merek HP, model, harga)
*   **Impact**: Menu "Devices" akan dihapus dari Admin Store dan hanya muncul di Super Admin Dashboard

---

## 6. 🔑 Kredensial Akses (Development)

**Admin Store** (`http://148.230.97.130/admin_store`)
*   Email: `chluik277@gmail.com`
*   Pass: `admin123`

**Mobile User** (App)
*   Email: `demo@smile.com`
*   Pass: `Demo1234`
*   IP Server (Localhost Fisik): `192.168.100.4:8000`

(env) [root@srv933640 Smile Project]# python manage.py createsuperuser
Email: admin@smile.com (atau email Anda)
Password: Admin123! (atau password pilihan Anda)
---
*Last Updated: 2026-01-08 by AI Assistant*

