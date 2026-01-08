"""
Verify wallet statistics calculations
Check if Total Balance = Total Top-Up - Total Spent
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from wallet.models import Wallet
from django.db.models import Sum

print("=" * 70)
print("WALLET STATISTICS VERIFICATION")
print("=" * 70)

# Get all wallets
wallets = Wallet.objects.all()
wallet_count = wallets.count()

print(f"\nTotal Wallets: {wallet_count}")

# Calculate aggregates
stats = Wallet.objects.aggregate(
    total_balance=Sum('balance'),
    total_topup=Sum('total_topup'),
    total_spent=Sum('total_spent')
)

total_balance = float(stats['total_balance'] or 0)
total_topup = float(stats['total_topup'] or 0)
total_spent = float(stats['total_spent'] or 0)

print("\n" + "-" * 70)
print("AGGREGATE STATS (FROM DATABASE)")
print("-" * 70)
print(f"Total Balance:  Rp {total_balance:,.0f}")
print(f"Total Top-Up:   Rp {total_topup:,.0f}")
print(f"Total Spent:    Rp {total_spent:,.0f}")

print("\n" + "-" * 70)
print("MATH VERIFICATION")
print("-" * 70)

expected_balance = total_topup - total_spent
print(f"Expected Balance (Top-Up - Spent): Rp {expected_balance:,.0f}")
print(f"Actual Balance (from DB):           Rp {total_balance:,.0f}")

if abs(expected_balance - total_balance) < 0.01:  # Allow small floating point differences
    print("\n✅ [PASS] Math is CORRECT!")
    print(f"   Total Top-Up ({total_topup:,.0f}) - Total Spent ({total_spent:,.0f}) = Total Balance ({total_balance:,.0f})")
else:
    difference = abs(expected_balance - total_balance)
    print(f"\n❌ [FAIL] Math is INCORRECT!")
    print(f"   Difference: Rp {difference:,.0f}")

# Detail per wallet
print("\n" + "-" * 70)
print("PER-WALLET BREAKDOWN")
print("-" * 70)
print(f"{'User Email':<30} {'Balance':>15} {'Top-Up':>15} {'Spent':>15}")
print("-" * 70)

for wallet in wallets:
    print(f"{wallet.user.email:<30} Rp {wallet.balance:>12,.0f} Rp {wallet.total_topup:>12,.0f} Rp {wallet.total_spent:>12,.0f}")

print("-" * 70)

# Verify each wallet individually
print("\n" + "-" * 70)
print("INDIVIDUAL WALLET VERIFICATION")
print("-" * 70)

all_correct = True
for wallet in wallets:
    expected = float(wallet.total_topup) - float(wallet.total_spent)
    actual = float(wallet.balance)
    
    is_correct = abs(expected - actual) < 0.01
    status = "✅ OK" if is_correct else "❌ ERROR"
    
    print(f"{status} {wallet.user.email:<30}")
    print(f"     Top-Up: Rp {wallet.total_topup:>12,.0f}")
    print(f"     Spent:  Rp {wallet.total_spent:>12,.0f}")
    print(f"     Expected Balance: Rp {expected:>12,.0f}")
    print(f"     Actual Balance:   Rp {actual:>12,.0f}")
    
    if not is_correct:
        all_correct = False
        diff = abs(expected - actual)
        print(f"     ⚠️ DIFFERENCE: Rp {diff:,.0f}")
    print()

print("=" * 70)
print("FINAL RESULT")
print("=" * 70)

if all_correct:
    print("✅ ALL WALLETS CORRECT!")
    print("✅ TOTAL STATS CORRECT!")
    print("\nThe numbers shown in admin dashboard are ACCURATE! 🎉")
else:
    print("❌ SOME WALLETS HAVE ERRORS!")
    print("⚠️ Please check wallet history for inconsistencies.")

print("\n" + "=" * 70)
