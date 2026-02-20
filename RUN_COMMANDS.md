# 🚀 Smile Insurance - Run Commands

## 1. Backend (Django API)
```bash
cd "d:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\activate
python manage.py runserver
```

## 2. Admin Dashboard (React)
```bash
cd "d:\Django Project\Asuransi Project\admin-dashboard"
npm run dev
```
- Dev: http://localhost:5174/
- Production: http://<SERVER_IP>/admin_store/

## 3. Customer Website (React)
```bash
cd "d:\Django Project\Asuransi Project\customer-website"
npm run dev
```
- Dev: http://localhost:5173/

## 4. Flutter Mobile App
```bash
cd "d:\Django Project\Asuransi Project\phone_insurance_app"
flutter pub get
flutter run --no-enable-impeller
```

## 5. Build APK (Release)
```bash
cd "d:\Django Project\Asuransi Project\phone_insurance_app"
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## 6. Database Migration
```bash
cd "d:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\activate
python manage.py makemigrations
python manage.py migrate
```

## 7. Create Superuser
```bash
cd "d:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\activate
python manage.py createsuperuser
```

## 8. Generate App Icon (Flutter)
```bash
cd "d:\Django Project\Asuransi Project\phone_insurance_app"
$env:PATH = "$env:PATH;C:\Program Files\Git\cmd"
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

## 9. Build Admin Dashboard for Production
```bash
cd "d:\Django Project\Asuransi Project\admin-dashboard"
npm run build
```
Output folder: `dist/`

## 10. Build Customer Website for Production
```bash
cd "d:\Django Project\Asuransi Project\customer-website"
npm run build
```
Output folder: `dist/`
