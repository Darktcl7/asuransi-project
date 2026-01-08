# admin_api/admin_topup_views.py
"""
Admin Manual Top-Up Views
Allow admin to create top-up transactions for users directly
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from decimal import Decimal
from django.utils import timezone

from users.models import User
from wallet.models import Wallet, TopUpTransaction, WalletHistory


class AdminTopUpViewSet(viewsets.ViewSet):
    """
    Admin can create top-up for any user
    POST /api/admin/topups/
    """
    permission_classes = [IsAdminUser]
    
    def create(self, request):
        """
        Create manual top-up for user
        Body: {
            user: user_id,
            amount: 100000,
            payment_method: 'admin_topup',
            notes: 'Manual top-up by admin',
            status: 'completed'
        }
        """
        user_id = request.data.get('user')
        amount = request.data.get('amount')
        payment_method = request.data.get('payment_method', 'admin_topup')
        notes = request.data.get('notes', 'Manual top-up by admin')
        topup_status = request.data.get('status', 'completed')
        
        # Validation
        if not user_id:
            return Response(
                {'error': 'User ID required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not amount or float(amount) <= 0:
            return Response(
                {'error': 'Amount must be positive'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Get or create wallet
        wallet, created = Wallet.objects.get_or_create(
            user=user,
            defaults={'balance': Decimal('0.00')}
        )
        
        # Create top-up transaction
        topup = TopUpTransaction.objects.create(
            user=user,
            transaction_id=f"ADMIN{timezone.now().strftime('%Y%m%d%H%M%S')}",
            amount=Decimal(str(amount)),
            payment_method=payment_method,
            status=topup_status,
            admin_notes=notes
        )
        
        # If status is completed, update wallet immediately
        if topup_status == 'completed':
            old_balance = wallet.balance
            wallet.balance += topup.amount
            wallet.total_topup += topup.amount
            wallet.save()
            
            # Create wallet history
            WalletHistory.objects.create(
                wallet=wallet,
                transaction_type='topup',
                amount=topup.amount,
                balance_before=old_balance,
                balance_after=wallet.balance,
                description=f"Admin top-up: {notes}",
                reference_id=str(topup.id)
            )
        
        return Response({
            'message': 'Top-up created successfully',
            'topup': {
                'id': str(topup.id),
                'user': user.email,
                'amount': float(topup.amount),
                'status': topup.status,
                'transaction_id': topup.transaction_id
            },
            'wallet': {
                'balance': float(wallet.balance)
            } if topup_status == 'completed' else None
        }, status=status.HTTP_201_CREATED)
