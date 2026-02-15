@echo off
REM =====================================================
REM AUTO CLEANUP ACTIVITY LOGS
REM Jalankan setiap minggu untuk hapus logs > 1 tahun
REM =====================================================

cd /d "D:\Django Project\Asuransi Project\Smile Project"

REM Activate virtual environment
call env\Scripts\activate.bat

REM Log start time
echo [%date% %time%] Starting cleanup... >> logs\cleanup_activity_logs.log

REM Run cleanup command (delete logs older than 365 days)
python manage.py cleanup_activity_logs --days=365 >> logs\cleanup_activity_logs.log 2>&1

REM Log end time
echo [%date% %time%] Cleanup completed. >> logs\cleanup_activity_logs.log
echo. >> logs\cleanup_activity_logs.log

REM Deactivate
deactivate
