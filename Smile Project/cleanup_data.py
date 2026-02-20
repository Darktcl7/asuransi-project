# cleanup_data.py
import os
import django
import sys

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import Claim, ClaimPhoto
from policies.models import Policy
from notifications.models import Notification
from stores.activity_log import ActivityLog
from wallet.models import TopUpTransaction, WalletHistory, Wallet

def cleanup():
    print("--- Starting Full Data Cleanup ---")
    
    # 1. Delete Claims & Photos
    print("Deleting Claims and Photos...")
    ClaimPhoto.objects.all().delete()
    Claim.objects.all().delete()
    
    # 2. Delete Policies
    print("Deleting Policies...")
    Policy.objects.all().delete()
    
    # 3. Delete Notifications
    print("Deleting Notifications...")
    Notification.objects.all().delete()
    
    # 4. Delete Activity Logs
    print("Deleting Activity Logs (Dashboard Data)...")
    ActivityLog.objects.all().delete()
    
    # 5. Delete Wallet History & Transactions
    print("Deleting Wallet Transactions and History...")
    WalletHistory.objects.all().delete()
    TopUpTransaction.objects.all().delete()
    
    # 6. Reset Wallet Balances
    print("Resetting all User Wallet balances to 0...")
    Wallet.objects.all().update(
        balance=0.00,
        total_topup=0.00,
        total_spent=0.00
    )
    
    print("--- Cleanup Finished Successfully ---")
    print("Semua data klaim, polis, notifikasi, log aktivitas, dan saldo wallet telah dibersihkan.")

if __name__ == "__main__":
    cleanup()
