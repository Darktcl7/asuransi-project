from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from django.db.models import Sum
from datetime import datetime
import openpyxl
from django.http import HttpResponse

from policies.models import Policy
from claims.models import Claim

class AdminReportViewSet(viewsets.ViewSet):
    """
    Reporting & Analytics API - Simple Version
    """
    permission_classes = [IsAdminUser]

    def list(self, request):
        try:
            start_date = request.query_params.get('start_date', '').strip()
            end_date = request.query_params.get('end_date', '').strip()

            data = []
            
            # Get user info for filtering
            user = request.user
            is_store_admin = hasattr(user, 'role') and user.role in ['store_admin', 'store_staff']
            user_store = getattr(user, 'store', None)
            
            # ===== BASE QUERIES =====
            all_policies = Policy.objects.filter(status__in=['active', 'expired'])
            all_claims = Claim.objects.filter(status__in=['approved', 'completed'])
            
            # Apply date filter if both dates provided
            if start_date and end_date:
                all_policies = all_policies.filter(created_at__date__range=[start_date, end_date])
                all_claims = all_claims.filter(created_at__date__range=[start_date, end_date])
            
            # ✅ FIX: Store Admin only sees their store data
            if is_store_admin and user_store:
                all_policies = all_policies.filter(store=user_store)
                all_claims = all_claims.filter(policy__store=user_store)
            
            # ===== GLOBAL TOTALS =====
            global_policy_count = all_policies.count()
            global_revenue = float(all_policies.aggregate(s=Sum('policy_price'))['s'] or 0)
            global_claim_count = all_claims.count()
            global_claim_amount = float(all_claims.aggregate(s=Sum('claim_amount'))['s'] or 0)
            global_loss_ratio = (global_claim_amount / global_revenue * 100) if global_revenue > 0 else 0
            
            # Build response
            date_label = f" ({start_date} s/d {end_date})" if start_date and end_date else " (Semua Waktu)"
            
            data.append({
                'id': 'total',
                'name': f'📊 Total Keseluruhan{date_label}',
                'code': 'TOTAL',
                'location': 'Semua Data' if not is_store_admin else (user_store.name if user_store else 'N/A'),
                'sales': {
                    'count': global_policy_count,
                    'revenue': global_revenue
                },
                'claims': {
                    'count': global_claim_count,
                    'amount': global_claim_amount
                },
                'loss_ratio': round(global_loss_ratio, 2)
            })
            
            # ===== PER-STORE BREAKDOWN (Super Admin Only) =====
            if not is_store_admin:
                from stores.models import Store
                stores = Store.objects.filter(is_active=True)
                
                for store in stores:
                    store_policies = all_policies.filter(store=store)
                    store_claims = all_claims.filter(policy__store=store)
                    
                    store_policy_count = store_policies.count()
                    store_revenue = float(store_policies.aggregate(s=Sum('policy_price'))['s'] or 0)
                    store_claim_count = store_claims.count()
                    store_claim_amount = float(store_claims.aggregate(s=Sum('claim_amount'))['s'] or 0)
                    store_loss_ratio = (store_claim_amount / store_revenue * 100) if store_revenue > 0 else 0
                    
                    data.append({
                        'id': str(store.id),
                        'name': store.name,
                        'code': store.registration_code,
                        'location': f"{store.city}, {store.province}" if store.city else store.address[:50],
                        'sales': {
                            'count': store_policy_count,
                            'revenue': store_revenue
                        },
                        'claims': {
                            'count': store_claim_count,
                            'amount': store_claim_amount
                        },
                        'loss_ratio': round(store_loss_ratio, 2)
                    })

            return Response(data)
            
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({'error': str(e)}, status=500)

    @action(detail=False, methods=['get'])
    def export(self, request):
        """Export Report to Excel"""
        try:
            response_data = self.list(request).data
            if isinstance(response_data, dict) and 'error' in response_data:
                return Response(response_data, status=500)
            
            wb = openpyxl.Workbook()
            ws = wb.active
            ws.title = "Laporan"

            headers = ['Kode', 'Nama', 'Lokasi', 'Total Polis', 'Revenue (Rp)', 'Total Klaim', 'Klaim Dibayar (Rp)', 'Loss Ratio (%)']
            ws.append(headers)

            for item in response_data:
                ws.append([
                    item['code'],
                    item['name'],
                    item['location'],
                    item['sales']['count'],
                    item['sales']['revenue'],
                    item['claims']['count'],
                    item['claims']['amount'],
                    item['loss_ratio']
                ])
                
            from openpyxl.styles import Font
            for cell in ws[1]:
                cell.font = Font(bold=True)

            response = HttpResponse(content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
            response['Content-Disposition'] = f'attachment; filename=laporan_{datetime.now().strftime("%Y%m%d")}.xlsx'
            
            wb.save(response)
            return response
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({'error': str(e)}, status=500)
