import os, sys, django
os.environ['DJANGO_SETTINGS_MODULE'] = 'config.settings'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User

print("=" * 60)
print("5 USER TERBARU:")
print("=" * 60)
for u in User.objects.order_by('-date_joined')[:5]:
    print(f"{u.email:35} | {u.first_name:10} | store_id={u.store_id}")
