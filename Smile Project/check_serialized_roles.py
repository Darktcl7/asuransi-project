import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from users.serializers import UserSerializer

admin_emails = ['admin@smile.com', 'superadmin@smile.com', 'chluik277@gmail.com']
users = User.objects.filter(email__in=admin_emails)

for u in users:
    serializer = UserSerializer(u)
    data = serializer.data
    print(f"User: {u.email}")
    print(f"  Role in DB: {u.role}")
    print(f"  Role in Serializer: {data.get('role')}")
    print(f"  Is Superuser: {u.is_superuser}")
    print("-" * 20)
