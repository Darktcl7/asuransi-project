"""
Test Admin Login
"""

import requests
import json

BASE_URL = "http://192.168.100.4:8000"
ADMIN_EMAIL = "chluik277@gmail.com"
ADMIN_PASSWORD = "password123"

print("=" * 70)
print("TESTING ADMIN LOGIN")
print("=" * 70)
print()

print(f"Email: {ADMIN_EMAIL}")
print(f"Password: {ADMIN_PASSWORD}")
print()

response = requests.post(
    f"{BASE_URL}/api/auth/login/",
    json={
        "username": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD
    }
)

print(f"Status Code: {response.status_code}")
print()

if response.status_code == 200:
    data = response.json()
    print("[SUCCESS] Admin login successful!")
    print(f"Token: {data['token'][:30]}...")
    print()
    print("You can now login to admin dashboard with:")
    print(f"  Email: {ADMIN_EMAIL}")
    print(f"  Password: {ADMIN_PASSWORD}")
else:
    print("[ERROR] Admin login failed!")
    print(f"Response: {response.text}")
