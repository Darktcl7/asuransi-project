import os
import django
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Smile_Project.settings')
django.setup()

from policies.models import Policy
from claims.models import Claim
from users.models import User
from django.db.models import Sum

print("===== DEBUG STATS =====")

# Policy Stats
total_policies = Policy.objects.count()
active_policies = Policy.objects.filter(status='active').count()
pending_policies = Policy.objects.filter(status='pending').count()
print(f"Total Policies: {total_policies}")
print(f"  - Active: {active_policies}")
print(f"  - Pending: {pending_policies}")

# Claim Stats
total_claims = Claim.objects.count()
approved_claims = Claim.objects.filter(status='active').count()
completed_claims = Claim.objects.filter(status='completed').count()
pending_claims = Claim.objects.filter(status='pending').count()
print(f"\nTotal Claims: {total_claims}")
print(f"  - Approved: {approved_claims}")
print(f"  - Completed: {completed_claims}")
print(f"  - Pending: {pending_claims}")


# Financial
total_premium = Policy.objects.filter(status__in=['active', 'expired']).aggregate(total=Sum('policy_price'))['total'] or 0
print(f"\nTotal Premium (Active/Expired): {total_premium}")

total_claim_paid = Claim.objects.filter(status__in=['approved', 'completed']).aggregate(total=Sum('claim_amount'))['total'] or 0
print(f"Total Claim Paid (Appr/Comp): {total_claim_paid}")
