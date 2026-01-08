@echo off
echo ========================================
echo BUILD APK - PhoneGuard Mobile App
echo ========================================
echo.
echo Building DEBUG APK...
echo This will take 3-5 minutes...
echo.
call flutter build apk --debug
echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Next steps:
echo 1. Copy app-debug.apk to your phone
echo 2. Install it on your phone
echo 3. Open the app
echo.
pause
