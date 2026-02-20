# claims/serializers.py

from rest_framework import serializers
from .models import Claim, ClaimPhoto
from policies.serializers import PolicySerializer


class ClaimPhotoSerializer(serializers.ModelSerializer):
    """Serializer for claim photos"""
    photo_url = serializers.SerializerMethodField()
    
    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo and request:
            return request.build_absolute_uri(obj.photo.url)
        elif obj.photo:
            return obj.photo.url
        return None
    
    class Meta:
        model = ClaimPhoto
        fields = ['id', 'photo', 'photo_url', 'uploaded_at']
        read_only_fields = ['id', 'uploaded_at']


class ClaimSerializer(serializers.ModelSerializer):
    # Tampilkan detail polis saat melihat klaim
    policy_details = PolicySerializer(source='policy', read_only=True)
    
    # Include photos
    photos = ClaimPhotoSerializer(many=True, read_only=True)
    
    # Add flat fields for Frontend (Defensive)
    device_brand = serializers.SerializerMethodField()
    device_model = serializers.SerializerMethodField()
    user_name = serializers.SerializerMethodField()
    user_email = serializers.SerializerMethodField()
    device = serializers.SerializerMethodField()
    
    def get_user_name(self, obj):
        """Get user full name"""
        try:
            if not obj.user: return "N/A"
            return f"{obj.user.first_name} {obj.user.last_name}".strip() or obj.user.email
        except:
            return "N/A"

    def get_user_email(self, obj):
        try:
            return obj.user.email if obj.user else "N/A"
        except:
            return "N/A"
    
    def get_device(self, obj):
        """Get device info (Brand + Model)"""
        try:
            pkg = obj.policy.device_package
            return f"{pkg.device_brand} {pkg.device_model}"
        except:
            return "N/A"

    def get_device_brand(self, obj):
        try:
            return obj.policy.device_package.device_brand
        except:
            return ""

    def get_device_model(self, obj):
        try:
            return obj.policy.device_package.device_model
        except:
            return ""

    class Meta:
        model = Claim
        fields = '__all__'
        read_only_fields = [
            'claim_number', 'user', 'wallet_deducted', 'status', 'claim_amount'
        ]