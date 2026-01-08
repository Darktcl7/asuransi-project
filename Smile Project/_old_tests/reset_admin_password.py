import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

# Reset password untuk admin
email = 'chluik277@gmail.com'
new_password = 'admin123'

try:
    user = User.objects.get(email=email)
    user.set_password(new_password)
    user.save()
    
    print("=== PASSWORD RESET BERHASIL ===")
    print(f"Email: {email}")
    print(f"Password Baru: {new_password}")
    print("\nSekarang bisa login ke: http://192.168.100.4:8000/admin/")
    
except User.DoesNotExist:
    print(f"ERROR: User dengan email {email} tidak ditemukan!")
