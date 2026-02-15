# claims/models.py

import uuid
from django.db import models
from django.conf import settings
from policies.models import Policy

User = settings.AUTH_USER_MODEL

class Claim(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),       # Menunggu review admin
        ('approved', 'Approved'),     # Disetujui, menunggu pengerjaan
        ('in_progress', 'In Progress'), # Sedang dikerjakan
        ('completed', 'Completed'),   # Selesai dikerjakan
        ('rejected', 'Rejected'),     # Ditolak
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    claim_number = models.CharField(max_length=50, unique=True)

    policy = models.ForeignKey(Policy, on_delete=models.PROTECT)
    user = models.ForeignKey(User, on_delete=models.PROTECT)

    damage_type = models.CharField(max_length=100) # Misal: Layar Pecah
    damage_description = models.TextField()
    incident_date = models.DateField()

    claim_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0) # Biaya perbaikan (set by admin)
    wallet_deducted = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True) # Saldo yg dipotong

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

    created_at = models.DateTimeField(auto_now_add=True)

    # Untuk admin
    processed_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='processed_claims'
    )
    processed_date = models.DateTimeField(null=True, blank=True)
    admin_notes = models.TextField(null=True, blank=True)
    
    # WhatsApp for payment notification (admin sends proof via WhatsApp)
    whatsapp_number = models.CharField(max_length=20, null=True, blank=True, help_text="User WhatsApp number for payment notification")
    payment_date = models.DateTimeField(null=True, blank=True)
    payment_notes = models.TextField(null=True, blank=True, help_text="Payment details/notes")
    
    # Store reference for multi-store filtering (denormalized for performance)
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='claims',
        help_text="Store where this claim was created (from user's store)"
    )

    class Meta:
        db_table = 'claims' # Sesuai ERD
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', '-created_at']),  # Fast filter by status + date
            models.Index(fields=['user', 'status']),  # Fast user claims lookup
            models.Index(fields=['policy']),  # Fast policy claims lookup
            models.Index(fields=['claim_number']),  # Fast claim number search
            models.Index(fields=['-created_at']),  # Fast date sorting
            models.Index(fields=['processed_by']),  # Fast admin claims lookup
            models.Index(fields=['store', '-created_at']),  # Fast store filter
        ]

    def __str__(self):
        return self.claim_number


class ClaimPhoto(models.Model):
    """Model to store claim damage photos"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    claim = models.ForeignKey(Claim, on_delete=models.CASCADE, related_name='photos')
    photo = models.ImageField(upload_to='claim_photos/%Y/%m/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'claim_photos'
        ordering = ['uploaded_at']
    
    def __str__(self):
        return f"Photo for {self.claim.claim_number}"