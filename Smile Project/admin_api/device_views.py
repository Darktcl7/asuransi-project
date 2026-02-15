from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from django.core.cache import cache
from policies.models import DevicePackage
from policies.serializers import DevicePackageSerializer
from .permissions import CanManageDevices

class AdminDeviceViewSet(viewsets.ModelViewSet):
    """
    Admin Device Management - SUPER ADMIN ONLY
    
    Note: Devices adalah data global, hanya Super Admin yang bisa mengelola.
    Store Admin tidak bisa akses menu ini.
    
    GET /api/admin/devices/ - List all devices
    POST /api/admin/devices/ - Create new device
    PUT /api/admin/devices/{id}/ - Update device
    DELETE /api/admin/devices/{id}/ - Delete device
    GET /api/admin/devices/?category=handphone - Filter by category
    """
    permission_classes = [CanManageDevices]  # Super Admin only
    serializer_class = DevicePackageSerializer
    
    def get_queryset(self):
        queryset = DevicePackage.objects.all().order_by('-id')
        
        # Filter by category
        category = self.request.query_params.get('category', None)
        if category:
            queryset = queryset.filter(device_category=category)
        
        # Filter by active status
        is_active = self.request.query_params.get('is_active', None)
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')
        
        # Search
        search = self.request.query_params.get('search', None)
        if search:
            queryset = queryset.filter(
                device_brand__icontains=search
            ) | queryset.filter(
                device_model__icontains=search
            )
        
        return queryset
    
    def list(self, request):
        """List all devices with filters"""
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def create(self, request):
        """Create new device"""
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            cache.delete('admin_dashboard_stats')
            return Response({
                'message': 'Device created successfully',
                'device': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def update(self, request, pk=None):
        """Update device"""
        device = self.get_object()
        serializer = self.get_serializer(device, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            cache.delete('admin_dashboard_stats')
            return Response({
                'message': 'Device updated successfully',
                'device': serializer.data
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def destroy(self, request, pk=None):
        """Delete device (soft delete - set is_active=False)"""
        device = self.get_object()
        
        # Check if device is used in any active policies
        from policies.models import Policy
        active_policies = Policy.objects.filter(
            device_package=device, 
            status__in=['active', 'pending']
        ).count()
        
        if active_policies > 0:
            return Response({
                'error': f'Cannot delete device. {active_policies} active policies are using this device.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Soft delete
        device.is_active = False
        device.save()
        cache.delete('admin_dashboard_stats')
        
        return Response({
            'message': 'Device deleted successfully'
        }, status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=False, methods=['get'])
    def categories(self, request):
        """Get all device categories"""
        categories = [
            {'value': choice[0], 'label': choice[1]}
            for choice in DevicePackage.CATEGORY_CHOICES
        ]
        return Response(categories)
