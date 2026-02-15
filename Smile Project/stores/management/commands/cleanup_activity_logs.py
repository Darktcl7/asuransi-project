"""
Management Command: cleanup_activity_logs
Hapus activity logs yang sudah lebih dari X hari

Usage:
    python manage.py cleanup_activity_logs             # Default: hapus > 365 hari
    python manage.py cleanup_activity_logs --days=180  # Hapus > 180 hari
    python manage.py cleanup_activity_logs --dry-run   # Preview tanpa hapus
"""

from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from stores.activity_log import ActivityLog


class Command(BaseCommand):
    help = 'Hapus activity logs yang sudah lama untuk menjaga performa database'

    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=365,
            help='Hapus logs yang lebih tua dari X hari (default: 365)'
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Preview jumlah yang akan dihapus tanpa benar-benar menghapus'
        )
        parser.add_argument(
            '--batch-size',
            type=int,
            default=1000,
            help='Jumlah records per batch (default: 1000)'
        )

    def handle(self, *args, **options):
        days = options['days']
        dry_run = options['dry_run']
        batch_size = options['batch_size']
        
        # Hitung tanggal cutoff
        cutoff_date = timezone.now() - timedelta(days=days)
        
        # Cari logs yang akan dihapus
        old_logs = ActivityLog.objects.filter(created_at__lt=cutoff_date)
        total_count = old_logs.count()
        
        if total_count == 0:
            self.stdout.write(
                self.style.SUCCESS(f'[OK] Tidak ada logs yang lebih tua dari {days} hari.')
            )
            return
        
        # Preview mode
        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f'[DRY RUN] Akan menghapus {total_count:,} activity logs '
                    f'yang lebih tua dari {days} hari '
                    f'(sebelum {cutoff_date.strftime("%Y-%m-%d")})'
                )
            )
            
            # Tampilkan breakdown per action
            from django.db.models import Count
            breakdown = old_logs.values('action').annotate(count=Count('id')).order_by('-count')[:10]
            
            self.stdout.write('\n[INFO] Breakdown per action type:')
            for item in breakdown:
                self.stdout.write(f"   - {item['action']}: {item['count']:,}")
            
            return
        
        # Hapus dalam batch untuk mencegah lock database
        self.stdout.write(
            self.style.WARNING(
                f'[DELETE] Menghapus {total_count:,} activity logs...'
            )
        )
        
        deleted_total = 0
        while True:
            # Ambil batch untuk dihapus
            batch_ids = list(
                ActivityLog.objects.filter(created_at__lt=cutoff_date)
                .values_list('id', flat=True)[:batch_size]
            )
            
            if not batch_ids:
                break
            
            # Hapus batch
            deleted_count, _ = ActivityLog.objects.filter(id__in=batch_ids).delete()
            deleted_total += deleted_count
            
            # Progress
            progress = (deleted_total / total_count) * 100
            self.stdout.write(f'   Progress: {deleted_total:,}/{total_count:,} ({progress:.1f}%)')
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\n[OK] Berhasil menghapus {deleted_total:,} activity logs '
                f'yang lebih tua dari {days} hari!'
            )
        )
        
        # Tampilkan statistik setelah cleanup
        remaining = ActivityLog.objects.count()
        self.stdout.write(f'[INFO] Total logs tersisa: {remaining:,}')
