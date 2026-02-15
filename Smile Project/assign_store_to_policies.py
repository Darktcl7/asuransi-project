"""
Script untuk mengassign store ke policy yang sudah ada.
Jalankan di terminal yang sudah aktif virtualenv:
python assign_store_to_policies.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import Policy
from stores.models import Store

# Ambil store pertama sebagai default (atau sesuaikan)
default_store = Store.objects.filter(is_active=True).first()

if not default_store:
    print("Tidak ada store aktif. Buat store terlebih dahulu.")
else:
    # Update semua policy yang belum punya store
    updated = Policy.objects.filter(store__isnull=True).update(store=default_store)
    print(f"Updated {updated} policies dengan store: {default_store.name} ({default_store.registration_code})")
    
    # Tampilkan summary
    for store in Store.objects.filter(is_active=True):
        count = Policy.objects.filter(store=store).count()
        print(f"  - {store.name}: {count} policies")
