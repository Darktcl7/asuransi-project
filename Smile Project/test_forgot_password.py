#!/usr/bin/env python
"""
Test Forgot Password Feature
Test email OTP flow
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
    print(f"{GREEN}[OK] {message}{RESET}")

def print_error(message):
    print(f"{RED}[ERROR] {message}{RESET}")

def print_info(message):
    print(f"  [INFO] {message}")

def print_warning(message):
    print(f"{YELLOW}[WARNING] {message}{RESET}")

# ============================================================================
# TEST FORGOT PASSWORD
# ============================================================================

def test_forgot_password():
    print_header("FORGOT PASSWORD - EMAIL OTP TEST")
    
    # Check backend running
    try:
        response = requests.get('http://127.0.0.1:8000/api/', timeout=5)
        # Backend is running if we get ANY response (200, 401, 403, etc)
        if response.status_code not in [200, 401, 403]:
            print_error("Backend returned unexpected status!")
            print_info("Please check Django server")
            return False
    except requests.exceptions.ConnectionError:
        print_error("Cannot connect to backend!")
        print_info("Please run: python manage.py runserver")
        return False
    except requests.exceptions.Timeout:
        print_error("Backend connection timeout!")
        print_info("Please check Django server")
        return False
    except Exception as e:
        print_error(f"Connection error: {e}")
        return False
    
    print_success("Backend is running")
    
    # Get test user
    test_user = User.objects.filter(email__contains='test').first()
    if not test_user:
        test_user = User.objects.first()
    
    if not test_user:
        print_error("No users in database!")
        print_info("Create a user first: python manage.py createsuperuser")
        return False
    
    print_info(f"Testing with user: {test_user.email}")
    
    # ========================================================================
    # STEP 1: Request OTP
    # ========================================================================
    
    print(f"\n{YELLOW}--- STEP 1: Request OTP ---{RESET}\n")
    
    try:
        response = requests.post(
            'http://127.0.0.1:8000/api/password-reset/request/',
            json={'identifier': test_user.email}
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("OTP request successful!")
            print_info(f"Method: {data.get('method')}")
            print_info(f"Sent to: {data.get('sent_to')}")
            print_info(f"Expires in: {data.get('expires_in')} seconds")
            print_warning("CHECK YOUR TERMINAL where Django is running!")
            print_warning("The email will be printed in the console (console backend)")
        else:
            print_error(f"Request failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False
    
    # ========================================================================
    # STEP 2: Get OTP from database (for testing)
    # ========================================================================
    
    print(f"\n{YELLOW}--- STEP 2: Retrieve OTP from Database ---{RESET}\n")
    
    from users.models_password_reset import PasswordReset
    
    reset = PasswordReset.objects.filter(
        user=test_user,
        is_used=False
    ).order_by('-created_at').first()
    
    if reset:
        otp_code = reset.otp_code
        print_success(f"OTP Code from database: {otp_code}")
        print_info(f"Created at: {reset.created_at}")
        print_info(f"Expires at: {reset.expires_at}")
        print_info(f"Attempts: {reset.attempts}/{reset.max_attempts}")
    else:
        print_error("No OTP found in database!")
        return False
    
    # ========================================================================
    # STEP 3: Verify OTP
    # ========================================================================
    
    print(f"\n{YELLOW}--- STEP 3: Verify OTP ---{RESET}\n")
    
    try:
        response = requests.post(
            'http://127.0.0.1:8000/api/password-reset/verify-otp/',
            json={
                'identifier': test_user.email,
                'otp_code': otp_code
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("OTP verified successfully!")
            print_info(f"Message: {data.get('message')}")
            print_info(f"Reset Token: {data.get('reset_token')[:20]}...")
            reset_token = data.get('reset_token')
        else:
            print_error(f"Verification failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False
    
    # ========================================================================
    # STEP 4: Reset Password
    # ========================================================================
    
    print(f"\n{YELLOW}--- STEP 4: Reset Password ---{RESET}\n")
    
    new_password = 'newpassword123'
    
    try:
        response = requests.post(
            'http://127.0.0.1:8000/api/password-reset/reset/',
            json={
                'reset_token': reset_token,
                'new_password': new_password
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("Password reset successful!")
            print_info(f"Message: {data.get('message')}")
            print_info(f"Email: {data.get('email')}")
        else:
            print_error(f"Reset failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False
    
    # ========================================================================
    # STEP 5: Test Login with New Password
    # ========================================================================
    
    print(f"\n{YELLOW}--- STEP 5: Test Login with New Password ---{RESET}\n")
    
    try:
        response = requests.post(
            'http://127.0.0.1:8000/api/login/',
            json={
                'identifier': test_user.email,
                'password': new_password
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("Login successful with new password!")
            print_info(f"Token: {data.get('token')[:20]}...")
            print_info(f"User: {data.get('user', {}).get('full_name')}")
        else:
            print_error(f"Login failed: {response.json()}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False
    
    # ========================================================================
    # SUMMARY
    # ========================================================================
    
    print_header("TEST SUMMARY")
    
    print(f"{GREEN}[OK] Step 1: Request OTP - PASSED{RESET}")
    print(f"{GREEN}[OK] Step 2: Retrieve OTP - PASSED{RESET}")
    print(f"{GREEN}[OK] Step 3: Verify OTP - PASSED{RESET}")
    print(f"{GREEN}[OK] Step 4: Reset Password - PASSED{RESET}")
    print(f"{GREEN}[OK] Step 5: Login with New Password - PASSED{RESET}")
    
    print(f"\n{GREEN}{'='*70}")
    print("SUCCESS! ALL TESTS PASSED! Forgot Password feature is working!")
    print(f"{'='*70}{RESET}\n")
    
    print_warning("NOTE: Check Django terminal to see the email content!")
    
    # Reset password back to original for other tests
    print("\n" + BLUE + "="*70 + RESET)
    print(BLUE + "Resetting password back to original..." + RESET)
    test_user.set_password('leo123')
    test_user.save()
    print_success("Password reset back to: leo123")
    
    return True

if __name__ == '__main__':
    test_forgot_password()
