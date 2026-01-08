# wallet/models.py

import uuid
from django.db import models
from django.conf import settings
from decimal import Decimal

# Ambil model User yang sudah kita buat
User = settings.AUTH_USER_MODEL

class Wallet(models.Model):
    # UUID primary key, sama seperti User
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relasi Satu-ke-Satu dengan User. 
    # Setiap User PASTI punya satu Wallet.
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    
    # Kita pakai DecimalField untuk presisi keuangan
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0.00)
    total_topup = models.DecimalField(max_digits=15, decimal_places=2, default=0.00)
    total_spent = models.DecimalField(max_digits=15, decimal_places=2, default=0.00)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'wallet' # Sesuai ERD Anda
        indexes = [
            models.Index(fields=['user']),  # Fast user wallet lookup
            models.Index(fields=['-balance']),  # Sort by balance
        ]

    def __str__(self):
        return f"Wallet {self.user.email} - Rp {self.balance}"

class TopUpTransaction(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('success', 'Success'),
        ('completed', 'Completed'),  # For admin manual top-ups
        ('failed', 'Failed'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.PROTECT) # Lindungi transaksi
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    
    payment_method = models.CharField(max_length=50)
    transaction_id = models.CharField(max_length=100, unique=True)
    payment_proof_url = models.TextField(null=True, blank=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    created_at = models.DateTimeField(auto_now_add=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    verified_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='verified_topups'
    )

    class Meta:
        db_table = 'topup_transactions' # Sesuai ERD Anda
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', '-created_at']),  # Fast filter by status
            models.Index(fields=['user', 'status']),  # Fast user topups lookup
            models.Index(fields=['transaction_id']),  # Fast transaction search
            models.Index(fields=['-created_at']),  # Fast date sorting
        ]

class WalletHistory(models.Model):
    TRANSACTION_TYPES = [
        ('topup', 'Top Up'),
        ('deduction', 'Deduction'), # (Potongan beli polis / klaim)
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='history')
    
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    
    balance_before = models.DecimalField(max_digits=15, decimal_places=2)
    balance_after = models.DecimalField(max_digits=15, decimal_places=2)
    
    description = models.CharField(max_length=255)
    
    # Untuk referensi ke Polis atau Klaim
    reference_id = models.UUIDField(null=True, blank=True)
    reference_type = models.CharField(max_length=50, null=True, blank=True) # 'policy' atau 'claim'
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'wallet_history'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['wallet', '-created_at']),  # Fast wallet history lookup
            models.Index(fields=['transaction_type', '-created_at']),  # Fast filter by type
            models.Index(fields=['-created_at']),  # Fast date sorting
            models.Index(fields=['reference_id']),  # Fast reference lookup
        ]