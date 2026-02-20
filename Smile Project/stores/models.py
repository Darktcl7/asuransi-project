# stores/models.py

import uuid
import random
import string
from django.db import models


class Store(models.Model):
    """
    Representasi toko/cabang.
    Setiap toko memiliki admin dan customer sendiri.
    """
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    
    # Informasi Toko
    code = models.CharField(
        max_length=20, 
        unique=True,
        help_text="Kode unik toko, contoh: SPC-OSP"
    )
    name = models.CharField(
        max_length=100,
        help_text="Nama toko, contoh: SPC Oesapa"
    )
    
    # Registration Code - 6 character code for customers to register
    registration_code = models.CharField(
        max_length=10,
        unique=True,
        blank=True,
        help_text="Kode registrasi untuk customer (contoh: OSP123)"
    )
    
    # Alamat
    address = models.TextField(blank=True)
    city = models.CharField(max_length=50, blank=True)
    province = models.CharField(max_length=50, blank=True)
    postal_code = models.CharField(max_length=10, blank=True)
    
    # Kontak
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    
    # Status
    is_active = models.BooleanField(default=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'stores'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.code} - {self.name}"
    
    def save(self, *args, **kwargs):
        # Auto-generate registration code if not set
        if not self.registration_code:
            self.registration_code = self.generate_registration_code()
        super().save(*args, **kwargs)
    
    @staticmethod
    def generate_registration_code():
        """Generate a unique 6-character registration code"""
        while True:
            # Format: 3 letters + 3 numbers (e.g., OSP123)
            letters = ''.join(random.choices(string.ascii_uppercase, k=3))
            numbers = ''.join(random.choices(string.digits, k=3))
            code = f"{letters}{numbers}"
            
            if not Store.objects.filter(registration_code=code).exists():
                return code
    
    @classmethod
    def get_by_registration_code(cls, reg_code):
        """Find store by registration code OR store code (case-insensitive)"""
        if not reg_code:
            return None
        
        reg_code = reg_code.strip()
        try:
            # First try registration_code
            return cls.objects.get(
                models.Q(registration_code__iexact=reg_code) |
                models.Q(code__iexact=reg_code),
                is_active=True
            )
        except cls.DoesNotExist:
            return None
