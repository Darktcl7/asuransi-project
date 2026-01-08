@echo off
echo ========================================
echo   Starting Flutter App (Chrome)
echo ========================================
echo.
echo PENTING: Pastikan Django server sudah jalan di terminal lain!
echo.
echo Server Django harus di: http://127.0.0.1:8000
echo.
echo Login dengan:
echo   Email: testuser20251122124718@example.com
echo   Password: testing123
echo.
echo ========================================
echo.

cd /d "%~dp0"
flutter run -d chrome

pause
