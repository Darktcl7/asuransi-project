import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from defender.models import AccessAttempt

# Clear all blocks
count = AccessAttempt.objects.all().count()
AccessAttempt.objects.all().delete()

print(f"=== DEFENDER BLOCKS CLEARED ===")
print(f"Cleared {count} failed login attempts")
print(f"You can login again now!")
print(f"\nCredentials:")
print(f"Email: chluik277@gmail.com")
print(f"Password: admin123")
