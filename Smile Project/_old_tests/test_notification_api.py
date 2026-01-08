"""
Test notification API endpoint
Verify that notifications work correctly
"""

import os
import django
import requests

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from claims.models import Claim

User = get_user_model()

print("=" * 70)
print("NOTIFICATION API TEST")
print("=" * 70)

# Get admin token
admin = User.objects.filter(is_staff=True, is_superuser=True).first()
if not admin:
    print("\n[ERROR] No admin user found!")
    exit()

token, _ = Token.objects.get_or_create(user=admin)

headers = {
    'Authorization': f'Token {token.key}',
    'Content-Type': 'application/json'
}

print(f"\nAdmin: {admin.email}")
print(f"Token: {token.key[:20]}...")

# Check pending claims
pending_claims = Claim.objects.filter(status='pending')
pending_count = pending_claims.count()

print("\n" + "-" * 70)
print("DATABASE CHECK")
print("-" * 70)
print(f"Pending Claims in DB: {pending_count}")

if pending_count > 0:
    print("\nRecent Pending Claims:")
    for claim in pending_claims[:5]:
        print(f"  - {claim.claim_number}: {claim.user.email} ({claim.damage_type})")

# Test API endpoint
print("\n" + "-" * 70)
print("API TEST")
print("-" * 70)
print("Testing: GET /api/admin/claims/notifications/")

try:
    response = requests.get(
        'http://127.0.0.1:8000/api/admin/claims/notifications/',
        headers=headers
    )
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        
        print("\n[SUCCESS] API Response:")
        print(f"  Pending Count: {data['pending_count']}")
        print(f"  Recent Claims: {len(data['recent_claims'])}")
        
        if data['recent_claims']:
            print("\n  Claims Details:")
            for claim in data['recent_claims']:
                print(f"    - {claim['claim_number']}")
                print(f"      User: {claim['user_name']} ({claim['user_email']})")
                print(f"      Device: {claim['device']}")
                print(f"      Damage: {claim['damage_type']}")
                print(f"      Time: {claim['created_at']}")
                print()
        
        # Verify data matches
        if data['pending_count'] == pending_count:
            print("[PASS] Pending count matches database!")
        else:
            print(f"[WARNING] Count mismatch! API: {data['pending_count']}, DB: {pending_count}")
            
    else:
        print(f"\n[ERROR] API returned status {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"\n[ERROR] Request failed: {e}")

print("\n" + "=" * 70)
print("TEST COMPLETE")
print("=" * 70)

if pending_count > 0:
    print(f"\n[OK] You have {pending_count} pending claim(s)")
    print("Notification bell should show badge with count!")
else:
    print("\n[INFO] No pending claims")
    print("Notification bell should show 'Tidak ada klaim pending'")

print()
