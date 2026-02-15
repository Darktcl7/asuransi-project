"""
Fix user data:
1. Set is_staff=True for store_admin
2. Assign customers to stores
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
print("🔧 Fixing User Data")
print("=" * 70)

# 1. Fix is_staff for store_admin
print("\n1️⃣ Setting is_staff=True for all store_admin users...")
updated = User.objects.filter(role='store_admin', is_staff=False).update(is_staff=True)
print(f"   ✅ Updated {updated} store_admin users")

# 2. Assign unassigned customers to stores (split evenly)
print("\n2️⃣ Assigning customers without store to stores...")
stores = list(Store.objects.filter(is_active=True))
if stores:
    unassigned = User.objects.filter(role='customer', store__isnull=True)
    unassigned_count = unassigned.count()
    print(f"   Found {unassigned_count} customers without store")
    
    # Split customers among stores
    for i, user in enumerate(unassigned):
        store = stores[i % len(stores)]
        user.store = store
        user.save(update_fields=['store'])
    
    print(f"   ✅ Assigned {unassigned_count} customers to stores")

# 3. Show updated summary
print("\n" + "=" * 70)
print("📊 Updated Summary")
print("=" * 70)

for store in stores:
    count = User.objects.filter(store=store, role='customer').count()
    admins = User.objects.filter(store=store, role='store_admin').count()
    print(f"   🏪 {store.code}: {count} customers, {admins} admin(s)")

no_store = User.objects.filter(store__isnull=True, role='customer').count()
print(f"   ❓ No Store: {no_store} customers")

print("\n✅ Done!")
