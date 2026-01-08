"""
QUICK SEED - Generate data faster (smaller dataset for quick testing)
- 1,000 users
- 500 policies
- 300 claims
- 1,000 transactions
"""

import os
import django
import random
from decimal import Decimal
from datetime import datetime, timedelta
from django.utils import timezone
from django.contrib.auth.hashers import make_password

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from policies.models import Policy, PolicyTier, DevicePackage
from claims.models import Claim
from wallet.models import Wallet, TopUpTransaction, WalletHistory

print("=" * 60)
print("  QUICK SEED - Performance Testing (Fast Mode)")
print("=" * 60)
print()

# Get or create device packages
print("[1/6] Creating Device Packages...")
devices_data = [
    {'device_brand': 'Samsung', 'device_model': 'Galaxy S23', 'device_variant': '256GB', 'device_value': Decimal('12000000')},
    {'device_brand': 'iPhone', 'device_model': 'iPhone 15 Pro', 'device_variant': '256GB', 'device_value': Decimal('18000000')},
    {'device_brand': 'Xiaomi', 'device_model': 'Mi 13', 'device_variant': '128GB', 'device_value': Decimal('7000000')},
    {'device_brand': 'Oppo', 'device_model': 'Reno 10', 'device_variant': '256GB', 'device_value': Decimal('6000000')},
    {'device_brand': 'Vivo', 'device_model': 'V27 Pro', 'device_variant': '256GB', 'device_value': Decimal('6500000')},
]

device_objects = []
for device_data in devices_data:
    device, created = DevicePackage.objects.get_or_create(
        device_brand=device_data['device_brand'],
        device_model=device_data['device_model'],
        defaults=device_data
    )
    device_objects.append(device)
print(f"[OK] Total devices: {len(device_objects)}")
print()

# Get or create tiers
print("[2/6] Getting Policy Tiers...")
tiers_data = [
    {'tier_name': 'Bronze', 'policy_price': Decimal('50000'), 'min_price': Decimal('1000000'), 'max_price': Decimal('2000000'), 'policy_duration_days': 365, 'max_claims_per_year': 2, 'claim_deduction_percent': Decimal('10.00')},
    {'tier_name': 'Silver', 'policy_price': Decimal('100000'), 'min_price': Decimal('2000000'), 'max_price': Decimal('5000000'), 'policy_duration_days': 365, 'max_claims_per_year': 3, 'claim_deduction_percent': Decimal('10.00')},
    {'tier_name': 'Gold', 'policy_price': Decimal('200000'), 'min_price': Decimal('5000000'), 'max_price': Decimal('10000000'), 'policy_duration_days': 365, 'max_claims_per_year': 4, 'claim_deduction_percent': Decimal('10.00')},
    {'tier_name': 'Platinum', 'policy_price': Decimal('300000'), 'min_price': Decimal('10000000'), 'max_price': Decimal('15000000'), 'policy_duration_days': 365, 'max_claims_per_year': 5, 'claim_deduction_percent': Decimal('10.00')},
]

tier_objects = []
for tier_data in tiers_data:
    tier, created = PolicyTier.objects.get_or_create(tier_name=tier_data['tier_name'], defaults=tier_data)
    tier_objects.append(tier)
print(f"[OK] Total tiers: {len(tier_objects)}")
print()

# Generate users (pre-hashed password for speed)
print("[3/6] Generating 1,000 Users...")
hashed_password = make_password('password123')
users_to_create = []
for i in range(1000):
    users_to_create.append(User(
        email=f"user{i+1}@test.com",
        phone_number=f"08{random.randint(1000000000, 9999999999)}",
        ktp_number=f"{random.randint(1000000000000000, 9999999999999999)}",
        is_verified=random.choice([True, True, True, False]),
        password=hashed_password
    ))

User.objects.bulk_create(users_to_create, ignore_conflicts=True)
print(f"[OK] Total users: {User.objects.count()}")
print()

# Generate wallets & policies
print("[4/6] Generating 500 Policies...")
all_users = list(User.objects.all()[:500])
policies_to_create = []
wallets_to_create = []

