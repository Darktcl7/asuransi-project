# users/serializers.py

from rest_framework import serializers
from django.contrib.auth import get_user_model

# Import model Wallet
from wallet.models import Wallet 

User = get_user_model() # Mengambil model User kustom kita

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    password_confirm = serializers.CharField(write_only=True, style={'input_type': 'password'})

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
            'birth_date'
        ]

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Password tidak sama")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')

        # Buat user pakai create_user agar password di-hash
        user = User.objects.create_user(**validated_data) 

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

    class Meta:
        model = User
        fields = [
            'id', 
            'email', 
            'full_name', # Ganti first_name & last_name
            'phone_number', 
            'ktp_number', 
            'is_verified', 
            'wallet_balance' # Tambahkan saldo
        ]

    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}"