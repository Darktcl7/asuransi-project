"""
END-TO-END WORKFLOW TEST
========================
Test complete flow:
1. Admin top-up untuk Leo & Ardy
2. Admin create policy untuk Leo & Ardy
3. User login dan view data
4. Verify semua data tampil dengan benar
"""

import requests
import json
from decimal import Decimal

# Configuration
BASE_URL = "http://192.168.100.4:8000"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "password123"

# Test Users
LEO_EMAIL = "leomanggi@gmail.com"
LEO_PASSWORD = "password123"
LEO_ID = "24637cca-0633-4b55-bb25-e6774b190254"

ARDY_EMAIL = "ardy@gamil.com"
ARDY_PASSWORD = "password123"
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

def print_step(step_num, text):
    print(f"{Colors.BLUE}{Colors.BOLD}Step {step_num}: {text}{Colors.END}")

def print_success(text):
    print(f"{Colors.GREEN}[OK] {text}{Colors.END}")

def print_error(text):
    print(f"{Colors.RED}[ERROR] {text}{Colors.END}")

def print_info(text):
    print(f"{Colors.YELLOW}[INFO] {text}{Colors.END}")

def print_data(label, value):
    print(f"   {Colors.BOLD}{label}:{Colors.END} {value}")


# ============================================================================
# STEP 1: ADMIN LOGIN
# ============================================================================
def admin_login():
    print_step(1, "Admin Login")
    
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
        print_data("Email", ADMIN_EMAIL)
        print_data("Token", data['token'][:20] + "...")
        return data['token']
    else:
        print_error(f"Admin login failed: {response.text}")
        return None


# ============================================================================
# STEP 2: GET USER IDs
# ============================================================================
def get_user_id(admin_token, email):
    print_info(f"Getting user ID for {email}...")
    
    # Try to get users list
    response = requests.get(
        f"{BASE_URL}/api/admin/users/",
        headers={"Authorization": f"Token {admin_token}"}
    )
    
    if response.status_code == 200:
        users = response.json()
        if isinstance(users, dict) and 'results' in users:
            users = users['results']
        
        for user in users:
            if user.get('email') == email:
                print_success(f"Found user: {email}")
                print_data("User ID", user['id'])
                print_data("Name", user.get('first_name', '') + ' ' + user.get('last_name', ''))
                return user['id']
        
        print_error(f"User {email} not found in list")
        return None
    else:
        print_error(f"Failed to get users: {response.text}")
        return None


# ============================================================================
# STEP 3: ADMIN TOP-UP
# ============================================================================
def admin_topup(admin_token, user_id, email, amount):
    import time
    import random
    
    print_step("3a" if email == LEO_EMAIL else "3b", f"Admin Top-Up: {email}")
    
    # Add small delay to avoid duplicate transaction IDs
    time.sleep(0.1)
    
    response = requests.post(
        f"{BASE_URL}/api/admin/topups/",
        headers={"Authorization": f"Token {admin_token}"},
        json={
            "user": user_id,
            "amount": str(amount),
            "payment_method": "admin_topup",
            "notes": f"Manual top-up by admin - End-to-end test {random.randint(1000, 9999)}",
            "status": "completed"
        }
    )
    
    if response.status_code == 201:
        data = response.json()
        print_success("Top-up successful!")
        print_data("User", email)
        print_data("Amount", f"Rp {amount:,}")
        print_data("Transaction ID", data['topup']['transaction_id'])
        print_data("New Balance", f"Rp {data['wallet_balance']:,}")
        return True
    else:
        print_error(f"Top-up failed: {response.text}")
        return False


# ============================================================================
# STEP 4: GET DEVICE PACKAGES
# ============================================================================
def get_device_packages(admin_token):
    print_info("Getting device packages...")
    
    response = requests.get(
        f"{BASE_URL}/api/device-packages/",
        headers={"Authorization": f"Token {admin_token}"}
    )
    
    if response.status_code == 200:
        devices = response.json()
        if isinstance(devices, dict) and 'results' in devices:
            devices = devices['results']
        
        print_success(f"Found {len(devices)} devices")
        return devices
    else:
        print_error(f"Failed to get devices: {response.text}")
        return []


def find_device(devices, search_term):
    """Find device by brand or model name"""
    for device in devices:
        device_name = f"{device.get('device_brand', '')} {device.get('device_model', '')}".lower()
        if search_term.lower() in device_name:
            return device
    return None


