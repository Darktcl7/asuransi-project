# security_settings.py
# Import this at the end of settings.py

from pathlib import Path

# ===================================================================
# SECURITY CONFIGURATION
# ===================================================================

# CORS Configuration - Secure (hanya allow specific origins)
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = [
    'http://localhost:5173',      # React Admin (development)
    'http://127.0.0.1:5173',
    'http://localhost:3000',      # Alternative port
    'http://127.0.0.1:3000',
    # Add production URLs here when deploying:
    # 'https://admin.yourdomain.com',
]

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]

# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# HTTPS Settings (Enable in production)
# SECURE_SSL_REDIRECT = True
# SESSION_COOKIE_SECURE = True
# CSRF_COOKIE_SECURE = True
# SECURE_HSTS_SECONDS = 31536000
# SECURE_HSTS_INCLUDE_SUBDOMAINS = True
# SECURE_HSTS_PRELOAD = True

# Session Security
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_AGE = 86400  # 24 hours

# CSRF Protection
CSRF_COOKIE_HTTPONLY = False  # Must be False for frontend to read
CSRF_COOKIE_SAMESITE = 'Lax'
CSRF_TRUSTED_ORIGINS = [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
]

# Django Defender - Brute Force Protection
DEFENDER_LOGIN_FAILURE_LIMIT = 5  # Max 5 failed attempts
DEFENDER_COOLOFF_TIME = 300  # 5 minutes lockout
DEFENDER_LOCKOUT_TEMPLATE = None  # API response instead of template
DEFENDER_BEHIND_REVERSE_PROXY = False
DEFENDER_DISABLE_IP_LOCKOUT = False
DEFENDER_DISABLE_USERNAME_LOCKOUT = False
DEFENDER_ACCESS_ATTEMPT_EXPIRATION = 24  # Hours

# Logging Configuration
import os
BASE_DIR = Path(__file__).resolve().parent.parent

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'WARNING',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, 'logs', 'security.log'),
            'formatter': 'verbose',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': True,
        },
        'django.security': {
            'handlers': ['file'],
            'level': 'WARNING',
            'propagate': False,
        },
        'defender': {
            'handlers': ['console', 'file'],
            'level': 'WARNING',
            'propagate': False,
        },
    },
}
