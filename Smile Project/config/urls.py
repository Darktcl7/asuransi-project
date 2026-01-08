# config/urls.py

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from rest_framework.authtoken.views import obtain_auth_token

# Import Views 
from users.views import UserViewSet
from users.auth_views import custom_login, logout
from users.password_reset_views import request_password_reset, verify_otp, reset_password
from wallet.views import WalletViewSet
from policies.views import PolicyTierViewSet, DevicePackageViewSet, PolicyViewSet
from claims.views import ClaimViewSet, AdminClaimViewSet

# Router otomatis membuat URL (list, create, detail, update)
router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'wallet', WalletViewSet, basename='wallet')
router.register(r'policy-tiers', PolicyTierViewSet, basename='policy-tier')
router.register(r'device-packages', DevicePackageViewSet, basename='device-package')
router.register(r'policies', PolicyViewSet, basename='policy')
router.register(r'claims', ClaimViewSet, basename='claim')
# REMOVED: admin/claims conflicting with admin_api.urls
# router.register(r'admin/claims', AdminClaimViewSet, basename='admin-claim')

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Daftarkan semua URL router di bawah '/api/'
    path('api/', include(router.urls)),
    
    # Admin API endpoints (optimized untuk jutaan data)
    path('api/admin/', include('admin_api.urls')),
    
    # Notifications API
    path('api/notifications/', include('notifications.urls')),
    
    # Custom Login/Logout (support email OR phone number)
    # POST /api/login/ - Body: {"identifier": "email OR phone", "password": "..."}
    path('api/login/', custom_login, name='custom_login'),
    path('api/logout/', logout, name='custom_logout'),
    
    # Password Reset (Forgot Password) with OTP
    # POST /api/password-reset/request/ - Request OTP
    # POST /api/password-reset/verify-otp/ - Verify OTP code
    # POST /api/password-reset/reset/ - Reset password
    path('api/password-reset/request/', request_password_reset, name='request_password_reset'),
    path('api/password-reset/verify-otp/', verify_otp, name='verify_otp'),
    path('api/password-reset/reset/', reset_password, name='reset_password'),
    
    # OLD Login endpoint (kept for backward compatibility with old app version)
    # POST /api/auth/login/ - Body: {"username": "email", "password": "..."}
    path('api/auth/login/', obtain_auth_token, name='api_token_auth'),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)