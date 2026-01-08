from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from claims.models import Claim
from .models import Notification
import logging

logger = logging.getLogger(__name__)

@receiver(pre_save, sender=Claim)
def track_claim_status_change(sender, instance, **kwargs):
    """Track old status before save"""
    if instance.pk:
        try:
            old_instance = Claim.objects.get(pk=instance.pk)
            instance._old_status = old_instance.status
        except Claim.DoesNotExist:
            instance._old_status = None
    else:
        instance._old_status = None

@receiver(post_save, sender=Claim)
def create_claim_notification(sender, instance, created, **kwargs):
    """
    Auto-create notification when claim status changes
    """
    try:
        if created:
            # New claim submitted
            Notification.objects.create(
                user=instance.user,
                notification_type='claim_submitted',
                title='Klaim Berhasil Diajukan',
                message=f'Klaim Anda untuk {instance.policy.device_package} telah diterima dan sedang diproses. Nomor klaim: {instance.claim_number}',
                related_claim_id=instance.id
            )
            logger.info(f"Notification created: claim submitted for {instance.claim_number}")
        else:
            # Status changed
            old_status = getattr(instance, '_old_status', None)
            if old_status != instance.status:
                notification_data = {
                    'approved': {
                        'type': 'claim_approved',
                        'title': 'Klaim Disetujui! ✅',
                        'message': f'Klaim Anda telah DISETUJUI! Nomor klaim: {instance.claim_number}. Biaya: Rp {instance.claim_amount:,.0f}',
                    },
                    'in_progress': {
                        'type': 'claim_in_progress',
                        'title': 'Klaim Sedang Diproses 🔧',
                        'message': f'Klaim Anda sedang dalam proses perbaikan. Nomor klaim: {instance.claim_number}',
                    },
                    'completed': {
                        'type': 'claim_completed',
                        'title': 'Klaim Selesai! 🎉',
                        'message': f'HP Anda sudah selesai diperbaiki! Nomor klaim: {instance.claim_number}. Silakan ambil device Anda.',
                    },
                    'rejected': {
                        'type': 'claim_rejected',
                        'title': 'Klaim Ditolak ❌',
                        'message': f'Klaim Anda ditolak. Nomor klaim: {instance.claim_number}. Silakan hubungi customer service untuk informasi lebih lanjut.',
                    },
                }
                
                notif_config = notification_data.get(instance.status)
                if notif_config:
                    Notification.objects.create(
                        user=instance.user,
                        notification_type=notif_config['type'],
                        title=notif_config['title'],
                        message=notif_config['message'],
                        related_claim_id=instance.id
                    )
                    logger.info(f"Notification created: {notif_config['type']} for {instance.claim_number}")
    except Exception as e:
        logger.error(f"Failed to create notification: {str(e)}")
