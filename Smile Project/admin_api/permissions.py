# admin_api/permissions.py
"""
Custom Permission Classes for Multi-Store System

Permission Hierarchy:
- Super Admin: Full access to all stores and data
- Store Admin: Full CRUD for their own store only
- Store Staff: Read-only access to their store
- Customer: Access own data only
"""

from rest_framework.permissions import BasePermission


class IsSuperAdmin(BasePermission):
    """
    Only Super Admin can access.
    Used for: Store management, global settings, activity logs
    """
    message = "Hanya Super Admin yang dapat mengakses fitur ini."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        return request.user.role == 'super_admin'


class IsStoreAdminOrSuperAdmin(BasePermission):
    """
    Store Admin or Super Admin can access.
    Used for: Manage users, claims, policies for their store
    """
    message = "Hanya Store Admin atau Super Admin yang dapat mengakses fitur ini."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        return request.user.role in ['store_admin', 'super_admin']


class IsStoreStaffOrAbove(BasePermission):
    """
    Store Staff, Store Admin, or Super Admin can access.
    Used for: View data (read-only for staff)
    """
    message = "Hanya Staff Toko atau lebih tinggi yang dapat mengakses fitur ini."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        return request.user.role in ['store_staff', 'store_admin', 'super_admin']


class IsAdminUserOrSuperAdmin(BasePermission):
    """
    Django admin (is_staff) OR our Super Admin role.
    Backward compatible with existing admin checks.
    """
    message = "Anda tidak memiliki akses admin."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        # Check Django's is_staff OR our super_admin role
        return request.user.is_staff or request.user.role == 'super_admin'


class CanManageDevices(BasePermission):
    """
    Only Super Admin can manage devices.
    Devices are global resources, not per-store.
    """
    message = "Hanya Super Admin yang dapat mengelola data perangkat."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        # Only Super Admin can manage devices
        return request.user.role == 'super_admin'


class CanManagePolicyTiers(BasePermission):
    """
    Only Super Admin can manage policy tiers.
    Policy tiers are global settings.
    """
    message = "Hanya Super Admin yang dapat mengelola tier polis."
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        return request.user.role == 'super_admin'


class StoreAccessMixin:
    """
    Mixin to filter queryset based on user's store access.
    
    Usage:
        class MyViewSet(StoreAccessMixin, viewsets.ModelViewSet):
            ...
    """
    
    def get_store_filtered_queryset(self, queryset, store_field='store'):
        """
        Filter queryset based on user's store access.
        
        Args:
            queryset: The base queryset
            store_field: The field name for store FK (default: 'store')
        
        Returns:
            Filtered queryset
        """
        user = self.request.user
        
        if user.role == 'super_admin':
            # Super admin can see all, but can filter by store
            store_filter = self.request.query_params.get('store')
            if store_filter:
                queryset = queryset.filter(**{f'{store_field}_id': store_filter})
            return queryset
        
        elif user.role in ['store_admin', 'store_staff']:
            # Filter only their store's data
            if user.store_id:
                return queryset.filter(**{f'{store_field}_id': user.store_id})
            return queryset.none()
        
        else:
            # Customer - filter to own data (handled elsewhere)
            return queryset


class UserStoreAccessMixin:
    """
    Mixin to filter User queryset based on store access.
    Uses 'store' field directly on User model.
    """
    
    def get_user_store_filtered_queryset(self, queryset):
        """
        Filter user queryset based on user's store access.
        """
        user = self.request.user
        
        if user.role == 'super_admin':
            # Super admin can see all users, but can filter by store
            store_filter = self.request.query_params.get('store')
            if store_filter:
                queryset = queryset.filter(store_id=store_filter)
            return queryset
        
        elif user.role in ['store_admin', 'store_staff']:
            # Filter only their store's users
            if user.store_id:
                return queryset.filter(store_id=user.store_id)
            return queryset.none()
        
        else:
            # Should not reach here for admin views
            return queryset.none()
