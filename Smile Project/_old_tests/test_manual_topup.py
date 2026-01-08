"""
Test Manual Top-Up API
Run with: env\Scripts\python.exe test_manual_topup.py
"""
import requests
import json
import sys
import io

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE_URL = "http://192.168.100.4:8000/api"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "admin123"  # Default admin password

def get_admin_token():
    """Login as admin and get token"""
    print("Logging in as admin...")
    response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={'username': ADMIN_EMAIL, 'password': ADMIN_PASSWORD}
    )
    if response.status_code == 200:
        token = response.json()['token']
        print(f"✅ Login successful!")
        return token
    else:
        print(f"❌ Login failed: {response.status_code}")
        print(response.text)
        return None

def test_manual_topup():
    """Test admin manual top-up"""
    print("\n" + "="*50)
    print("TEST: Admin Manual Top-Up")
    print("="*50)
    
    # First, get list of users to find a test user
    print("\n1. Fetching users...")
    global ADMIN_TOKEN
    headers = {'Authorization': f'Token {ADMIN_TOKEN}'}
    response = requests.get(f"{BASE_URL}/admin/users/?search=test", headers=headers)
    
    if response.status_code != 200:
        print(f"❌ Failed to get users: {response.status_code}")
        print(response.text)
        return
    
    users = response.json()
    if not users.get('results'):
        print("❌ No test users found. Please create a test user first.")
        return
    
    test_user = users['results'][0]
    print(f"✅ Found user: {test_user['email']}")
    print(f"   User ID: {test_user['id']}")
    
    # Test manual top-up
    print("\n2. Creating manual top-up...")
    topup_data = {
        'user': test_user['id'],
        'amount': '500000',  # Rp 500,000
        'payment_method': 'admin_topup',
        'notes': 'Test manual top-up via API',
        'status': 'completed'
    }
    
    response = requests.post(
        f"{BASE_URL}/admin/topups/",
        headers=headers,
        json=topup_data
    )
    
    print(f"\nResponse Status: {response.status_code}")
    print(f"Response Body:\n{json.dumps(response.json(), indent=2)}")
    
    if response.status_code == 201:
        print("\n✅ SUCCESS! Manual top-up created!")
        result = response.json()
        print(f"   Transaction ID: {result['topup']['transaction_id']}")
        print(f"   Amount: Rp {result['topup']['amount']:,.0f}")
        print(f"   Status: {result['topup']['status']}")
        print(f"   New Wallet Balance: Rp {result.get('wallet_balance', 0):,.0f}")
    else:
        print("\n❌ FAILED! Top-up creation failed!")
        print(f"Error: {response.json()}")

if __name__ == "__main__":
    try:
        # Get admin token first
        global ADMIN_TOKEN
        ADMIN_TOKEN = get_admin_token()
        if not ADMIN_TOKEN:
            print("\n❌ Cannot proceed without admin token")
            exit(1)
        
        test_manual_topup()
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
