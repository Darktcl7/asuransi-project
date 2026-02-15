@echo off
echo ========================================
echo   SMILE INSURANCE - RUN MIGRATIONS
echo ========================================
echo.

cd /d "D:\Django Project\Asuransi Project\Smile Project"

echo Activating virtual environment...
call env\Scripts\activate.bat

echo.
echo Running makemigrations for all apps...
python manage.py makemigrations

echo.
echo Running makemigrations for stores...
python manage.py makemigrations stores

echo.
echo Running makemigrations for policies...
python manage.py makemigrations policies

echo.
echo Applying all migrations...
python manage.py migrate

echo.
echo ========================================
echo   MIGRATIONS COMPLETE!
echo ========================================
echo.
pause
