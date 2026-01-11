# Smile Insurance - Project Documentation

## 📋 Project Overview

**Project Name**: Smile Insurance  
**Server**: 148.230.97.130  
**Last Updated**: 11 Januari 2026

---

## 🌐 URLs

| Service | URL |
|---------|-----|
| Admin Store Dashboard | http://148.230.97.130/admin_store |
| Customer Website | http://148.230.97.130/ |
| API | http://148.230.97.130/api/ |
| Django Admin | http://148.230.97.130/admin/ |
| APK Download | http://148.230.97.130/download/smile-insurance.apk |

> **Note:** Link lama `/dashboard` akan redirect otomatis ke `/admin_store`


---

## 🔐 Admin Credentials

- **Email**: chluik277@gmail.com
- **Password**: adminsmile277

---

## 💻 Technology Stack

Project ini menggunakan **Full-Stack** dengan berbagai bahasa pemrograman:

| Bahasa | Persentase | Digunakan Untuk | Lokasi Folder |
|--------|------------|-----------------|---------------|
| **Python** 🐍 | ~33% | Django Backend (API, Database) | `Smile Project/` |
| **JavaScript** | ~28% | Admin Store & Customer Website (React) | `admin-dashboard/`, `customer-website/` |
| **Dart** 🎯 | ~27% | Mobile App (Flutter) | `smile_app/` |
| **CSS** | ~6% | Styling website | `*/src/*.css` |
| **C++** | ~2% | Flutter engine (auto-generated) | `smile_app/windows/`, `smile_app/linux/` |
| **CMake** | ~2% | Flutter build config (auto-generated) | `smile_app/*/CMakeLists.txt` |

### Penjelasan Singkat:

- **Python/Django**: Backend server yang menangani API, database, dan business logic
- **JavaScript/React**: Frontend untuk Admin Store dan Customer Website di browser
- **Dart/Flutter**: Mobile app untuk Android (file APK yang bisa didownload user)
- **CSS**: Styling untuk membuat tampilan website menarik
- **C++/CMake**: File auto-generated oleh Flutter untuk build desktop (tidak perlu diedit)

### Stack Architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    SMILE INSURANCE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ Admin Store │  │ Customer Website│  │ Mobile App  │ │
│  │ (React/JS)      │  │ (React/JS)      │  │ (Flutter)   │ │
│  └────────┬────────┘  └────────┬────────┘  └──────┬──────┘ │
│           │                    │                   │        │
│           └────────────────────┴───────────────────┘        │
│                              │                              │
│                              ▼                              │
│                    ┌─────────────────┐                      │
│                    │  Django API     │                      │
│                    │  (Python)       │                      │
│                    └────────┬────────┘                      │
│                             │                               │
│                             ▼                               │
│                    ┌─────────────────┐                      │
│                    │  PostgreSQL DB  │                      │
│                    └─────────────────┘                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
D:\Django Project\Asuransi Project\
├── Smile Project/           # Django Backend
│   ├── config/              # Django settings
│   ├── users/               # User authentication
│   ├── policies/            # Policy management
│   ├── claims/              # Claims management
│   ├── wallet/              # Wallet & top-up
│   ├── admin_api/           # Admin API endpoints
│   └── manage.py
│
├── admin-dashboard/         # React Admin Store
│   ├── src/
│   │   ├── pages/           # Page components
│   │   ├── components/      # Reusable components
│   │   ├── services/        # API services
│   │   └── layout/          # Layout components
│   └── dist/                # Production build
│
├── customer-website/        # Customer facing website (React)
├── smile_app/               # Flutter mobile app
└── _archive/                # Old documentation
```

---

## ✅ Completed Features

### Admin Store

| Feature | Route | Description |
|---------|-------|-------------|
| Dashboard | `/` | Stats overview (users, claims, policies) |
| Users Management | `/users` | View, search, filter users |
| Claims Management | `/claims` | View, approve, reject claims |
| Policies Management | `/policies` | View all policies |
| Devices Management | `/devices` | Device packages list |
| Create Policy | `/manual-policy-create` | Create policy for user with auto top-up |
| **🆘 Assist Claim** | `/admin-claim-create` | **NEW!** Submit claim on behalf of user |

### 🆘 Assist Claim Feature (Completed 10 Jan 2026)

**Purpose**: Allow admin to submit claims for users who cannot access the mobile app (e.g., damaged phone).

**How to Use**:
1. Go to `/dashboard/admin-claim-create`
2. Search user by email, name, or phone
3. Select the user's active policy
4. Fill in damage details and optional photos
5. Submit claim

**Technical Details**:
- Endpoint: `POST /api/admin/claims/create_for_user/`
- Claim number prefix: `CLM-ADM-`
- Status: `pending` (requires normal review)
- Admin notes auto-filled with submission reason

---

## 🔧 Server Management

### SSH Access
```bash
ssh root@148.230.97.130
```

### Service Commands
```bash
# Restart Gunicorn (Django)
systemctl restart smile

