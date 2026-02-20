# setup_local_admin.py
import os
import django
import sys

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

def setup_admin():
    email = 'admin@smile.com'
    password = 'admin' # You can change this
    
    user, created = User.objects.get_or_create(
        email=email,
        defaults={
            'role': 'super_admin',
            'is_staff': True,
            'is_superuser': True,
            'first_name': 'Super',
            'last_name': 'Admin',
            'is_active': True,
            'is_verified': True
        }
    )
    
    user.set_password(password)
    user.role = 'super_admin'
    user.is_staff = True
    user.is_superuser = True
    user.save()
    
    status = "Created" if created else "Updated"
    print(f"[{status}] Super Admin: {email}")
    print(f"Password set to: {password}")
    print(f"Role set to: {user.role}")

if __name__ == "__main__":
    setup_admin()
