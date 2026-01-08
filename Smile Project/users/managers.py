# users/managers.py

from django.contrib.auth.models import BaseUserManager

class CustomUserManager(BaseUserManager):
    """
    Manajer kustom untuk model User kita, di mana email adalah
    identifier unik, bukan username.
    """
    def create_user(self, email, password, **extra_fields):
        """
        Membuat dan menyimpan User dengan email dan password.
        """
        if not email:
            raise ValueError('Email harus diisi')
        
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password) # Ini untuk hashing password
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **extra_fields):
        """
        Membuat dan menyimpan Superuser dengan email dan password.
        
        Ini adalah fungsi yang dipanggil oleh 'createsuperuser'
        """
        # Set default wajib untuk superuser
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        # Panggil create_user yang sudah kita buat di atas
        return self.create_user(email, password, **extra_fields)