# Check service status
systemctl status smile

# View logs
journalctl -u smile -n 50 --no-pager

# Restart Nginx
systemctl restart nginx
```

### File Locations on Server
```
/var/www/smile/
├── Smile Project/              # Django backend
├── admin-store-build/          # Admin Store Dashboard (React build) - NEW!
├── customer-website-build/     # Customer website (React build)
├── media/                      # Uploaded files
├── static/                     # Static files
└── smile.sock                  # Gunicorn socket
```

---

## 🚀 Deployment Commands

### Deploy Backend Changes
```powershell
# Upload file
scp "D:\Django Project\Asuransi Project\Smile Project\<path>" root@148.230.97.130:"/var/www/smile/Smile Project/<path>"

# Restart service
ssh root@148.230.97.130 "systemctl restart smile"
```

### Deploy Frontend Changes
```powershell
# Build
cd "D:\Django Project\Asuransi Project\admin-dashboard"
npm run build

# Upload to admin-store-build (NOT admin-dashboard-build)
scp -r "D:\Django Project\Asuransi Project\admin-dashboard\dist\*" root@148.230.97.130:/var/www/smile/admin-store-build/
```

---

## 📊 Database

- **Type**: PostgreSQL
- **Host**: localhost
- **Database**: smile_db
- **Models**:
  - `User` - Custom user with UUID, email login
  - `Policy` - Insurance policies with balance
  - `PolicyTier` - Tier configurations
  - `DevicePackage` - Registered devices
  - `Claim` - User claims
  - `ClaimPhoto` - Claim photos
  - `Wallet` - User wallet
  - `TopUpTransaction` - Top-up history
  - `WalletHistory` - Transaction history

### Policy Tier Reference (Current)

| Tier | Price Range (Device Value) | Policy Price | Duration |
|------|---------------------------|--------------|----------|
| **Standar** | Rp 1.500.000 - Rp 3.000.000 | Rp 150.000 | 1 Year |
| **Gold** | Rp 3.000.001 - Rp 5.000.000 | Rp 250.000 | 1 Year |
| **Premium** | Rp 5.000.001 - Rp 99.999.999 | Rp 500.000 | 1 Year |

*Note: Super Admin will be able to update these configurations dynamically in the future update.*

---

## 📱 Mobile App

- **Framework**: Flutter
- **APK Location**: `smile_app/build/app/outputs/flutter-apk/app-release.apk`
- **Download URL**: http://148.230.97.130/download/smile-insurance.apk

---

## 🔄 API Endpoints

### Admin API (`/api/admin/`)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/admin/dashboard/` | GET | Dashboard stats |
| `/admin/users/` | GET | List users |
| `/admin/claims/` | GET | List claims |
| `/admin/claims/{id}/approve/` | POST | Approve claim |
| `/admin/claims/{id}/reject/` | POST | Reject claim |
| `/admin/claims/create_for_user/` | POST | Admin-assisted claim |
| `/admin/policies/` | GET | List policies |
| `/admin/policies/manual-create/` | POST | Create policy |

### User API (`/api/`)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/register/` | POST | User registration |
| `/auth/login/` | POST | User login |
| `/policies/` | GET/POST | User policies |
| `/claims/` | GET/POST | User claims |

---

## 📝 Recent Changes Log

### 11 January 2026
- ✅ Changed Admin Store URL from `/dashboard` to `/admin_store`
- ✅ Added auto-redirect from `/dashboard` to `/admin_store`
- ✅ Fixed mobile sidebar - added close button (X) and overlay backdrop
- ✅ Fixed notification API endpoints (mark_as_read, mark_all_as_read)
- ✅ Fixed notification click to redirect to claims page
- 📋 **PLANNED**: Move Devices management from Admin Store to Super Admin only

### 10 January 2026
- ✅ Implemented Admin-Assisted Claim feature
- ✅ Fixed policy list API to filter by user
- ✅ Added `policy_balance` to policy API response
- ✅ Fixed sidebar navigation
- ✅ Cleaned up old documentation files

### Previous Sessions
- Deployed to VPS (148.230.97.130)
- Fixed Nginx configuration for proper routing
- Implemented customer website
- Built and deployed Flutter APK
- Implemented notification system
- Implemented policy balance system (replaced wallet system)

---

## 🎯 Future Roadmap

See `FUTURE_ROADMAP.md` for planned features.

---

## 🐛 Known Issues

None currently.

---

## 📞 Support

For any issues with deployment or features, check:
1. Server logs: `journalctl -u smile -n 100`
2. Nginx logs: `/var/log/nginx/smile_error.log`
3. Browser console for frontend errors
