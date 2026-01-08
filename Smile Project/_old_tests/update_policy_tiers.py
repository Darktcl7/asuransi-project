"""
Update Policy Tiers ke Smile 1-6
Run: env\Scripts\python.exe update_policy_tiers.py
"""

import os
import sys
import io
import django

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import PolicyTier
from decimal import Decimal

print("\n" + "="*70)
print("  UPDATE POLICY TIERS - SMILE 1-6")
print("="*70)

# Definisi tier baru - UPDATED PRICING!
new_tiers = [
    {
        'tier_name': 'Smile 1',
        'min_price': Decimal('0'),
        'max_price': Decimal('3000000'),
        'policy_price': Decimal('300000'),  # UPDATED: 150K → 300K
        'claim_deduction_percent': Decimal('10.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 3,
    },
    {
        'tier_name': 'Smile 2',
        'min_price': Decimal('3000001'),
        'max_price': Decimal('5000000'),
        'policy_price': Decimal('400000'),  # UPDATED: 250K → 400K
        'claim_deduction_percent': Decimal('8.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 4,
    },
    {
        'tier_name': 'Smile 3',
        'min_price': Decimal('5000001'),
        'max_price': Decimal('10000000'),
        'policy_price': Decimal('600000'),  # SAME: 400K → 600K (already correct)
        'claim_deduction_percent': Decimal('6.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 5,
    },
    {
        'tier_name': 'Smile 4',
        'min_price': Decimal('10000001'),
        'max_price': Decimal('15000000'),
        'policy_price': Decimal('900000'),  # UPDATED: 600K → 900K
        'claim_deduction_percent': Decimal('4.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 6,
    },
    {
        'tier_name': 'Smile 5',
        'min_price': Decimal('15000001'),
        'max_price': Decimal('20000000'),
        'policy_price': Decimal('1250000'),  # UPDATED: 800K → 1.25M
        'claim_deduction_percent': Decimal('2.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 8,
    },
    {
        'tier_name': 'Smile 6',
        'min_price': Decimal('20000001'),
        'max_price': Decimal('999999999'),
        'policy_price': Decimal('2500000'),  # UPDATED: 1M → 2.5M
        'claim_deduction_percent': Decimal('0.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 10,
    },
]

print("\n🗑️  STEP 1: Hapus tier lama...")
old_count = PolicyTier.objects.count()
print(f"   Found {old_count} existing tiers")

# Nonaktifkan tier lama instead of delete (untuk preserve referensi)
PolicyTier.objects.all().update(is_active=False)
print(f"   ✅ Deactivated all old tiers")

print("\n✅ STEP 2: Buat tier baru (Smile 1-6)...")
for tier_data in new_tiers:
    # Ensure is_active is True in defaults
    tier_data_with_active = tier_data.copy()
    tier_data_with_active['is_active'] = True
    
    tier, created = PolicyTier.objects.update_or_create(
        tier_name=tier_data['tier_name'],
        defaults=tier_data_with_active
    )
    
    if created:
        print(f"   ✅ Created: {tier.tier_name}")
    else:
        print(f"   ✅ Updated: {tier.tier_name}")
    
    print(f"      Price Range: Rp {tier.min_price:,.0f} - Rp {tier.max_price:,.0f}")
    print(f"      Policy Price: Rp {tier.policy_price:,.0f}")
    print(f"      Deduction: {tier.claim_deduction_percent}%")
    print(f"      Max Claims/Year: {tier.max_claims_per_year}")
    print()

print("="*70)
print("  TIER SUMMARY")
print("="*70)

active_tiers = PolicyTier.objects.filter(is_active=True).order_by('min_price')
print(f"\n📊 Total Active Tiers: {active_tiers.count()}\n")

print("┌─────────────┬────────────────────┬──────────────┬────────────┐")
print("│ Tier        │ Price Range        │ Policy Price │ Deduction  │")
print("├─────────────┼────────────────────┼──────────────┼────────────┤")

for tier in active_tiers:
    tier_name = tier.tier_name.ljust(11)
    price_range = f"{tier.min_price/1000000:.1f}M - {tier.max_price/1000000:.1f}M".ljust(18)
    policy_price = f"Rp {tier.policy_price/1000:.0f}K".ljust(12)
    deduction = f"{tier.claim_deduction_percent}%".ljust(10)
    
    print(f"│ {tier_name} │ {price_range} │ {policy_price} │ {deduction} │")

print("└─────────────┴────────────────────┴──────────────┴────────────┘")

print("\n" + "="*70)
print("  UPDATE SELESAI!")
print("="*70)
print("\n✅ Policy Tiers berhasil diupdate ke Smile 1-6!")
print("✅ Admin sekarang bisa input polis manual untuk user")
print("✅ User akan melihat nama paket polis secara otomatis\n")
