"""
Management command to auto-expire policies that passed expiry_date

Usage:
    python manage.py expire_policies
    
Can be run via cron job daily:
    0 0 * * * cd /path/to/project && python manage.py expire_policies
"""

from django.core.management.base import BaseCommand
from django.utils import timezone
from policies.models import Policy

class Command(BaseCommand):
    help = 'Auto-expire policies that have passed their expiry date (1 year)'

    def handle(self, *args, **options):
        today = timezone.now().date()
        
        # Find active policies that passed expiry_date
        expired_policies = Policy.objects.filter(
            status='active',
            expiry_date__lt=today
        )
        
        count = expired_policies.count()
        
        if count == 0:
            self.stdout.write(self.style.SUCCESS('No policies to expire.'))
            return
        
        # Update status to expired
        updated = expired_policies.update(status='expired')
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully expired {updated} policies.'
            )
        )
        
        # Log expired policies
        for policy in expired_policies:
            self.stdout.write(
                f'  - {policy.policy_number} (User: {policy.user.email}, '
                f'Expired: {policy.expiry_date})'
            )
