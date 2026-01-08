"""
Test Complete Workflow:
1. Register user
2. Top-up wallet
3. Approve top-up (manual via shell)
4. Create policy
5. Create claim
6. Admin approve claim

Jalankan: python test_complete_workflow.py
"""

import requests
import json
from datetime import datetime
import time

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
            print(f"Response: {json.dumps(data, indent=2)}")
        else:
            # Print only important fields
            if isinstance(data, dict):
                for key in ['message', 'token', 'policy_number', 'claim_number', 'balance', 'status']:
                    if key in data:
                        print(f"  {key}: {data[key]}")
            elif isinstance(data, list) and len(data) > 0:
                print(f"  Total items: {len(data)}")
                if 'balance' in data[0]:
                    print(f"  Balance: Rp {float(data[0]['balance']):,.0f}")
    except:
        print(f"Response: {response.text[:200]}")

# =====================================================
# STEP 1: Register User
# =====================================================
print_header("STEP 1: Register User")

timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
register_data = {
    "email": f"testuser{timestamp}@example.com",
    "password": "testing123",
    "password_confirm": "testing123",
    "first_name": "Test",
    "last_name": "User",
    "phone_number": f"0812{timestamp[-6:]}",
    "birth_date": "1995-05-15"
}

response = requests.post(f"{BASE_URL}/users/register/", json=register_data)
print_response(response)

if response.status_code != 201:
    print("\n[ERROR] Registration failed. Stop.")
    exit()

data = response.json()
USER_TOKEN = data['token']
USER_EMAIL = data['user']['email']
USER_ID = data['user']['id']

print(f"\n[OK] User registered: {USER_EMAIL}")
print(f"[OK] Token: {USER_TOKEN[:20]}...")

headers = {"Authorization": f"Token {USER_TOKEN}"}

# =====================================================
# STEP 2: Get Device Package ID
# =====================================================
print_header("STEP 2: Get Device Packages")

response = requests.get(f"{BASE_URL}/device-packages/")
devices = response.json()

if len(devices) == 0:
    print("[ERROR] No devices found. Run seed_data.py first!")
    exit()

# Pilih device pertama (atau cari yang harganya sesuai)
selected_device = None
for device in devices:
    # Cari device dengan harga 4-5 juta (tier Standar)
    if 4000000 <= float(device['device_value']) <= 5000000:
        selected_device = device
        break

if not selected_device:
    selected_device = devices[0]  # Fallback ke device pertama

print(f"\n[OK] Selected device: {selected_device['device_brand']} {selected_device['device_model']}")
print(f"[OK] Price: Rp {float(selected_device['device_value']):,.0f}")
print(f"[OK] Device ID: {selected_device['id']}")

DEVICE_ID = selected_device['id']
DEVICE_PRICE = float(selected_device['device_value'])

# =====================================================
# STEP 3: Request Top-Up
# =====================================================
print_header("STEP 3: Request Top-Up (Rp 1,000,000)")

topup_data = {
    "amount": 1000000,
    "payment_method": "Bank Transfer BCA",
    "payment_proof_url": "https://example.com/bukti_transfer.jpg"
}

response = requests.post(f"{BASE_URL}/wallet/topup/", headers=headers, json=topup_data)
print_response(response)

if response.status_code != 201:
    print("\n[ERROR] Top-up request failed. Stop.")
    exit()

print("\n[OK] Top-up request created (status: pending)")

# =====================================================
# STEP 4: Manual Approve Top-Up
# =====================================================
print_header("STEP 4: Approve Top-Up (Manual)")

print("\n[INFO] Top-up perlu di-approve manual via Django shell.")
print("[INFO] Buka terminal baru dan jalankan:\n")
print("cd \"D:\\Django Project\\Asuransi Project\\Smile Project\"")
print("env\\Scripts\\python.exe manage.py shell\n")
print("Lalu copy-paste code ini:\n")
print("-" * 70)
print(f"""
from wallet.models import TopUpTransaction, Wallet, WalletHistory
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()
user = User.objects.get(email='{USER_EMAIL}')
topup = TopUpTransaction.objects.filter(user=user, status='pending').last()

# Approve
topup.status = 'success'
topup.verified_at = timezone.now()
topup.save()

# Update wallet
wallet = user.wallet
balance_before = wallet.balance
wallet.balance += topup.amount
wallet.total_topup += topup.amount
wallet.save()

# History
WalletHistory.objects.create(
    wallet=wallet,
    transaction_type='topup',
    amount=topup.amount,
    balance_before=balance_before,
    balance_after=wallet.balance,
    description=f'Top up approved: {{topup.transaction_id}}'
)

print(f'[OK] Approved! Balance: Rp {{wallet.balance:,.0f}}')
exit()
""")
print("-" * 70)

