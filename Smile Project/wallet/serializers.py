# wallet/serializers.py

from rest_framework import serializers
from .models import Wallet, TopUpTransaction, WalletHistory

class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wallet
        fields = ['id', 'balance', 'total_topup', 'total_spent']

class TopUpSerializer(serializers.ModelSerializer):
    class Meta:
        model = TopUpTransaction
        fields = [
            'id', 
            'amount', 
            'payment_method', 
            'transaction_id', 
            'status', 
            'payment_proof_url', 
            'created_at'
        ]
        # User tidak bisa mengubah status
        read_only_fields = ['status', 'transaction_id'] 

    def validate_amount(self, value):
        # Validasi minimal top up 100rb
        if value < 100000:
            raise serializers.ValidationError("Minimal top up Rp 100.000")
        return value

class WalletHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = WalletHistory
        fields = '__all__'