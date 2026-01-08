import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim
from users.models import User

print("=" * 50)
print("CHECKING CLAIMS DATA")
print("=" * 50)

# Check total claims
claims_count = Claim.objects.all().count()
print(f"\nTotal Claims: {claims_count}")

# Show all claims
if claims_count > 0:
    print("\nClaims List:")
    for claim in Claim.objects.all().order_by('-created_at'):
        print(f"\n  - Claim: {claim.claim_number}")
        print(f"    User: {claim.user.email}")
        print(f"    Status: {claim.status}")
        print(f"    Amount: Rp {claim.claim_amount:,.0f}")
        print(f"    Damage: {claim.damage_type}")
        print(f"    Created: {claim.created_at}")
else:
    print("\n❌ No claims found in database!")
    print("\nChecking users...")
    users = User.objects.all()
    print(f"Total users: {users.count()}")
    for user in users:
        print(f"  - {user.email}")

print("\n" + "=" * 50)