input("\nTekan ENTER setelah top-up di-approve...")

# Verify balance
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
current_balance = float(wallet['balance'])

if current_balance > 0:
    print(f"\n[OK] Balance updated: Rp {current_balance:,.0f}")
else:
    print("\n[ERROR] Balance masih 0. Top-up belum di-approve?")
    print("Silakan approve dulu, lalu jalankan script ini lagi.")
    exit()

# =====================================================
# STEP 5: Create Policy (Buy Insurance)
# =====================================================
print_header("STEP 5: Create Policy (Buy Insurance)")

policy_data = {
    "device_package_id": DEVICE_ID,
    "imei_number": f"12345{timestamp[-10:]}",  # Unique IMEI
    "purchase_price": DEVICE_PRICE
}

response = requests.post(f"{BASE_URL}/policies/", headers=headers, json=policy_data)
print_response(response, show_full=True)

if response.status_code != 201:
    print("\n[ERROR] Create policy failed. Stop.")
    exit()

policy_data = response.json()['data']
POLICY_ID = policy_data['id']
POLICY_NUMBER = policy_data['policy_number']

print(f"\n[OK] Policy created: {POLICY_NUMBER}")
print(f"[OK] Policy ID: {POLICY_ID}")
print(f"[OK] Status: {policy_data['status']}")

# Check balance after buying policy
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
balance_after_policy = float(wallet['balance'])
print(f"[OK] Balance after buy policy: Rp {balance_after_policy:,.0f}")

# =====================================================
# STEP 6: Create Claim
# =====================================================
print_header("STEP 6: Create Claim")

claim_data = {
    "policy_id": POLICY_ID,
    "damage_type": "Layar Pecah",
    "damage_description": "Layar ponsel pecah karena terjatuh dari meja",
    "incident_date": "2025-11-21",
    "claim_amount": 2000000
}

response = requests.post(f"{BASE_URL}/claims/", headers=headers, json=claim_data)
print_response(response, show_full=True)

if response.status_code != 201:
    print("\n[ERROR] Create claim failed. Stop.")
    exit()

claim_response = response.json()
CLAIM_ID = claim_response['data']['id']
CLAIM_NUMBER = claim_response['data']['claim_number']
DEDUCTION = float(claim_response['deduction_info']['deduction_amount'])

print(f"\n[OK] Claim created: {CLAIM_NUMBER}")
print(f"[OK] Claim ID: {CLAIM_ID}")
print(f"[OK] Deduction will be: Rp {DEDUCTION:,.0f}")

# =====================================================
# STEP 7: Login as Admin
# =====================================================
print_header("STEP 7: Login as Admin")

admin_login = {
    "username": "chluik277@gmail.com",
    "password": "adminsmile277"
}

response = requests.post(f"{BASE_URL}/auth/login/", json=admin_login)

if response.status_code != 200:
    print("\n[ERROR] Admin login failed.")
    print("Default admin: chluik277@gmail.com / adminsmile277")
    exit()

ADMIN_TOKEN = response.json()['token']
print(f"\n[OK] Admin logged in")
print(f"[OK] Admin Token: {ADMIN_TOKEN[:20]}...")

admin_headers = {"Authorization": f"Token {ADMIN_TOKEN}"}

# =====================================================
# STEP 8: Admin Approve Claim
# =====================================================
print_header("STEP 8: Admin Approve Claim")

response = requests.post(
    f"{BASE_URL}/admin/claims/{CLAIM_ID}/approve/",
    headers=admin_headers
)
print_response(response, show_full=True)

if response.status_code != 200:
    print("\n[ERROR] Approve claim failed.")
    exit()

print(f"\n[OK] Claim approved!")

# Check final balance
response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
wallet = response.json()[0]
final_balance = float(wallet['balance'])

print(f"[OK] Final balance: Rp {final_balance:,.0f}")

# =====================================================
# SUMMARY
# =====================================================
print_header("TEST SUMMARY")

print(f"""
User Email:       {USER_EMAIL}
Initial Balance:  Rp 0
After Top-up:     Rp {current_balance:,.0f}
After Buy Policy: Rp {balance_after_policy:,.0f}
After Claim:      Rp {final_balance:,.0f}

Policy Number:    {POLICY_NUMBER}
Claim Number:     {CLAIM_NUMBER}
Deduction:        Rp {DEDUCTION:,.0f}

[OK] ALL TESTS PASSED!
""")

print("="*70)
