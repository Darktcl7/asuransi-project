# policies/admin.py
from django.contrib import admin
from .models import PolicyTier, DevicePackage, Policy

admin.site.register(PolicyTier)
admin.site.register(DevicePackage)
admin.site.register(Policy)