# Multi-Store System - Implementation Plan

## 📋 Overview

Dokumen ini menjelaskan rencana implementasi sistem **Multi-Toko (Multi-Branch)** untuk Smile Insurance, yang memungkinkan:

1. **Super Admin** - Kontrol penuh atas semua toko
2. **Store Admin** - Hanya bisa akses data toko masing-masing
3. **Activity Log** - Rekam semua aktivitas per toko
4. **Isolasi Data** - Data Toko A tidak bisa diakses oleh Toko B

---

## 🏗️ Arsitektur Sistem

### Hierarki User

```
                    ┌─────────────────────┐
                    │    SUPER ADMIN      │
                    │  (Full Access)      │
                    │                     │
                    │ • Lihat semua data  │
                    │ • Manage semua toko │
                    │ • Activity log      │
                    │ • Reports global    │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
    │ STORE ADMIN │     │ STORE ADMIN │     │ STORE ADMIN │
    │   TOKO A    │     │   TOKO B    │     │   TOKO C    │
    │             │     │             │     │             │
    │ • CRUD data │     │ • CRUD data │     │ • CRUD data │
    │   toko A    │     │   toko B    │     │   toko C    │
    │ • Approve   │     │ • Approve   │     │ • Approve   │
    │   claims A  │     │   claims B  │     │   claims C  │
    └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
           │                   │                   │
           ▼                   ▼                   ▼
    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
    │ CUSTOMERS   │     │ CUSTOMERS   │     │ CUSTOMERS   │
    │   TOKO A    │     │   TOKO B    │     │   TOKO C    │
    └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 🗄️ Database Schema

### 1. Model Baru: Store (Toko)

```python
# stores/models.py

import uuid
from django.db import models

class Store(models.Model):
    """
    Representasi toko/cabang.
    Setiap toko memiliki admin dan customer sendiri.
    """
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    
    # Informasi Toko
    code = models.CharField(
        max_length=20, 
        unique=True,
        help_text="Kode unik toko, contoh: STORE-JKT-01"
    )
    name = models.CharField(
        max_length=100,
        help_text="Nama toko, contoh: Smile Insurance - Cabang Jakarta Pusat"
    )
    
    # Alamat
    address = models.TextField()
    city = models.CharField(max_length=50)
    province = models.CharField(max_length=50)
    postal_code = models.CharField(max_length=10, blank=True)
    
    # Kontak
    phone = models.CharField(max_length=20)
    email = models.EmailField()
    
    # Status
    is_active = models.BooleanField(default=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'stores'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.code} - {self.name}"
```

### 2. Update User Model

```python
# users/models.py

class User(AbstractUser):
    # ... existing fields ...
    
    ROLE_CHOICES = [
        ('customer', 'Customer'),           # Pelanggan biasa
        ('store_staff', 'Store Staff'),     # Staff toko (lihat saja)
        ('store_admin', 'Store Admin'),     # Admin toko (full CRUD toko sendiri)
        ('super_admin', 'Super Admin'),     # Admin pusat (full access semua)
    ]
    
    role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default='customer'
    )
    
    # Relasi ke Toko (null untuk Super Admin dan Customer yang belum assign)
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='users',
        help_text="Toko tempat user bekerja/terdaftar"
    )
    
    def is_super_admin(self):
        return self.role == 'super_admin'
    
    def is_store_admin(self):
        return self.role == 'store_admin'
    
    def can_access_store(self, store_id):
        """Check apakah user bisa akses toko tertentu"""
        if self.is_super_admin():
            return True
        return str(self.store_id) == str(store_id)
```

### 3. Model Activity Log

```python
# activity_logs/models.py

import uuid
from django.db import models
from django.conf import settings

