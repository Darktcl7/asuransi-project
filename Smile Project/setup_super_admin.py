"""
Script untuk membuat Super Admin BARU
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User

def create_super_admin():
    email = 'superadmin@smile.com'
    password = 'SuperAdmin123!'
    
    # Cek apakah sudah ada
    if User.objects.filter(email=email).exists():
        user = User.objects.get(email=email)
        user.role = 'super_admin'
        user.is_staff = True
        user.is_superuser = True
        user.set_password(password)  # Reset password
        user.save()
        print(f"✅ UPDATED! Super Admin password reset:")
    else:
        # Buat user baru
        user = User.objects.create_user(
            email=email,
            password=password,
            first_name='Super',
            last_name='Admin',
            role='super_admin',
            is_staff=True,
            is_superuser=True,
        )
        print(f"✅ CREATED! New Super Admin:")
    
    print(f"   Email: {email}")
    print(f"   Password: {password}")
    print(f"   Role: {user.role}")

def set_store_admin():
    email = 'chluik277@gmail.com'
    try:
        user = User.objects.get(email=email)
        user.role = 'store_admin'  # Set sebagai Store Admin (bukan Super Admin)
        user.save()
        print(f"\n✅ Store Admin tetap:")
        print(f"   Email: {email}")
        print(f"   Role: {user.role}")
    except User.DoesNotExist:
        print(f"\n⚠️ User {email} tidak ditemukan")

if __name__ == '__main__':
    print("=" * 50)
    print("Setting up Admin Accounts...")
    print("=" * 50)
    create_super_admin()
    set_store_admin()
    print("=" * 50)
