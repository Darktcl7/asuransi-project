# 📚 API Testing Documentation - Phone Insurance App

Base URL: `http://127.0.0.1:8000/api/`

## 🔐 Authentication

Semua endpoint (kecuali register & login) membutuhkan **Token Authentication**.

Header format:
```
Authorization: Token YOUR_TOKEN_HERE
```

---

## 1️⃣ USER ENDPOINTS

### 1.1 Register User
**POST** `/api/users/register/`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "081234567890",
  "ktp_number": "1234567890123456",
  "birth_date": "1990-01-01",
  "address": "Jl. Contoh No. 123"
}
```

**Response (201 Created):**
```json
{
  "token": "abc123xyz...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    ...
  }
}
```

---

### 1.2 Login
**POST** `/api/auth/login/`

**Request Body:**
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "abc123xyz..."
}
```

---

### 1.3 Get Current User Info
**GET** `/api/users/me/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Response (200 OK):**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "081234567890",
  "is_verified": false,
  ...
}
```

---

## 2️⃣ WALLET ENDPOINTS

### 2.1 Get Wallet Info
**GET** `/api/wallet/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "balance": "1000000.00",
    "total_topup": "1000000.00",
    "total_spent": "0.00",
    "created_at": "2025-11-21T10:00:00Z"
  }
]
```

---

### 2.2 Top Up Wallet
**POST** `/api/wallet/topup/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Request Body:**
```json
{
  "amount": 500000,
  "payment_method": "Bank Transfer",
  "payment_proof_url": "https://example.com/bukti_bayar.jpg"
}
```

**Response (201 Created):**
```json
{
  "message": "Top up berhasil dibuat. Menunggu verifikasi admin.",
  "data": {
    "id": "uuid-here",
    "amount": "500000.00",
    "payment_method": "Bank Transfer",
    "status": "pending",
    ...
  }
}
```

---

### 2.3 Get Wallet History
**GET** `/api/wallet/history/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "transaction_type": "topup",
    "amount": "500000.00",
    "balance_before": "0.00",
    "balance_after": "500000.00",
    "description": "Top up via Bank Transfer",
    "created_at": "2025-11-21T10:00:00Z"
  }
]
```

---

## 3️⃣ POLICY ENDPOINTS

### 3.1 Get Policy Tiers (Public)
**GET** `/api/policy-tiers/`

**No Auth Required**

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "tier_name": "Standar",
    "min_price": "1000000.00",
    "max_price": "5000000.00",
    "policy_price": "150000.00",
    "claim_deduction_percent": "10.00",
    "policy_duration_days": 365,
    "max_claims_per_year": 3
  },
  ...
]
```

---

### 3.2 Get Device Packages (Public)
**GET** `/api/device-packages/`

**No Auth Required**

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "device_brand": "Apple",
    "device_model": "iPhone 15 Pro Max",
    "device_variant": "256GB",
    "device_value": "19999000.00"
  },
  ...
]
```

---

### 3.3 Create Policy
**POST** `/api/policies/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Request Body:**
```json
{
  "device_package_id": "uuid-device-here",
  "imei_number": "123456789012345",
  "purchase_price": 12999000
}
```

**Response (201 Created):**
```json
{
  "message": "Polis berhasil dibuat dan diaktifkan",
  "data": {
    "id": "uuid-here",
    "policy_number": "POL-20251121120000",
    "status": "active",
    "activation_date": "2025-11-21",
    "expiry_date": "2026-11-21",
    "policy_price": "150000.00",
    ...
  }
}
```

---

### 3.4 Get User Policies
**GET** `/api/policies/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "policy_number": "POL-20251121120000",
    "status": "active",
    "tier": {
      "tier_name": "Standar",
      "policy_price": "150000.00"
    },
    "device_package": {
      "device_brand": "Apple",
      "device_model": "iPhone 15"
    },
    ...
  }
]
```

---

## 4️⃣ CLAIM ENDPOINTS

### 4.1 Create Claim
**POST** `/api/claims/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Request Body:**
```json
{
  "policy_id": "uuid-policy-here",
  "damage_type": "Layar Pecah",
  "damage_description": "Layar ponsel pecah karena terjatuh",
  "incident_date": "2025-11-20",
  "claim_amount": 2000000
}
```

**Response (201 Created):**
```json
{
  "message": "Klaim berhasil dibuat. Menunggu review admin.",
  "data": {
    "id": "uuid-here",
    "claim_number": "CLM-20251121120000",
    "status": "pending",
    "claim_amount": "2000000.00",
    "deduction_amount": "200000.00",
    ...
  },
  "deduction_info": {
    "deduction_amount": 200000.0,
    "will_be_deducted_from_wallet_on_approval": true
  }
}
```

---

### 4.2 Get User Claims
**GET** `/api/claims/`

**Headers:**
```
Authorization: Token abc123xyz...
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-here",
    "claim_number": "CLM-20251121120000",
    "status": "pending",
    "damage_type": "Layar Pecah",
    "claim_amount": "2000000.00",
    "deduction_amount": "200000.00",
    "created_at": "2025-11-21T12:00:00Z",
    ...
  }
]
```

---

## 5️⃣ ADMIN ENDPOINTS

### 5.1 Approve Claim (Admin Only)
**POST** `/api/admin/claims/{claim_id}/approve/`

**Headers:**
```
Authorization: Token admin_token_here
```

**Response (200 OK):**
```json
{
  "message": "Klaim berhasil disetujui",
  "data": {
    "id": "uuid-here",
    "status": "approved",
    "wallet_deducted": "200000.00",
    ...
  }
}
```

---

### 5.2 Reject Claim (Admin Only)
**POST** `/api/admin/claims/{claim_id}/reject/`

**Headers:**
```
Authorization: Token admin_token_here
```

**Request Body:**
```json
{
  "rejection_reason": "Bukti tidak lengkap"
}
```

**Response (200 OK):**
```json
{
  "message": "Klaim ditolak",
  "data": {
    "id": "uuid-here",
    "status": "rejected",
    "admin_notes": "Bukti tidak lengkap",
    ...
  }
}
```

---

## 📝 Testing Workflow

### Scenario 1: User Register & Buy Policy
1. **POST** `/api/users/register/` → Get token
2. **GET** `/api/wallet/` → Cek wallet (balance = 0)
3. **POST** `/api/wallet/topup/` → Top up 500k
4. **GET** `/api/device-packages/` → Pilih device
5. **POST** `/api/policies/` → Beli polis

### Scenario 2: User Create Claim
1. **GET** `/api/policies/` → Cek polis aktif
2. **POST** `/api/claims/` → Buat klaim
3. **GET** `/api/claims/` → Cek status klaim

### Scenario 3: Admin Approve Claim
1. **GET** `/api/admin/claims/` → List all claims
2. **POST** `/api/admin/claims/{id}/approve/` → Approve

---

## 🚀 Start Django Server

```bash
cd "D:\Django Project\Asuransi Project\Smile Project"
env\Scripts\python.exe manage.py runserver
```

Access at: `http://127.0.0.1:8000/`
