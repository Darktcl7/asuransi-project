
import os
import django
from django.conf import settings
from django.db.models import Sum

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Smile_Project.settings')
django.setup()

from policies.models import Policy
from claims.models import Claim

print("===== DATA DEBUG =====")

# Cek 5 Polis Aktif pertama
active_policies = Policy.objects.filter(status='active')
print(f"Jumlah Polis Aktif: {active_policies.count()}")

print("\nSample 5 Polis Aktif:")
for p in active_policies[:5]:
    print(f" - ID: {p.id} | Price: {p.policy_price} | Tipe: {type(p.policy_price)}")

# Cek Total via Aggregate
total = active_policies.aggregate(total=Sum('policy_price'))['total']
print(f"\nTotal Aggregate Policy Price: {total}")

# Cek Klaim Approved
approved_claims = Claim.objects.filter(status='approved')
print(f"\nJumlah Klaim Approved: {approved_claims.count()}")
for c in approved_claims[:5]:
    print(f" - ID: {c.id} | Amount: {c.claim_amount}")
