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
    
    # Add flat fields for Flutter (allow null)
    device_brand = serializers.CharField(
        source='policy.device_package.device_brand', 
        read_only=True, 
        allow_null=True,
        default=''
    )
    device_model = serializers.CharField(
        source='policy.device_package.device_model', 
        read_only=True,
        allow_null=True,
        default=''
    )
    
    # Add fields for Admin Dashboard
    user_name = serializers.SerializerMethodField()
    user_email = serializers.EmailField(source='user.email', read_only=True)
    device = serializers.SerializerMethodField()
    
    def get_user_name(self, obj):
        """Get user full name"""
        return f"{obj.user.first_name} {obj.user.last_name}".strip() or obj.user.email
    
    def get_device(self, obj):
        """Get device info (Brand + Model)"""
        try:
            pkg = obj.policy.device_package
            return f"{pkg.device_brand} {pkg.device_model}"
        except:
            return "N/A"

    class Meta:
        model = Claim
        fields = '__all__'
        read_only_fields = [
            'claim_number', 'user', 'wallet_deducted', 'status', 'claim_amount'
        ]