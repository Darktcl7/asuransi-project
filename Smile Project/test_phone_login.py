#!/usr/bin/env python
"""
Test Phone Number Login Feature

Test login dengan:
1. Email + Password
2. Phone Number + Password

Run: python test_phone_login.py
"""

import os
import sys
import django
import requests

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

# Colors
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_header(title):
    print(f"\n{BLUE}{'='*70}{RESET}")
    print(f"{BLUE}{title.center(70)}{RESET}")
    print(f"{BLUE}{'='*70}{RESET}\n")

def print_success(message):
    print(f"{GREEN}✅ {message}{RESET}")

def print_error(message):
    print(f"{RED}❌ {message}{RESET}")

def print_info(message):
    print(f"  ℹ️  {message}")

# ============================================================================
# TEST 1: LOGIN WITH EMAIL
# ============================================================================

def test_login_with_email():
    print_header("TEST 1: LOGIN WITH EMAIL")
    
    # Get test user
    test_user = User.objects.filter(phone_number__isnull=False).first()
    if not test_user:
        print_error("No user with phone number found. Creating test user...")
        test_user = User.objects.create_user(
            email='test_phone_login@example.com',
            password='test123',
            first_name='Test',
            last_name='Phone Login',
            phone_number='081234567890'
        )
        print_success(f"Test user created: {test_user.email}")
    
    print_info(f"Testing login with email: {test_user.email}")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': test_user.email,
            'password': 'test123'
        })
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Login successful!")
            print_info(f"Token: {data['token'][:20]}...")
            print_info(f"Login method: {data.get('login_method', 'N/A')}")
            print_info(f"User: {data['user']['full_name']}")
            return True
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# TEST 2: LOGIN WITH PHONE NUMBER (08...)
# ============================================================================

def test_login_with_phone_08():
    print_header("TEST 2: LOGIN WITH PHONE NUMBER (08...)")
    
    # Get user
    test_user = User.objects.filter(phone_number='081234567890').first()
    if not test_user:
        print_error("Test user not found")
        return False
    
    print_info(f"User email: {test_user.email}")
    print_info(f"User phone: {test_user.phone_number}")
    print_info(f"Testing login with phone: 081234567890")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': '081234567890',
            'password': 'test123'
        })
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Login successful with phone number!")
            print_info(f"Token: {data['token'][:20]}...")
            print_info(f"Login method: {data.get('login_method', 'N/A')}")
            print_info(f"User: {data['user']['full_name']}")
            return True
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# TEST 3: LOGIN WITH PHONE NUMBER (62...)
# ============================================================================

def test_login_with_phone_62():
    print_header("TEST 3: LOGIN WITH PHONE NUMBER (62...)")
    
    print_info("Testing with international format: 6281234567890")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': '6281234567890',  # International format
            'password': 'test123'
        })
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Login successful with international format!")
            print_info(f"Token: {data['token'][:20]}...")
            print_info(f"Login method: {data.get('login_method', 'N/A')}")
            return True
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# TEST 4: LOGIN WITH PHONE NUMBER (+62...)
# ============================================================================

def test_login_with_phone_plus():
    print_header("TEST 4: LOGIN WITH PHONE NUMBER (+62...)")
    
    print_info("Testing with plus format: +6281234567890")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': '+6281234567890',  # Plus format
            'password': 'test123'
        })
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Login successful with plus format!")
            print_info(f"Token: {data['token'][:20]}...")
            print_info(f"Login method: {data.get('login_method', 'N/A')}")
            return True
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# TEST 5: LOGIN WITH FORMATTED PHONE
# ============================================================================

def test_login_with_formatted_phone():
    print_header("TEST 5: LOGIN WITH FORMATTED PHONE")
    
    print_info("Testing with formatted: 0812-3456-7890")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': '0812-3456-7890',  # With dashes
            'password': 'test123'
        })
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Login successful with formatted phone!")
            print_info(f"Token: {data['token'][:20]}...")
            print_info(f"Login method: {data.get('login_method', 'N/A')}")
            return True
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# TEST 6: INVALID CREDENTIALS
# ============================================================================

def test_invalid_credentials():
    print_header("TEST 6: INVALID CREDENTIALS")
    
    print_info("Testing with wrong password")
    
    try:
        response = requests.post('http://127.0.0.1:8000/api/login/', json={
            'identifier': '081234567890',
            'password': 'wrongpassword'
        })
        
        if response.status_code == 401:
            print_success(f"Correctly rejected invalid credentials")
            print_info(f"Error message: {response.json().get('error')}")
            return True
        else:
            print_error(f"Should return 401, got {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

# ============================================================================
# MAIN
# ============================================================================

def run_tests():
    print_header("PHONE NUMBER LOGIN - TESTING")
    
    results = {
        'passed': 0,
        'failed': 0,
        'total': 6
    }
    
    # Check backend running
    try:
        response = requests.get('http://127.0.0.1:8000/api/')
        if response.status_code != 200:
            print_error("Backend not running on port 8000!")
            print_info("Run: python manage.py runserver")
            return
    except:
        print_error("Cannot connect to backend!")
        print_info("Run: python manage.py runserver")
        return
    
    print_success("Backend is running\n")
    
    # Run tests
    tests = [
        ("Login with Email", test_login_with_email),
        ("Login with Phone 08...", test_login_with_phone_08),
        ("Login with Phone 62...", test_login_with_phone_62),
        ("Login with Phone +62...", test_login_with_phone_plus),
        ("Login with Formatted Phone", test_login_with_formatted_phone),
        ("Invalid Credentials", test_invalid_credentials),
    ]
    
    for name, test_func in tests:
        if test_func():
            results['passed'] += 1
        else:
            results['failed'] += 1
    
    # Summary
    print_header("TEST SUMMARY")
    
    print(f"Total Tests:  {results['total']}")
    print(f"{GREEN}Passed:       {results['passed']}{RESET}")
    print(f"{RED}Failed:       {results['failed']}{RESET}")
    
    percentage = (results['passed'] / results['total']) * 100
    print(f"\nSuccess Rate: {percentage:.1f}%")
    
    if percentage == 100:
        print(f"\n{GREEN}{'='*70}")
        print("🎉 ALL TESTS PASSED! Phone login working perfectly!")
        print(f"{'='*70}{RESET}\n")
    else:
        print(f"\n{YELLOW}{'='*70}")
        print(f"⚠️  {results['failed']} tests failed. Check errors above.")
        print(f"{'='*70}{RESET}\n")

if __name__ == '__main__':
    run_tests()
