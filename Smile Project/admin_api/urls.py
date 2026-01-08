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
)
from .device_views import AdminDeviceViewSet

router = DefaultRouter()
router.register(r'dashboard', DashboardStatsViewSet, basename='admin-dashboard')
router.register(r'users', AdminUserViewSet, basename='admin-users')
router.register(r'claims', AdminClaimViewSet, basename='admin-claims')
router.register(r'policies', AdminPolicyViewSet, basename='admin-policies')
router.register(r'wallets', AdminWalletViewSet, basename='admin-wallets')
router.register(r'topups', AdminTopUpViewSet, basename='admin-topups')
router.register(r'devices', AdminDeviceViewSet, basename='admin-devices')

urlpatterns = router.urls
