@echo off
echo ========================================
echo   SMILE INSURANCE - LOCAL DEVELOPMENT
echo ========================================
echo.

cd /d "D:\Django Project\Asuransi Project\Smile Project"

echo Activating virtual environment...
call env\Scripts\activate.bat

echo.
echo Installing dependencies...
pip install openpyxl django-ratelimit Pillow --quiet

echo.
echo Running migrations...
python manage.py migrate

echo.
echo Setting up Super Admin...
python setup_super_admin.py

echo.
echo ========================================
echo   STARTING DJANGO SERVER (Port 8000)
echo ========================================
echo.
echo Press Ctrl+C to stop the server
echo.
python manage.py runserver