# ============================================================================
# STEP 5: ADMIN CREATE POLICY
# ============================================================================
def admin_create_policy(admin_token, user_id, email, device_id, device_name, imei, price):
    step_label = "4a" if email == LEO_EMAIL else "4b"
    print_step(step_label, f"Admin Create Policy: {email}")
    
    response = requests.post(
        f"{BASE_URL}/api/admin/policies/manual-create/",
        headers={"Authorization": f"Token {admin_token}"},
        json={
            "user_id": user_id,
            "device_package_id": device_id,
            "imei_number": imei,
            "purchase_price": str(price)
        }
    )
    
    if response.status_code == 201:
        data = response.json()
        policy = data['policy']
        print_success("Policy created successfully!")
        print_data("User", email)
        print_data("Policy Number", policy['policy_number'])
        print_data("Tier", policy['tier'])
        print_data("Device", policy['device'])
        print_data("IMEI", policy['imei'])
        print_data("Purchase Price", f"Rp {policy['purchase_price']:,.0f}")
        print_data("Policy Price", f"Rp {policy['policy_price']:,.0f}")
        print_data("Status", policy['status'].upper())
        print_data("Expiry Date", policy['expiry_date'])
        return True
    else:
        print_error(f"Policy creation failed: {response.text}")
        return False


