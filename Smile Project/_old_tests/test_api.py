"""
Script untuk test API endpoints secara otomatis
Jalankan: python test_api.py
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:8000/api"

def print_header(text):
    print("\n" + "="*60)
    print(f"  {text}")
    print("="*60)

def print_response(response):
    print(f"Status Code: {response.status_code}")
    try:
        print(f"Response: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"Response: {response.text}")

# =====================================================
# TEST 1: Register User Baru
# =====================================================
print_header("TEST 1: Register User Baru")

register_data = {
    "email": f"testuser{datetime.now().strftime('%Y%m%d%H%M%S')}@example.com",
    "password": "testing123",
    "password_confirm": "testing123",
    "first_name": "Test",
    "last_name": "User",
    "phone_number": f"0812{datetime.now().strftime('%H%M%S')}",
    "birth_date": "1995-05-15"
}

response = requests.post(f"{BASE_URL}/users/register/", json=register_data)
print_response(response)

if response.status_code == 201:
    data = response.json()
    USER_TOKEN = data['token']
    USER_EMAIL = data['user']['email']
    print(f"\n[OK] SUCCESS! User registered.")
    print(f"[EMAIL] {USER_EMAIL}")
    print(f"[TOKEN] {USER_TOKEN[:20]}...")
    
    # Save token untuk test selanjutnya
    with open("test_token.txt", "w") as f:
        f.write(f"USER_TOKEN={USER_TOKEN}\n")
        f.write(f"USER_EMAIL={USER_EMAIL}\n")
    
    # =====================================================
    # TEST 2: Get Wallet Info (Cek Auto-Create)
    # =====================================================
    print_header("TEST 2: Get Wallet Info (Auto-Create Check)")
    
    headers = {"Authorization": f"Token {USER_TOKEN}"}
    response = requests.get(f"{BASE_URL}/wallet/", headers=headers)
    print_response(response)
    
    if response.status_code == 200:
        wallet_data = response.json()
        if wallet_data and len(wallet_data) > 0:
            print(f"\n[OK] SUCCESS! Wallet auto-created.")
            print(f"[BALANCE] Rp {float(wallet_data[0]['balance']):,.0f}")
        else:
            print("\n[ERROR] FAILED! Wallet not found.")
    
    # =====================================================
    # TEST 3: Get User Profile
    # =====================================================
    print_header("TEST 3: Get User Profile (/api/users/me/)")
    
    response = requests.get(f"{BASE_URL}/users/me/", headers=headers)
    print_response(response)
    
    if response.status_code == 200:
        print("\n[OK] SUCCESS! User profile retrieved.")
    
    # =====================================================
    # TEST 4: Get User Policies (Should be empty)
    # =====================================================
    print_header("TEST 4: Get User Policies")
    
    response = requests.get(f"{BASE_URL}/policies/", headers=headers)
    print_response(response)
    
    if response.status_code == 200:
        policies = response.json()
        print(f"\n[OK] SUCCESS! Total policies: {len(policies)}")
    
else:
    print("\n[ERROR] FAILED! User registration failed.")
    print("Kemungkinan email atau phone sudah dipakai. Coba jalankan lagi.")

print("\n" + "="*60)
print("  Test Selesai!")
print("="*60)
print("\nToken disimpan di: test_token.txt")
print("Gunakan token tersebut untuk test selanjutnya.")
