"""
SEED LARGE DATA - Generate realistic dummy data for performance testing
- 10,000 users
- 5,000 policies
- 3,000 claims
- 10,000 wallet transactions
"""

import os
import django
import random
from decimal import Decimal
from datetime import datetime, timedelta
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from policies.models import Policy, PolicyTier
from claims.models import Claim
from wallet.models import Wallet, TopUpTransaction, WalletHistory

# Faker for realistic data
from faker import Faker
fake = Faker('id_ID')  # Indonesian locale

print("=" * 60)
print("  SEED LARGE DATA - Performance Testing")
print("=" * 60)
print()

# ===================================================================
# 1. CREATE POLICY TIERS (if not exist)
# ===================================================================
print("[1/5] Creating Policy Tiers...")

tiers = [
    {
        'tier_name': 'Bronze',
        'policy_price': Decimal('50000'),
        'min_price': Decimal('1000000'),
        'max_price': Decimal('2000000'),
        'policy_duration_days': 365,
        'max_claims_per_year': 2,
        'claim_deduction_percent': Decimal('10.00'),
    },
    {
        'tier_name': 'Silver',
        'policy_price': Decimal('100000'),
        'min_price': Decimal('2000000'),
        'max_price': Decimal('5000000'),
        'policy_duration_days': 365,
        'max_claims_per_year': 3,
        'claim_deduction_percent': Decimal('10.00'),
    },
    {
        'tier_name': 'Gold',
        'policy_price': Decimal('200000'),
        'min_price': Decimal('5000000'),
        'max_price': Decimal('10000000'),
        'policy_duration_days': 365,
        'max_claims_per_year': 4,
        'claim_deduction_percent': Decimal('10.00'),
    },
    {
        'tier_name': 'Platinum',
        'policy_price': Decimal('300000'),
        'min_price': Decimal('10000000'),
        'max_price': Decimal('15000000'),
        'policy_duration_days': 365,
        'max_claims_per_year': 5,
        'claim_deduction_percent': Decimal('10.00'),
    }
]

tier_objects = []
for tier_data in tiers:
    tier, created = PolicyTier.objects.get_or_create(
        tier_name=tier_data['tier_name'],
        defaults=tier_data
    )
    tier_objects.append(tier)
    if created:
        print(f"  [+] Created tier: {tier.tier_name}")
    else:
        print(f"  [*] Tier exists: {tier.tier_name}")

print(f"[OK] Total tiers: {len(tier_objects)}")
print()

# ===================================================================
# 2. GENERATE USERS
# ===================================================================
print("[2/5] Generating 10,000 Users...")
print("  This may take 2-3 minutes...")

users_to_create = []
batch_size = 500

for i in range(10000):
    email = f"user{i+1}@test.com"
    phone = f"08{random.randint(1000000000, 9999999999)}"
    ktp = f"{random.randint(1000000000000000, 9999999999999999)}"
    
    user = User(
        email=email,
        phone_number=phone,
        ktp_number=ktp,
        is_verified=random.choice([True, True, True, False]),  # 75% verified
    )
    user.set_password('password123')
    users_to_create.append(user)
    
    # Bulk create every 500 users
    if len(users_to_create) >= batch_size:
        User.objects.bulk_create(users_to_create, ignore_conflicts=True)
        print(f"  [+] Created {i+1}/10,000 users...")
        users_to_create = []

# Create remaining
if users_to_create:
    User.objects.bulk_create(users_to_create, ignore_conflicts=True)

total_users = User.objects.count()
print(f"[OK] Total users in database: {total_users}")
print()

# ===================================================================
# 3. GENERATE WALLETS & POLICIES
# ===================================================================
print("[3/5] Generating 5,000 Policies...")
print("  Creating wallets and policies...")

all_users = list(User.objects.all()[:5000])  # First 5000 users
policies_to_create = []
wallets_to_create = []

for i, user in enumerate(all_users):
    # Create wallet for user
    wallet = Wallet(
        user=user,
        balance=Decimal(random.randint(0, 5000000))
    )
    wallets_to_create.append(wallet)
    
    # Create policy for user
    tier = random.choice(tier_objects)
    policy = Policy(
        user=user,
        tier=tier,
        imei_number=f"{random.randint(100000000000000, 999999999999999)}",
        device_brand=random.choice(['Samsung', 'iPhone', 'Xiaomi', 'Oppo', 'Vivo']),
        device_model=f"Model-{random.randint(1, 100)}",
        purchase_date=timezone.now() - timedelta(days=random.randint(1, 365)),
        status=random.choice(['active', 'active', 'active', 'expired']),  # 75% active
        start_date=timezone.now() - timedelta(days=random.randint(1, 365)),
        end_date=timezone.now() + timedelta(days=random.randint(30, 365))
    )
    policies_to_create.append(policy)
    
    if len(policies_to_create) >= batch_size:
        Wallet.objects.bulk_create(wallets_to_create, ignore_conflicts=True)
        Policy.objects.bulk_create(policies_to_create, ignore_conflicts=True)
        print(f"  [+] Created {i+1}/5,000 policies...")
        policies_to_create = []
        wallets_to_create = []