for i, user in enumerate(all_users):
    wallets_to_create.append(Wallet(user=user, balance=Decimal(random.randint(0, 5000000))))
    tier = random.choice(tier_objects)
    device = random.choice(device_objects)
    policies_to_create.append(Policy(
        user=user,
        tier=tier,
        device_package=device,
        policy_number=f"POL{timezone.now().year}{str(i+1).zfill(6)}",
        imei_number=f"{random.randint(100000000000000, 999999999999999)}",
        purchase_price=device.device_value,
        policy_price=tier.policy_price,
        status=random.choice(['active', 'active', 'active', 'expired'])
    ))

Wallet.objects.bulk_create(wallets_to_create, ignore_conflicts=True)
Policy.objects.bulk_create(policies_to_create, ignore_conflicts=True)
print(f"[OK] Total policies: {Policy.objects.count()}")
print(f"[OK] Total wallets: {Wallet.objects.count()}")
print()

# Generate claims
print("[5/6] Generating 300 Claims...")
policies_with_users = list(Policy.objects.select_related('user').all()[:300])
claims_to_create = []

for i, policy in enumerate(policies_with_users):
    claim_amt = Decimal(random.randint(100000, 5000000))
    deduction_pct = Decimal('10.00')
    deduction_amt = (claim_amt * deduction_pct) / Decimal('100')
    
    claims_to_create.append(Claim(
        user=policy.user,
        policy=policy,
        claim_number=f"CLM{timezone.now().year}{str(i+1).zfill(6)}",
        damage_type=random.choice(['Layar Pecah', 'Kerusakan Air', 'Baterai Rusak', 'Mati Total']),
        damage_description=f"Test damage description {i+1}",
        incident_date=timezone.now().date() - timedelta(days=random.randint(1, 90)),
        claim_amount=claim_amt,
        deduction_percent=deduction_pct,
        deduction_amount=deduction_amt,
        status=random.choice(['pending', 'approved', 'rejected', 'pending'])
    ))

Claim.objects.bulk_create(claims_to_create, ignore_conflicts=True)
print(f"[OK] Total claims: {Claim.objects.count()}")
print()

# Generate transactions
print("[6/6] Generating 1,000 Transactions...")
wallets_list = list(Wallet.objects.select_related('user').all())
topups_to_create = []
histories_to_create = []

for i in range(1000):
    wallet = random.choice(wallets_list)
    topups_to_create.append(TopUpTransaction(
        user=wallet.user,
        transaction_id=f"TOP{timezone.now().year}{str(i+1).zfill(8)}",
        amount=Decimal(random.choice([50000, 100000, 200000, 500000])),
        payment_method=random.choice(['bank_transfer', 'ewallet', 'credit_card']),
        status=random.choice(['completed', 'pending', 'completed', 'completed'])
    ))
    amt = Decimal(random.randint(10000, 500000))
    histories_to_create.append(WalletHistory(
        wallet=wallet,
        transaction_type=random.choice(['topup', 'claim_payout', 'policy_payment']),
        amount=amt,
        balance_before=wallet.balance,
        balance_after=wallet.balance + amt,
        description=f"Test transaction {i+1}"
    ))

TopUpTransaction.objects.bulk_create(topups_to_create, ignore_conflicts=True)
WalletHistory.objects.bulk_create(histories_to_create, ignore_conflicts=True)
print(f"[OK] Total top-ups: {TopUpTransaction.objects.count()}")
print(f"[OK] Total histories: {WalletHistory.objects.count()}")
print()

# Summary
print("=" * 60)
print("  [SUCCESS] QUICK SEED COMPLETE!")
print("=" * 60)
print()
print("Database Statistics:")
print(f"  Users:              {User.objects.count():,}")
print(f"  Policies:           {Policy.objects.count():,}")
print(f"  Claims:             {Claim.objects.count():,}")
print(f"  Wallets:            {Wallet.objects.count():,}")
print(f"  Top-ups:            {TopUpTransaction.objects.count():,}")
print(f"  Wallet Histories:   {WalletHistory.objects.count():,}")
print()
total = User.objects.count() + Policy.objects.count() + Claim.objects.count() + Wallet.objects.count() + TopUpTransaction.objects.count() + WalletHistory.objects.count()
print(f"  TOTAL RECORDS:      {total:,}")
print()
print("=" * 60)
print("  Ready for performance testing!")
print("=" * 60)
