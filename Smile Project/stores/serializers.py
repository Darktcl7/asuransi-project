# stores/serializers.py

from rest_framework import serializers
from .models import Store


class StoreSerializer(serializers.ModelSerializer):
    """Serializer for Store model"""
    
    class Meta:
        model = Store
        fields = [
            'id', 'code', 'name', 'registration_code',
            'address', 'city', 'province', 'postal_code',
            'phone', 'email', 
            'is_active', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class StoreListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing stores"""
    
    class Meta:
        model = Store
        fields = ['id', 'code', 'name', 'registration_code', 'city', 'is_active']
