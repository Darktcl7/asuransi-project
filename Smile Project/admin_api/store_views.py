# admin_api/store_views.py
"""
Store Management ViewSets for Super Admin

Only Super Admin can:
- Create, update, delete stores
- View all stores

Store Admin can:
- View their own store details only
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count, Q

from stores.models import Store
from stores.serializers import StoreSerializer, StoreListSerializer
from stores.activity_log import ActivityLog
from users.models import User
from policies.models import Policy
from claims.models import Claim
from .permissions import IsSuperAdmin, IsStoreAdminOrSuperAdmin


class StoreViewSet(viewsets.ModelViewSet):
    """
    Store Management API - Super Admin Only
    
    GET /api/admin/stores/ - List all stores
    POST /api/admin/stores/ - Create new store
    GET /api/admin/stores/{id}/ - Get store detail
    PUT /api/admin/stores/{id}/ - Update store
    DELETE /api/admin/stores/{id}/ - Deactivate store
    GET /api/admin/stores/{id}/stats/ - Get store statistics
    """
    serializer_class = StoreSerializer
    permission_classes = [IsAuthenticated, IsSuperAdmin]
    
    def get_queryset(self):
        queryset = Store.objects.all()
        
        # Filters
        is_active = self.request.query_params.get('is_active')
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')
        
        city = self.request.query_params.get('city')
        if city:
            queryset = queryset.filter(city__icontains=city)
        
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(code__icontains=search) |
                Q(name__icontains=search) |
                Q(city__icontains=search) |
                Q(registration_code__icontains=search)
            )
        
        return queryset.order_by('name')
    
    def get_serializer_class(self):
        if self.action == 'list':
            return StoreListSerializer
        return StoreSerializer
    
    def list(self, request):
        """List all stores with stats"""
        queryset = self.get_queryset()
        
        # Annotate with counts
        queryset = queryset.annotate(
            user_count=Count('users', filter=Q(users__role='customer')),
            admin_count=Count('users', filter=Q(users__role__in=['store_admin', 'store_staff'])),
        )
        
        serializer = self.get_serializer(queryset, many=True)
        data = serializer.data
        
        # Add counts to response
        for i, store in enumerate(queryset):
            data[i]['user_count'] = store.user_count
            data[i]['admin_count'] = store.admin_count
        
        return Response({
            'count': len(data),
            'results': data
        })
    
    def create(self, request, *args, **kwargs):
        """Create new store with activity logging"""
        response = super().create(request, *args, **kwargs)
        if response.status_code == 201:
            ActivityLog.log(
                request=request,
                action='STORE_CREATE',
                target_model='Store',
                target_id=response.data.get('id', ''),
                description=f"Toko baru dibuat: {response.data.get('name', '')} ({response.data.get('registration_code', '')})"
            )
        return response
    
    def update(self, request, *args, **kwargs):
        """Update store with activity logging"""
        store = self.get_object()
        old_status = store.is_active
        response = super().update(request, *args, **kwargs)
        
        if response.status_code == 200:
            # Check if reactivating
            new_status = response.data.get('is_active', old_status)
            if not old_status and new_status:
                action_type = 'STORE_UPDATE'  # Reactivation
                desc = f"Toko diaktifkan kembali: {store.name}"
            else:
                action_type = 'STORE_UPDATE'
                desc = f"Toko diupdate: {store.name}"
            
            ActivityLog.log(
                request=request,
                action=action_type,
                target_model='Store',
                target_id=str(store.id),
                description=desc
            )
        return response
    
    @action(detail=True, methods=['post'], url_path='reset-data')
    def reset_data(self, request, pk=None):
        """
        Reset Store Data:
        - Hapus semua Customer (cascade ke Policy, Claim, Wallet)
        - PERTAHANKAN Store Admin/Staff
        """
        store = self.get_object()
        
        # Cari customer di toko ini
        customers = User.objects.filter(store=store, role='customer')
        count = customers.count()
        
        if count == 0:
            return Response({'message': 'Toko sudah kosong, tidak ada data customer.'})
            
        # Verify Password
        password = request.data.get('password')
        if not password:
            return Response({'error': 'Password diperlukan untuk melakukan reset data.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not request.user.check_password(password):
            return Response({'error': 'Password yang Anda masukkan salah.'}, status=status.HTTP_400_BAD_REQUEST)
            
        # Log activity
        ActivityLog.log(
            request=request,
            action='STORE_RESET',
            target_model='Store',
            target_id=str(store.id),
            description=f"Reset Data Toko: {store.name} ({count} customers dihapus)"
        )
        
        # Hapus customers (akan menghapus polis & claim mereka secara cascade)
        customers.delete()
        
        return Response({
            'message': f'Berhasil mereset data toko. {count} customer (beserta polis & klaim) telah dihapus.'
        })

    def destroy(self, request, pk=None):
        """Soft delete (default) or Permanent delete with password verification"""
        store = self.get_object()
        
        # Verify Password for any delete action
        password = request.data.get('password') or request.query_params.get('password')
        if not password:
            return Response({'error': 'Password diperlukan untuk menonaktifkan atau menghapus toko.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not request.user.check_password(password):
            return Response({'error': 'Password yang Anda masukkan salah.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if permanent delete requested
        is_permanent = request.query_params.get('permanent') == 'true'
        
        if is_permanent:
            # Check for related data to prevent inconsistency
            # Check users (count users who belong to this store)
            user_count = User.objects.filter(store=store).count()
            if user_count > 0:
                return Response({
                    'detail': f'Gagal hapus permanen: Masih ada {user_count} user/admin terdaftar di toko ini.'
                }, status=status.HTTP_400_BAD_REQUEST)
                
            # Check policies
            policy_count = Policy.objects.filter(user__store=store).count()
            if policy_count > 0:
                return Response({
                    'detail': f'Gagal hapus permanen: Masih ada {policy_count} polis terkait toko ini.'
                }, status=status.HTTP_400_BAD_REQUEST)

             # Log activity BEFORE delete
            ActivityLog.log(
                request=request,
                action='STORE_DELETE_PERMANENT',
                target_model='Store',
                target_id=str(store.id),
                description=f"Toko DIHAPUS PERMANEN: {store.name} ({store.registration_code})"
            )
            
            store.delete()
            return Response({'message': f'Toko {store.name} berhasil dihapus permanen'})

        # Soft Delete Logic
        store.is_active = False
        store.save()
        
        # Log activity
        ActivityLog.log(
            request=request,
            action='STORE_DEACTIVATE',
            target_model='Store',
            target_id=str(store.id),
            description=f"Toko dinonaktifkan: {store.name} ({store.registration_code})"
        )
        
        return Response({
            'message': f'Toko {store.name} berhasil dinonaktifkan'
        })
    
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        """
        Get detailed statistics for a store with custom date range and grouping
        GET /api/admin/stores/{id}/stats/?start_date=2025-01-01&end_date=2025-12-31&period=month
        """
        from django.utils import timezone
        from datetime import datetime, timedelta
        from django.db.models import Sum, Avg
        from django.db.models.functions import TruncDate, TruncMonth, TruncYear, TruncWeek
        
        store = self.get_object()
        
        # Parse query params
        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')
        period = request.query_params.get('period', 'day') # day, week, month, year
        
        print(f"DEBUG STORE STATS: Store={store.name}, Start={start_date_str}, End={end_date_str}")
        
        # Default range: TODAY (Daily Recap) if not provided
        today = timezone.now().date()
        if start_date_str:
            try:
                start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            except ValueError:
                start_date = today
        else:
            start_date = today # Default to today
            
        if end_date_str:
            try:
                end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            except ValueError:
                end_date = today
        else:
            end_date = today

        # Base filter for periods
        date_filter = Q(created_at__date__gte=start_date, created_at__date__lte=end_date)
        
        # User stats (Global & Filtered)
        users = User.objects.filter(store=store)
        new_customers = users.filter(role='customer', date_joined__date__gte=start_date, date_joined__date__lte=end_date).count()
        
        user_stats = {
            'total_customers': users.filter(role='customer').count(), # Global
            'new_customers': new_customers, # Filtered
            'total_staff': users.filter(role='store_staff').count(),
            'total_admins': users.filter(role='store_admin').count(),
        }
        
        # Policy stats (Filtered by store)
        policies = Policy.objects.filter(Q(store=store) | Q(user__store=store)).distinct()
        
        # Filtered policies for recap (Daily/Range)
        filtered_policies = policies.filter(date_filter)
        
        policy_stats = {
            'total': policies.count(), # Global
            'filtered_count': filtered_policies.count(), # Range
            'filtered_revenue': float(filtered_policies.aggregate(total=Sum('policy_price'))['total'] or 0), # Range
            'active': policies.filter(status='active').count(),
            'pending': policies.filter(status='pending').count(),
            'expired': policies.filter(status='expired').count(),
        }

        # Grouping logic for Chart (Recap)
        trunc_func = TruncDate
        if period == 'month':
            trunc_func = TruncMonth
        elif period == 'year':
            trunc_func = TruncYear
        elif period == 'week':
            trunc_func = TruncWeek
            
        # Advanced recap based on period
        recap = filtered_policies.annotate(
            bucket=trunc_func('created_at')
        ).values('bucket').annotate(
            count=Count('id'),
            revenue=Sum('policy_price')
        ).order_by('bucket')
        
        # Phone type distribution (Top 5 models in this range)
        phone_distribution = filtered_policies.values(
            'device_package__device_brand', 
            'device_package__device_model'
        ).annotate(
            count=Count('id')
        ).order_by('-count')[:5]
        
        # Claim stats (Filtered by range)
        claims = Claim.objects.filter(policy__store=store)
        filtered_claims = claims.filter(date_filter)
        
        claim_stats = {
            'total': claims.count(), # Global
            'filtered_total': filtered_claims.count(), # Range
            'filtered_pending': filtered_claims.filter(status='pending').count(), # Range
            'filtered_approved': filtered_claims.filter(status='approved').count(), # Range
            'filtered_in_progress': filtered_claims.filter(status='in_progress').count(), # Range
            'filtered_completed': filtered_claims.filter(status='completed').count(), # Range
            'filtered_rejected': filtered_claims.filter(status='rejected').count(), # Range
        }
        
        # Summary for the selected range (Dashboard Cards)
        summary = {
            'total_policies': policy_stats['filtered_count'],
            'total_revenue': policy_stats['filtered_revenue'],
            'new_customers': new_customers,
            'new_claims': claim_stats['filtered_total'],
            'claim_pending': claim_stats['filtered_pending']
        }
        
        return Response({
            'store': StoreSerializer(store).data,
            'summary': summary,
            'recap': list(recap),
            'users': user_stats,
            'policies': policy_stats,
            'phone_distribution': list(phone_distribution),
            'claims': claim_stats,
            'filters': {
                'start_date': start_date,
                'end_date': end_date,
                'period': period
            }
        })
    
    @action(detail=True, methods=['get'])
    def admins(self, request, pk=None):
        """
        Get all admins for a store
        GET /api/admin/stores/{id}/admins/
        """
        store = self.get_object()
        admins = User.objects.filter(
            store=store,
            role__in=['store_admin', 'store_staff']
        ).values('id', 'email', 'first_name', 'last_name', 'role', 'is_active')
        
        return Response({
            'store': store.name,
            'admins': list(admins)
        })


class MyStoreViewSet(viewsets.ViewSet):
    """
    Store Admin - View their own store
    
    GET /api/admin/my-store/ - Get current user's store
    GET /api/admin/my-store/stats/ - Get store statistics
    """
    permission_classes = [IsAuthenticated, IsStoreAdminOrSuperAdmin]
    
    def list(self, request):
        """Get current user's store"""
        user = request.user
        
        if user.role == 'super_admin':
            return Response({
                'message': 'Super Admin tidak terikat ke toko tertentu',
                'role': 'super_admin',
                'store': None
            })
        
        if not user.store:
            return Response({
                'error': 'Anda belum terdaftar di toko manapun'
            }, status=400)
        
        serializer = StoreSerializer(user.store)
        return Response({
            'role': user.role,
            'store': serializer.data
        })
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get current user's store statistics"""
        user = request.user
        
        if user.role == 'super_admin':
            return Response({
                'error': 'Gunakan /api/admin/stores/ untuk Super Admin'
            }, status=400)
        
        if not user.store:
            return Response({
                'error': 'Anda belum terdaftar di toko manapun'
            }, status=400)
        
        store = user.store
        
        # User stats
        users = User.objects.filter(store=store, role='customer')
        user_stats = {
            'total': users.count(),
            'verified': users.filter(is_verified=True).count(),
        }
        
        # Policy stats
        policies = Policy.objects.filter(user__store=store)
        policy_stats = {
            'total': policies.count(),
            'active': policies.filter(status='active').count(),
            'pending': policies.filter(status='pending').count(),
        }
        
        # Claim stats
        claims = Claim.objects.filter(user__store=store)
        claim_stats = {
            'total': claims.count(),
            'pending': claims.filter(status='pending').count(),
            'approved': claims.filter(status='approved').count(),
        }
        
        return Response({
            'store': StoreSerializer(store).data,
            'users': user_stats,
            'policies': policy_stats,
            'claims': claim_stats,
        })
