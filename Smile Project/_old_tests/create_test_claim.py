import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim
from policies.models import Policy
from django.utils import timezone

print("=" * 60)
print("CREATE TEST CLAIM")
print("=" * 60)

# Reset existing claim to pending
existing_claim = Claim.objects.first()
if existing_claim:
    print(f"\nResetting claim: {existing_claim.claim_number}")
    existing_claim.status = 'pending'
    existing_claim.claim_amount = 0
    existing_claim.deduction_amount = 0
    existing_claim.wallet_deducted = None
    existing_claim.processed_by = None
    existing_claim.processed_date = None
    existing_claim.admin_notes = None
    existing_claim.save()
    print(f"Status: {existing_claim.status}")
    print("[OK] Claim reset to pending!")
else:
    # Create new claim if none exists
    policy = Policy.objects.filter(status='active').first()
    if policy:
        claim = Claim.objects.create(
            user=policy.user,
            policy=policy,
            claim_number=f"CLM-TEST-{timezone.now().strftime('%Y%m%d%H%M%S')}",
            damage_type='Test Damage',
            damage_description='Test claim for endpoint testing',
            incident_date=timezone.now().date(),
            claim_amount=0,
            deduction_percent=policy.tier.claim_deduction_percent,
            deduction_amount=0,
            status='pending'
        )
        print(f"\n[OK] Created claim: {claim.claim_number}")
    else:
        print("\n[ERROR] No active policy found!")

print("\n" + "=" * 60)
