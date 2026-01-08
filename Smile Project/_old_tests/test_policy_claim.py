"""
Test Policy & Claim workflow untuk user yang sudah punya saldo
User: testuser20251122124718@example.com
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:8000/api"

def print_header(text):
    print("\n" + "="*70)
    print(f"  {text}")
    print("="*70)

def print_response(response, show_full=False):
    print(f"Status Code: {response.status_code}")
    try:
        data = response.json()
        if show_full:
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
        else:
            if isinstance(data, dict):
                for key in ['message', 'policy_number', 'claim_number', 'balance', 'status']:
                    if key in data:
                        print(f"  {key}: {data[key]}")
                if 'data' in data:
                    d = data['data']
                    if 'policy_number' in d:
                        print(f"  policy_number: {d['policy_number']}")
                    if 'claim_number' in d:
                        print(f"  claim_number: {d['claim_number']}")
                    if 'status' in d:
                        print(f"  status: {d['status']}")
    except:
        print(f"Response: {response.text[:200]}")

# Login user
USER_EMAIL = "testuser20251122124718@example.com"
USER_PASSWORD = "testing123"

print_header("LOGIN USER")

login_data = {
    "username": USER_EMAIL,
    "password": USER_PASSWORD
}

response = requests.post(f"{BASE_URL}/auth/login/", json=login_data)
print_response(response)

if response.status_code != 200:
    print("\n[ERROR] Login failed!")
    exit()

USER_TOKEN = response.json()['token']
print(f"\n[OK] Logged in: {USER_EMAIL}")
headers = {"Authorization": f"Token {USER_TOKEN}"}

# Check balance
print_header("CHECK WALLET BALANCE")
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
current_balance = float(wallet['balance'])
print(f"Current Balance: Rp {current_balance:,.0f}")

if current_balance < 150000:
    print("\n[ERROR] Balance not enough to buy policy!")
    exit()

# Get device
print_header("GET DEVICE PACKAGE")
response = requests.get(f"{BASE_URL}/device-packages/")
devices = response.json()

selected_device = None
for device in devices:
    if 4000000 <= float(device['device_value']) <= 5000000:
        selected_device = device
        break

if not selected_device:
    selected_device = devices[0]

print(f"Selected: {selected_device['device_brand']} {selected_device['device_model']}")
print(f"Price: Rp {float(selected_device['device_value']):,.0f}")

DEVICE_ID = selected_device['id']
DEVICE_PRICE = float(selected_device['device_value'])

# Create Policy
print_header("CREATE POLICY (BUY INSURANCE)")

timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
policy_data = {
    "device_package_id": DEVICE_ID,
    "imei_number": f"99999{timestamp[-10:]}",
    "purchase_price": DEVICE_PRICE
}

response = requests.post(f"{BASE_URL}/policies/", headers=headers, json=policy_data)
print_response(response, show_full=True)

if response.status_code != 201:
    print("\n[ERROR] Create policy failed!")
    exit()

policy_result = response.json()['data']
POLICY_ID = policy_result['id']
POLICY_NUMBER = policy_result['policy_number']

print(f"\n[OK] Policy created: {POLICY_NUMBER}")

# Check balance after
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
balance_after_policy = float(wallet['balance'])
print(f"[OK] Balance after: Rp {balance_after_policy:,.0f}")

# Create Claim
print_header("CREATE CLAIM")

claim_data = {
    "policy_id": POLICY_ID,
    "damage_type": "Layar Pecah",
    "damage_description": "Layar pecah karena terjatuh",
    "incident_date": "2025-11-21",
    "claim_amount": 2000000
}

response = requests.post(f"{BASE_URL}/claims/", headers=headers, json=claim_data)
print_response(response, show_full=True)

if response.status_code != 201:
    print("\n[ERROR] Create claim failed!")
    exit()

claim_result = response.json()['data']
CLAIM_ID = claim_result['id']
CLAIM_NUMBER = claim_result['claim_number']
DEDUCTION = float(response.json()['deduction_info']['deduction_amount'])

print(f"\n[OK] Claim created: {CLAIM_NUMBER}")
print(f"[OK] Deduction: Rp {DEDUCTION:,.0f}")

# Admin Login
print_header("ADMIN LOGIN")

admin_login = {
    "username": "chluik277@gmail.com",
    "password": "adminsmile277"
}

response = requests.post(f"{BASE_URL}/auth/login/", json=admin_login)

if response.status_code != 200:
    print("\n[ERROR] Admin login failed!")
    exit()

ADMIN_TOKEN = response.json()['token']
print(f"[OK] Admin logged in")

admin_headers = {"Authorization": f"Token {ADMIN_TOKEN}"}

# Admin Approve Claim
print_header("ADMIN APPROVE CLAIM")

response = requests.post(
    f"{BASE_URL}/admin/claims/{CLAIM_ID}/approve/",
    headers=admin_headers
)
print_response(response, show_full=True)

if response.status_code != 200:
    print("\n[ERROR] Approve failed!")
    exit()

print(f"\n[OK] Claim approved!")

# Final balance
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
final_balance = float(wallet['balance'])

print_header("FINAL SUMMARY")
print(f"""
Initial Balance:      Rp {current_balance:,.0f}
After Buy Policy:     Rp {balance_after_policy:,.0f} (deducted Rp 150,000)
After Claim Approved: Rp {final_balance:,.0f} (deducted Rp {DEDUCTION:,.0f})

Policy: {POLICY_NUMBER}
Claim:  {CLAIM_NUMBER}

[SUCCESS] ALL TESTS PASSED!
""")
