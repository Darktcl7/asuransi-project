# users/models.py

import uuid  # Import library uuid bawaan python
from django.db import models
from django.contrib.auth.models import AbstractUser
from .managers import CustomUserManager   

# password : adminsmile277
#Email: chluik277@gmail.com
#First name: Admin
#Last name: Smile

class User(AbstractUser):
    
    # Role choices for multi-store system
    ROLE_CHOICES = [
        ('customer', 'Customer'),           # Pelanggan biasa
        ('store_staff', 'Store Staff'),     # Staff toko (lihat saja)
        ('store_admin', 'Store Admin'),     # Admin toko (full CRUD toko sendiri)
        ('super_admin', 'Super Admin'),     # Admin pusat (full access semua)
    ]
    
    # Hapus field 'username' bawaan, kita akan pakai 'email'
    username = None 
    email = models.EmailField(unique=True) # Jadikan email unik

    # OPTIMASI JUTAAN DATA:
    # Menggunakan UUID sebagai Primary Key.
    # - Mencegah integer overflow (jika user lebih dari 2 miliar)
    # - Lebih baik untuk database terdistribusi (clustering/replication)
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    
    # Role untuk multi-store system
    role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default='customer',
        help_text="Role user dalam sistem"
    )
    
    # Relasi ke Toko (null untuk Super Admin dan Customer yang belum assign)
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='users',
        help_text="Toko tempat user bekerja/terdaftar"
    )
    
    # Field tambahan sesuai file structure.tsx Anda
    phone_number = models.CharField(max_length=20, unique=True, null=True, blank=True)
    ktp_number = models.CharField(max_length=16, unique=True, null=True, blank=True)
    ktp_photo_url = models.TextField(null=True, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    
    # Field ini sudah ada di AbstractUser:
    # full_name (first_name, last_name), is_active, created_at (date_joined)

    # Tentukan field 'email' sebagai field untuk login
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name'] # Field yang wajib diisi saat createsuperuser

    objects = CustomUserManager()   

    class Meta:
        db_table = 'users' # Menyamakan nama tabel dengan ERD Anda
        indexes = [
            models.Index(fields=['email']),  # Fast email lookup
            models.Index(fields=['phone_number']),  # Fast phone search
            models.Index(fields=['ktp_number']),  # Fast KTP search
            models.Index(fields=['is_verified', '-date_joined']),  # Filter verified users by date
            models.Index(fields=['is_active']),  # Fast active user filter
            models.Index(fields=['role']),  # Fast role filter
            models.Index(fields=['store', 'role']),  # Fast store + role filter
        ]

    def __str__(self):
        return self.email
    
    # ===== Helper Methods for Role Checking =====
    
    def is_super_admin(self):
        """Check if user is Super Admin"""
        return self.role == 'super_admin'
    
    def is_store_admin(self):
        """Check if user is Store Admin"""
        return self.role == 'store_admin'
    
    def is_store_staff(self):
        """Check if user is Store Staff"""
        return self.role == 'store_staff'
    
    def is_customer(self):
        """Check if user is Customer"""
        return self.role == 'customer'
    
    def can_access_store(self, store_id):
        """Check if user can access a specific store"""
        if self.is_super_admin():
            return True
        if self.store_id is None:
            return False
        return str(self.store_id) == str(store_id)
    
    def can_manage_store(self):
        """Check if user can manage store data"""
        return self.role in ['store_admin', 'super_admin']
    
    @property
    def full_name(self):
        """Return full name"""
        return f"{self.first_name} {self.last_name}".strip() or self.email
