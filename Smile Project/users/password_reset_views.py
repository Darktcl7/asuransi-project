"""
Password Reset Views
Handle forgot password flow with OTP
"""

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from .models_password_reset import PasswordReset
import re
import logging

logger = logging.getLogger(__name__)

User = get_user_model()


def is_phone_number(identifier):
    """Check if identifier is phone number"""
    cleaned = re.sub(r'[\s\-\(\)\+]', '', identifier)
    return cleaned.isdigit() and 10 <= len(cleaned) <= 15


def normalize_phone_number(phone):
    """Normalize phone to 08... format"""
    cleaned = re.sub(r'[\s\-\(\)\+]', '', phone)
    if cleaned.startswith('62'):
        cleaned = '0' + cleaned[2:]
    return cleaned


def send_otp_email(user, otp_code):
    """
    Send OTP code via email
    
    TODO: Integrate with your email service (utils/email_service.py)
    """
    from django.core.mail import send_mail
    from django.conf import settings
    
    subject = 'Reset Password - PhoneGuard Insurance'
    
    # Get user name safely
    user_name = user.get_full_name() if hasattr(user, 'get_full_name') and user.get_full_name() else user.first_name
    if not user_name:
        user_name = user.email.split('@')[0]  # Use email prefix if no name
    
    message = f"""
Halo {user_name},

Anda meminta reset password untuk akun PhoneGuard Insurance.

Kode OTP Anda: {otp_code}

Kode ini berlaku selama 10 menit.
Jangan berikan kode ini kepada siapa pun!

Jika Anda tidak meminta reset password, abaikan email ini.

Salam,
Tim PhoneGuard Insurance
    """.strip()
    
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )
        logger.info(f"OTP email sent to {user.email}")
        return True
    except Exception as e:
        logger.error(f"Failed to send OTP email: {str(e)}")
        return False


def send_otp_sms(user, otp_code):
    """
    Send OTP code via SMS
    
    TODO: Integrate with SMS service (Twilio, etc)
    For now, just log it
    """
    logger.warning(f"SMS OTP not implemented. OTP for {user.phone_number}: {otp_code}")
    
    # TODO: Implement SMS sending
    # Example with Twilio:
    # from twilio.rest import Client
    # client = Client(account_sid, auth_token)
    # message = client.messages.create(
    #     body=f"Kode OTP PhoneGuard: {otp_code}",
    #     from_='+1234567890',
    #     to=user.phone_number
    # )
    
    # For now, return False (not implemented)
    return False


