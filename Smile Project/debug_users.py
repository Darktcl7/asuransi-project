"""
Debug script to check user data and store assignments
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User
from stores.models import Store

print("=" * 80)
print("📊 LATEST 15 USERS (by date_joined)")
print("=" * 80)
print(f"{'Email':40} | {'Role':12} | {'Store':12} | Staff")
print("-" * 80)

for user in User.objects.select_related('store').order_by('-date_joined')[:15]:
    store_code = user.store.code if user.store else "NO STORE"
    print(f"{user.email:40} | {user.role:12} | {store_code:12} | {user.is_staff}")

print("\n" + "=" * 80)
print("🏪 STORES AND THEIR REGISTRATION CODES")
print("=" * 80)
for store in Store.objects.all():
    user_count = User.objects.filter(store=store).count()
    print(f"   {store.code}: '{store.registration_code}' -> {user_count} users")

print("\n" + "=" * 80)
print("📊 SUMMARY BY ROLE")
print("=" * 80)
for role in ['super_admin', 'store_admin', 'store_staff', 'customer']:
    count = User.objects.filter(role=role).count()
    with_store = User.objects.filter(role=role, store__isnull=False).count()
    print(f"   {role:15}: {count} total, {with_store} with store")

print("\n✅ Done!")
