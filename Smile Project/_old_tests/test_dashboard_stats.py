"""
Test dashboard stats endpoint
Verify all statistics are calculated correctly
"""

import os
import django
import requests

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from claims.models import Claim
from policies.models import Policy
from wallet.models import Wallet
from wallet.models import TopUpTransaction

User = get_user_model()

print("=" * 70)
print("DASHBOARD STATS TEST")
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

# Calculate expected stats from database
print("\n" + "-" * 70)
print("DATABASE ACTUAL DATA")
print("-" * 70)

# Users
total_users = User.objects.count()
verified_users = User.objects.filter(is_verified=True).count()
active_users = User.objects.filter(is_active=True).count()

print(f"\nUSERS:")
print(f"  Total: {total_users}")
print(f"  Verified: {verified_users}")
print(f"  Active: {active_users}")

# Policies
total_policies = Policy.objects.count()
active_policies = Policy.objects.filter(status='active').count()
pending_policies = Policy.objects.filter(status='pending').count()
expired_policies = Policy.objects.filter(status='expired').count()

print(f"\nPOLICIES:")
print(f"  Total: {total_policies}")
print(f"  Active: {active_policies}")
print(f"  Pending: {pending_policies}")
print(f"  Expired: {expired_policies}")

# Claims
total_claims = Claim.objects.count()
pending_claims = Claim.objects.filter(status='pending').count()
approved_claims = Claim.objects.filter(status='approved').count()
rejected_claims = Claim.objects.filter(status='rejected').count()

from django.db.models import Sum
total_claim_amount = Claim.objects.filter(
    status__in=['approved', 'completed']
).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

print(f"\nCLAIMS:")
print(f"  Total: {total_claims}")
print(f"  Pending: {pending_claims}")
print(f"  Approved: {approved_claims}")
print(f"  Rejected: {rejected_claims}")
print(f"  Total Amount: Rp {total_claim_amount:,.0f}")

# Wallet
total_balance = Wallet.objects.aggregate(Sum('balance'))['balance__sum'] or 0
total_topup = Wallet.objects.aggregate(Sum('total_topup'))['total_topup__sum'] or 0
pending_topups = TopUpTransaction.objects.filter(status='pending').count()

print(f"\nWALLET:")
print(f"  Total Balance: Rp {total_balance:,.0f}")
print(f"  Total Top-Up: Rp {total_topup:,.0f}")
print(f"  Pending Top-Ups: {pending_topups}")

# Test API endpoint
print("\n" + "-" * 70)
print("API TEST")
print("-" * 70)
print("Testing: GET /api/admin/dashboard/")

try:
    response = requests.get(
        'http://127.0.0.1:8000/api/admin/dashboard/',
        headers=headers
    )
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        
        print("\n[SUCCESS] API Response:")
        print(f"\nUSERS (API):")
        print(f"  Total: {data.get('users', {}).get('total', 0)}")
        print(f"  Verified: {data.get('users', {}).get('verified', 0)}")
        print(f"  Active: {data.get('users', {}).get('active', 0)}")
        
        print(f"\nPOLICIES (API):")
        print(f"  Total: {data.get('policies', {}).get('total', 0)}")
        print(f"  Active: {data.get('policies', {}).get('active', 0)}")
        print(f"  Pending: {data.get('policies', {}).get('pending', 0)}")
        print(f"  Expired: {data.get('policies', {}).get('expired', 0)}")
        
        print(f"\nCLAIMS (API):")
        print(f"  Total: {data.get('claims', {}).get('total', 0)}")
        print(f"  Pending: {data.get('claims', {}).get('pending', 0)}")
        print(f"  Approved: {data.get('claims', {}).get('approved', 0)}")
        print(f"  Total Amount: Rp {data.get('claims', {}).get('total_amount', 0):,.0f}")
        
        print(f"\nWALLET (API):")
        print(f"  Total Balance: Rp {data.get('wallet', {}).get('total_balance', 0):,.0f}")
        print(f"  Total Top-Up: Rp {data.get('wallet', {}).get('total_topup', 0):,.0f}")
        print(f"  Pending Top-Ups: {data.get('wallet', {}).get('pending_topups', 0)}")
        
        # Verify accuracy
        print("\n" + "-" * 70)
        print("VERIFICATION")
        print("-" * 70)
        
        errors = []
        
        if data['users']['total'] != total_users:
            errors.append(f"Users Total: API={data['users']['total']}, DB={total_users}")
        
        if data['policies']['total'] != total_policies:
            errors.append(f"Policies Total: API={data['policies']['total']}, DB={total_policies}")
        
        if data['claims']['total'] != total_claims:
            errors.append(f"Claims Total: API={data['claims']['total']}, DB={total_claims}")
        
        if abs(data['wallet']['total_balance'] - float(total_balance)) > 0.01:
            errors.append(f"Wallet Balance: API={data['wallet']['total_balance']}, DB={total_balance}")
        
        if errors:
            print("\n[FAIL] Mismatches found:")
            for error in errors:
                print(f"  - {error}")
        else:
            print("\n[PASS] All data matches database!")
            
    else:
        print(f"\n[ERROR] API returned status {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"\n[ERROR] Request failed: {e}")

print("\n" + "=" * 70)
print("TEST COMPLETE")
print("=" * 70)
print()
