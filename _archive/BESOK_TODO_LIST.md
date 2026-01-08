# 📋 TODO LIST UNTUK BESOK

**Date:** 2025-01-23  
**Priority:** Deploy Backend → Build APK → Distribute

---

## 🎯 MAIN GOAL: Deploy to Production

### **Target:** App live di internet dalam 3-4 jam

---

## ✅ CHECKLIST LENGKAP

### **Phase 1: Persiapan (15 menit)**

- [ ] Review SESSION_COMPLETION_REPORT.md
- [ ] Start Django backend: `python manage.py runserver 0.0.0.0:8000`
- [ ] Start Flutter: `flutter run -d 10DF9A05880001M`
- [ ] Quick test semua features working:
  - [ ] Login
  - [ ] Dashboard
  - [ ] Top-up
  - [ ] Buy policy
  - [ ] Submit claim
  - [ ] Claim history
  - [ ] Wallet history
  - [ ] Profile & logout

---

### **Phase 2: Deploy Backend ke Railway (2-3 jam)**

#### **Step 1: Setup Railway Account (10 menit)**
- [ ] Buka https://railway.app
- [ ] Sign up with GitHub
- [ ] Verify email
- [ ] (Optional) Add credit card for verification

#### **Step 2: Prepare Project Files (20 menit)**
- [ ] Create `Procfile` di root Django project:
  ```
  web: gunicorn config.wsgi --log-file -
  ```

- [ ] Create `runtime.txt`:
  ```
  python-3.11.0
  ```

- [ ] Update `requirements.txt` (add if missing):
  ```
  Django==4.2.7
  djangorestframework==3.14.0
  psycopg2-binary==2.9.9
  djangorestframework-simplejwt==5.3.0
  django-cors-headers==4.3.1
  gunicorn==21.2.0
  whitenoise==6.6.0
  dj-database-url==2.1.0
  ```

- [ ] Update `settings.py` for production:
  ```python
  import dj_database_url
  import os
  
  # Production settings
  if os.environ.get('RAILWAY_ENVIRONMENT'):
      DEBUG = False
      ALLOWED_HOSTS = ['*.railway.app', 'localhost', '127.0.0.1']
      
      # Database
      DATABASES = {
          'default': dj_database_url.config(
              default=os.environ.get('DATABASE_URL')
          )
      }
      
      # Static files
      STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
      STATIC_URL = '/static/'
      
      # Security
      SECURE_SSL_REDIRECT = True
      SESSION_COOKIE_SECURE = True
      CSRF_COOKIE_SECURE = True
  ```

#### **Step 3: Deploy to Railway (30 menit)**
- [ ] Install Railway CLI: `npm i -g @railway/cli`
- [ ] Login: `railway login`
- [ ] Init project: `railway init`
- [ ] Add PostgreSQL: `railway add` (select PostgreSQL)
- [ ] Deploy: `railway up`
- [ ] Wait for deployment (5-10 minutes)