# Create remaining
if policies_to_create:
    Wallet.objects.bulk_create(wallets_to_create, ignore_conflicts=True)
    Policy.objects.bulk_create(policies_to_create, ignore_conflicts=True)

total_policies = Policy.objects.count()
total_wallets = Wallet.objects.count()
print(f"[OK] Total policies: {total_policies}")
print(f"[OK] Total wallets: {total_wallets}")
print()

# ===================================================================
# 4. GENERATE CLAIMS
# ===================================================================
print("[4/5] Generating 3,000 Claims...")

policies_with_users = list(Policy.objects.select_related('user').all()[:3000])
claims_to_create = []

for i, policy in enumerate(policies_with_users):
    claim = Claim(
        user=policy.user,
        policy=policy,
        claim_number=f"CLM{timezone.now().year}{str(i+1).zfill(6)}",
        incident_date=timezone.now() - timedelta(days=random.randint(1, 90)),
        incident_description=fake.text(max_nb_chars=200),
        claim_amount=Decimal(random.randint(100000, 5000000)),
        status=random.choice(['pending', 'approved', 'rejected', 'pending']),
        created_at=timezone.now() - timedelta(days=random.randint(1, 90))
    )
    
    # Add admin notes for approved/rejected
    if claim.status in ['approved', 'rejected']:
        claim.admin_notes = fake.sentence()
        claim.processed_at = timezone.now() - timedelta(days=random.randint(1, 30))
    
    claims_to_create.append(claim)
    
    if len(claims_to_create) >= batch_size:
        Claim.objects.bulk_create(claims_to_create, ignore_conflicts=True)
        print(f"  [+] Created {i+1}/3,000 claims...")
        claims_to_create = []

# Create remaining
if claims_to_create:
    Claim.objects.bulk_create(claims_to_create, ignore_conflicts=True)

total_claims = Claim.objects.count()
print(f"[OK] Total claims: {total_claims}")
print()

# ===================================================================
# 5. GENERATE WALLET TRANSACTIONS
# ===================================================================
print("[5/5] Generating 10,000 Wallet Transactions...")

wallets_list = list(Wallet.objects.select_related('user').all()[:2000])
topups_to_create = []
histories_to_create = []

for i in range(10000):
    wallet = random.choice(wallets_list)
    
    # Create top-up
    topup = TopUpTransaction(
        user=wallet.user,
        wallet=wallet,
        transaction_id=f"TOP{timezone.now().year}{str(i+1).zfill(8)}",
        amount=Decimal(random.choice([50000, 100000, 200000, 500000])),
        status=random.choice(['completed', 'pending', 'completed', 'completed']),
        created_at=timezone.now() - timedelta(days=random.randint(1, 180))
    )
    topups_to_create.append(topup)
    
    # Create wallet history
    history = WalletHistory(
        wallet=wallet,
        transaction_type=random.choice(['topup', 'claim_payout', 'policy_payment']),
        amount=Decimal(random.randint(10000, 500000)),
        balance_after=wallet.balance,
        description=fake.sentence(),
        created_at=timezone.now() - timedelta(days=random.randint(1, 180))
    )
    histories_to_create.append(history)
    
    if len(topups_to_create) >= batch_size:
        TopUpTransaction.objects.bulk_create(topups_to_create, ignore_conflicts=True)
        WalletHistory.objects.bulk_create(histories_to_create, ignore_conflicts=True)
        print(f"  [+] Created {i+1}/10,000 transactions...")
        topups_to_create = []
        histories_to_create = []

# Create remaining
if topups_to_create:
    TopUpTransaction.objects.bulk_create(topups_to_create, ignore_conflicts=True)
    WalletHistory.objects.bulk_create(histories_to_create, ignore_conflicts=True)

total_topups = TopUpTransaction.objects.count()
total_histories = WalletHistory.objects.count()
print(f"[OK] Total top-ups: {total_topups}")
print(f"[OK] Total wallet histories: {total_histories}")
print()

# ===================================================================
# SUMMARY
# ===================================================================
print("=" * 60)
print("  [SUCCESS] DATA SEEDING COMPLETE!")
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
print(f"  TOTAL RECORDS:      {User.objects.count() + Policy.objects.count() + Claim.objects.count() + Wallet.objects.count() + TopUpTransaction.objects.count() + WalletHistory.objects.count():,}")
print()
print("=" * 60)
print("  Ready for performance testing!")
print("=" * 60)
