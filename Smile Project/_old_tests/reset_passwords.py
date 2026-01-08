"""
Reset Password untuk User Tertentu
Run: env\Scripts\python.exe reset_passwords.py
"""

import os
import sys
import io
import django

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

print("\n" + "="*60)
print("  PASSWORD RESET UTILITY")
print("="*60)

# Daftar user yang mau di-reset passwordnya
users_to_reset = [
    {'email': 'leomanggi@gmail.com', 'new_password': 'password123'},
    {'email': 'ardy@gamil.com', 'new_password': 'password123'},  # Keep original: ardy@gamil.com
]

print("\nResetting passwords...\n")

for user_data in users_to_reset:
    email = user_data['email']
    new_password = user_data['new_password']
    
    try:
        user = User.objects.get(email=email)
        user.set_password(new_password)
        user.save()
        
        print(f"✅ SUCCESS: {email}")
        print(f"   New Password: {new_password}")
        print(f"   User ID: {user.id}")
        print(f"   Name: {user.first_name} {user.last_name}")
        print()
        
    except User.DoesNotExist:
        print(f"❌ ERROR: User '{email}' tidak ditemukan!")
        print(f"   Mungkin typo di email? Coba cek database.")
        print()

print("\n" + "="*60)
print("  PASSWORD RESET SELESAI!")
print("="*60)
print("\n📝 Default password untuk semua user: password123")
print("   User bisa login dengan password ini.\n")
