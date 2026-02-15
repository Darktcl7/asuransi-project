# -*- coding: utf-8 -*-
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from users.models import User

user = User.objects.get(email='superadmin@smile.com')
print(f"Email: {user.email}")
print(f"Role: {user.role}")
print(f"is_staff: {user.is_staff}")
print(f"is_superuser: {user.is_superuser}")
print(f"is_active: {user.is_active}")
print(f"Store: {user.store}")
