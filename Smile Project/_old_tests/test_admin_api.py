import os
import django
import requests
from pprint import pprint

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token

User = get_user_model()

print("=" * 60)
print("TESTING ADMIN CLAIMS API")
print("=" * 60)

# Get admin user
try:
    admin = User.objects.filter(is_staff=True, is_superuser=True).first()
    if not admin:
        print("\n[ERROR] No admin user found!")
        print("Creating admin user...")
        admin = User.objects.create_superuser(
            email='admin@admin.com',
            password='admin123',
            first_name='Admin',
            last_name='System'
        )
        print("[OK] Admin created!")
    
    print(f"\nAdmin User: {admin.email}")
    print(f"Is Staff: {admin.is_staff}")
    print(f"Is Superuser: {admin.is_superuser}")
    
    # Get or create token
    token, created = Token.objects.get_or_create(user=admin)
    print(f"\nAdmin Token: {token.key}")
    
    # Test API endpoint
    print("\n" + "-" * 60)
    print("Testing API: GET /api/admin/claims/")
    print("-" * 60)
    
    headers = {
        'Authorization': f'Token {token.key}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get('http://127.0.0.1:8000/api/admin/claims/', headers=headers)
    
    print(f"\nStatus Code: {response.status_code}")
    print(f"Response Headers: {dict(response.headers)}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n[SUCCESS] API returned data!")
        print(f"Data Type: {type(data)}")
        
        # Check if pagination format
        if isinstance(data, dict):
            print(f"Count: {data.get('count', 0)}")
            print(f"Next: {data.get('next')}")
            print(f"Previous: {data.get('previous')}")
            results = data.get('results', [])
            print(f"Results: {len(results)}")
            
            if results:
                print("\nFirst Claim:")
                first_claim = results[0]
                for key, value in first_claim.items():
                    print(f"  - {key}: {value}")
        elif isinstance(data, list):
            print(f"List Length: {len(data)}")
            if data:
                print("\nFirst Claim:")
                first_claim = data[0]
                for key, value in first_claim.items():
                    print(f"  - {key}: {value}")
        else:
            print(f"Unexpected data format: {data}")
    else:
        print(f"\n[ERROR] API returned error!")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"\n[ERROR] {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 60)
