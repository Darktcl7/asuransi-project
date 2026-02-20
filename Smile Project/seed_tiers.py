# seed_tiers.py
import os
import django
import sys

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import PolicyTier
from decimal import Decimal

def seed_tiers():
    tiers_data = [
        {"name": "Smile 1", "min": 0, "max": 3000000, "price": 300000},
        {"name": "Smile 2", "min": 3000001, "max": 5000000, "price": 400000},
        {"name": "Smile 3", "min": 5000001, "max": 10000000, "price": 600000},
        {"name": "Smile 4", "min": 10000011, "max": 15000000, "price": 900000},
        {"name": "Smile 5", "min": 15000001, "max": 20000000, "price": 1250000},
        {"name": "Smile 6", "min": 20000001, "max": 999999999, "price": 2500000},
    ]

    print("Seeding Policy Tiers...")
    for data in tiers_data:
        tier, created = PolicyTier.objects.update_or_create(
            tier_name=data["name"],
            defaults={
                "min_price": Decimal(data["min"]),
                "max_price": Decimal(data["max"]),
                "policy_price": Decimal(data["price"]),
                "is_active": True
            }
        )
        status = "Created" if created else "Updated"
        print(f"[{status}] {tier.tier_name}: Rp {tier.min_price:,.0f} - Rp {tier.max_price:,.0f} (Price: Rp {tier.policy_price:,.0f})")

    print("\nSuccess: Policy Tiers have been seeded!")

if __name__ == "__main__":
    seed_tiers()
