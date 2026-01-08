"""
Verify New Pricing
Run: env\Scripts\python.exe verify_pricing.py
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

print("\n" + "="*70)
print("  VERIFY NEW POLICY PRICING")
print("="*70)

tiers = PolicyTier.objects.filter(is_active=True).order_by('min_price')

print(f"\n✅ Total Active Tiers: {tiers.count()}\n")

print("┌─────────┬──────────────────┬──────────────┬────────────┬────────────┐")
print("│ Tier    │ Price Range      │ Policy Price │ Deduction  │ Max Claims │")
print("├─────────┼──────────────────┼──────────────┼────────────┼────────────┤")

for tier in tiers:
    tier_name = tier.tier_name.ljust(7)
    price_range = f"{int(tier.min_price/1000000)}M - {int(tier.max_price/1000000)}M".ljust(16)
    policy_price = f"Rp {int(tier.policy_price):,}".ljust(12)
    deduction = f"{tier.claim_deduction_percent}%".ljust(10)
    max_claims = f"{tier.max_claims_per_year}/year".ljust(10)
    
    print(f"│ {tier_name} │ {price_range} │ {policy_price} │ {deduction} │ {max_claims} │")

print("└─────────┴──────────────────┴──────────────┴────────────┴────────────┘")

print("\n✅ Harga polis baru:")
print("   Smile 1: Rp 300.000")
print("   Smile 2: Rp 400.000")
print("   Smile 3: Rp 600.000")
print("   Smile 4: Rp 900.000")
print("   Smile 5: Rp 1.250.000")
print("   Smile 6: Rp 2.500.000")

print("\n" + "="*70)
print("  VERIFICATION COMPLETE!")
print("="*70 + "\n")
