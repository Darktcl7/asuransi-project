# users/serializers.py

from rest_framework import serializers
from django.contrib.auth import get_user_model

# Import model Wallet
from wallet.models import Wallet 
from stores.models import Store

User = get_user_model() # Mengambil model User kustom kita

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    password_confirm = serializers.CharField(write_only=True, style={'input_type': 'password'})
    
    # Store registration code - customer inputs this to be assigned to a store
    store_code = serializers.CharField(
        write_only=True, 
        required=True,
        max_length=10,
        help_text="Kode toko dari Admin (contoh: KUA001)"
    )

    class Meta:
        model = User
        # Ambil field sesuai file docs Anda
        fields = [
            'email', 
            'password', 
            'password_confirm', 
            'first_name', # Kita pakai first_name & last_name
            'last_name',
            'phone_number',
            'ktp_number',  # Tambahkan KTP untuk identifikasi
            'birth_date',
            'store_code',  # Kode toko untuk registrasi
        ]

    def validate_store_code(self, value):
        """Validate store code exists and is active"""
        store = Store.get_by_registration_code(value)
        if not store:
            raise serializers.ValidationError(
                "Kode toko tidak valid. Silakan minta kode yang benar dari Admin toko."
            )
        return value

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Password tidak sama")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        store_code = validated_data.pop('store_code')
        
        # Find store by registration code
        store = Store.get_by_registration_code(store_code)

        # Buat user pakai create_user agar password di-hash
        user = User.objects.create_user(**validated_data)
        
        # Assign user to store
        if store:
            user.store = store
            user.save(update_fields=['store'])

        # TIDAK PERLU buat wallet manual, sudah ada signal!
        # Wallet akan otomatis dibuat oleh signal di wallet/signals.py
        return user

class UserSerializer(serializers.ModelSerializer):
    # Ambil saldo wallet dan tampilkan di profil user
    wallet_balance = serializers.DecimalField(
        source='wallet.balance', 
        max_digits=15, 
        decimal_places=2, 
        read_only=True
    )

    # Gabungkan first_name dan last_name
    full_name = serializers.SerializerMethodField()
    
    # Store info for multi-store system
    store = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 
            'email', 
            'full_name', # Ganti first_name & last_name
            'first_name',
            'last_name',
            'phone_number', 
            'ktp_number', 
            'is_verified', 
            'wallet_balance', # Tambahkan saldo
            'role', # Role untuk multi-store
            'store', # Store info
        ]

    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}"
    
    def get_store(self, obj):
        """Return store info if user has a store"""
        if obj.store:
            return {
                'id': str(obj.store.id),
                'code': obj.store.code,
                'name': obj.store.name,
                'registration_code': obj.store.registration_code,  # For admin display
            }
        return None