import os
import django
import sys

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from notifications.models import Notification

# List all users first
print("Available users:")
for u in User.objects.all()[:10]:
    print(f"  - {u.email} ({u.get_full_name()})")

# Try to get first user
user = User.objects.first()
if not user:
    print("No users found!")
    sys.exit(1)

print(f"\nUsing user: {user.email}")

# Check existing notifications
existing = Notification.objects.filter(user=user)
print(f"\nExisting notifications: {existing.count()}")

for notif in existing:
    print(f"  - {notif.title} (read: {notif.is_read})")

# Create test notification
notif = Notification.objects.create(
    user=user,
    notification_type='system',
    title='Test Notification',
    message='Ini adalah test notification untuk debugging badge.'
)
print(f"\nTest notification created: {notif.id}")

# Check unread count
unread = Notification.objects.filter(user=user, is_read=False).count()
print(f"\nUnread notifications: {unread}")
