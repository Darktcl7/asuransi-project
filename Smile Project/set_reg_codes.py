"""
Set registration codes for existing stores
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    cursor.execute("UPDATE stores SET registration_code = 'KUA001' WHERE code = 'SPC-KUA'")
    cursor.execute("UPDATE stores SET registration_code = 'OSP001' WHERE code = 'SPC-OSP'")
    print("✅ Registration codes set!")
    print("   SPC-KUA -> KUA001")
    print("   SPC-OSP -> OSP001")
