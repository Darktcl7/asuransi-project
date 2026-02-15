"""
Script untuk melihat dan fix data users
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User
from stores.models import Store

print("=" * 70)
print("📊 Current Users Data")
print("=" * 70)

for user in User.objects.all().order_by('role', '-date_joined')[:50]:
    store_code = user.store.code if user.store else "No Store"
    print(f"{user.email:40} | {user.role:12} | {store_code:12} | staff={user.is_staff}")

print("\n" + "=" * 70)
print("📊 Summary by Role")
print("=" * 70)
for role in ['super_admin', 'store_admin', 'store_staff', 'customer']:
    count = User.objects.filter(role=role).count()
    print(f"   {role}: {count}")

print("\n" + "=" * 70)
print("🏪 Available Stores")
print("=" * 70)
for store in Store.objects.all():
    print(f"   {store.id} | {store.code} | {store.name}")
