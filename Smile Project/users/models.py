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
        ]

    def __str__(self):
        return self.email