#### **Step 4: Configure Environment (20 menit)**
- [ ] Set environment variables di Railway dashboard:
  - [ ] `SECRET_KEY` = (generate new di https://djecrety.ir/)
  - [ ] `DEBUG` = False
  - [ ] `RAILWAY_ENVIRONMENT` = production
  - [ ] `DATABASE_URL` = (auto-generated)

#### **Step 5: Run Migrations (10 menit)**
- [ ] Railway dashboard → Service → Terminal
- [ ] Run: `python manage.py migrate`
- [ ] Run: `python manage.py seed_data`
- [ ] Create superuser: `python manage.py createsuperuser`

#### **Step 6: Get Production URL (5 menit)**
- [ ] Railway dashboard → Settings → Domains
- [ ] Copy public URL (e.g., `https://phoneguard-production.railway.app`)
- [ ] Test URL di browser: `https://your-url.railway.app/api/`
- [ ] Should see: `{"message": "PhoneGuard Insurance API"}`

#### **Step 7: Test Production API (20 menit)**
- [ ] Test dengan Postman/Thunder Client:
  - [ ] POST `/api/register/` - Create test user
  - [ ] POST `/api/login/` - Get token
  - [ ] GET `/api/tiers/` - List tiers
  - [ ] GET `/api/devices/` - List devices
  - [ ] GET `/api/user/profile/` - Get profile

---

### **Phase 3: Update Flutter App (20 menit)**

#### **Step 1: Update API URL (10 menit)**
- [ ] Open: `lib/services/api_service.dart`
- [ ] Change `baseUrl` to Railway URL:
  ```dart
  final String baseUrl = 'https://your-app.railway.app/api';
  ```

#### **Step 2: Test dengan Production API (10 menit)**
- [ ] Hot restart Flutter: `R`
- [ ] Test register new user
- [ ] Test login
- [ ] Test all features with production backend

---

### **Phase 4: Build Release APK (30 menit)**

#### **Step 1: Prepare App Info (5 menit)**
- [ ] Edit `pubspec.yaml`:
  ```yaml
  name: phoneguard_insurance
  description: Phone Insurance Application
  version: 1.0.0+1
  ```

- [ ] Edit `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <application
      android:label="PhoneGuard"
      android:icon="@mipmap/ic_launcher">
  ```

#### **Step 2: Build APK (15 menit)**
- [ ] Clean build: `flutter clean`
- [ ] Get dependencies: `flutter pub get`
- [ ] Build: `flutter build apk --release`
- [ ] Wait for build (10-15 minutes)

#### **Step 3: Find APK (2 menit)**
- [ ] Navigate to: `build/app/outputs/flutter-apk/`
- [ ] File: `app-release.apk` (~40MB)

#### **Step 4: Test APK (8 menit)**
- [ ] Copy APK to phone (USB/Google Drive)
- [ ] Install manually
- [ ] Test app with production API
- [ ] Verify all features working

---

### **Phase 5: Distribute & Document (20 menit)**

#### **Step 1: Upload APK (10 menit)**
- [ ] Upload to Google Drive
- [ ] Set sharing: "Anyone with link can view"
- [ ] Copy share link

#### **Step 2: Create Distribution Notes (10 menit)**
- [ ] Create DISTRIBUTION.md:
  ```markdown
  # PhoneGuard Insurance App v1.0.0
  
  ## Download APK
  Link: [Your Google Drive Link]
  Size: ~40MB
  
  ## Requirements
  - Android 5.0 (Lollipop) or higher
  - Internet connection
  
  ## Installation
  1. Download APK
  2. Enable "Install from Unknown Sources"
  3. Install APK
  4. Open app & register
  
  ## Features
  - User registration & login
  - Wallet management
  - Policy creation (19 devices, 3 tiers)
  - Claim submission
  - Transaction history
  - Profile management
  
  ## Backend
  - API URL: https://your-app.railway.app
  - Admin Panel: https://your-app.railway.app/admin
  
  ## Support
  Email: chluik277@gmail.com
  ```

---

## 📊 PROGRESS TRACKER

```
Total Time Estimated: 3-4 hours

Phase 1: Persiapan           [ ] 15 min    ⏱️ __:__
Phase 2: Deploy Railway      [ ] 2-3 hours ⏱️ __:__
Phase 3: Update Flutter      [ ] 20 min    ⏱️ __:__
Phase 4: Build APK           [ ] 30 min    ⏱️ __:__
Phase 5: Distribute          [ ] 20 min    ⏱️ __:__

Total:                       [ ] ~4 hours  ⏱️ __:__
```

---

## 🚨 COMMON ISSUES & SOLUTIONS

### **Issue: Railway deployment fails**
**Solution:** 
- Check Procfile exists
- Check runtime.txt has correct Python version
- Check requirements.txt complete
- View Railway logs for error details

### **Issue: Database migration fails**
**Solution:**
- Make sure PostgreSQL plugin added
- Check DATABASE_URL in env variables
- Try manual migration via Railway terminal

### **Issue: Flutter can't connect to production**
**Solution:**
- Verify Railway URL correct in api_service.dart
- Check Railway app is running (not sleeping)
- Check CORS settings allow Flutter requests

### **Issue: APK build fails**
**Solution:**
- Run `flutter clean`
- Run `flutter pub get`
- Check Android SDK installed
- Check disk space available

---

## 💡 TIPS

1. **Deploy Early:** Start dengan Railway deployment pagi-pagi
2. **Test Often:** Test setiap step sebelum lanjut
3. **Save Logs:** Screenshot error messages untuk debug
4. **Backup:** Git commit before major changes
5. **Document:** Note Railway URL & credentials

---

## 🎯 SUCCESS CRITERIA

By end of tomorrow, you should have:
- [✓] Backend live di Railway (24/7 accessible)
- [✓] Production API URL
- [✓] Flutter app pointing to production
- [✓] Release APK built & tested
- [✓] APK uploaded & shareable
- [✓] Distribution notes created

**Result: Production app yang bisa dipakai user dari mana saja! 🚀**

---

## 📞 NEED HELP?

**Resources:**
1. SESSION_COMPLETION_REPORT.md (comprehensive status)
2. Railway Docs: https://docs.railway.app
3. Flutter Build Docs: https://docs.flutter.dev/deployment/android

**Contact:**
- Email: chluik277@gmail.com

---

*Good luck! Let's ship this app! 🚀*
