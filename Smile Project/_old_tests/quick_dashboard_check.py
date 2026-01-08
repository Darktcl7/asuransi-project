"""
Quick Dashboard Check
Verify dashboard displays correct data
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from claims.models import Claim
from policies.models import Policy
from wallet.models import Wallet

User = get_user_model()

print("=" * 70)
print("QUICK DASHBOARD CHECK")
print("=" * 70)

print("\nEXPECTED DASHBOARD DATA:")
print("-" * 70)

# Users
total_users = User.objects.count()
verified_users = User.objects.filter(is_verified=True).count()
print(f"\nTOTAL USERS: {total_users:,}")
print(f"   Verified: {verified_users:,}")

# Policies
active_policies = Policy.objects.filter(status='active').count()
pending_policies = Policy.objects.filter(status='pending').count()
print(f"\nACTIVE POLICIES: {active_policies}")
print(f"   Pending: {pending_policies}")

# Claims
pending_claims = Claim.objects.filter(status='pending').count()
approved_claims = Claim.objects.filter(status='approved').count()
print(f"\nPENDING CLAIMS: {pending_claims}")
print(f"   Approved: {approved_claims}")

# Wallet
from django.db.models import Sum
total_balance = Wallet.objects.aggregate(Sum('balance'))['balance__sum'] or 0
print(f"\nTOTAL BALANCE: Rp {total_balance:,.0f}")
print(f"   In Millions: Rp {total_balance/1000000:.1f}M")

print("\n" + "-" * 70)
print("NEXT STEPS:")
print("-" * 70)
print("\n1. Open admin dashboard:")
print("   http://localhost:5174")
print("\n2. Verify numbers match:")
print(f"   - Total Users: {total_users:,}")
print(f"   - Active Policies: {active_policies}")
print(f"   - Pending Claims: {pending_claims}")
print(f"   - Total Balance: Rp {total_balance/1000000:.0f}M")
print("\n3. Check charts display correctly")
print("4. Verify Quick Actions show correct counts")
print("\n" + "=" * 70)
print()
