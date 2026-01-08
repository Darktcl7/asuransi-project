"""
TEST: Transaction ID Duplicate Fix
Test that multiple top-ups can happen simultaneously without duplicate error
"""

import requests
import json
from decimal import Decimal
import threading
import time

# Configuration
BASE_URL = "http://192.168.100.4:8000"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "password123"

# Test Users
LEO_ID = "24637cca-0633-4b55-bb25-e6774b190254"
ARDY_ID = "93092294-33a0-483d-b470-6083e8b9d44c"

# Colors for output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}\n")

def print_success(text):
    print(f"{Colors.GREEN}[OK] {text}{Colors.END}")

def print_error(text):
    print(f"{Colors.RED}[ERROR] {text}{Colors.END}")

def print_info(text):
    print(f"{Colors.YELLOW}[INFO] {text}{Colors.END}")


def admin_login():
    """Login as admin"""
    print_info("Logging in as admin...")
    
    response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={
            "username": ADMIN_EMAIL,
            "password": ADMIN_PASSWORD
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        print_success(f"Admin login successful!")
        return data['token']
    else:
        print_error(f"Admin login failed: {response.text}")
        return None


def test_single_topup(admin_token, user_id, user_email, amount):
    """Test single top-up"""
    print_info(f"Testing top-up for {user_email}...")
    
    response = requests.post(
        f"{BASE_URL}/api/admin/topups/",
        headers={"Authorization": f"Token {admin_token}"},
        json={
            "user": user_id,
            "amount": str(amount),
            "payment_method": "admin_topup",
            "notes": f"Test top-up fix",
            "status": "completed"
        }
    )
    
    if response.status_code == 201:
        data = response.json()
        print_success(f"Top-up successful!")
        print(f"   Transaction ID: {data['topup']['transaction_id']}")
        print(f"   Amount: Rp {data['topup']['amount']:,.0f}")
        return True
    else:
        print_error(f"Top-up failed!")
        print(f"   Status Code: {response.status_code}")
        if 'duplicate' in response.text.lower():
            print_error("   DUPLICATE KEY ERROR DETECTED!")
        return False


def test_rapid_topups(admin_token, user_id, user_email, count=3):
    """Test multiple rapid top-ups (same second)"""
    print_info(f"Testing {count} rapid top-ups for {user_email}...")
    
    results = []
    threads = []
    
    def do_topup(index):
        response = requests.post(
            f"{BASE_URL}/api/admin/topups/",
            headers={"Authorization": f"Token {admin_token}"},
            json={
                "user": user_id,
                "amount": "100000",
                "payment_method": "admin_topup",
                "notes": f"Rapid test #{index}",
                "status": "completed"
            }
        )
        
        result = {
            'index': index,
            'status_code': response.status_code,
            'success': response.status_code == 201,
            'transaction_id': None
        }
        
        if response.status_code == 201:
            data = response.json()
            result['transaction_id'] = data['topup']['transaction_id']
        
        results.append(result)
    
    # Start all threads at once
    for i in range(count):
        thread = threading.Thread(target=do_topup, args=(i+1,))
        threads.append(thread)
        thread.start()
    
    # Wait for all to complete
    for thread in threads:
        thread.join()
    
    # Analyze results
    success_count = sum(1 for r in results if r['success'])
    
    print(f"\n   Results: {success_count}/{count} successful")
    
    for result in sorted(results, key=lambda x: x['index']):
        if result['success']:
            print_success(f"   Top-up #{result['index']}: {result['transaction_id']}")
        else:
            print_error(f"   Top-up #{result['index']}: FAILED (status {result['status_code']})")
    
    return success_count == count


def main():
    print_header("TRANSACTION ID DUPLICATE FIX TEST")
    
    # Login
    admin_token = admin_login()
    if not admin_token:
        print_error("Cannot proceed without admin token!")
        return
    
    print()
    
    # Test 1: Single top-ups (should both work)
    print_header("TEST 1: Sequential Top-Ups")
    print_info("Testing if 2 sequential top-ups work without error...")
    
    test1_leo = test_single_topup(admin_token, LEO_ID, "leomanggi@gmail.com", 100000)
    time.sleep(0.2)  # Small delay
    test1_ardy = test_single_topup(admin_token, ARDY_ID, "ardy@gamil.com", 100000)
    
    if test1_leo and test1_ardy:
        print_success("\nTEST 1: PASSED - Sequential top-ups work!")
    else:
        print_error("\nTEST 1: FAILED - One or both top-ups failed!")
    
    print()
    
    # Test 2: Rapid fire top-ups (stress test)
    print_header("TEST 2: Rapid Fire Top-Ups (Stress Test)")
    print_info("Testing 3 top-ups happening at exact same time...")
    
    test2_result = test_rapid_topups(admin_token, LEO_ID, "leomanggi@gmail.com", 3)
    
    if test2_result:
        print_success("\nTEST 2: PASSED - Rapid top-ups work without duplicates!")
    else:
        print_error("\nTEST 2: FAILED - Some rapid top-ups failed!")
    
    print()
    
    # Final Summary
    print_header("TEST SUMMARY")
    
    if test1_leo and test1_ardy and test2_result:
        print(f"{Colors.GREEN}{Colors.BOLD}[SUCCESS] ALL TESTS PASSED!{Colors.END}")
        print(f"\n{Colors.GREEN}Transaction ID duplicate bug is FIXED!{Colors.END}")
        print(f"{Colors.GREEN}Multiple top-ups can now happen simultaneously.{Colors.END}")
    else:
        print(f"{Colors.RED}{Colors.BOLD}[FAILED] SOME TESTS FAILED!{Colors.END}")
        print(f"\n{Colors.YELLOW}Check backend logs for more details.{Colors.END}")
    
    print()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Test interrupted by user.{Colors.END}")
    except Exception as e:
        print(f"\n{Colors.RED}Error: {e}{Colors.END}")
        import traceback
        traceback.print_exc()
