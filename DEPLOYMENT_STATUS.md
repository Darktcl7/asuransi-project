# Status Deployment Smile Insurance (22 Jan 2026)

## 📊 Ringkasan Status
| Komponen | Status | Keterangan |
|----------|--------|------------|
| **Server** | ✅ Aktif | `148.230.97.130` (Nginx + Gunicorn) |
| **Django Backend** | ✅ Terdeploy | Database fresh, semua migrations applied |
| **Admin Dashboard** | ✅ Aktif | `http://148.230.97.130/admin_store/` |
| **Customer Website** | ✅ Aktif | `http://148.230.97.130/` |
| **Mobile App (APK)** | ✅ Tersedia | `http://148.230.97.130/download/smile-insurance.apk` |

---

## 🔐 AKUN LOGIN PRODUCTION

### Super Admin (Full Access)
| Field | Value |
|-------|-------|
| **Email** | `admin@smile.com` |
| **Password** | `Admin123!` |
| **Role** | `super_admin` |
| **Access** | Semua fitur, semua store |

### Default Store
| Field | Value |
|-------|-------|
| **Code** | `HQ001` |
| **Name** | `Smile HQ` |
| **Address** | Jakarta |

---

## 🔐 CREDENTIALS SERVER

### PostgreSQL Database
| Field | Value |
|-------|-------|
| **Database** | `insurance_db` |
| **User** | `postgres` |
| **Password** | `Rossoneri277` |
| **Host** | `localhost` |
| **Port** | `5432` |

### SSH Server
| Field | Value |
|-------|-------|
| **IP** | `148.230.97.130` |
| **User** | `root` |
| **Port** | `22` |

---

## 🔧 Masalah yang Perlu Diperbaiki (Next Steps)

### 1. Fix Admin Dashboard (White Screen)
**Penyebab:** Konfigurasi `base` path di `vite.config.js` belum aktif saat buil terakhir.
**Solusi:**
- File `vite.config.js` **sudah diperbaiki** (status: *modified*).
- Langkah selanjutnya:
  1. Jalankan `npm run build` di folder `admin-dashboard`.
  2. Upload folder `dist` baru ke server `/var/www/smile/admin-store-build/`.

### 2. Fix Login Customer Website (Error 400)
**Penyebab:** Server menolak request login (`Bad Request`).
**Kemungkinan:** Format data yang dikirim frontend tidak sesuai dengan yang diharapkan backend, atau validasi `csrf` / `store_code`.
**Langkah Debugging:**
- SSH ke server dan pantau log saat mencoba login:
  ```bash
  ssh root@148.230.97.130
  tail -f /var/www/smile/smile_error.log  # atau log gunicorn
  ```

---

## 📂 Informasi Server

- **IP:** `148.230.97.130`
- **User:** `root`
- **Project Path:** `/var/www/smile/`
  - Backend: `./Smile Project/`
  - Admin Frontend: `./admin-store-build/`
  - Customer Frontend: `./customer-website-build/`
  - Downloads: `./downloads/`

### Perintah Paling Sering Digunakan

**Restart Backend:**
```bash
cd /var/www/smile
./start_gunicorn.sh
# atau
systemctl restart nginx
```

**Upload Frontend Baru (dari PC Lokal):**
```powershell
# Upload Admin Dashboard
scp -r "admin-dashboard\dist\*" root@148.230.97.130:/var/www/smile/admin-store-build/

# Upload Customer Website
scp -r "customer-website\dist\*" root@148.230.97.130:/var/www/smile/customer-website-build/
```
