@echo off
echo ========================================
echo FORGOT PASSWORD FEATURE TEST
echo ========================================
echo.
echo IMPORTANT: Make sure Django backend is running!
echo Run in another terminal: python manage.py runserver
echo.
echo Press any key to start test...
pause > nul
echo.
echo Starting test...
echo.
.\env\Scripts\python.exe test_forgot_password.py
echo.
echo ========================================
echo Test completed!
echo ========================================
pause