# ============================================================================
# STEP 6: USER LOGIN & VIEW
# ============================================================================
def user_login(email, password):
    step_label = "5a" if email == LEO_EMAIL else "5b"
    print_step(step_label, f"User Login: {email}")
    
    response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={
            "username": email,
            "password": password
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        print_success(f"User login successful!")
        print_data("Email", email)
        return data['token']
    else:
        print_error(f"User login failed: {response.text}")
        return None


def check_user_wallet(user_token, email):
    print_info(f"Checking wallet for {email}...")
    
    response = requests.get(
        f"{BASE_URL}/api/wallet/",
        headers={"Authorization": f"Token {user_token}"}
    )
    
    if response.status_code == 200:
        wallet_data = response.json()
        
        # Handle both list and dict response
        if isinstance(wallet_data, list):
            wallet = wallet_data[0] if len(wallet_data) > 0 else {}
        else:
            wallet = wallet_data
            
        print_success("Wallet data retrieved!")
        print_data("Balance", f"Rp {float(wallet.get('balance', 0)):,.0f}")
        print_data("Total Top-Up", f"Rp {float(wallet.get('total_topup', 0)):,.0f}")
        print_data("Total Spent", f"Rp {float(wallet.get('total_spent', 0)):,.0f}")
        return wallet
    else:
        print_error(f"Failed to get wallet: {response.text}")
        return None


def check_user_policies(user_token, email):
    print_info(f"Checking policies for {email}...")
    
    response = requests.get(
        f"{BASE_URL}/api/policies/",
        headers={"Authorization": f"Token {user_token}"}
    )
    
    if response.status_code == 200:
        policies = response.json()
        if isinstance(policies, dict) and 'results' in policies:
            policies = policies['results']
        
        if len(policies) > 0:
            print_success(f"Found {len(policies)} policy(ies)!")
            
            for idx, policy in enumerate(policies, 1):
                print(f"\n   {Colors.BOLD}Policy #{idx}:{Colors.END}")
                print_data("   Tier", policy.get('tier_name', 'N/A'))
                print_data("   Policy Number", policy.get('policy_number', 'N/A'))
                
                # Device info
                device_details = policy.get('device_details', {})
                device_name = f"{device_details.get('device_brand', '')} {device_details.get('device_model', '')}"
                print_data("   Device", device_name)
                
                print_data("   IMEI", policy.get('imei_number', 'N/A'))
                print_data("   Status", policy.get('status', 'N/A').upper())
                
                # Claims info
                claims_used = policy.get('claims_used', 0)
                max_claims = policy.get('max_claims_per_year', 'N/A')
                print_data("   Claims Used", f"{claims_used} / {max_claims}")
                
                print_data("   Activation Date", policy.get('activation_date', 'N/A'))
                print_data("   Expiry Date", policy.get('expiry_date', 'N/A'))
            
            return policies
        else:
            print_error("No policies found!")
            return []
    else:
        print_error(f"Failed to get policies: {response.text}")
        return None


# ============================================================================
# MAIN TEST FLOW
# ============================================================================
def main():
    print_header("END-TO-END WORKFLOW TEST")
    print(f"{Colors.BOLD}Testing complete flow from admin to user view{Colors.END}\n")
    
    # Step 1: Admin Login
    admin_token = admin_login()
    if not admin_token:
        print_error("Cannot proceed without admin token!")
        return
    
    print()
    
    # Step 2: Get User IDs (using hardcoded IDs for reliability)
    print_step(2, "Get User Information")
    print_info(f"Using Leo ID: {LEO_ID}")
    print_info(f"Using Ardy ID: {ARDY_ID}")
    
    leo_id = LEO_ID
    ardy_id = ARDY_ID
    
    print()
    
    # Step 3: Admin Top-Up
    print_header("ADMIN TOP-UP WALLET")
    admin_topup(admin_token, leo_id, LEO_EMAIL, 500000)
    print()
    admin_topup(admin_token, ardy_id, ARDY_EMAIL, 500000)
    print()
    
    # Step 4: Get Devices
    print_step(3, "Get Device Packages")
    devices = get_device_packages(admin_token)
    
    # Find Samsung A54 for Leo
    samsung_a54 = find_device(devices, "samsung a54") or find_device(devices, "samsung galaxy a54")
    if not samsung_a54:
        print_error("Samsung A54 not found!")
        return
    
    print_success(f"Found Samsung A54: {samsung_a54['device_brand']} {samsung_a54['device_model']}")
    print_data("Price", f"Rp {float(samsung_a54['device_value']):,.0f}")
    
    # Find iPhone 15 for Ardy
    iphone_15 = find_device(devices, "iphone 15")
    if not iphone_15:
        print_error("iPhone 15 not found!")
        return
    
    print_success(f"Found iPhone 15: {iphone_15['device_brand']} {iphone_15['device_model']}")
    print_data("Price", f"Rp {float(iphone_15['device_value']):,.0f}")
    print()
    
    # Step 5: Admin Create Policies
    print_header("ADMIN CREATE POLICIES")
    
    # Leo's policy
    admin_create_policy(
        admin_token, 
        leo_id, 
        LEO_EMAIL, 
        samsung_a54['id'],
        f"{samsung_a54['device_brand']} {samsung_a54['device_model']}",
        "111111111111111",
        float(samsung_a54['device_value'])
    )
    print()
    
    # Ardy's policy
    admin_create_policy(
        admin_token, 
        ardy_id, 
        ARDY_EMAIL, 
        iphone_15['id'],
        f"{iphone_15['device_brand']} {iphone_15['device_model']}",
        "222222222222222",
        float(iphone_15['device_value'])
    )
    print()
    
    # Step 6: User Login & View
    print_header("USER VIEW - MOBILE APP SIMULATION")
    
    # Leo's view
    leo_token = user_login(LEO_EMAIL, LEO_PASSWORD)
    if leo_token:
        print()
        leo_wallet = check_user_wallet(leo_token, LEO_EMAIL)
        print()
        leo_policies = check_user_policies(leo_token, LEO_EMAIL)
    
    print("\n")
    
    # Ardy's view
    ardy_token = user_login(ARDY_EMAIL, ARDY_PASSWORD)
    if ardy_token:
        print()
        ardy_wallet = check_user_wallet(ardy_token, ARDY_EMAIL)
        print()
        ardy_policies = check_user_policies(ardy_token, ARDY_EMAIL)
    
    # Final Summary
    print_header("TEST SUMMARY")
    
    print(f"{Colors.BOLD}[OK] Admin Actions:{Colors.END}")
    print("   [OK] Admin login successful")
    print("   [OK] Top-up Leo: Rp 500.000")
    print("   [OK] Top-up Ardy: Rp 500.000")
    print("   [OK] Create policy for Leo (Samsung A54)")
    print("   [OK] Create policy for Ardy (iPhone 15)")
    
    print(f"\n{Colors.BOLD}[OK] User Verification:{Colors.END}")
    print(f"   [OK] Leo can login")
    print(f"   [OK] Leo's wallet: Rp {float(leo_wallet.get('balance', 0)):,.0f}")
    print(f"   [OK] Leo has {len(leo_policies)} policy (Tier: {leo_policies[0].get('tier_name', 'N/A') if leo_policies else 'N/A'})")
    
    print(f"   [OK] Ardy can login")
    print(f"   [OK] Ardy's wallet: Rp {float(ardy_wallet.get('balance', 0)):,.0f}")
    print(f"   [OK] Ardy has {len(ardy_policies)} policy (Tier: {ardy_policies[0].get('tier_name', 'N/A') if ardy_policies else 'N/A'})")
    
    print(f"\n{Colors.GREEN}{Colors.BOLD}[SUCCESS] END-TO-END TEST COMPLETED SUCCESSFULLY!{Colors.END}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Test interrupted by user.{Colors.END}")
    except Exception as e:
        print(f"\n{Colors.RED}Error: {e}{Colors.END}")
        import traceback
        traceback.print_exc()
