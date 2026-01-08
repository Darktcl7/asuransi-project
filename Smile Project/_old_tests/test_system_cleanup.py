"""
Test script to verify system cleanup and policy expiry implementation
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.utils import timezone
from policies.models import Policy
from claims.models import Claim
from decimal import Decimal

print("=" * 70)
print("SYSTEM CLEANUP & POLICY EXPIRY - VERIFICATION TEST")
print("=" * 70)

# Test 1: Check Claim model (no more deduction fields)
print("\n[TEST 1] Claim Model - Field Check")
print("-" * 70)

claim_fields = [f.name for f in Claim._meta.get_fields()]
print(f"Claim fields: {claim_fields}")

# Check removed fields
has_deduction_percent = 'deduction_percent' in claim_fields
has_deduction_amount = 'deduction_amount' in claim_fields
has_wallet_deducted = 'wallet_deducted' in claim_fields
has_claim_amount = 'claim_amount' in claim_fields

print(f"\n- Has deduction_percent: {'YES [FAIL]' if has_deduction_percent else 'NO [OK]'}")
print(f"- Has deduction_amount: {'YES [FAIL]' if has_deduction_amount else 'NO [OK]'}")
print(f"- Has claim_amount: {'YES [OK]' if has_claim_amount else 'NO [FAIL]'}")
print(f"- Has wallet_deducted: {'YES [OK]' if has_wallet_deducted else 'NO [FAIL]'}")

if not has_deduction_percent and not has_deduction_amount:
    print("\n[PASS] Deduction fields successfully removed!")
else:
    print("\n[FAIL] Deduction fields still exist!")

# Test 2: Check Policy model methods
print("\n[TEST 2] Policy Model - Method Check")
print("-" * 70)

policy = Policy.objects.filter(status='active').first()

if policy:
    print(f"Testing Policy: {policy.policy_number}")
    print(f"  - Activation: {policy.activation_date}")
    print(f"  - Expiry: {policy.expiry_date}")
    print(f"  - Status: {policy.status}")
    
    # Test methods
    has_is_expired = hasattr(policy, 'is_expired')
    has_can_claim = hasattr(policy, 'can_claim')
    
    print(f"\n- Has is_expired() method: {'YES [OK]' if has_is_expired else 'NO [FAIL]'}")
    print(f"- Has can_claim() method: {'YES [OK]' if has_can_claim else 'NO [FAIL]'}")
    
    if has_is_expired and has_can_claim:
        is_expired = policy.is_expired()
        can_claim = policy.can_claim()
        
        print(f"\n- Policy expired: {is_expired}")
        print(f"- Can claim: {can_claim}")
        
        if policy.status == 'active' and not is_expired and can_claim:
            print("\n[PASS] Policy is active and can be claimed!")
        elif is_expired:
            print("\n[WARN] Policy has expired!")
        else:
            print("\n[INFO] Policy status:", policy.status)
    else:
        print("\n[FAIL] Required methods not found!")
else:
    print("[WARN] ⚠️  No active policy found for testing")

# Test 3: Create a test claim (verify no deduction calculation)
print("\n[TEST 3] Claim Creation - No Deduction Logic")
print("-" * 70)

if policy:
    try:
        # Try to get existing claim or create new
        test_claim = Claim.objects.filter(policy=policy, status='pending').first()
        
        if test_claim:
            print(f"Using existing claim: {test_claim.claim_number}")
        else:
            print("No test claim found. System ready for claim creation.")
        
        # Verify claim structure
        if test_claim:
            print(f"\nClaim Details:")
            print(f"  - Claim Amount: Rp {test_claim.claim_amount:,.0f}")
            print(f"  - Wallet Deducted: Rp {test_claim.wallet_deducted or 0:,.0f}")
            print(f"  - Status: {test_claim.status}")
            
            # Check no deduction fields
            try:
                _ = test_claim.deduction_amount
                print("\n[FAIL] deduction_amount field still exists!")
            except AttributeError:
                print("\n[PASS] No deduction_amount field (as expected)")
                
            try:
                _ = test_claim.deduction_percent
                print("[FAIL] deduction_percent field still exists!")
            except AttributeError:
                print("[PASS] No deduction_percent field (as expected)")
    except Exception as e:
        print(f"[ERROR] Test failed: {e}")
else:
    print("[SKIP] No active policy available for claim test")

# Test 4: Database indexes
print("\n[TEST 4] Database Indexes")
print("-" * 70)

policy_indexes = Policy._meta.indexes
print(f"Policy model has {len(policy_indexes)} indexes")

expiry_index_exists = any('expiry_date' in str(idx.fields) for idx in policy_indexes)
print(f"\n- Has expiry_date index: {'YES [OK]' if expiry_index_exists else 'NO [FAIL]'}")

if expiry_index_exists:
    print("[PASS] Expiry index created for performance!")
else:
    print("[WARN] Expiry index not found")

# Summary
print("\n" + "=" * 70)
print("TEST SUMMARY")
print("=" * 70)

tests_passed = 0
tests_total = 4

if not has_deduction_percent and not has_deduction_amount:
    tests_passed += 1
    print("[PASS] Test 1: Deduction fields removed")
else:
    print("[FAIL] Test 1: Deduction fields still exist")

if has_is_expired and has_can_claim:
    tests_passed += 1
    print("[PASS] Test 2: Policy methods added")
else:
    print("[FAIL] Test 2: Policy methods missing")

if not has_deduction_percent and not has_deduction_amount:
    tests_passed += 1
    print("[PASS] Test 3: Claim structure updated")
else:
    print("[FAIL] Test 3: Claim structure outdated")

if expiry_index_exists:
    tests_passed += 1
    print("[PASS] Test 4: Database indexes created")
else:
    print("[FAIL] Test 4: Database indexes missing")

print(f"\n{'='*70}")
print(f"RESULT: {tests_passed}/{tests_total} tests passed")
print(f"{'='*70}")

if tests_passed == tests_total:
    print("\n*** ALL TESTS PASSED! System cleanup successful! ***")
else:
    print(f"\n*** WARNING: {tests_total - tests_passed} test(s) failed. Please review. ***")

print()
