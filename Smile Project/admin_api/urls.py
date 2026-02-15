# admin_api/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    DashboardStatsViewSet,
    AdminUserViewSet,
    AdminClaimViewSet,
    AdminPolicyViewSet,
    AdminWalletViewSet,
    AdminTopUpViewSet,
    AdminPolicyTierViewSet, # Added
)
from .device_views import AdminDeviceViewSet
from .store_views import StoreViewSet, MyStoreViewSet
from .activity_views import ActivityLogViewSet
from .report_views import AdminReportViewSet

router = DefaultRouter()
router.register(r'dashboard', DashboardStatsViewSet, basename='admin-dashboard')
router.register(r'users', AdminUserViewSet, basename='admin-users')
router.register(r'claims', AdminClaimViewSet, basename='admin-claims')
router.register(r'policies', AdminPolicyViewSet, basename='admin-policies')
router.register(r'policy-tiers', AdminPolicyTierViewSet, basename='admin-policy-tiers') # Added
router.register(r'wallets', AdminWalletViewSet, basename='admin-wallets')
router.register(r'topups', AdminTopUpViewSet, basename='admin-topups')
router.register(r'devices', AdminDeviceViewSet, basename='admin-devices')
router.register(r'stores', StoreViewSet, basename='admin-stores')  # Super Admin only
router.register(r'my-store', MyStoreViewSet, basename='admin-my-store')  # Store Admin
router.register(r'activity-logs', ActivityLogViewSet, basename='admin-activity-logs')  # Super Admin only
router.register(r'reports', AdminReportViewSet, basename='admin-reports') # ENABLED

urlpatterns = router.urls


