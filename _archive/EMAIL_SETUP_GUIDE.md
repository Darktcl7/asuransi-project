# 📧 EMAIL NOTIFICATIONS - QUICK SETUP GUIDE

**Estimated Time:** 30 minutes  
**Difficulty:** Easy

---

## 🎯 **WHAT YOU'LL GET:**

✅ Welcome email saat user register  
✅ Email saat claim submitted  
✅ Email saat claim approved/rejected/completed  
✅ Policy expiry warning emails (30d, 7d, 1d)

---

## 📋 **SETUP STEPS:**

### **Step 1: Configure Email Settings (5 min)**

Edit `config/settings.py`:

```python
# Email Configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'  # ← CHANGE THIS
EMAIL_HOST_PASSWORD = 'your-app-password'  # ← CHANGE THIS
DEFAULT_FROM_EMAIL = 'PhoneGuard Insurance <noreply@phoneguard.com>'
EMAIL_TIMEOUT = 10
```

**Important:** Jangan commit password ke git! Gunakan environment variables.

---

### **Step 2: Get Gmail App Password (10 min)**

**Why App Password?**  
Gmail tidak allow login dengan password biasa untuk security. Perlu app-specific password.

**How to Get:**

1. **Go to Google Account:**  
   https://myaccount.google.com/apppasswords

2. **Select app:** Mail  
   **Select device:** Windows Computer

3. **Generate Password:**  
   Copy the 16-character password (format: xxxx xxxx xxxx xxxx)

4. **Use in settings.py:**
   ```python
   EMAIL_HOST_PASSWORD = 'abcd efgh ijkl mnop'  # Paste here
   ```

**Note:** App password works even if 2FA is enabled!

---

### **Step 3: Create Email Templates (10 min)**

Create directory:
```bash
mkdir -p templates/emails
```

**Create base template:** `templates/emails/base.html`

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                  color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #fff; padding: 30px; border: 1px solid #e0e0e0; }
        .footer { background: #f5f5f5; padding: 20px; text-align: center; 
                  font-size: 12px; color: #666; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #667eea; 
                  color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📱 PhoneGuard Insurance</h1>
        </div>
        <div class="content">
            {% block content %}{% endblock %}
        </div>
        <div class="footer">
            <p>© 2025 PhoneGuard Insurance. All rights reserved.</p>
            <p>Butuh bantuan? Email: support@phoneguard.com</p>
        </div>
    </div>
</body>
</html>
```

**Create welcome email:** `templates/emails/welcome.html`

```html
{% extends 'emails/base.html' %}
{% block content %}
<h2>Selamat Datang, {{ full_name }}! 🎉</h2>
<p>Terima kasih telah bergabung dengan PhoneGuard Insurance!</p>
<p><strong>Email Anda:</strong> {{ email }}</p>
<p>Anda sekarang bisa:</p>
<ul>
    <li>Membeli polis asuransi untuk HP Anda</li>
    <li>Mengajukan klaim kerusakan</li>
    <li>Melacak status klaim</li>
</ul>
<p>Jika ada pertanyaan, jangan ragu untuk menghubungi kami.</p>
<p>Salam hangat,<br><strong>Tim PhoneGuard Insurance</strong></p>
{% endblock %}
```

**Create claim submitted email:** `templates/emails/claim_submitted.html`

```html
{% extends 'emails/base.html' %}
{% block content %}
<h2>Klaim Anda Telah Diterima</h2>
<p>Halo {{ full_name }},</p>
<p>Klaim Anda sudah kami terima dan sedang diproses:</p>
<div style="background: #f8f9fa; padding: 15px; border-left: 4px solid #667eea; margin: 20px 0;">
    <strong>Detail Klaim:</strong><br>
    📱 Device: {{ device }}<br>
    🔢 Nomor Klaim: {{ claim_number }}<br>
    📝 Kerusakan: {{ damage_type }}<br>
    📅 Tanggal: {{ created_date }}
</div>
<p>Status: <strong>PENDING</strong> (Menunggu review admin)</p>
<p>Kami akan review klaim Anda dalam 1-2 hari kerja.</p>
<p>Terima kasih,<br>Tim PhoneGuard Insurance</p>
{% endblock %}
```

---

### **Step 4: Setup Django Signals (5 min)**

Create `claims/signals.py`:

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Claim
from utils.email_service import (
    send_claim_submitted_email,
    send_claim_approved_email,
    send_claim_rejected_email,
    send_claim_completed_email
)
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Claim)
def send_claim_notification_email(sender, instance, created, **kwargs):
    """Send email notification on claim status change"""
    try:
        if created:
            # New claim submitted
            send_claim_submitted_email(instance)
            logger.info(f"Claim submitted email sent for {instance.claim_number}")
        else:
            # Status changed
            old_status = getattr(instance, '_old_status', None)
            if old_status != instance.status:
                if instance.status == 'approved':
                    send_claim_approved_email(instance)
                elif instance.status == 'rejected':
                    send_claim_rejected_email(instance)
                elif instance.status == 'completed':
                    send_claim_completed_email(instance)
                logger.info(f"Claim {instance.status} email sent for {instance.claim_number}")
    except Exception as e:
        logger.error(f"Failed to send claim email: {str(e)}")
```

**Register signals in** `claims/apps.py`:

```python
from django.apps import AppConfig

class ClaimsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'claims'
    
    def ready(self):
        import claims.signals  # Import signals
```

---

## 🧪 **TEST EMAILS:**

**Test in Django shell:**

```python
python manage.py shell

from users.models import User
from utils.email_service import send_welcome_email

user = User.objects.first()
send_welcome_email(user)

# Check your email inbox!
```

---

## 🚨 **TROUBLESHOOTING:**

### **Error: SMTPAuthenticationError**
**Fix:** Make sure you're using App Password, not regular Gmail password.

### **Error: Connection timeout**
**Fix:** Check firewall, try different network.

### **Emails go to Spam**
**Fix:** 
- Use proper FROM email
- Add SPF/DKIM records (advanced)
- Send to yourself first for testing

---

## 📊 **GMAIL LIMITS:**

```
Free Gmail Account:
- 500 emails per day
- 100 recipients per email
- Good for testing & small scale

G Suite (Paid):
- 2000 emails per day
- Better for production
```

---

## 🎯 **WHAT'S INCLUDED:**

✅ `utils/email_service.py` - Email functions  
✅ `templates/emails/` - HTML templates  
✅ `claims/signals.py` - Auto-send on claim events  
✅ `EMAIL_SETUP_GUIDE.md` - This guide

---

## 🚀 **NEXT STEPS AFTER SETUP:**

1. **Test all email types:**
   - Welcome email
   - Claim submitted
   - Claim approved
   - Claim rejected
   - Claim completed

2. **Create remaining templates:**
   - claim_approved.html
   - claim_rejected.html
   - claim_completed.html
   - policy_expiry_30d.html

3. **Setup cron for expiry warnings:**
   ```bash
   # Run daily at 9 AM
   0 9 * * * cd /path/to/project && python manage.py send_expiry_warnings
   ```

---

**Total Setup Time:** ~30 minutes  
**Benefit:** Professional user communication! 🎉
