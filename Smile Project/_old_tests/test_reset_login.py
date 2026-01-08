"""
Test Login dengan Password Baru
Run: env\Scripts\python.exe test_reset_login.py
"""
import requests
import json
import sys
import io

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE_URL = "http://192.168.100.4:8000/api"

print("\n" + "="*60)
print("  TEST LOGIN - Password Baru")
print("="*60)

users_to_test = [
    {'email': 'leomanggi@gmail.com', 'password': 'password123'},
    {'email': 'ardy@gamil.com', 'password': 'password123'},
]

for user_data in users_to_test:
    email = user_data['email']
    password = user_data['password']
    
    print(f"\n🔐 Testing login: {email}")
    print(f"   Password: {password}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login/",
            json={'username': email, 'password': password},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ LOGIN SUCCESS!")
            print(f"   Token: {data['token'][:20]}...")
        else:
            print(f"   ❌ LOGIN FAILED!")
            print(f"   Status: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"   ❌ ERROR: {str(e)}")

print("\n" + "="*60)
print("  TEST SELESAI!")
print("="*60 + "\n")
