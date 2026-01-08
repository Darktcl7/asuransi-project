import os
import django
import requests

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from claims.models import Claim

User = get_user_model()

print("=" * 60)
print("TESTING CLAIM STATUS UPDATE ENDPOINTS")
print("=" * 60)

# Get admin token
admin = User.objects.filter(is_staff=True, is_superuser=True).first()
token, _ = Token.objects.get_or_create(user=admin)

headers = {
    'Authorization': f'Token {token.key}',
    'Content-Type': 'application/json'
}

# Get pending claim
claim = Claim.objects.filter(status='pending').first()

if not claim:
    print("\n[ERROR] No pending claim found!")
    print("Please create a claim first from mobile app")
    exit()

print(f"\nClaim: {claim.claim_number}")
print(f"Current Status: {claim.status}")

# Test 1: Approve claim
print("\n" + "-" * 60)
print("TEST 1: Approve Claim")
print("-" * 60)

response = requests.post(
    f'http://127.0.0.1:8000/api/admin/claims/{claim.id}/approve/',
    json={'claim_amount': 500000, 'admin_notes': 'Test approval'},
    headers=headers
)

print(f"Status Code: {response.status_code}")
if response.status_code == 200:
    print("[OK] Claim approved!")
    claim.refresh_from_db()
    print(f"New Status: {claim.status}")
else:
    print(f"[ERROR] {response.text}")

# Test 2: Set In Progress
print("\n" + "-" * 60)
print("TEST 2: Set In Progress")
print("-" * 60)

response = requests.post(
    f'http://127.0.0.1:8000/api/admin/claims/{claim.id}/set_in_progress/',
    json={'admin_notes': 'Being processed'},
    headers=headers
)

print(f"Status Code: {response.status_code}")
if response.status_code == 200:
    print("[OK] Status updated to In Progress!")
    data = response.json()
    print(f"Response: {data}")
    claim.refresh_from_db()
    print(f"New Status: {claim.status}")
else:
    print(f"[ERROR] {response.text}")

# Test 3: Set Completed
print("\n" + "-" * 60)
print("TEST 3: Set Completed")
print("-" * 60)

response = requests.post(
    f'http://127.0.0.1:8000/api/admin/claims/{claim.id}/set_completed/',
    json={'admin_notes': 'Repair completed'},
    headers=headers
)

print(f"Status Code: {response.status_code}")
if response.status_code == 200:
    print("[OK] Status updated to Completed!")
    data = response.json()
    print(f"Response: {data}")
    claim.refresh_from_db()
    print(f"New Status: {claim.status}")
else:
    print(f"[ERROR] {response.text}")

print("\n" + "=" * 60)
print("TESTING COMPLETE!")
print("=" * 60)
