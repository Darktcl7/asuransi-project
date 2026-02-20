# delete_customers.py
import os
import django
import sys

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

def delete_customers():
    print("--- Starting Customer Data Deletion ---")
    
    # Get customers
    customers = User.objects.filter(role='customer')
    count = customers.count()
    
    if count == 0:
        print("Tidak ada data user customer untuk dihapus.")
        return

    print(f"Menghapus {count} user customer...")
    
    # Delete customers
    # Note: Foreign keys like Wallet, etc. should be handled by on_delete=models.CASCADE
    customers.delete()
    
    print(f"--- Successfully deleted {count} customer users ---")

if __name__ == "__main__":
    delete_customers()
