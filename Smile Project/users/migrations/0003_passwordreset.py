# Generated migration for PasswordReset model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_alter_user_managers_user_users_email_4b85f2_idx_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='PasswordReset',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('otp_code', models.CharField(max_length=6)),
                ('method', models.CharField(choices=[('email', 'Email'), ('sms', 'SMS')], default='email', max_length=10)),
                ('sent_to', models.CharField(max_length=255)),
                ('is_used', models.BooleanField(default=False)),
                ('used_at', models.DateTimeField(blank=True, null=True)),
                ('attempts', models.IntegerField(default=0)),
                ('max_attempts', models.IntegerField(default=5)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('expires_at', models.DateTimeField()),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='password_resets', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='passwordreset',
            index=models.Index(fields=['user', '-created_at'], name='users_passw_user_id_5f0e51_idx'),
        ),
        migrations.AddIndex(
            model_name='passwordreset',
            index=models.Index(fields=['otp_code', 'is_used'], name='users_passw_otp_cod_8c3e24_idx'),
        ),
    ]
