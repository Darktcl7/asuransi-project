"""
Update policy tier pricing
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import PolicyTier
from decimal import Decimal

print("==> Updating Policy Tiers...")

tiers_update = {
    'Standar': {
        'min_price': Decimal('1500000'),
        'max_price': Decimal('3000000'),
        'policy_price': Decimal('150000'),
    },
    'Gold': {
        'min_price': Decimal('3000001'),
        'max_price': Decimal('5000000'),
        'policy_price': Decimal('250000'),
    },
    'Premium': {
        'min_price': Decimal('5000001'),
        'max_price': Decimal('99999999'),
        'policy_price': Decimal('500000'),
    },
}

for tier_name, updates in tiers_update.items():
    tier = PolicyTier.objects.get(tier_name=tier_name)
    tier.min_price = updates['min_price']
    tier.max_price = updates['max_price']
    tier.policy_price = updates['policy_price']
    tier.save()
    print(f"  [✓] Updated {tier_name}: Rp {tier.min_price:,.0f} - Rp {tier.max_price:,.0f} (Policy: Rp {tier.policy_price:,.0f})")

print("\n==> Update selesai!")
