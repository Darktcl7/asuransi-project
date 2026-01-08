"""
Password Reset Model
Store OTP codes for password reset
"""

from django.db import models
from django.contrib.auth import get_user_model
import uuid
import random
from datetime import timedelta
from django.utils import timezone

User = get_user_model()


class PasswordReset(models.Model):
    """
    Store password reset OTP codes
    
    Flow:
    1. User requests reset (email or phone)
    2. System generates 6-digit OTP
    3. OTP sent via email (or SMS if phone)
    4. User enters OTP + new password
    5. System verifies OTP and resets password
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_resets')
    
    # OTP code (6 digits)
    otp_code = models.CharField(max_length=6)
    
    # How was OTP sent
    METHOD_CHOICES = [
        ('email', 'Email'),
        ('sms', 'SMS'),
    ]
    method = models.CharField(max_length=10, choices=METHOD_CHOICES, default='email')
    
    # Where it was sent
    sent_to = models.CharField(max_length=255)  # email or phone number
    
    # Status
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    
    # Attempts tracking (prevent brute force)
    attempts = models.IntegerField(default=0)
    max_attempts = models.IntegerField(default=5)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['otp_code', 'is_used']),
        ]
    
    def __str__(self):
        return f"Reset for {self.user.email} via {self.method} ({self.otp_code})"
    
    def save(self, *args, **kwargs):
        # Auto-set expiry (10 minutes from now)
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(minutes=10)
        super().save(*args, **kwargs)
    
    def is_expired(self):
        """Check if OTP has expired"""
        return timezone.now() > self.expires_at
    
    def is_valid(self):
        """Check if OTP is valid (not used, not expired, attempts not exceeded)"""
        return (
            not self.is_used and 
            not self.is_expired() and 
            self.attempts < self.max_attempts
        )
    
    def increment_attempts(self):
        """Increment failed attempts"""
        self.attempts += 1
        self.save()
    
    def mark_as_used(self):
        """Mark OTP as used"""
        self.is_used = True
        self.used_at = timezone.now()
        self.save()
    
    @staticmethod
    def generate_otp():
        """Generate random 6-digit OTP"""
        return str(random.randint(100000, 999999))
    
    @classmethod
    def create_for_user(cls, user, method='email'):
        """
        Create new password reset OTP for user
        
        Args:
            user: User instance
            method: 'email' or 'sms'
        
        Returns:
            PasswordReset instance
        """
        # Invalidate old unused OTPs for this user
        cls.objects.filter(
            user=user, 
            is_used=False
        ).update(is_used=True, used_at=timezone.now())
        
        # Generate OTP
        otp_code = cls.generate_otp()
        
        # Determine where to send
        sent_to = user.email if method == 'email' else user.phone_number
        
        # Create new reset request
        reset = cls.objects.create(
            user=user,
            otp_code=otp_code,
            method=method,
            sent_to=sent_to
        )
        
        return reset
