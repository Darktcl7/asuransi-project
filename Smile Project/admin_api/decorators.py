# admin_api/decorators.py
"""
Security decorators untuk rate limiting
Prevent abuse dengan membatasi request per IP/user
"""

from functools import wraps
from django_ratelimit.decorators import ratelimit
from rest_framework.response import Response
from rest_framework import status


def rate_limit_api(key='ip', rate='100/h', method='ALL'):
    """
    Rate limit decorator untuk API endpoints
    
    Usage:
        @rate_limit_api(key='ip', rate='100/h')
        def my_view(request):
            ...
    
    Args:
        key: 'ip', 'user', or callable
        rate: '100/h' (100 requests per hour), '10/m' (10 per minute)
        method: 'GET', 'POST', or 'ALL'
    """
    def decorator(view_func):
        @wraps(view_func)
        @ratelimit(key=key, rate=rate, method=method, block=True)
        def wrapped_view(request, *args, **kwargs):
            # Check if rate limit was exceeded
            if getattr(request, 'limited', False):
                return Response(
                    {
                        'error': 'Rate limit exceeded',
                        'detail': f'Too many requests. Please try again later.',
                        'retry_after': '1 hour'
                    },
                    status=status.HTTP_429_TOO_MANY_REQUESTS
                )
            return view_func(request, *args, **kwargs)
        return wrapped_view
    return decorator


def rate_limit_login(view_func):
    """
    Strict rate limit untuk login endpoints
    Max 5 attempts per 15 minutes per IP
    """
    @wraps(view_func)
    @ratelimit(key='ip', rate='5/15m', method='POST', block=True)
    def wrapped_view(request, *args, **kwargs):
        if getattr(request, 'limited', False):
            return Response(
                {
                    'error': 'Too many login attempts',
                    'detail': 'Please wait 15 minutes before trying again.',
                },
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )
        return view_func(request, *args, **kwargs)
    return wrapped_view
