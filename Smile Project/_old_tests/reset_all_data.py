"""
Reset All User Data (Policies, Claims, Wallet, Transactions)
⚠️ WARNING: This will delete ALL policies, claims, wallet history, and reset wallets!
⚠️ User accounts will be kept, but all transaction data will be removed.

Run: env\Scripts\python.exe reset_all_data.py
"""

import os
import sys
import io
import django

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import Policy
from claims.models import Claim
from wallet.models import Wallet, WalletHistory, TopUpTransaction
from users.models import User
from decimal import Decimal

print("\n" + "="*70)
print("  ⚠️  RESET ALL USER DATA  ⚠️")
print("="*70)

print("\n📊 CURRENT DATA COUNT:")
print(f"   Users: {User.objects.filter(is_staff=False).count()}")
print(f"   Policies: {Policy.objects.count()}")
print(f"   Claims: {Claim.objects.count()}")
print(f"   Wallets: {Wallet.objects.count()}")
print(f"   Wallet History: {WalletHistory.objects.count()}")
print(f"   Top-Up Transactions: {TopUpTransaction.objects.count()}")

# Ask for confirmation
print("\n⚠️  WARNING: This will DELETE:")
print("   ❌ All policies")
print("   ❌ All claims")
print("   ❌ All wallet history")
print("   ❌ All top-up transactions")
print("   ❌ Reset all wallet balances to 0")
print("\n✅ KEEP:")
print("   ✅ User accounts (email, password)")
print("   ✅ Device packages")
print("   ✅ Policy tiers")

confirm = input("\n❓ Are you sure? Type 'YES' to confirm: ")

if confirm != 'YES':
    print("\n❌ Reset cancelled.")
    exit(0)

print("\n🗑️  Starting data reset...\n")

# Step 1: Delete all claims
claims_count = Claim.objects.count()
Claim.objects.all().delete()
print(f"✅ Step 1: Deleted {claims_count} claims")

# Step 2: Delete all policies
policies_count = Policy.objects.count()
Policy.objects.all().delete()
print(f"✅ Step 2: Deleted {policies_count} policies")

# Step 3: Delete all wallet history
history_count = WalletHistory.objects.count()
WalletHistory.objects.all().delete()
print(f"✅ Step 3: Deleted {history_count} wallet history entries")

# Step 4: Delete all top-up transactions
topup_count = TopUpTransaction.objects.count()
TopUpTransaction.objects.all().delete()
print(f"✅ Step 4: Deleted {topup_count} top-up transactions")

# Step 5: Reset all wallet balances to 0
wallets_count = Wallet.objects.count()
Wallet.objects.all().update(
    balance=Decimal('0.00'),
    total_topup=Decimal('0.00'),
    total_spent=Decimal('0.00')
)
print(f"✅ Step 5: Reset {wallets_count} wallets to Rp 0")

print("\n" + "="*70)
print("  RESET COMPLETE!")
print("="*70)

print("\n📊 NEW DATA COUNT:")
print(f"   Users: {User.objects.filter(is_staff=False).count()} (unchanged)")
print(f"   Policies: {Policy.objects.count()}")
print(f"   Claims: {Claim.objects.count()}")
print(f"   Wallets: {Wallet.objects.count()} (reset to Rp 0)")
print(f"   Wallet History: {WalletHistory.objects.count()}")
print(f"   Top-Up Transactions: {TopUpTransaction.objects.count()}")

print("\n✅ All user data has been reset!")
print("✅ You can now input data from scratch.")
print("✅ User accounts are still intact (can login).\n")
