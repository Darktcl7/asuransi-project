@echo off
echo ========================================
echo   PhoneGuard Admin - Starting Server
echo ========================================
echo.
cd /d "D:\Django Project\Asuransi Project\Smile Project"
echo Activating virtual environment...
call env\Scripts\activate.bat
echo.
echo Starting Django server...
echo Server will be available at: http://192.168.100.4:8000
echo Admin API: http://192.168.100.4:8000/api/admin/
echo.
python.exe manage.py runserver 0.0.0.0:8000
