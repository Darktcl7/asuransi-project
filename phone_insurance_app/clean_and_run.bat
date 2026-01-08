@echo off
echo ========================================
echo CLEAN INSTALL - PhoneGuard Mobile App
echo ========================================
echo.
echo Step 1: Cleaning build cache...
call flutter clean
echo.
echo Step 2: Getting dependencies...
call flutter pub get
echo.
echo Step 3: Building and installing to phone...
echo (This will take 3-5 minutes, please wait...)
echo.
call flutter run
