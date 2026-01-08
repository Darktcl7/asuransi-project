# policies/serializers.py

from rest_framework import serializers
from .models import PolicyTier, DevicePackage, Policy

class PolicyTierSerializer(serializers.ModelSerializer):
    class Meta:
        model = PolicyTier
        fields = '__all__'

class DevicePackageSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_device_category_display', read_only=True)
    
    class Meta:
        model = DevicePackage
        fields = [
            'id', 'device_category', 'category_display',
            'device_brand', 'device_model', 'device_variant', 
            'device_color', 'device_value', 'is_active'
        ]

class PolicySerializer(serializers.ModelSerializer):
    # Tampilkan detail, bukan cuma ID
    tier_details = PolicyTierSerializer(source='tier', read_only=True)
    device_details = DevicePackageSerializer(source='device_package', read_only=True)
    user_name = serializers.CharField(source='user.first_name', read_only=True)
    
    # Add flat fields for Flutter
    tier_name = serializers.CharField(source='tier.tier_name', read_only=True)
    claims_limit = serializers.IntegerField(source='tier.max_claims_per_year', read_only=True)
    max_claims_per_year = serializers.IntegerField(source='tier.max_claims_per_year', read_only=True)

    class Meta:
        model = Policy
        fields = [
            'id', 'policy_number', 'user', 'user_name', 'tier', 
            'tier_details', 'tier_name', 'claims_limit', 'max_claims_per_year',
            'device_package', 'device_details', 
            'imei_number', 'purchase_price', 'policy_price', 'policy_balance',
            'activation_date', 'expiry_date', 'claims_used', 'status'
        ]
        # Field ini akan diisi oleh sistem di backend
        read_only_fields = [
            'policy_number', 'user', 'tier', 'policy_price', 'policy_balance',
            'activation_date', 'expiry_date', 'claims_used', 'status'
        ]