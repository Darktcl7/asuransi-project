"""
Ensure all users have wallets
Auto-create wallets for users who don't have one
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from wallet.models import Wallet
from decimal import Decimal

print("=" * 60)
print("  Checking & Creating Wallets")
print("=" * 60)
print()

# Find users without wallets
users_without_wallet = User.objects.filter(wallet__isnull=True)
count = users_without_wallet.count()

print(f"Found {count} users without wallets")
print()

if count > 0:
    print("Creating wallets...")
    wallets_created = []
    
    for user in users_without_wallet:
        wallet = Wallet.objects.create(
            user=user,
            balance=Decimal('0.00'),
            total_topup=Decimal('0.00'),
            total_spent=Decimal('0.00')
        )
        wallets_created.append(wallet)
        print(f"  [+] Created wallet for: {user.email}")
    
    print()
    print(f"[OK] Created {len(wallets_created)} wallets")
else:
    print("[OK] All users already have wallets!")

print()
print("=" * 60)
print("  Summary")
print("=" * 60)
print(f"  Total Users:   {User.objects.count()}")
print(f"  Total Wallets: {Wallet.objects.count()}")
print()
print("[SUCCESS] All users have wallets now!")
print("=" * 60)
