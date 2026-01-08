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
    queryset = User.objects.all()
    serializer_class = UserSerializer

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
    # (Hanya butuh token, tidak perlu ID)
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request):
        # 'request.user' adalah user yang sedang login
        serializer = self.get_serializer(request.user) 
        return Response(serializer.data)