import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim
from claims.serializers import ClaimSerializer

print("=" * 60)
print("TESTING UPDATED CLAIMS SERIALIZER")
print("=" * 60)

claims = Claim.objects.all()
print(f"\nTotal claims: {claims.count()}")

if claims.count() > 0:
    claim = claims.first()
    
    print(f"\nSerializing claim: {claim.claim_number}")
    
    try:
        serializer = ClaimSerializer(claim)
        data = serializer.data
        
        print("\n[SUCCESS] Serialization completed!")
        
        # Check required fields for admin dashboard
        required_fields = ['user_name', 'user_email', 'device', 'claim_number', 
                          'damage_type', 'claim_amount', 'status']
        
        print("\nChecking required fields:")
        for field in required_fields:
            if field in data:
                print(f"  [OK] {field}: {data[field]}")
            else:
                print(f"  [MISSING] {field}")
        
        print("\nFull serialized data:")
        print(json.dumps(data, indent=2, default=str))
        
    except Exception as e:
        print(f"\n[ERROR] Serialization failed: {e}")
        import traceback
        traceback.print_exc()
else:
    print("\n[ERROR] No claims found!")

print("\n" + "=" * 60)
