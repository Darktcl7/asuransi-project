# policies/models.py

import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

User = settings.AUTH_USER_MODEL

class PolicyTier(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tier_name = models.CharField(max_length=50, unique=True) # Standar, Gold, Premium

    # Harga device
    min_price = models.DecimalField(max_digits=15, decimal_places=2)
    max_price = models.DecimalField(max_digits=15, decimal_places=2)

    # Biaya
    policy_price = models.DecimalField(max_digits=15, decimal_places=2) # Harga polis (150rb, etc)
    claim_deduction_percent = models.DecimalField(max_digits=5, decimal_places=2, default=10.00)

    # Aturan
    policy_duration_days = models.IntegerField(default=365) # Durasi polis (1 tahun)
    max_claims_per_year = models.IntegerField(default=3)

    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'policy_tiers' # Sesuai ERD

    def __str__(self):
        return self.tier_name

class DevicePackage(models.Model):
    CATEGORY_CHOICES = [
        ('handphone', 'Handphone'),
        ('elektronik', 'Elektronik'),
        ('laptop', 'Laptop'),
        ('printer', 'Printer'),
        ('sepeda_listrik', 'Sepeda Listrik'),
        ('lainnya', 'Lainnya'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    device_category = models.CharField(
        max_length=50, 
        choices=CATEGORY_CHOICES, 
        default='handphone',
        help_text='Kategori device (Handphone, Elektronik, dll)'
    )
    device_brand = models.CharField(max_length=100) # Apple, Samsung
    device_model = models.CharField(max_length=100) # iPhone 15 Pro
    device_variant = models.CharField(max_length=100, null=True, blank=True) # 8+256, 12+512
    device_color = models.CharField(max_length=50, null=True, blank=True) # Hitam, Putih, Biru
    device_value = models.DecimalField(max_digits=15, decimal_places=2) # Harga pasaran
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'device_packages' # Sesuai ERD

    def __str__(self):
        return f"{self.device_brand} {self.device_model}"

class Policy(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),   # Menunggu verifikasi admin
        ('active', 'Active'),     # Aktif dan bisa klaim
        ('expired', 'Expired'),   # Sudah lewat masa berlaku
        ('rejected', 'Rejected'), # Ditolak admin
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    policy_number = models.CharField(max_length=50, unique=True)

    user = models.ForeignKey(User, on_delete=models.PROTECT) # Lindungi polis
    tier = models.ForeignKey(PolicyTier, on_delete=models.PROTECT)
    device_package = models.ForeignKey(DevicePackage, on_delete=models.PROTECT)
    
    # Toko yang menjual polis ini
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='policies',
        help_text="Toko yang menjual polis ini"
    )

    imei_number = models.CharField(max_length=20, unique=True)
    purchase_price = models.DecimalField(max_digits=15, decimal_places=2) # Harga beli user
    policy_price = models.DecimalField(max_digits=15, decimal_places=2) # Harga polis (ter-copy dari tier)
    
    # Policy balance - saldo per policy (sesuai harga HP)
    policy_balance = models.DecimalField(
        max_digits=15, 
        decimal_places=2, 
        default=0,
        help_text="Saldo policy untuk claim (sesuai harga HP)"
    )

    activation_date = models.DateField(null=True, blank=True)
    expiry_date = models.DateField(null=True, blank=True)

    claims_used = models.IntegerField(default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'policies' # Sesuai ERD
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['imei_number']),
            models.Index(fields=['expiry_date', 'status']),  # For auto-expire queries
            models.Index(fields=['store', 'status']),  # ✅ For store admin filtering
            models.Index(fields=['store', '-created_at']),  # ✅ For store + date sorting
            models.Index(fields=['-created_at']),  # ✅ For date sorting
            models.Index(fields=['policy_number']),  # ✅ For policy number search
        ]

    def __str__(self):
        return self.policy_number
    
    def is_expired(self):
        """Check if policy has expired (passed 1 year)"""
        if not self.expiry_date:
            return False
        return timezone.now().date() > self.expiry_date
    
    def can_claim(self):
        """Check if policy can be used for claims"""
        return (
            self.status == 'active' and 
            not self.is_expired()
        )