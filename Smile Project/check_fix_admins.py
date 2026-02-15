# -*- coding: utf-8 -*-
"""
Script untuk mengecek dan memperbaiki role store admin
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User
from stores.models import Store

def check_users():
    print("=" * 60)
    print("CHECKING STORE ADMIN USERS")
    print("=" * 60)
    
    emails = ['chluik277@gmail.com', 'demo@smile.com']
    
    for email in emails:
        try:
            user = User.objects.get(email=email)
            print(f"\n[OK] Found: {email}")
            print(f"   Role: {user.role}")
            print(f"   Store: {user.store.name if user.store else 'None'}")
            print(f"   Active: {user.is_active}")
        except User.DoesNotExist:
            print(f"\n[NOT FOUND]: {email}")

def list_all_admins():
    print("\n" + "=" * 60)
    print("ALL ADMIN USERS (non-customer)")
    print("=" * 60)
    
    admins = User.objects.filter(role__in=['super_admin', 'store_admin', 'store_staff'])
    
    if admins.exists():
        for user in admins:
            print(f"\nEmail: {user.email}")
            print(f"   Role: {user.role}")
            print(f"   Store: {user.store.name if user.store else 'N/A'}")
            print(f"   Active: {user.is_active}")
    else:
        print("\n[!] No admin users found!")

def fix_store_admins():
    print("\n" + "=" * 60)
    print("FIXING STORE ADMIN ROLES")
    print("=" * 60)
    
    # Get first store for assignment
    store = Store.objects.filter(is_active=True).first()
    
    admin_emails = ['chluik277@gmail.com', 'demo@smile.com']
    
    for email in admin_emails:
        try:
            user = User.objects.get(email=email)
            if user.role != 'store_admin':
                old_role = user.role
                user.role = 'store_admin'
                if store and not user.store:
                    user.store = store
                user.save()
                print(f"\n[FIXED]: {email}")
                print(f"   Old role: {old_role} -> New role: store_admin")
                print(f"   Store: {user.store.name if user.store else 'N/A'}")
            else:
                print(f"\n[OK] Already correct: {email} is store_admin")
        except User.DoesNotExist:
            print(f"\n[NOT FOUND]: {email}")

if __name__ == '__main__':
    check_users()
    list_all_admins()
    
    # Fix
    print("\n" + "=" * 60)
    fix_store_admins()
    print("\n" + "=" * 60)
    print("DONE!")
