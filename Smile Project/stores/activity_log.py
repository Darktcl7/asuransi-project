"""
Activity Log Model
Untuk tracking semua aktivitas di sistem
"""
import uuid
from django.db import models
from django.conf import settings


class ActivityLog(models.Model):
    """
    Log semua aktivitas penting di sistem.
    Digunakan untuk audit trail dan monitoring.
    """
    
    ACTION_CHOICES = [
        # Authentication
        ('LOGIN', 'User Login'),
        ('LOGOUT', 'User Logout'),
        ('LOGIN_FAILED', 'Login Failed'),
        
        # User Management
        ('USER_CREATE', 'Create User'),
        ('USER_UPDATE', 'Update User'),
        ('USER_DELETE', 'Delete User'),
        ('USER_VERIFY', 'Verify User'),
        ('USER_ASSIGN_STORE', 'Assign User to Store'),
        
        # Policy
        ('POLICY_CREATE', 'Create Policy'),
        ('POLICY_UPDATE', 'Update Policy'),
        ('POLICY_ACTIVATE', 'Activate Policy'),
        ('POLICY_EXPIRE', 'Expire Policy'),
        
        # Claims
        # Claims
        ('CLAIM_CREATE', 'Create Claim'),
        ('CLAIM_UPDATE', 'Update Claim'),  # Added
        ('CLAIM_APPROVE', 'Approve Claim'),
        ('CLAIM_REJECT', 'Reject Claim'),
        ('CLAIM_COMPLETE', 'Complete Claim'),
        ('CLAIM_ADMIN_CREATE', 'Admin Create Claim'),

        # Store Management
        ('STORE_CREATE', 'Create Store'),
        ('STORE_UPDATE', 'Update Store'),
        ('STORE_DEACTIVATE', 'Deactivate Store'),
        ('STORE_DELETE_PERMANENT', 'Delete Store Permanent'),
        ('STORE_RESET', 'Reset Store Data'),
        
        # Store
        ('STORE_CREATE', 'Create Store'),
        ('STORE_UPDATE', 'Update Store'),
        ('STORE_DEACTIVATE', 'Deactivate Store'),
        
        # Device & Policy Tier
        ('DEVICE_CREATE', 'Create Device'),
        ('DEVICE_UPDATE', 'Update Device'),
        ('TIER_UPDATE', 'Update Policy Tier'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Who
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='activity_logs'
    )
    user_email = models.EmailField(help_text="Snapshot email saat log dibuat")
    user_role = models.CharField(max_length=20)
    
    # Where
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='activity_logs'
    )
    store_code = models.CharField(max_length=20, blank=True)
    
    # What
    action = models.CharField(max_length=30, choices=ACTION_CHOICES)
    target_model = models.CharField(
        max_length=50,
        help_text="Model yang diakses: User, Policy, Claim, etc"
    )
    target_id = models.CharField(
        max_length=50,
        blank=True,
        help_text="ID object yang diakses"
    )
    
    # Details
    description = models.TextField(blank=True)
    extra_data = models.JSONField(
        null=True, 
        blank=True,
        help_text="Data tambahan"
    )
    
    # Client Info
    ip_address = models.GenericIPAddressField(null=True)
    user_agent = models.TextField(blank=True)
    
    # Timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'activity_logs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['store', '-created_at']),
            models.Index(fields=['action', '-created_at']),
            models.Index(fields=['-created_at']),
        ]
    
    def __str__(self):
        return f"{self.user_email} - {self.action} - {self.created_at}"
    
    @classmethod
    def log(cls, request, action, target_model, target_id='', description='', extra_data=None):
        """
        Helper method untuk membuat log
        """
        user = request.user if request.user.is_authenticated else None
        
        return cls.objects.create(
            user=user,
            user_email=user.email if user else 'anonymous',
            user_role=getattr(user, 'role', 'unknown') if user else 'anonymous',
            store=getattr(user, 'store', None) if user else None,
            store_code=user.store.code if user and user.store else '',
            action=action,
            target_model=target_model,
            target_id=str(target_id),
            description=description,
            extra_data=extra_data,
            ip_address=cls._get_client_ip(request),
            user_agent=request.META.get('HTTP_USER_AGENT', '')[:500],
        )
    
    @staticmethod
    def _get_client_ip(request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
