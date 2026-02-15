# stores/admin.py

from django.contrib import admin
from .models import Store


@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = ['code', 'name', 'city', 'phone', 'is_active', 'created_at']
    list_filter = ['is_active', 'province', 'city']
    search_fields = ['code', 'name', 'city', 'address']
    ordering = ['name']
    
    fieldsets = (
        ('Informasi Toko', {
            'fields': ('code', 'name', 'is_active')
        }),
        ('Alamat', {
            'fields': ('address', 'city', 'province', 'postal_code')
        }),
        ('Kontak', {
            'fields': ('phone', 'email')
        }),
    )
