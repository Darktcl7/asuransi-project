from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser # Sudah ada
from django.db import transaction
from django.utils import timezone
from decimal import Decimal

from .models import Claim, ClaimPhoto
from .serializers import ClaimSerializer
from policies.models import Policy
# Note: WalletHistory no longer used - system now uses policy_balance


class ClaimViewSet(viewsets.ModelViewSet):
    """
    ViewSet untuk user mengajukan klaim.
    """
    serializer_class = ClaimSerializer
    
    def get_queryset(self):
        # User hanya bisa lihat klaim miliknya
        if self.request.user.is_staff:
            return Claim.objects.all().order_by('-created_at')
        return Claim.objects.filter(user=self.request.user).order_by('-created_at')
    
    @transaction.atomic
    def create(self, request):
        data = request.data
        user = request.user
        
        # Support both 'policy' and 'policy_id' field names
        policy_id = data.get('policy') or data.get('policy_id')
        if not policy_id:
            return Response({'error': 'Policy ID is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Pastikan polis adalah milik user yang mengajukan
            policy = Policy.objects.get(id=policy_id, user=user)
        except Policy.DoesNotExist:
            return Response({'error': 'Polis tidak ditemukan'}, status=status.HTTP_404_NOT_FOUND)

        # 1. Validasi Polis Aktif
        if policy.status != 'active':
            return Response({'error': 'Polis tidak aktif'}, status=status.HTTP_400_BAD_REQUEST)
        
        # 2. Validasi Tanggal Expired (Policy maksimal 1 tahun)
        if policy.is_expired():
            # Auto-update status to expired
            policy.status = 'expired'
            policy.save()
            return Response({
                'error': 'Polis sudah kadaluarsa (maksimal 1 tahun)',
                'expiry_date': policy.expiry_date.isoformat()
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # 3. Validasi Policy Balance - minimal harus ada saldo
        if policy.policy_balance <= 0:
            return Response({
                'error': 'Saldo policy sudah habis. Tidak bisa mengajukan klaim.',
                'policy_balance': float(policy.policy_balance)
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # 4. Buat Klaim (Status 'Pending' - Admin will set claim_amount later)
        claim = Claim.objects.create(
            user=user,
            policy=policy,
            claim_number=f"CLM-{timezone.now().strftime('%Y%m%d%H%M%S')}",
            damage_type=data['damage_type'],
            damage_description=data.get('damage_description', ''),
            incident_date=data['incident_date'],
            claim_amount=0,  # Admin will set this on approval
            status='pending' 
        )
        
        # 5. Handle photo uploads (multipart form data)
        photos = request.FILES.getlist('photos')
        print(f"[DEBUG] Received FILES: {request.FILES}")
        print(f"[DEBUG] Photos list: {photos}")
        print(f"[DEBUG] Number of photos: {len(photos) if photos else 0}")
        
        if photos:
            for photo in photos:
                print(f"[DEBUG] Processing photo: {photo.name}, size: {photo.size}")
                # Validate file size (max 10MB)
                if photo.size > 10 * 1024 * 1024:
                    print(f"[DEBUG] Photo {photo.name} exceeds 10MB, skipping")
                    continue  # Skip files > 10MB
                
                created_photo = ClaimPhoto.objects.create(
                    claim=claim,
                    photo=photo
                )
                print(f"[DEBUG] Created ClaimPhoto: {created_photo.id}")
        
        response_data = {
            'message': 'Klaim berhasil dibuat. Menunggu review admin.',
            'data': ClaimSerializer(claim, context={'request': request}).data,
            'info': 'Admin akan menentukan biaya perbaikan.',
            'photos_uploaded': len(photos) if photos else 0
        }
        
        return Response(response_data, status=status.HTTP_201_CREATED)


class AdminClaimViewSet(viewsets.ModelViewSet):
    """
    ViewSet HANYA UNTUK ADMIN.
    Untuk menyetujui atau menolak klaim.
    """
    queryset = Claim.objects.all().order_by('-created_at')
    serializer_class = ClaimSerializer
    permission_classes = [IsAdminUser] # Hanya Admin/Superuser yang bisa akses

    @transaction.atomic
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        claim = self.get_object()
        policy = claim.policy
        
        # Admin bisa update claim_amount sebelum approve
        new_claim_amount = request.data.get('claim_amount')
        if new_claim_amount:
            claim.claim_amount = Decimal(new_claim_amount)
            claim.save()
        
        # Sistem baru: Potong dari POLICY BALANCE (bukan wallet!)
        amount_to_deduct = claim.claim_amount
        
        # Cek saldo policy
        if policy.policy_balance < amount_to_deduct:
            return Response({
                'error': 'Saldo policy tidak cukup untuk biaya perbaikan',
                'required': float(amount_to_deduct),
                'current_balance': float(policy.policy_balance)
            }, status=status.HTTP_400_BAD_REQUEST)

        # Potong Saldo Policy (sesuai biaya perbaikan yang ditentukan admin)
        balance_before = policy.policy_balance
        policy.policy_balance -= amount_to_deduct
        policy.claims_used += 1
        policy.save()

        # Update Status Klaim
        claim.status = 'approved'
        claim.wallet_deducted = amount_to_deduct  # Field name kept for backward compatibility
        claim.processed_by = request.user
        claim.processed_date = timezone.now()
        
        # Update admin notes if provided
        admin_notes = request.data.get('admin_notes')
        if admin_notes:
            claim.admin_notes = admin_notes
        
        claim.save()

        return Response({
            'message': 'Klaim berhasil disetujui dan saldo policy dipotong',
            'data': ClaimSerializer(claim).data,
            'policy_balance_info': {
                'amount_deducted': float(amount_to_deduct),
                'balance_before': float(balance_before),
                'balance_after': float(policy.policy_balance)
            }
        }) 

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        claim = self.get_object()
        claim.status = 'rejected'
        claim.processed_by = request.user
        claim.processed_date = timezone.now()
        claim.admin_notes = request.data.get('rejection_reason', 'Ditolak')
        claim.save()
        
        return Response({
            'message': 'Klaim ditolak',
            'data': ClaimSerializer(claim).data
        })
    
    @action(detail=True, methods=['post'])
    def set_in_progress(self, request, pk=None):
        """Set claim status to in_progress (sedang dikerjakan)"""
        claim = self.get_object()
        
        if claim.status != 'approved':
            return Response({
                'error': 'Hanya klaim yang sudah approved yang bisa diproses'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        claim.status = 'in_progress'
        
        # Update admin notes if provided
        admin_notes = request.data.get('admin_notes')
        if admin_notes:
            claim.admin_notes = admin_notes
        
        claim.save()
        
        return Response({
            'message': 'Status klaim diupdate ke In Progress',
            'data': ClaimSerializer(claim).data
        })
    
    @action(detail=True, methods=['post'])
    def set_completed(self, request, pk=None):
        """Set claim status to completed (selesai)"""
        claim = self.get_object()
        
        if claim.status not in ['approved', 'in_progress']:
            return Response({
                'error': 'Klaim harus dalam status approved atau in_progress'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        claim.status = 'completed'
        
        # Update admin notes if provided
        admin_notes = request.data.get('admin_notes')
        if admin_notes:
            claim.admin_notes = admin_notes
        
        claim.save()
        
        return Response({
            'message': 'Klaim selesai dikerjakan',
            'data': ClaimSerializer(claim).data
        })

    @transaction.atomic
    @action(detail=False, methods=['post'])
    def create_for_user(self, request):
        """
        Admin creates a claim on behalf of a user.
        Use case: User's phone is damaged and they cannot access the app.
        """
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        data = request.data
        
        # Validate required fields
        user_id = data.get('user_id')
        policy_id = data.get('policy_id')
        damage_type = data.get('damage_type')
        incident_date = data.get('incident_date')
        
        if not all([user_id, policy_id, damage_type, incident_date]):
            return Response({
                'error': 'Missing required fields: user_id, policy_id, damage_type, incident_date'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get user
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User tidak ditemukan'}, status=status.HTTP_404_NOT_FOUND)
        
        # Get and validate policy
        try:
            policy = Policy.objects.get(id=policy_id, user=user)
        except Policy.DoesNotExist:
            return Response({'error': 'Policy tidak ditemukan atau bukan milik user ini'}, status=status.HTTP_404_NOT_FOUND)
        
        # Validate policy is active
        if policy.status != 'active':
            return Response({'error': f'Policy tidak aktif (status: {policy.status})'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate not expired
        if policy.is_expired():
            policy.status = 'expired'
            policy.save()
            return Response({
                'error': 'Policy sudah kadaluarsa',
                'expiry_date': policy.expiry_date.isoformat()
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate balance
        if policy.policy_balance <= 0:
            return Response({
                'error': 'Saldo policy sudah habis',
                'policy_balance': float(policy.policy_balance)
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create claim on behalf of user
        claim = Claim.objects.create(
            user=user,
            policy=policy,
            claim_number=f"CLM-ADM-{timezone.now().strftime('%Y%m%d%H%M%S')}",
            damage_type=damage_type,
            damage_description=data.get('damage_description', 'Klaim diajukan oleh Admin'),
            incident_date=incident_date,
            claim_amount=0,  # Admin will set this on approval
            status='pending',
            admin_notes=f"Klaim diajukan oleh Admin ({request.user.email}) atas nama user. Alasan: {data.get('reason', 'HP user rusak, tidak bisa akses aplikasi')}"
        )
        
        # Handle photo uploads (if any)
        photos = request.FILES.getlist('photos')
        if photos:
            for photo in photos:
                if photo.size <= 10 * 1024 * 1024:  # Max 10MB
                    ClaimPhoto.objects.create(
                        claim=claim,
                        photo=photo
                    )
        
        return Response({
            'message': f'Klaim berhasil dibuat atas nama {user.full_name or user.email}',
            'data': ClaimSerializer(claim, context={'request': request}).data,
            'created_by_admin': request.user.email,
            'photos_uploaded': len(photos) if photos else 0
        }, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['get'])
    def users_with_policies(self, request):
        """
        Get list of users who have active policies.
        Used for Admin-Assisted Claim form dropdown.
        """
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        # Get users with at least one active policy
        # Note: Policy model uses default related_name 'policy_set'
        users_with_active_policies = User.objects.filter(
            policy__status='active'
        ).distinct().values('id', 'email', 'full_name', 'phone_number')
        
        return Response(list(users_with_active_policies))
    
    @action(detail=False, methods=['get'])
    def user_policies(self, request):
        """
        Get active policies for a specific user.
        Used for Admin-Assisted Claim form.
        """
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({'error': 'user_id parameter required'}, status=status.HTTP_400_BAD_REQUEST)
        
        policies = Policy.objects.filter(
            user_id=user_id,
            status='active'
        ).select_related('device').values(
            'id', 'policy_number', 'device__brand', 'device__model', 
            'policy_balance', 'expiry_date', 'tier_name'
        )
        
        return Response(list(policies))