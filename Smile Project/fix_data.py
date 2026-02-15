
import os
import django
from django.db.models import Sum

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Smile_Project.settings')
django.setup()

from policies.models import Policy

print("===== FIXING POLICY PRICES =====")

# Ambil semua polis
policies = Policy.objects.all()
fixed_count = 0

for p in policies:
    # Jika harga 0 dan punya Tier
    if p.policy_price <= 0 and p.tier:
        old_price = p.policy_price
        # Set harga sesuai harga Tier saat ini
        p.policy_price = p.tier.price
        p.save()
        print(f"Fixed Policy {p.policy_number}: {old_price} -> {p.policy_price}")
        fixed_count += 1

print(f"\nSelesai! {fixed_count} polis diperbaiki.")

# Verifikasi Total
total = Policy.objects.filter(status='active').aggregate(total=Sum('policy_price'))['total']
print(f"Total Revenue Baru (Active): {total}")
