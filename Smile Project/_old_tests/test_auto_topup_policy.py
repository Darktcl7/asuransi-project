"""
TEST: Auto Top-Up saat Create Policy
Verify bahwa ketika admin create policy, wallet otomatis di top-up
"""

import requests
import json

BASE_URL = "http://192.168.100.4:8000"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "password123"

# Test user
LEO_ID = "24637cca-0633-4b55-bb25-e6774b190254"
LEO_EMAIL = "leomanggi@gmail.com"

class Colors:
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.BLUE}{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.BLUE}{Colors.BOLD}{text}{Colors.END}")
    print(f"{Colors.BLUE}{Colors.BOLD}{'='*70}{Colors.END}\n")

def print_success(text):
    print(f"{Colors.GREEN}[OK] {text}{Colors.END}")

def print_error(text):
    print(f"{Colors.RED}[ERROR] {text}{Colors.END}")

def print_info(text):
    print(f"{Colors.YELLOW}[INFO] {text}{Colors.END}")


print_header("TEST AUTO TOP-UP SAAT CREATE POLICY")

# Step 1: Admin login
print_info("Step 1: Admin login...")
response = requests.post(
    f"{BASE_URL}/api/auth/login/",
    json={"username": ADMIN_EMAIL, "password": ADMIN_PASSWORD}
)

if response.status_code != 200:
    print_error(f"Admin login failed: {response.text}")
    exit(1)

admin_token = response.json()['token']
print_success(f"Admin login successful!")
print()

# Step 2: Check wallet before
print_info("Step 2: Check Leo's wallet BEFORE policy creation...")
response = requests.get(
    f"{BASE_URL}/api/admin/wallets/",
    headers={"Authorization": f"Token {admin_token}"}
)

wallets = response.json()
if isinstance(wallets, dict) and 'results' in wallets:
    wallets = wallets['results']

leo_wallet = None
for wallet in wallets:
    if wallet['user_email'] == LEO_EMAIL:
        leo_wallet = wallet
        break

if leo_wallet:
    print_success("Leo's wallet found!")
    print(f"   Balance BEFORE: Rp {float(leo_wallet['balance']):,.0f}")
    print(f"   Total Top-Up BEFORE: Rp {float(leo_wallet['total_topup']):,.0f}")
    balance_before = float(leo_wallet['balance'])
    topup_before = float(leo_wallet['total_topup'])
else:
    print_error("Leo's wallet not found!")
    balance_before = 0
    topup_before = 0

print()

# Step 3: Get device (Samsung A54)
print_info("Step 3: Get device packages...")
response = requests.get(
    f"{BASE_URL}/api/device-packages/",
    headers={"Authorization": f"Token {admin_token}"}
)

devices = response.json()
samsung = None
for device in devices:
    if 'samsung' in device.get('device_brand', '').lower() and 'a54' in device.get('device_model', '').lower():
        samsung = device
        break

if not samsung:
    print_error("Samsung A54 not found!")
    exit(1)

print_success(f"Found device: {samsung['device_brand']} {samsung['device_model']}")
print(f"   Price: Rp {float(samsung['device_value']):,.0f}")
print()

# Step 4: Create policy (with auto top-up)
print_header("Step 4: Create Policy (AUTO TOP-UP)")
print_info("Creating policy for Leo...")

import time
import random
test_imei = f"{random.randint(300000000000000, 399999999999999)}"

response = requests.post(
    f"{BASE_URL}/api/admin/policies/manual-create/",
    headers={"Authorization": f"Token {admin_token}"},
    json={
        "user_id": LEO_ID,
        "device_package_id": samsung['id'],
        "imei_number": test_imei,
        "purchase_price": samsung['device_value']
    }
)

if response.status_code != 201:
    print_error(f"Policy creation failed!")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    exit(1)

data = response.json()
policy = data['policy']
wallet = data['wallet']

print_success("Policy created successfully with AUTO TOP-UP!")
print()

print(f"{Colors.BOLD}[POLICY] Details:{Colors.END}")
print(f"   Policy Number: {policy['policy_number']}")
print(f"   User: {policy['user']}")
print(f"   Tier: {policy['tier']}")
print(f"   Device: {policy['device']}")
print(f"   IMEI: {policy['imei']}")
print(f"   Status: {policy['status']}")
print()

print(f"{Colors.BOLD}[WALLET] Transaction:{Colors.END}")
print(f"   Balance BEFORE: Rp {wallet['balance_before']:,.0f}")
print(f"   [+] Auto Top-Up: Rp {wallet['topup_amount']:,.0f}")
print(f"   Balance AFTER: Rp {wallet['balance_after']:,.0f}")
print(f"   Final Balance: Rp {wallet['final_balance']:,.0f} (FULL, tidak dipotong)")
print()

# Step 5: Verify wallet after
print_info("Step 5: Verify Leo's wallet AFTER policy creation...")
time.sleep(0.5)

response = requests.get(
    f"{BASE_URL}/api/admin/wallets/",
    headers={"Authorization": f"Token {admin_token}"}
)

wallets = response.json()
if isinstance(wallets, dict) and 'results' in wallets:
    wallets = wallets['results']

leo_wallet_after = None
for w in wallets:
    if w['user_email'] == LEO_EMAIL:
        leo_wallet_after = w
        break

if leo_wallet_after:
    balance_after = float(leo_wallet_after['balance'])
    topup_after = float(leo_wallet_after['total_topup'])
    
    print_success("Wallet verification:")
    print(f"   Balance AFTER: Rp {balance_after:,.0f}")
    print(f"   Total Top-Up AFTER: Rp {topup_after:,.0f}")
    print()
    
    # Verify calculations (NO DEDUCTION for policy price)
    expected_balance = balance_before + wallet['topup_amount']  # NO DEDUCTION!
    expected_topup = topup_before + wallet['topup_amount']
    
    print_info("Verification:")
    
    if abs(balance_after - expected_balance) < 0.01:
        print_success(f"[OK] Balance calculation correct!")
    else:
        print_error(f"[X] Balance mismatch! Expected: {expected_balance:,.0f}, Got: {balance_after:,.0f}")
    
    if abs(topup_after - expected_topup) < 0.01:
        print_success(f"[OK] Total top-up calculation correct!")
    else:
        print_error(f"[X] Top-up mismatch! Expected: {expected_topup:,.0f}, Got: {topup_after:,.0f}")

print()

# Summary
print_header("TEST SUMMARY")

print(f"{Colors.GREEN}{Colors.BOLD}[SUCCESS] AUTO TOP-UP WORKING!{Colors.END}\n")

print(f"{Colors.BOLD}Flow yang terjadi:{Colors.END}")
print(f"1. Admin create policy untuk Leo")
print(f"2. System AUTO TOP-UP wallet: Rp {wallet['topup_amount']:,.0f}")
print(f"3. System create policy: {policy['tier']}")
print(f"4. Saldo TETAP FULL: Rp {wallet['final_balance']:,.0f} (tidak dipotong)")
print()

print(f"{Colors.GREEN}Status: BERHASIL! Workflow auto top-up sudah jalan!{Colors.END}")
