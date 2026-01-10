# Smile Insurance - Project Documentation

## 📋 Project Overview

**Project Name**: Smile Insurance  
**Server**: 148.230.97.130  
**Last Updated**: 10 Januari 2026

---

## 🌐 URLs

| Service | URL |
|---------|-----|
| Admin Dashboard | http://148.230.97.130/dashboard |
| Customer Website | http://148.230.97.130/ |
| API | http://148.230.97.130/api/ |
| Django Admin | http://148.230.97.130/admin/ |
| APK Download | http://148.230.97.130/download/smile-insurance.apk |

---

## 🔐 Admin Credentials

- **Email**: chluik277@gmail.com
- **Password**: adminsmile277

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
├── admin-dashboard/         # React Admin Dashboard
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

### Admin Dashboard

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
├── admin-dashboard-build/      # Admin dashboard (React build)
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

# Upload
scp -r "D:\Django Project\Asuransi Project\admin-dashboard\dist\*" root@148.230.97.130:/var/www/smile/admin-dashboard-build/
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
