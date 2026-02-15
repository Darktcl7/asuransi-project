# wallet/views.py

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone

from .models import Wallet, WalletHistory
from .serializers import WalletSerializer, TopUpSerializer, WalletHistorySerializer

class WalletViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet untuk melihat Wallet dan Riwayat.
    Hanya 'ReadOnly' karena balance diubah oleh sistem, bukan oleh user.
    """
    serializer_class = WalletSerializer

    def get_queryset(self):
        # User hanya bisa melihat wallet-nya sendiri
        return Wallet.objects.filter(user=self.request.user)

    # Endpoint: /api/wallet/topup/
    @action(detail=False, methods=['post'])
    def topup(self, request):
        wallet = request.user.wallet
        serializer = TopUpSerializer(data=request.data)

        if serializer.is_valid():
            # Buat ID transaksi unik
            trx_id = f"TOP-{timezone.now().strftime('%Y%m%d%H%M%S')}-{request.user.id.hex[:4]}"

            # Simpan transaksi top up
            topup = serializer.save(
                user=request.user,
                transaction_id=trx_id
            )
            return Response({
                'message': 'Top up berhasil dibuat. Menunggu verifikasi admin.',
                'data': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Endpoint: /api/wallet/history/
    @action(detail=False, methods=['get'])
    def history(self, request):
        wallet = request.user.wallet
        # OPTIMIZED: Limit to last 500 transactions to prevent loading millions
        history = WalletHistory.objects.filter(wallet=wallet).order_by('-created_at')[:500]

        # Terapkan Paginasi (dari settings.py)
        page = self.paginate_queryset(history)
        if page is not None:
            serializer = WalletHistorySerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = WalletHistorySerializer(history, many=True)
        return Response(serializer.data)