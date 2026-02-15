# policies/views.py

from rest_framework import viewsets, status
from rest_framework.response import Response
from django.db import transaction

from .models import PolicyTier, DevicePackage, Policy
from .serializers import PolicyTierSerializer, DevicePackageSerializer, PolicySerializer
# Note: Wallet imports removed - system now uses policy_balance managed by admin_api

class PolicyTierViewSet(viewsets.ReadOnlyModelViewSet):
    """ Endpoint untuk ambil list Tier (Standar, Gold, Premium) """
    queryset = PolicyTier.objects.filter(is_active=True)
    serializer_class = PolicyTierSerializer
    permission_classes = [] # Izinkan siapa saja melihat

class DevicePackageViewSet(viewsets.ReadOnlyModelViewSet):
    """ Endpoint untuk ambil list Device (iPhone 15, etc) """
    queryset = DevicePackage.objects.filter(is_active=True)
    serializer_class = DevicePackageSerializer
    permission_classes = [] # Izinkan siapa saja melihat

class PolicyViewSet(viewsets.ModelViewSet):
    serializer_class = PolicySerializer

    def get_queryset(self):
        # OPTIMIZED with select_related
        base_qs = Policy.objects.select_related(
            'user', 'tier', 'device_package', 'store'
        ).order_by('-created_at')
        
        # User hanya bisa lihat polis miliknya
        if self.request.user.is_staff:
            return base_qs
        return base_qs.filter(user=self.request.user)

    @transaction.atomic # Pastikan semua berhasil atau gagal total
    def create(self, request):
        """
        DEPRECATED: User-based policy creation is disabled.
        Policies should be created by Admin via /api/admin/policies/manual-create/
        
        This endpoint is kept for backward compatibility but returns an error.
        """
        # Check if user is admin - only allow admin to create via this endpoint
        if not request.user.is_staff:
            return Response({
                'error': 'Pembuatan polis hanya bisa dilakukan oleh Admin.',
                'message': 'Silakan hubungi Admin untuk mendaftarkan device Anda.',
                'info': 'User tidak diizinkan membuat polis sendiri.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # For admin, redirect to use the proper endpoint
        return Response({
            'error': 'Gunakan endpoint /api/admin/policies/manual-create/ untuk membuat polis.',
            'info': 'Endpoint ini sudah deprecated untuk admin.'
        }, status=status.HTTP_400_BAD_REQUEST)