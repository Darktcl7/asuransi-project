@echo off
echo ====================================================
echo   PhoneGuard Insurance - Starting All Services
echo ====================================================
echo.

:: Start Django Backend
echo [1/3] Starting Django Backend Server...
start "Django Backend" cmd /k "cd /d \"d:\Django Project\Asuransi Project\Smile Project\" && .\env\Scripts\activate && python manage.py runserver"

:: Wait a bit for Django to start
timeout /t 3 /nobreak > nul

:: Start React Admin Dashboard
echo [2/3] Starting React Admin Dashboard...
start "React Dashboard" cmd /k "cd /d \"d:\Django Project\Asuransi Project\admin-dashboard\" && npm run dev"

:: Wait a bit
timeout /t 2 /nobreak > nul

:: Start Flutter Mobile App
echo [3/3] Starting Flutter Mobile App...
start "Flutter App" cmd /k "cd /d \"d:\Django Project\Asuransi Project\phone_insurance_app\" && flutter run"

echo.
echo ====================================================
echo   All services are starting in separate windows!
echo ====================================================
echo.
echo   Django Backend:    http://127.0.0.1:8000
echo   Admin Dashboard:   http://localhost:5174
echo   Flutter App:       Running on emulator/device
echo.
echo ====================================================
pause
