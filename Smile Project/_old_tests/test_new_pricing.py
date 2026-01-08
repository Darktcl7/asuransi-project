"""
Test Policy Creation with New Pricing
Run: env\Scripts\python.exe test_new_pricing.py
"""
import requests
import json
import sys
import io

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE_URL = "http://192.168.100.4:8000/api"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "admin123"

def get_admin_token():
    """Login as admin"""
    print("🔐 Logging in as admin...")
    response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={'username': ADMIN_EMAIL, 'password': ADMIN_PASSWORD}
    )
    if response.status_code == 200:
        print("   ✅ Login successful!")
        return response.json()['token']
    return None

def test_new_pricing():
    """Test policy creation with new pricing"""
    print("\n" + "="*70)
    print("  TEST: Policy Creation with NEW PRICING")
    print("="*70)
    
    admin_token = get_admin_token()
    if not admin_token:
        print("❌ Failed to login")
        return
    
    headers = {'Authorization': f'Token {admin_token}'}
    
    # Get user
    print("\n1️⃣  Getting test user (ardy@gamil.com)...")
    response = requests.get(f"{BASE_URL}/admin/users/?search=ardy", headers=headers)
    users = response.json().get('results', [])
    if not users:
        print("   ❌ No users found")
        return
    
    user = users[0]
    print(f"   ✅ User: {user['email']}")
    
    # Test different device prices for different tiers
    test_cases = [
        {"device_price": 2500000, "expected_tier": "Smile 1", "expected_price": 300000},
        {"device_price": 4000000, "expected_tier": "Smile 2", "expected_price": 400000},
        {"device_price": 7000000, "expected_tier": "Smile 3", "expected_price": 600000},
    ]
    
    print("\n2️⃣  Testing policy creation with different prices...")
    
    for i, test_case in enumerate(test_cases, 1):
        device_price = test_case['device_price']
        expected_tier = test_case['expected_tier']
        expected_price = test_case['expected_price']
        
        print(f"\n   Test {i}: Device Price = Rp {device_price:,}")
        print(f"   Expected Tier: {expected_tier}")
        print(f"   Expected Policy Price: Rp {expected_price:,}")
        
        # Get device with matching price
        response = requests.get(f"{BASE_URL}/device-packages/", headers=headers)
        devices = response.json()
        
        # Find device close to test price
        device = None
        for d in devices:
            if abs(float(d['device_value']) - device_price) < 100000:
                device = d
                break
        
        if not device:
            # Just use first device and override price
            device = devices[0]
        
        # Create policy
        policy_data = {
            'user_id': user['id'],
            'device_package_id': device['id'],
            'imei_number': f'12345678901234{i}',  # Unique IMEI for each test
            'purchase_price': device_price
        }
        
        response = requests.post(
            f"{BASE_URL}/admin/policies/manual-create/",
            headers=headers,
            json=policy_data
        )
        
        if response.status_code == 201:
            result = response.json()
            actual_tier = result['policy']['tier']
            actual_price = result['policy']['policy_price']
            
            if actual_tier == expected_tier and actual_price == expected_price:
                print(f"   ✅ SUCCESS!")
                print(f"      Tier: {actual_tier}")
                print(f"      Policy Price: Rp {int(actual_price):,}")
            else:
                print(f"   ❌ MISMATCH!")
                print(f"      Expected: {expected_tier} / Rp {expected_price:,}")
                print(f"      Got: {actual_tier} / Rp {int(actual_price):,}")
        else:
            print(f"   ❌ Failed: {response.status_code}")
            print(f"      Error: {response.json()}")
    
    print("\n" + "="*70)
    print("  TEST COMPLETED!")
    print("="*70 + "\n")

if __name__ == "__main__":
    try:
        test_new_pricing()
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
