"""
Email Notification Service
Send automated emails to users for important events
"""

from django.core.mail import send_mail, EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


def send_html_email(subject, template_name, context, recipient_email):
    """
    Send HTML email with fallback to plain text
    
    Args:
        subject: Email subject
        template_name: Template path (e.g., 'emails/welcome.html')
        context: Dictionary with template variables
        recipient_email: Recipient email address
    
    Returns:
        bool: True if sent successfully, False otherwise
    """
    try:
        # Render HTML content
        html_content = render_to_string(template_name, context)
        
        # Create plain text version
        text_content = strip_tags(html_content)
        
        # Create email
        email = EmailMultiAlternatives(
            subject=subject,
            body=text_content,
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[recipient_email]
        )
        
        # Attach HTML version
        email.attach_alternative(html_content, "text/html")
        
        # Send email
        email.send(fail_silently=False)
        
        logger.info(f"Email sent successfully to {recipient_email}: {subject}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send email to {recipient_email}: {str(e)}")
        return False


# ============================================================================
# SPECIFIC EMAIL FUNCTIONS
# ============================================================================

def send_welcome_email(user):
    """Send welcome email to new user"""
    context = {
        'full_name': user.full_name,
        'email': user.email,
    }
    return send_html_email(
        subject='Selamat Datang di PhoneGuard Insurance! 🎉',
        template_name='emails/welcome.html',
        context=context,
        recipient_email=user.email
    )


def send_claim_submitted_email(claim):
    """Send email when user submits new claim"""
    context = {
        'full_name': claim.user.full_name,
        'claim_number': claim.claim_number,
        'device': f"{claim.policy.device_package.device_brand} {claim.policy.device_package.device_model}",
        'damage_type': claim.damage_type,
        'description': claim.damage_description,
        'created_date': claim.created_at.strftime('%d %b %Y'),
    }
    return send_html_email(
        subject=f'Klaim Anda Telah Diterima - {claim.claim_number}',
        template_name='emails/claim_submitted.html',
        context=context,
        recipient_email=claim.user.email
    )


def send_claim_approved_email(claim):
    """Send email when admin approves claim"""
    context = {
        'full_name': claim.user.full_name,
        'claim_number': claim.claim_number,
        'device': f"{claim.policy.device_package.device_brand} {claim.policy.device_package.device_model}",
        'claim_amount': claim.claim_amount,
        'admin_notes': claim.admin_notes,
    }
    return send_html_email(
        subject=f'Klaim Disetujui! ✅ - {claim.claim_number}',
        template_name='emails/claim_approved.html',
        context=context,
        recipient_email=claim.user.email
    )


def send_claim_rejected_email(claim):
    """Send email when admin rejects claim"""
    context = {
        'full_name': claim.user.full_name,
        'claim_number': claim.claim_number,
        'device': f"{claim.policy.device_package.device_brand} {claim.policy.device_package.device_model}",
        'admin_notes': claim.admin_notes or 'Silakan hubungi customer service untuk informasi lebih lanjut.',
    }
    return send_html_email(
        subject=f'Klaim Ditolak ❌ - {claim.claim_number}',
        template_name='emails/claim_rejected.html',
        context=context,
        recipient_email=claim.user.email
    )


def send_claim_completed_email(claim):
    """Send email when claim is completed"""
    context = {
        'full_name': claim.user.full_name,
        'claim_number': claim.claim_number,
        'device': f"{claim.policy.device_package.device_brand} {claim.policy.device_package.device_model}",
        'claim_amount': claim.claim_amount,
        'admin_notes': claim.admin_notes,
        'payment_date': claim.payment_date.strftime('%d %b %Y') if claim.payment_date else None,
    }
    return send_html_email(
        subject=f'Klaim Selesai! HP Anda Sudah Siap 🎉 - {claim.claim_number}',
        template_name='emails/claim_completed.html',
        context=context,
        recipient_email=claim.user.email
    )


def send_policy_expiry_warning(policy, days_remaining):
    """Send policy expiry warning email"""
    context = {
        'full_name': policy.user.full_name,
        'device': f"{policy.device_package.device_brand} {policy.device_package.device_model}",
        'policy_number': policy.policy_number,
        'end_date': policy.end_date.strftime('%d %b %Y'),
        'days_remaining': days_remaining,
    }
    
    if days_remaining == 30:
        subject = '⚠️ Policy Akan Expired dalam 30 Hari'
        template = 'emails/policy_expiry_30d.html'
    elif days_remaining == 7:
        subject = '🚨 URGENT: Policy Expired dalam 7 Hari!'
        template = 'emails/policy_expiry_7d.html'
    else:  # 1 day
        subject = '🔴 TERAKHIR: Policy Expired BESOK!'
        template = 'emails/policy_expiry_1d.html'
    
    return send_html_email(
        subject=subject,
        template_name=template,
        context=context,
        recipient_email=policy.user.email
    )
