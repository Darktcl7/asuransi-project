"""
Activity Log ViewSet - Super Admin Only
Untuk memantau semua aktivitas di sistem termasuk Store Admin
"""
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import serializers
from django.utils import timezone
from datetime import timedelta

from stores.activity_log import ActivityLog
from .permissions import IsSuperAdmin


class ActivityLogSerializer(serializers.ModelSerializer):
    """Serializer untuk Activity Log"""
    
    action_display = serializers.CharField(source='get_action_display', read_only=True)
    
    class Meta:
        model = ActivityLog
        fields = [
            'id',
            'user_email',
            'user_role',
            'store_code',
            'action',
            'action_display',
            'target_model',
            'target_id',
            'description',
            'ip_address',
            'created_at',
        ]


class ActivityLogViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Activity Log Management - SUPER ADMIN ONLY
    
    Super Admin dapat memantau SEMUA aktivitas di sistem,
    termasuk aktivitas Store Admin di semua toko.
    
    GET /api/admin/activity-logs/ - List all activities
    GET /api/admin/activity-logs/?store={code} - Filter by store
    GET /api/admin/activity-logs/?action={type} - Filter by action
    GET /api/admin/activity-logs/?user={email} - Filter by user
    GET /api/admin/activity-logs/?date_from=2026-01-01 - Filter by date
    """
    permission_classes = [IsAuthenticated, IsSuperAdmin]
    serializer_class = ActivityLogSerializer
    
    def get_queryset(self):
        # Super Admin bisa lihat SEMUA activity logs
        queryset = ActivityLog.objects.all()
        
        # Filter by store
        store = self.request.query_params.get('store')
        if store:
            queryset = queryset.filter(store_code__icontains=store)
        
        # Filter by action
        action = self.request.query_params.get('action')
        if action:
            queryset = queryset.filter(action=action)
        
        # Filter by user email
        user_filter = self.request.query_params.get('user')
        if user_filter:
            queryset = queryset.filter(user_email__icontains=user_filter)
        
        # Filter by user role (untuk filter Store Admin activities)
        role = self.request.query_params.get('role')
        if role:
            queryset = queryset.filter(user_role=role)
        
        # Filter by date range
        date_from = self.request.query_params.get('date_from')
        if date_from:
            queryset = queryset.filter(created_at__date__gte=date_from)
        
        date_to = self.request.query_params.get('date_to')
        if date_to:
            queryset = queryset.filter(created_at__date__lte=date_to)
        
        # Default: last 30 days if no filter (increased from 7)
        if not any([store, action, user_filter, role, date_from, date_to]):
            month_ago = timezone.now() - timedelta(days=30)
            queryset = queryset.filter(created_at__gte=month_ago)
        
        return queryset.order_by('-created_at')[:500]  # Limit 500 records
    
    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        
        # Get action choices for filter dropdown
        action_choices = [
            {'value': choice[0], 'label': choice[1]} 
            for choice in ActivityLog.ACTION_CHOICES
        ]
        
        return Response({
            'results': serializer.data,
            'count': len(serializer.data),
            'action_choices': action_choices,
        })

