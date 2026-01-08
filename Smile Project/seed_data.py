"""
Script untuk seed data awal:
- Policy Tiers (Standar, Gold, Premium)
- Device Packages (contoh ponsel populer)

Jalankan dengan: python manage.py shell < seed_data.py
Atau: env\Scripts\python.exe manage.py shell < seed_data.py
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import PolicyTier, DevicePackage
from decimal import Decimal

print("==> Mulai seeding data...")

# ==================== POLICY TIERS ====================
tiers_data = [
    {
        'tier_name': 'Standar',
        'min_price': Decimal('1500000'),
        'max_price': Decimal('3000000'),
        'policy_price': Decimal('150000'),
        'claim_deduction_percent': Decimal('10.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 3,
    },
    {
        'tier_name': 'Gold',
        'min_price': Decimal('3000001'),
        'max_price': Decimal('5000000'),
        'policy_price': Decimal('250000'),
        'claim_deduction_percent': Decimal('5.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 5,
    },
    {
        'tier_name': 'Premium',
        'min_price': Decimal('5000001'),
        'max_price': Decimal('99999999'),
        'policy_price': Decimal('500000'),
        'claim_deduction_percent': Decimal('0.00'),
        'policy_duration_days': 365,
        'max_claims_per_year': 10,
    },
]

print("\n==> Creating Policy Tiers...")
for tier_data in tiers_data:
    tier, created = PolicyTier.objects.get_or_create(
        tier_name=tier_data['tier_name'],
        defaults=tier_data
    )
    if created:
        print(f"  [+] Created: {tier.tier_name} (Rp {tier.policy_price:,.0f})")
    else:
        print(f"  [=] Already exists: {tier.tier_name}")

# ==================== DEVICE PACKAGES ====================
devices_data = [
    # Apple
    {'brand': 'Apple', 'model': 'iPhone 15 Pro Max', 'variant': '256GB', 'value': Decimal('19999000')},
    {'brand': 'Apple', 'model': 'iPhone 15 Pro', 'variant': '256GB', 'value': Decimal('17999000')},
    {'brand': 'Apple', 'model': 'iPhone 15', 'variant': '128GB', 'value': Decimal('12999000')},
    {'brand': 'Apple', 'model': 'iPhone 14 Pro', 'variant': '256GB', 'value': Decimal('15999000')},
    {'brand': 'Apple', 'model': 'iPhone 14', 'variant': '128GB', 'value': Decimal('10999000')},
    
    # Samsung
    {'brand': 'Samsung', 'model': 'Galaxy S24 Ultra', 'variant': '256GB', 'value': Decimal('18999000')},
    {'brand': 'Samsung', 'model': 'Galaxy S24+', 'variant': '256GB', 'value': Decimal('14999000')},
    {'brand': 'Samsung', 'model': 'Galaxy S24', 'variant': '128GB', 'value': Decimal('11999000')},
    {'brand': 'Samsung', 'model': 'Galaxy Z Fold 5', 'variant': '256GB', 'value': Decimal('24999000')},
    {'brand': 'Samsung', 'model': 'Galaxy A54', 'variant': '128GB', 'value': Decimal('4999000')},
    
    # Xiaomi
    {'brand': 'Xiaomi', 'model': '14 Pro', 'variant': '256GB', 'value': Decimal('7999000')},
    {'brand': 'Xiaomi', 'model': '13T Pro', 'variant': '256GB', 'value': Decimal('6999000')},
    {'brand': 'Xiaomi', 'model': 'Redmi Note 13 Pro', 'variant': '128GB', 'value': Decimal('3499000')},
    
    # OPPO
    {'brand': 'OPPO', 'model': 'Find X6 Pro', 'variant': '256GB', 'value': Decimal('12999000')},
    {'brand': 'OPPO', 'model': 'Reno 11', 'variant': '128GB', 'value': Decimal('4999000')},
    
    # Vivo
    {'brand': 'Vivo', 'model': 'X100 Pro', 'variant': '256GB', 'value': Decimal('11999000')},
    {'brand': 'Vivo', 'model': 'V29', 'variant': '128GB', 'value': Decimal('4499000')},
]

print("\n==> Creating Device Packages...")
for device_data in devices_data:
    device, created = DevicePackage.objects.get_or_create(
        device_brand=device_data['brand'],
        device_model=device_data['model'],
        device_variant=device_data['variant'],
        defaults={'device_value': device_data['value']}
    )
    if created:
        print(f"  [+] Created: {device.device_brand} {device.device_model} {device.device_variant} (Rp {device.device_value:,.0f})")
    else:
        print(f"  [=] Already exists: {device.device_brand} {device.device_model}")

print("\n==> Seeding selesai!")
print(f"==> Total Policy Tiers: {PolicyTier.objects.count()}")
print(f"==> Total Device Packages: {DevicePackage.objects.count()}")
