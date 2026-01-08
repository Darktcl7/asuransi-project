from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Notification
from .serializers import NotificationSerializer

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for user notifications
    
    GET /api/notifications/ - List all notifications (newest first)
    GET /api/notifications/unread_count/ - Get unread notification count
    POST /api/notifications/{id}/mark_as_read/ - Mark single notification as read
    POST /api/notifications/mark_all_as_read/ - Mark all notifications as read
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return notifications for current user only"""
        return Notification.objects.filter(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'unread_count': count})
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark a single notification as read"""
        notification = self.get_object()
        notification.mark_as_read()
        return Response({
            'message': 'Notification marked as read',
            'notification': NotificationSerializer(notification).data
        })
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """Mark all user's notifications as read"""
        from django.utils import timezone
        updated = self.get_queryset().filter(is_read=False).update(
            is_read=True,
            read_at=timezone.now()
        )
        return Response({
            'message': f'{updated} notifications marked as read',
            'count': updated
        })
