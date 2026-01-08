"""
Test Manual Policy Creation by Admin
Run: env\Scripts\python.exe test_manual_policy.py
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
    """Login as admin and get token"""
    print("🔐 Logging in as admin...")
    response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={'username': ADMIN_EMAIL, 'password': ADMIN_PASSWORD}
    )
    if response.status_code == 200:
        token = response.json()['token']
        print(f"   ✅ Login successful!")
        return token
    else:
        print(f"   ❌ Login failed: {response.status_code}")
        print(response.text)
        return None

def test_manual_policy_creation(admin_token):
    """Test admin creating policy for user"""
    print("\n" + "="*70)
    print("  TEST: Admin Manual Policy Creation")
    print("="*70)
    
    headers = {'Authorization': f'Token {admin_token}'}
    
    # Step 1: Get test user
    print("\n1️⃣  Finding test user...")
    response = requests.get(f"{BASE_URL}/admin/users/?search=leo", headers=headers)
    if response.status_code != 200:
        print(f"   ❌ Failed to get users: {response.status_code}")
        return
    
    users = response.data if isinstance(response.json(), list) else response.json().get('results', [])
    if not users:
        print("   ❌ No users found")
        return
    
    test_user = users[0]
    print(f"   ✅ Found user: {test_user['email']}")
    print(f"      User ID: {test_user['id']}")
    
    # Step 2: Get device packages
    print("\n2️⃣  Getting device packages...")
    response = requests.get(f"{BASE_URL}/device-packages/", headers=headers)
    if response.status_code != 200:
        print(f"   ❌ Failed to get devices: {response.status_code}")
        return
    
    devices = response.json()
    if not devices:
        print("   ❌ No devices found")
        return
    
    # Find a device with price around 5 million (should be Smile 2)
    test_device = None
    for device in devices:
        if 3000001 <= float(device['device_value']) <= 5000000:
            test_device = device
            break
    
    if not test_device:
        test_device = devices[0]  # Fallback to first device
    
    print(f"   ✅ Selected device: {test_device['device_brand']} {test_device['device_model']}")
    print(f"      Price: Rp {float(test_device['device_value']):,.0f}")
    
    # Step 3: Create policy
    print("\n3️⃣  Creating policy...")
    policy_data = {
        'user_id': test_user['id'],
        'device_package_id': test_device['id'],
        'imei_number': '123456789012345',  # Test IMEI
        'purchase_price': test_device['device_value']
    }
    
    print(f"   Data: {json.dumps(policy_data, indent=2)}")
    
    response = requests.post(
        f"{BASE_URL}/admin/policies/manual-create/",
        headers=headers,
        json=policy_data
    )
    
    print(f"\n   Response Status: {response.status_code}")
    
    if response.status_code == 201:
        result = response.json()
        print("\n   ✅ SUCCESS! Policy created!")
        print(f"\n   Policy Details:")
        print(f"   - Policy Number: {result['policy']['policy_number']}")
        print(f"   - User: {result['policy']['user']}")
        print(f"   - Tier: {result['policy']['tier']}")
        print(f"   - Device: {result['policy']['device']}")
        print(f"   - IMEI: {result['policy']['imei']}")
        print(f"   - Purchase Price: Rp {result['policy']['purchase_price']:,.0f}")
        print(f"   - Policy Price: Rp {result['policy']['policy_price']:,.0f}")
        print(f"   - Activation: {result['policy']['activation_date']}")
        print(f"   - Expiry: {result['policy']['expiry_date']}")
        print(f"   - Status: {result['policy']['status']}")
        
        return result['policy']
    else:
        print("\n   ❌ FAILED! Policy creation failed!")
        print(f"   Error: {response.json()}")
        return None

def test_user_can_see_policy(test_user_email='leomanggi@gmail.com', test_user_password='password123'):
    """Test that user can see the created policy"""
    print("\n" + "="*70)
    print("  TEST: User Viewing Policy")
    print("="*70)
    
    # Login as user
    print(f"\n1️⃣  Logging in as user: {test_user_email}...")
    response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={'username': test_user_email, 'password': test_user_password}
    )
    
    if response.status_code != 200:
        print(f"   ❌ User login failed: {response.status_code}")
        return
    
    user_token = response.json()['token']
    print(f"   ✅ User logged in successfully!")
    
    # Get user's policies
    print(f"\n2️⃣  Fetching user's policies...")
    headers = {'Authorization': f'Token {user_token}'}
    response = requests.get(f"{BASE_URL}/policies/", headers=headers)
    
    if response.status_code != 200:
        print(f"   ❌ Failed to get policies: {response.status_code}")
        return
    
    policies = response.json()
    print(f"   ✅ Found {len(policies)} policy(ies)")
    
    if policies:
        for i, policy in enumerate(policies, 1):
            print(f"\n   📋 Policy #{i}:")
            print(f"      - Tier: {policy.get('tier_name', 'N/A')}")
            print(f"      - Policy Number: {policy['policy_number']}")
            print(f"      - Device: {policy['device_details']['device_brand']} {policy['device_details']['device_model']}")
            print(f"      - Status: {policy['status']}")
            print(f"      - Claims Used: {policy['claims_used']}/{policy.get('max_claims_per_year', 'N/A')}")
    else:
        print("   ⚠️  No policies found for this user")

if __name__ == "__main__":
    try:
        # Get admin token
        admin_token = get_admin_token()
        if not admin_token:
            print("\n❌ Cannot proceed without admin token")
            exit(1)
        
        # Test policy creation
        policy = test_manual_policy_creation(admin_token)
        
        if policy:
            # Test user viewing policy
            test_user_can_see_policy()
        
        print("\n" + "="*70)
        print("  TEST COMPLETED!")
        print("="*70 + "\n")
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