class ActivityLog(models.Model):
    """
    Log semua aktivitas penting di sistem.
    Digunakan untuk audit trail dan monitoring.
    """
    
    ACTION_CHOICES = [
        # Authentication
        ('LOGIN', 'User Login'),
        ('LOGOUT', 'User Logout'),
        ('LOGIN_FAILED', 'Login Failed'),
        
        # User Management
        ('USER_CREATE', 'Create User'),
        ('USER_UPDATE', 'Update User'),
        ('USER_DELETE', 'Delete User'),
        ('USER_VERIFY', 'Verify User'),
        
        # Policy
        ('POLICY_CREATE', 'Create Policy'),
        ('POLICY_UPDATE', 'Update Policy'),
        ('POLICY_ACTIVATE', 'Activate Policy'),
        ('POLICY_EXPIRE', 'Expire Policy'),
        
        # Claims
        ('CLAIM_CREATE', 'Create Claim'),
        ('CLAIM_APPROVE', 'Approve Claim'),
        ('CLAIM_REJECT', 'Reject Claim'),
        ('CLAIM_COMPLETE', 'Complete Claim'),
        ('CLAIM_ADMIN_CREATE', 'Admin Create Claim'),
        
        # Store
        ('STORE_CREATE', 'Create Store'),
        ('STORE_UPDATE', 'Update Store'),
        ('STORE_DEACTIVATE', 'Deactivate Store'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Who
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='activity_logs'
    )
    user_email = models.EmailField(help_text="Snapshot email saat log dibuat")
    user_role = models.CharField(max_length=20)
    
    # Where
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='activity_logs'
    )
    store_code = models.CharField(max_length=20, blank=True)
    
    # What
    action = models.CharField(max_length=30, choices=ACTION_CHOICES)
    target_model = models.CharField(
        max_length=50,
        help_text="Model yang diakses: User, Policy, Claim, etc"
    )
    target_id = models.CharField(
        max_length=50,
        blank=True,
        help_text="ID object yang diakses"
    )
    
    # Details
    description = models.TextField(blank=True)
    old_values = models.JSONField(
        null=True, 
        blank=True,
        help_text="Data sebelum perubahan"
    )
    new_values = models.JSONField(
        null=True, 
        blank=True,
        help_text="Data setelah perubahan"
    )
    
    # Client Info
    ip_address = models.GenericIPAddressField(null=True)
    user_agent = models.TextField(blank=True)
    
    # Timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'activity_logs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['store', '-created_at']),
            models.Index(fields=['action', '-created_at']),
            models.Index(fields=['-created_at']),
        ]
    
    def __str__(self):
        return f"{self.user_email} - {self.action} - {self.created_at}"
```

### 4. Update Model Lainnya

Semua model yang perlu di-filter per toko harus ditambahkan field `store`:

```python
# policies/models.py
class Policy(models.Model):
    # ... existing fields ...
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.PROTECT,
        related_name='policies'
    )

# claims/models.py
class Claim(models.Model):
    # ... existing fields ...
    # store bisa diambil dari policy.store atau user.store
```

---

## 🔐 Permission System

### Permission Matrix

| Action | Customer | Store Staff | Store Admin | Super Admin |
|--------|----------|-------------|-------------|-------------|
| Lihat data sendiri | ✅ | ✅ | ✅ | ✅ |
| Lihat data toko sendiri | ❌ | ✅ | ✅ | ✅ |
| Lihat data toko lain | ❌ | ❌ | ❌ | ✅ |
| Create policy | ❌ | ❌ | ✅ | ✅ |
| Approve claim | ❌ | ❌ | ✅ | ✅ |
| Manage users toko | ❌ | ❌ | ✅ | ✅ |
| **Manage devices** | ❌ | ❌ | ❌ | ✅ |
| Manage toko | ❌ | ❌ | ❌ | ✅ |
| Manage Policy Tiers | ❌ | ❌ | ❌ | ✅ |
| Lihat semua activity | ❌ | ❌ | ❌ | ✅ |
| Dashboard global | ❌ | ❌ | ❌ | ✅ |

### Backend Implementation

```python
# permissions.py

from rest_framework.permissions import BasePermission

class IsSuperAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'super_admin'

class IsStoreAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ['store_admin', 'super_admin']

