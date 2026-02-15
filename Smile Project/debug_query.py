# -*- coding: utf-8 -*-
"""
Debug: Check what AdminUserViewSet query returns
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User
from django.db.models import Q

print("=" * 60)
print("DEBUG: AdminUserViewSet Query")
print("=" * 60)

# Simulating what the ViewSet does
queryset = User.objects.select_related('store').order_by('-date_joined')

print(f"\nTotal users in database: {queryset.count()}")

# Check by role
print("\nUsers by role:")
for role in ['customer', 'store_admin', 'store_staff', 'super_admin']:
    count = queryset.filter(role=role).count()
    print(f"  {role}: {count}")

# Search test
search = 'chluik277'
print(f"\nSearch for '{search}':")
results = queryset.filter(
    Q(email__icontains=search) |
    Q(phone_number__icontains=search) |
    Q(first_name__icontains=search) |
    Q(last_name__icontains=search) |
    Q(ktp_number__icontains=search)
)
print(f"  Found: {results.count()}")
for user in results:
    print(f"    - {user.email} (role: {user.role}, store: {user.store})")

# Check if store_admin is being filtered out somehow
print("\n" + "=" * 60)
print("All store_admin users:")
print("=" * 60)
for user in User.objects.filter(role='store_admin'):
    print(f"  {user.email}")
    print(f"    store_id: {user.store_id}")
    print(f"    store: {user.store}")
