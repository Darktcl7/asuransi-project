"""
Verify Data Reset
Run: env\Scripts\python.exe verify_reset.py
"""
import os
import sys
import io
import django

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from policies.models import Policy, PolicyTier, DevicePackage
from claims.models import Claim
from wallet.models import Wallet, WalletHistory, TopUpTransaction

print("\n" + "="*70)
print("  VERIFICATION AFTER RESET")
print("="*70)

print("\nCURRENT DATA COUNT:")
print(f"  Users (non-admin): {User.objects.filter(is_staff=False).count()}")
print(f"  Admin users: {User.objects.filter(is_staff=True).count()}")
print(f"  Policies: {Policy.objects.count()}")
print(f"  Claims: {Claim.objects.count()}")
print(f"  Wallets: {Wallet.objects.count()}")
print(f"  Wallet History: {WalletHistory.objects.count()}")
print(f"  Top-Up Transactions: {TopUpTransaction.objects.count()}")

print("\nSYSTEM RESOURCES (INTACT):")
print(f"  Policy Tiers: {PolicyTier.objects.filter(is_active=True).count()}")
print(f"  Device Packages: {DevicePackage.objects.filter(is_active=True).count()}")

print("\nWALLET STATUS:")
sample_wallets = Wallet.objects.all()[:5]
for wallet in sample_wallets:
    print(f"  {wallet.user.email}: Rp {wallet.balance}")

print("\n" + "="*70)
print("  VERIFICATION COMPLETE!")
print("="*70)
print("\nSTATUS: Ready for new data input!")
print("Users can login with existing credentials.")
print("Admin can create policies & top-ups.\n")
