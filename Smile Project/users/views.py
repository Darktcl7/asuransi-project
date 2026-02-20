from django.shortcuts import render

# Create your views here.
# users/views.py

from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token

from .serializers import UserRegistrationSerializer, UserSerializer

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    
    def get_queryset(self):
        # OPTIMIZED with select_related for store
        return User.objects.select_related('store').order_by('-date_joined')

    # Endpoint: /api/users/register/
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Buat token otomatis saat register
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Endpoint: /api/users/me/
    # GET: Get current user profile
    # PATCH: Update current user profile
    @action(detail=False, methods=['get', 'patch'], permission_classes=[IsAuthenticated])
    def me(self, request):
        user = request.user
            
        if request.method == 'GET':
            # 'request.user' adalah user yang sedang login
            serializer = self.get_serializer(user)
            print(f"DEBUG PROFILE: User={user.email}, SerializedRole={serializer.data.get('role')}")
            return Response(serializer.data)
        
        elif request.method == 'PATCH':
            # Update profile fields
            data = request.data
            
            # Fields yang boleh diupdate oleh user sendiri
            allowed_fields = ['full_name', 'first_name', 'last_name', 'phone_number', 'address', 'ktp_number']
            
            for field in allowed_fields:
                if field in data:
                    if field == 'full_name':
                        # Split full_name into first_name and last_name
                        names = data['full_name'].strip().split(' ', 1)
                        user.first_name = names[0]
                        user.last_name = names[1] if len(names) > 1 else ''
                    elif field == 'ktp_number':
                        # KTP hanya bisa diinput SEKALI oleh customer
                        # Jika sudah ada KTP, tidak bisa diubah (hanya admin yang bisa)
                        if user.ktp_number and user.ktp_number.strip():
                            return Response({
                                'error': 'Nomor KTP sudah diinput sebelumnya dan tidak dapat diubah. Hubungi admin jika ingin mengubah.'
                            }, status=status.HTTP_400_BAD_REQUEST)
                        setattr(user, field, data[field])
                    else:
                        setattr(user, field, data[field])
            
            user.save()
            serializer = self.get_serializer(user)
            return Response(serializer.data)