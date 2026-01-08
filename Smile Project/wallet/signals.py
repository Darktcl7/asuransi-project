# wallet/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings
from .models import Wallet

User = settings.AUTH_USER_MODEL

@receiver(post_save, sender=User)
def create_user_wallet(sender, instance, created, **kwargs):
    """
    Otomatis buat Wallet saat User baru dibuat.
    """
    if created:
        Wallet.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_wallet(sender, instance, **kwargs):
    """
    Pastikan wallet selalu ada saat user di-save.
    """
    if not hasattr(instance, 'wallet'):
        Wallet.objects.create(user=instance)
