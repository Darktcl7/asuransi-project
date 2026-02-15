"""
Script untuk membersihkan data test customers
Menggunakan raw SQL dengan try-except untuk handle missing tables
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from django.db.models import Count
from django.db import connection
from users.models import User
from stores.models import Store

def clean_related_data(user_ids):
    """Clean all related data for users using raw SQL with error handling"""
    if not user_ids:
        return
    
    ids_str = ','.join([f"'{str(uid)}'" for uid in user_ids])
    
    # Tables that might have user references
    tables_to_clean = [
        'users_passwordreset',
        'notifications',
        'topup_transactions',
        'wallets',
        'authtoken_token',
        'wallet_histories',
    ]
    
    with connection.cursor() as cursor:
        for table in tables_to_clean:
            try:
                cursor.execute(f"DELETE FROM {table} WHERE user_id IN ({ids_str})")
                print(f"   ✅ Cleaned {table}")
            except Exception as e:
                print(f"   ⏭️ Skip {table}: {str(e)[:50]}")

def clean_test_customers():
    print("=" * 60)
    print("🧹 Cleaning Test Customers Data")
    print("=" * 60)
    
    # Keep these important users (admin accounts)
    protected_emails = [
        'superadmin@smile.com',
        'chluik277@gmail.com',
        'demo@smile.com',
        'admin@smile.com',
    ]
    
    # Find customers without any data
    print("\n🔍 Finding customers without policies/claims...")
    
    customers_without_data = User.objects.filter(
        role='customer'
    ).exclude(
        email__in=protected_emails
    ).annotate(
        policy_count=Count('policy'),
        claim_count=Count('claim'),
    ).filter(
        policy_count=0,
        claim_count=0,
    ).order_by('-date_joined')
    
    total = customers_without_data.count()
    print(f"   Found {total} customers with NO policy/claim data")
    
    if total > 20:
        # Keep 20, delete the rest
        to_keep = 20
        to_delete_ids = list(customers_without_data.values_list('id', flat=True)[to_keep:])
        
        print(f"\n   Cleaning related data for {len(to_delete_ids)} users...")
        clean_related_data(to_delete_ids)
        
        print(f"\n   Deleting {len(to_delete_ids)} customers...")
        deleted, _ = User.objects.filter(id__in=to_delete_ids).delete()
        print(f"   ✅ Deleted {deleted} customers, kept {to_keep}")
    else:
        print(f"   ✅ Only {total} customers without data, no deletion needed")
    
    print("\n" + "=" * 60)
    print("📊 Current Summary:")
    print("=" * 60)
    
    # Count by role
    print("\n   By Role:")
    for role in ['customer', 'store_admin', 'store_staff', 'super_admin']:
        count = User.objects.filter(role=role).count()
        print(f"      {role}: {count}")
    
    # Users with policy data
    with_policy = User.objects.filter(role='customer').annotate(
        pc=Count('policy')
    ).filter(pc__gt=0).count()
    print(f"\n   📋 Customers WITH policies: {with_policy}")
    
    # Total users
    total = User.objects.count()
    print(f"   📊 Total Users: {total}")

if __name__ == '__main__':
    clean_test_customers()
