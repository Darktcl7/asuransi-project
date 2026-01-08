from django.db import models
from django.conf import settings
import uuid

class Notification(models.Model):
    """
    Notification model untuk in-app notifications
    Dibuat otomatis saat ada aktivitas (claim status change, dll.)
    """
    NOTIFICATION_TYPES = [
        ('claim_submitted', 'Claim Submitted'),
        ('claim_approved', 'Claim Approved'),
        ('claim_rejected', 'Claim Rejected'),
        ('claim_in_progress', 'Claim In Progress'),
        ('claim_completed', 'Claim Completed'),
        ('policy_expiring', 'Policy Expiring'),
        ('wallet_topup', 'Wallet Top-up'),
        ('system', 'System Notification'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    notification_type = models.CharField(max_length=50, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=255)
    message = models.TextField()
    
    # Optional: Link to related object
    related_claim_id = models.UUIDField(null=True, blank=True)
    related_policy_id = models.UUIDField(null=True, blank=True)
    
    # Status
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_read']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.title}"
    
    def mark_as_read(self):
        """Mark notification as read"""
        if not self.is_read:
            from django.utils import timezone
            self.is_read = True
            self.read_at = timezone.now()
            self.save()
