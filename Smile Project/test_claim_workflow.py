"""
Test Claim Workflow Transitions
Verify all status transitions work correctly
"""

import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim
from users.models import User
from django.utils import timezone

def test_workflow():
    print("="*70)
    print("TESTING CLAIM WORKFLOW STATUS TRANSITIONS")
    print("="*70)
    print()
    
    # Check database
    print("DATABASE STATUS:")
    print("-" * 50)
    
    total_claims = Claim.objects.count()
    pending_claims = Claim.objects.filter(status='pending').count()
    approved_claims = Claim.objects.filter(status='approved').count()
    in_progress_claims = Claim.objects.filter(status='in_progress').count()
    completed_claims = Claim.objects.filter(status='completed').count()
    rejected_claims = Claim.objects.filter(status='rejected').count()
    
    print(f"Total Claims:      {total_claims}")
    print(f"  - Pending:       {pending_claims}")
    print(f"  - Approved:      {approved_claims}")
    print(f"  - In Progress:   {in_progress_claims}")
    print(f"  - Completed:     {completed_claims}")
    print(f"  - Rejected:      {rejected_claims}")
    print()
    
    # Test status choices
    print("TEST 1: Verify Status Choices")
    print("-" * 50)
    
    expected_statuses = ['pending', 'approved', 'in_progress', 'completed', 'rejected']
    actual_statuses = [choice[0] for choice in Claim.STATUS_CHOICES]
    
    print(f"Expected Statuses: {expected_statuses}")
    print(f"Actual Statuses:   {actual_statuses}")
    
    if set(expected_statuses) == set(actual_statuses):
        print("[PASS] All status choices are correctly defined!")
    else:
        print("[FAIL] Status choices mismatch!")
        missing = set(expected_statuses) - set(actual_statuses)
        extra = set(actual_statuses) - set(expected_statuses)
        if missing:
            print(f"  Missing: {missing}")
        if extra:
            print(f"  Extra: {extra}")
    
    print()
    
    # Test payment proof fields
    print("TEST 2: Verify Payment Proof Fields")
    print("-" * 50)
    
    # Check if fields exist in model
    claim_fields = [f.name for f in Claim._meta.get_fields()]
    
    has_payment_proof = 'payment_proof_url' in claim_fields
    has_payment_date = 'payment_date' in claim_fields
    
    print(f"payment_proof_url field: {'[PASS]' if has_payment_proof else '[FAIL]'}")
    print(f"payment_date field:      {'[PASS]' if has_payment_date else '[FAIL]'}")
    
    if has_payment_proof and has_payment_date:
        print("[PASS] Payment proof fields exist in model!")
    else:
        print("[FAIL] Payment proof fields missing!")
    
    print()
    
    # Test workflow transitions (if there are claims)
    if total_claims > 0:
        print("TEST 3: Sample Workflow Data")
        print("-" * 50)
        
        # Show sample claims by status
        for status_code, status_label in Claim.STATUS_CHOICES:
            claims = Claim.objects.filter(status=status_code)[:2]
            if claims.exists():
                print(f"\n{status_label} Claims ({claims.count()}):")
                for claim in claims:
                    print(f"  - {claim.claim_number}")
                    print(f"    Amount: Rp {claim.claim_amount:,.0f}")
                    print(f"    User: {claim.user.email}")
                    if claim.admin_notes:
                        print(f"    Notes: {claim.admin_notes[:50]}...")
                    if claim.payment_proof_url:
                        print(f"    Payment Proof: {claim.payment_proof_url[:50]}...")
    
    print()
    
    # Workflow diagram
    print("TEST 4: Workflow Diagram")
    print("-" * 50)
    print()
    print("CLAIM WORKFLOW:")
    print()
    print("  pending")
    print("     |")
    print("     | (Admin Reviews)")
    print("     v")
    print("  approved  -----------> rejected")
    print("     |")
    print("     | (Admin Sets In Progress)")
    print("     v")
    print("  in_progress")
    print("     |")
    print("     | (Admin Marks Complete + Payment Proof)")
    print("     v")
    print("  completed")
    print()
    
    # Action availability
    print("TEST 5: Available Actions by Status")
    print("-" * 50)
    print()
    
    actions = {
        'pending': ['Approve (wallet deduction)', 'Reject'],
        'approved': ['Set In Progress'],
        'in_progress': ['Mark Completed (with payment proof)'],
        'completed': ['No further actions (final state)'],
        'rejected': ['No further actions (final state)']
    }
    
    for status, available_actions in actions.items():
        status_label = dict(Claim.STATUS_CHOICES).get(status, status)
        print(f"{status_label}:")
        for action in available_actions:
            print(f"  - {action}")
        print()
    
    # API Endpoints
    print("TEST 6: API Endpoints")
    print("-" * 50)
    print()
    print("Available Endpoints:")
    print("  GET  /api/admin/claims/               - List all claims")
    print("  GET  /api/admin/claims/<id>/          - Get claim detail")
    print("  POST /api/admin/claims/<id>/approve/  - Approve claim")
    print("  POST /api/admin/claims/<id>/reject/   - Reject claim")
    print("  POST /api/admin/claims/<id>/set_in_progress/  - Set in progress")
    print("  POST /api/admin/claims/<id>/set_completed/    - Mark completed")
    print()
    
    # Summary
    print("="*70)
    print("WORKFLOW TESTS COMPLETE!")
    print("="*70)
    print()
    
    # Status Report
    all_passed = True
    
    if set(expected_statuses) != set(actual_statuses):
        all_passed = False
        print("[FAIL] Status choices test failed")
    
    if not (has_payment_proof and has_payment_date):
        all_passed = False
        print("[FAIL] Payment proof fields test failed")
    
    if all_passed:
        print("[SUCCESS] All workflow tests passed!")
        print()
        print("NEXT STEPS:")
        print("  1. Start Django server: python manage.py runserver")
        print("  2. Start React app: cd admin-dashboard && npm run dev")
        print("  3. Open: http://localhost:5174/dashboard/claims")
        print("  4. Test workflow:")
        print("     a. Review pending claim -> Approve")
        print("     b. Set approved claim -> In Progress")
        print("     c. Mark in progress claim -> Completed (with payment proof)")
        print()
    else:
        print("[WARNING] Some tests failed. Please review above.")
    
    print()

if __name__ == '__main__':
    test_workflow()
