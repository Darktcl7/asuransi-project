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
    user_name = serializers.SerializerMethodField()
    
    # Flat fields for Frontend (Defensive)
    tier_name = serializers.SerializerMethodField()
    device_brand = serializers.SerializerMethodField()
    device_model = serializers.SerializerMethodField()
    store_name = serializers.SerializerMethodField()
    claims_limit = serializers.SerializerMethodField()
    max_claims_per_year = serializers.SerializerMethodField()

    class Meta:
        model = Policy
        fields = [
            'id', 'policy_number', 'user', 'user_name', 'tier', 
            'tier_details', 'tier_name', 'device_brand', 'device_model', 'store_name', 
            'claims_limit', 'max_claims_per_year',
            'device_package', 'device_details', 
            'imei_number', 'purchase_price', 'policy_price', 'policy_balance',
            'activation_date', 'expiry_date', 'claims_used', 'status'
        ]
        # Field ini akan diisi oleh sistem di backend
        read_only_fields = [
            'policy_number', 'user', 'tier', 'policy_price', 'policy_balance',
            'activation_date', 'expiry_date', 'claims_used', 'status'
        ]

    def get_user_name(self, obj):
        try:
            if not obj.user: return None
            return f"{obj.user.first_name} {obj.user.last_name}".strip() or obj.user.email
        except:
            return None

    def get_tier_name(self, obj):
        try:
            return obj.tier.tier_name if obj.tier else None
        except:
            return None

    def get_device_brand(self, obj):
        try:
            return obj.device_package.device_brand if obj.device_package else None
        except:
            return None

    def get_device_model(self, obj):
        try:
            return obj.device_package.device_model if obj.device_package else None
        except:
            return None

    def get_store_name(self, obj):
        try:
            return obj.store.name if obj.store else None
        except:
            return None

    def get_claims_limit(self, obj):
        try:
            return obj.tier.max_claims_per_year if obj.tier else 0
        except:
            return 0
        
    def get_max_claims_per_year(self, obj):
        try:
            return obj.tier.max_claims_per_year if obj.tier else 0
        except:
            return 0