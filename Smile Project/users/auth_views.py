"""
Custom Authentication Views
Support login dengan Email atau Phone Number
"""

from django.contrib.auth import get_user_model, authenticate
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .serializers import UserSerializer
import re

User = get_user_model()


def is_phone_number(identifier):
    """
    Check if identifier is phone number
    Phone format: 08123456789 or 628123456789 or +628123456789
    """
    # Remove spaces, dashes, parentheses
    cleaned = re.sub(r'[\s\-\(\)\+]', '', identifier)
    
    # Check if all digits and length 10-15
    if cleaned.isdigit() and 10 <= len(cleaned) <= 15:
        return True
    return False


def normalize_phone_number(phone):
    """
    Normalize phone number to standard format
    08123456789 -> 08123456789
    628123456789 -> 08123456789
    +628123456789 -> 08123456789
    """
    # Remove spaces, dashes, parentheses, plus
    cleaned = re.sub(r'[\s\-\(\)\+]', '', phone)
    
    # Convert 62 prefix to 0
    if cleaned.startswith('62'):
        cleaned = '0' + cleaned[2:]
    
    return cleaned


@api_view(['POST'])
@permission_classes([AllowAny])
def custom_login(request):
    """
    Custom login endpoint that accepts email OR phone number
    
    POST /api/login/
    Body: {
        "identifier": "user@email.com" OR "08123456789",
        "password": "password123"
    }
    
    Returns: {
        "token": "...",
        "user": {...}
    }
    """
    identifier = request.data.get('identifier', '').strip()
    password = request.data.get('password', '')
    
    if not identifier or not password:
        return Response({
            'error': 'Identifier (email/phone) dan password harus diisi'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    user = None
    
    # Check if identifier is phone number or email
    if is_phone_number(identifier):
        # Login dengan phone number
        normalized_phone = normalize_phone_number(identifier)
        
        try:
            # Find user by phone number
            user = User.objects.get(phone_number=normalized_phone)
            
            # Verify password
            if not user.check_password(password):
                user = None
                
        except User.DoesNotExist:
            user = None
    else:
        # Login dengan email (standard Django authenticate)
        user = authenticate(username=identifier, password=password)
    
    # Check if authentication successful
    if user is None:
        return Response({
            'error': 'Email/nomor HP atau password salah'
        }, status=status.HTTP_401_UNAUTHORIZED)
    
    # Check if user is active
    if not user.is_active:
        return Response({
            'error': 'Akun tidak aktif. Hubungi administrator.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    # Get or create token
    token, created = Token.objects.get_or_create(user=user)
    
    # Return success response
    return Response({
        'token': token.key,
        'user': UserSerializer(user).data,
        'login_method': 'phone' if is_phone_number(identifier) else 'email'
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([])  # Requires authentication (default from settings)
def logout(request):
    """
    Logout endpoint - Delete user's token
    
    POST /api/logout/
    Headers: Authorization: Token <token>
    """
    try:
        # Delete the user's token
        request.user.auth_token.delete()
        return Response({
            'message': 'Logout berhasil'
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)
