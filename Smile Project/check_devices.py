import os, sys, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from policies.models import DevicePackage, PolicyTier

print("=" * 50)
print(f"Total devices: {DevicePackage.objects.count()}")
print(f"Active devices: {DevicePackage.objects.filter(is_active=True).count()}")
print()
print(f"Total tiers: {PolicyTier.objects.count()}")
print(f"Active tiers: {PolicyTier.objects.filter(is_active=True).count()}")
print("=" * 50)