class IsStoreStaff(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ['store_staff', 'store_admin', 'super_admin']

class StoreFilterMixin:
    """
    Mixin untuk filter queryset berdasarkan toko user.
    """
    def get_queryset(self):
        queryset = super().get_queryset()
        user = self.request.user
        
        if user.role == 'super_admin':
            # Super admin bisa lihat semua
            store_filter = self.request.query_params.get('store')
            if store_filter:
                queryset = queryset.filter(store_id=store_filter)
            return queryset
        
        elif user.role in ['store_admin', 'store_staff']:
            # Filter hanya data toko sendiri
            return queryset.filter(store=user.store)
        
        else:
            # Customer - filter data sendiri
            return queryset.filter(user=user)
```

---

## 📊 Dashboard Design

### Super Admin Dashboard

```
┌────────────────────────────────────────────────────────────────────┐
│ SUPER ADMIN DASHBOARD                           Welcome, Admin!    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐│
│  │ TOTAL TOKO   │ │ TOTAL CLAIMS │ │ TOTAL POLICY │ │ REVENUE    ││
│  │     15       │ │    1,234     │ │    5,678     │ │ 2.5M       ││
│  │ Active: 14   │ │ Pending: 45  │ │ Active: 4,500│ │ This Month ││
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘│
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ PERFORMA PER TOKO                              [This Month] │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │ Toko      │ Policies │ Claims │ Approved │ Revenue         │  │
│  │───────────┼──────────┼────────┼──────────┼─────────────────│  │
│  │ Jakarta A │   234    │   45   │   40     │ Rp 450.000.000  │  │
│  │ Bandung   │   189    │   32   │   28     │ Rp 320.000.000  │  │
│  │ Surabaya  │   156    │   28   │   25     │ Rp 280.000.000  │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ ACTIVITY LOG                               [View All →]     │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │ 14:30 │ Toko Jakarta │ admin@jkt   │ Approved Claim #123  │  │
│  │ 14:25 │ Toko Bandung │ admin@bdg   │ Created Policy #456  │  │
│  │ 14:20 │ Toko Surabaya│ admin@sby   │ Rejected Claim #789  │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Store Admin Dashboard

```
┌────────────────────────────────────────────────────────────────────┐
│ TOKO JAKARTA PUSAT                      Welcome, Store Admin!      │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐│
│  │ CUSTOMERS    │ │ CLAIMS       │ │ POLICIES     │ │ PENDING    ││
│  │    234       │ │    45        │ │    189       │ │    12      ││
│  │ +5 New       │ │ +3 New       │ │ Active       │ │ Claims     ││
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘│
│                                                                    │
│  (Hanya data TOKO INI yang ditampilkan)                           │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 API Endpoints

### Store Management (Super Admin Only)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/stores/` | List semua toko |
| POST | `/api/admin/stores/` | Create toko baru |
| GET | `/api/admin/stores/{id}/` | Detail toko |
| PUT | `/api/admin/stores/{id}/` | Update toko |
| DELETE | `/api/admin/stores/{id}/` | Deactivate toko |
| GET | `/api/admin/stores/{id}/stats/` | Stats per toko |

### Activity Log (Super Admin)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/activity-logs/` | List all activities |
| GET | `/api/admin/activity-logs/?store={id}` | Filter by store |
| GET | `/api/admin/activity-logs/?user={id}` | Filter by user |
| GET | `/api/admin/activity-logs/?action={type}` | Filter by action |

### Modified Existing Endpoints

Semua endpoint existing akan otomatis filter berdasarkan store user yang login:

```
GET /api/admin/users/
  - Super Admin: Semua user + filter by store
  - Store Admin: Hanya user toko sendiri

GET /api/admin/claims/
  - Super Admin: Semua claims + filter by store
  - Store Admin: Hanya claims toko sendiri

GET /api/admin/policies/
  - Super Admin: Semua policies + filter by store
  - Store Admin: Hanya policies toko sendiri
```

---

## 📝 Implementation Steps

### Phase 1: Database Setup (2-3 jam)
- [ ] Create `stores` app
- [ ] Create Store model
- [ ] Add migrations
- [ ] Update User model dengan role dan store FK
- [ ] Create ActivityLog model

### Phase 2: Backend API (6-8 jam)
- [ ] Create StoreViewSet
- [ ] Create ActivityLogViewSet
- [ ] Create permission classes
- [ ] Add StoreFilterMixin ke semua ViewSets
- [ ] Add activity logging decorator
- [ ] Update all existing endpoints

### Phase 3: Super Admin Dashboard (6-8 jam)
- [ ] Create store management page
- [ ] Create global dashboard with store stats
- [ ] Create activity log viewer
- [ ] **Create Policy Tier Management page** (Update price, range, duration)
- [ ] Add store filter to all pages
- [ ] Create comparative reports

### Phase 4: Store Admin Dashboard (4-6 jam)
- [ ] Modify login to show store info
- [ ] Update dashboard untuk show store-specific data
- [ ] Hide store filter (show only their store)
- [ ] Update all pages to respect store filter

### Phase 5: Testing & Deployment (4-6 jam)
- [ ] Test permission isolation
- [ ] Test data filtering
- [ ] Test activity logging
- [ ] Deploy to production
- [ ] Create test stores and test admins

---

## 📅 Timeline

| Week | Tasks | Status |
|------|-------|--------|
| Week 1 | Phase 1 + Phase 2 | 🔲 Pending |
| Week 2 | Phase 3 + Phase 4 | 🔲 Pending |
| Week 3 | Phase 5 + Bug fixes | 🔲 Pending |

---

## ⚠️ Important Notes

1. **Data Migration**: Data existing perlu di-assign ke store default
2. **Backward Compatibility**: API lama tetap berjalan, tapi semua data akan terfilter
3. **Security**: Setiap request harus validate store access
4. **Activity Log**: Tidak menghapus data, untuk audit trail

---

## 🎯 Success Criteria

- [ ] Store Admin TIDAK BISA melihat data toko lain
- [ ] Super Admin BISA melihat dan filter semua data
- [ ] Semua aktivitas tercatat di Activity Log
- [ ] Dashboard menampilkan stats yang benar per toko
- [ ] Login menampilkan informasi toko yang benar
