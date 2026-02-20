import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

# List of admins to fix
admin_emails = ['admin@smile.com', 'superadmin@smile.com', 'chluik277@gmail.com']

for email in admin_emails:
    admin = User.objects.filter(email=email).first()
    if admin:
        admin.role = 'super_admin'
        admin.is_staff = True
        admin.is_superuser = True
        admin.save()
        print(f"✅ Verified {admin.email} (Role: {admin.role}, Superuser: {admin.is_superuser})")
    else:
        print(f"❌ User {email} not found.")

# Also update any other superusers just in case
others = User.objects.filter(is_superuser=True).exclude(email__in=admin_emails).update(role='super_admin')
print(f"✅ Updated {others} other superuser(s).")
