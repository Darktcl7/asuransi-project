@echo off
echo ========================================
echo FULL REBUILD FLUTTER APP
echo ========================================
echo.
echo Cleaning build cache...
flutter clean
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Building and running app...
flutter run