@api_view(['POST'])
@permission_classes([AllowAny])
def request_password_reset(request):
    """
    Request password reset - generates and sends OTP
    
    POST /api/password-reset/request/
    Body: {
        "identifier": "user@email.com" OR "08123456789"
    }
    
    Returns: {
        "message": "OTP code sent to your email/phone",
        "method": "email" or "sms",
        "sent_to": "u***@email.com" or "0812****7890",
        "expires_in": 600
    }
    """
    identifier = request.data.get('identifier', '').strip()
    
    if not identifier:
        return Response({
            'error': 'Email atau nomor HP wajib diisi'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Find user by email or phone
    user = None
    method = 'email'
    
    if is_phone_number(identifier):
        # Find by phone number
        normalized_phone = normalize_phone_number(identifier)
        try:
            user = User.objects.get(phone_number=normalized_phone)
            method = 'sms'
        except User.DoesNotExist:
            pass
    else:
        # Find by email
        try:
            user = User.objects.get(email=identifier)
            method = 'email'
        except User.DoesNotExist:
            pass
    
    # Security: Don't reveal if user exists or not
    if user is None:
        # Return success anyway (prevent user enumeration)
        return Response({
            'message': 'Jika akun ditemukan, kode OTP telah dikirim',
            'method': method,
        }, status=status.HTTP_200_OK)
    
    # Create password reset OTP
    reset = PasswordReset.create_for_user(user, method=method)
    
    # Send OTP
    if method == 'email':
        sent = send_otp_email(user, reset.otp_code)
        if not sent:
            return Response({
                'error': 'Gagal mengirim email. Coba lagi nanti.'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:  # sms
        sent = send_otp_sms(user, reset.otp_code)
        if not sent:
            return Response({
                'error': 'SMS OTP belum tersedia. Gunakan email untuk reset password.',
                'suggestion': 'Coba dengan email Anda'
            }, status=status.HTTP_501_NOT_IMPLEMENTED)
    
    # Mask email/phone for security
    if method == 'email':
        parts = user.email.split('@')
        masked = parts[0][:1] + '***@' + parts[1]
    else:
        masked = user.phone_number[:4] + '****' + user.phone_number[-4:]
    
    return Response({
        'message': f'Kode OTP telah dikirim ke {method} Anda',
        'method': method,
        'sent_to': masked,
        'expires_in': 600,  # 10 minutes
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_otp(request):
    """
    Verify OTP code (step 2)
    
    POST /api/password-reset/verify-otp/
    Body: {
        "identifier": "user@email.com" OR "08123456789",
        "otp_code": "123456"
    }
    
    Returns: {
        "message": "OTP verified",
        "reset_token": "uuid..." (use this for password reset)
    }
    """
    identifier = request.data.get('identifier', '').strip()
    otp_code = request.data.get('otp_code', '').strip()
    
    if not identifier or not otp_code:
        return Response({
            'error': 'Email/phone dan kode OTP wajib diisi'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Find user
    user = None
    if is_phone_number(identifier):
        normalized_phone = normalize_phone_number(identifier)
        try:
            user = User.objects.get(phone_number=normalized_phone)
        except User.DoesNotExist:
            pass
    else:
        try:
            user = User.objects.get(email=identifier)
        except User.DoesNotExist:
            pass
    
    if user is None:
        return Response({
            'error': 'Akun tidak ditemukan'
        }, status=status.HTTP_404_NOT_FOUND)
    
    # Find valid reset request
    reset = PasswordReset.objects.filter(
        user=user,
        otp_code=otp_code,
    ).order_by('-created_at').first()
    
    if reset is None:
        return Response({
            'error': 'Kode OTP tidak valid'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Check if valid
    if not reset.is_valid():
        if reset.is_expired():
            return Response({
                'error': 'Kode OTP sudah expired. Minta kode baru.',
                'expired': True
            }, status=status.HTTP_400_BAD_REQUEST)
        elif reset.is_used:
            return Response({
                'error': 'Kode OTP sudah digunakan. Minta kode baru.',
                'used': True
            }, status=status.HTTP_400_BAD_REQUEST)
        elif reset.attempts >= reset.max_attempts:
            return Response({
                'error': 'Terlalu banyak percobaan. Minta kode baru.',
                'max_attempts_exceeded': True
            }, status=status.HTTP_400_BAD_REQUEST)
    
    # Verify OTP code
    if reset.otp_code != otp_code:
        reset.increment_attempts()
        remaining = reset.max_attempts - reset.attempts
        return Response({
            'error': f'Kode OTP salah. Sisa percobaan: {remaining}',
            'attempts_remaining': remaining
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # OTP verified! Return reset token
    return Response({
        'message': 'Kode OTP berhasil diverifikasi',
        'reset_token': str(reset.id),  # Use reset ID as token
        'user_email': user.email,
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password(request):
    """
    Reset password with verified OTP token
    
    POST /api/password-reset/reset/
    Body: {
        "reset_token": "uuid...",
        "new_password": "newpassword123"
    }
    
    Returns: {
        "message": "Password berhasil direset"
    }
    """
    reset_token = request.data.get('reset_token', '').strip()
    new_password = request.data.get('new_password', '')
    
    if not reset_token or not new_password:
        return Response({
            'error': 'Reset token dan password baru wajib diisi'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Validate password
    if len(new_password) < 6:
        return Response({
            'error': 'Password minimal 6 karakter'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Find reset request by token
    try:
        reset = PasswordReset.objects.get(id=reset_token)
    except PasswordReset.DoesNotExist:
        return Response({
            'error': 'Reset token tidak valid'
        }, status=status.HTTP_404_NOT_FOUND)
    
    # Check if still valid
    if not reset.is_valid():
        return Response({
            'error': 'Reset token sudah expired atau sudah digunakan. Minta kode OTP baru.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Reset password
    user = reset.user
    user.set_password(new_password)
    user.save()
    
    # Mark reset as used
    reset.mark_as_used()
    
    logger.info(f"Password reset successful for user: {user.email}")
    
    return Response({
        'message': 'Password berhasil direset! Silakan login dengan password baru.',
        'email': user.email,
    }, status=status.HTTP_200_OK)
