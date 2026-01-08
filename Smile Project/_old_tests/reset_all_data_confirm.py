"""
Reset All User Data - AUTO CONFIRMED
⚠️ This will automatically reset all data without asking!

Run: env\Scripts\python.exe reset_all_data_confirm.py
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

print("\n📊 DATA SEBELUM RESET:")
users_count = User.objects.filter(is_staff=False).count()
policies_count = Policy.objects.count()
claims_count = Claim.objects.count()
wallets_count = Wallet.objects.count()
history_count = WalletHistory.objects.count()
topup_count = TopUpTransaction.objects.count()

print(f"   👥 Users: {users_count}")
print(f"   📋 Policies: {policies_count}")
print(f"   🎫 Claims: {claims_count}")
print(f"   💰 Wallets: {wallets_count}")
print(f"   📊 Wallet History: {history_count}")
print(f"   💳 Top-Up Transactions: {topup_count}")

print("\n🗑️  Mulai reset data...\n")

# Step 1: Delete all claims
deleted_claims = Claim.objects.all().delete()
print(f"✅ Step 1: Deleted {deleted_claims[0]} claims")

# Step 2: Delete all policies
deleted_policies = Policy.objects.all().delete()
print(f"✅ Step 2: Deleted {deleted_policies[0]} policies")

# Step 3: Delete all wallet history
deleted_history = WalletHistory.objects.all().delete()
print(f"✅ Step 3: Deleted {deleted_history[0]} wallet history")

# Step 4: Delete all top-up transactions
deleted_topups = TopUpTransaction.objects.all().delete()
print(f"✅ Step 4: Deleted {deleted_topups[0]} top-up transactions")

# Step 5: Reset all wallet balances to 0
updated_wallets = Wallet.objects.all().update(
    balance=Decimal('0.00'),
    total_topup=Decimal('0.00'),
    total_spent=Decimal('0.00')
)
print(f"✅ Step 5: Reset {updated_wallets} wallets to Rp 0")

print("\n" + "="*70)
print("  ✅ RESET SELESAI!")
print("="*70)

print("\n📊 DATA SETELAH RESET:")
print(f"   👥 Users: {User.objects.filter(is_staff=False).count()} (tetap)")
print(f"   📋 Policies: {Policy.objects.count()}")
print(f"   🎫 Claims: {Claim.objects.count()}")
print(f"   💰 Wallets: {Wallet.objects.count()} (balance = Rp 0)")
print(f"   📊 Wallet History: {WalletHistory.objects.count()}")
print(f"   💳 Top-Up Transactions: {TopUpTransaction.objects.count()}")

print("\n✅ Semua data berhasil di-reset!")
print("✅ User accounts tetap ada (bisa login)")
print("✅ Device packages tetap ada")
print("✅ Policy tiers tetap ada")
print("\n🎯 Sekarang bisa input data dari awal!\n")
