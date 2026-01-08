import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim
from claims.serializers import ClaimSerializer

print("=" * 50)
print("TESTING CLAIMS SERIALIZER")
print("=" * 50)

claims = Claim.objects.all()
print(f"\nTotal claims in DB: {claims.count()}")

if claims.count() > 0:
    claim = claims.first()
    print(f"\nClaim Object:")
    print(f"  - claim_number: {claim.claim_number}")
    print(f"  - user: {claim.user.email}")
    print(f"  - policy: {claim.policy}")
    print(f"  - damage_type: {claim.damage_type}")
    
    print("\nTrying to serialize...")
    try:
        serializer = ClaimSerializer(claim)
        data = serializer.data
        print("\n✅ Serialization SUCCESS!")
        print("\nSerialized Data:")
        import json
        print(json.dumps(data, indent=2, default=str))
    except Exception as e:
        print(f"\n❌ Serialization FAILED!")
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

print("\n" + "=" * 50)
