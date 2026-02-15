import requests
import json

BASE_URL = 'http://localhost:8000/api'

def debug_users_api():
    print("="*60)
    print("DEBUGGING ADMIN USERS API")
    print("="*60)

    # 1. Login as Super Admin
    print("\n[1] Logging in as Super Admin...")
    try:
        resp = requests.post(f"{BASE_URL}/login/", json={
            "identifier": "superadmin@smile.com",
            "password": "SuperAdmin123!"
        })
        
        if resp.status_code != 200:
            print(f"❌ Login Error: {resp.status_code}")
            print(resp.text)
            return

        token = resp.json()['token']
        role = resp.json()['user']['role']
        print(f"✅ Login Success. Token obtained. Role: {role}")
    
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        return

    # 2. Fetch Users
    print("\n[2] Fetching /api/admin/users/ ...")
    headers = {'Authorization': f'Token {token}'}
    
    try:
        # Request without filters first (should show all)
        resp = requests.get(f"{BASE_URL}/admin/users/?page=1&page_size=100", headers=headers)
        
        if resp.status_code != 200:
            print(f"❌ API Error: {resp.status_code}")
            print(resp.text)
            return
            
        data = resp.json()
        results = data.get('results', [])
        count = data.get('count', 0)
        
        print(f"✅ API Response: {resp.status_code}")
        print(f"   Total Count: {count}")
        print(f"   Results Length: {len(results)}")
        
        # 3. Search for Store Admins
        print("\n[3] Searching for Store Admins in results:")
        found_admins = []
        for user in results:
            if user['role'] in ['store_admin', 'store_staff'] or user['email'] in ['chluik277@gmail.com', 'demo@smile.com']:
                found_admins.append(user)
                print(f"   FOUND -> {user['email']} | Role: {user['role']} | Store: {user.get('store', {}).get('name') if user.get('store') else 'None'}")
        
        if not found_admins:
            print("   ❌ NO Store Admins found in the list!")
            
            # Debug: Check filters
            print("\n   Checking if 'role' field exists in response items:")
            if results:
                print(f"   Sample user keys: {list(results[0].keys())}")
                print(f"   Sample user role: {results[0].get('role')}")
        
    except Exception as e:
        print(f"❌ Request Failed: {e}")

if __name__ == "__main__":
    debug_users_api()
