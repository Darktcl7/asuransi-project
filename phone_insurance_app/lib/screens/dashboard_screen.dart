// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:developer'; // Untuk log debug

// Impor Model & Service yang dibutuhkan
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/user.dart';
import '../models/wallet.dart'; 
import '../models/policy.dart';
import '../widgets/shimmer_card.dart';
import 'notifications_screen.dart';
import 'claim/claim_form_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  User? _user;
  Wallet? _wallet; 
  List<Policy> _policies = []; 
  bool _isLoading = true;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();

      log("Memuat User Profile...");
      final userJson = await _apiService.getUserProfile(); // /users/me/
      
      log("Memuat Wallet...");
      final walletJson = await _apiService.getWalletBalance(); // /wallet/
      
      log("Memuat Polis...");
      final policiesJson = await _apiService.getPolicies(); // /policies/
      
      log("Memuat Notifikasi Count...");
      final unreadCount = await _notificationService.getUnreadCount();
      log("✅ Unread notification count: $unreadCount");
      
      log("Data berhasil dimuat, memproses UI...");

      setState(() {
        _user = User.fromJson(userJson);
        
        if (walletJson != null) {
          _wallet = Wallet.fromJson(walletJson);
        } else {
          // Buat wallet default jika API mengembalikan null
          _wallet = Wallet(id: "default", balance: 0, totalTopup: 0, totalSpent: 0);
        }
        
        _policies = policiesJson.map((p) => Policy.fromJson(p)).toList();
        _unreadNotificationCount = unreadCount;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      log("!!!!!!!!!!!!!! ERROR SAAT _loadData !!!!!!!!!!!!!!", error: e);
      log("!!!!!!!!!!!!!! STACK TRACE !!!!!!!!!!!!!!", error: stackTrace);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Gagal memuat data. $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('😊 ', style: TextStyle(fontSize: 18)),
              const Text('Dashboard'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Wallet shimmer
            const ShimmerCard(height: 140),
            const SizedBox(height: 24),
            // Quick actions shimmer
            Row(
              children: const [
                Expanded(child: ShimmerCard(height: 120)),
                SizedBox(width: 12),
                Expanded(child: ShimmerCard(height: 120)),
              ],
            ),
            const SizedBox(height: 24),
            // Policy list shimmer
            const ShimmerPolicyCard(),
            const ShimmerPolicyCard(),
          ],
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('😊 ', style: TextStyle(fontSize: 18)),
            Text('Hi, ${_user?.fullName ?? "Pengguna"}'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        actions: [
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifikasi',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  _loadData(); // Refresh notification count
                },
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationCount > 9 ? '9+' : '$_unreadNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Riwayat Klaim',
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/claim-history');
              if (result == true) {
                _loadData(); // Refresh if claim status changed
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      // FloatingActionButton DIHAPUS - Tombol "Ajukan Klaim" sekarang di setiap policy card
      body: RefreshIndicator(
        onRefresh: _loadData, // Fungsi refresh
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ❌ WALLET DIHAPUS - Setiap policy punya saldo sendiri
            // _buildWalletCard(context),
            // const SizedBox(height: 24),

            // Quick Actions - DIHAPUS, sekarang pakai FAB di kanan bawah
            // _buildQuickActions(),

            // const SizedBox(height: 24),
            
            // Bagian Polis Aktif
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Polis Anda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dikelola oleh Admin',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List Polis - User hanya melihat, tidak bisa beli sendiri
            if (_policies.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: const [
                      Icon(Icons.shield_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada polis',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Admin akan menambahkan polis untuk Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._policies.map((policy) => _buildPolicyCard(policy)).toList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk Quick Actions
  // NOTE: "Beli Polis" DIHAPUS - Admin yang input polis manual
  Widget _buildQuickActions() {
    return _buildActionCard(
      icon: Icons.report_problem,
      label: 'Ajukan Klaim',
      color: Colors.orange,
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/select-policy');
        if (result == true) {
          _loadData();
        }
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Kartu Saldo
  Widget _buildWalletCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/wallet-history');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Tersedia',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Icon(
                    Icons.history,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_wallet?.balance.toStringAsFixed(0) ?? "0"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Top-up dikelola oleh admin',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap untuk lihat riwayat transaksi',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Kartu Polis - Tampilkan NAMA PAKET POLIS
  Widget _buildPolicyCard(Policy policy) {
    // Determine status color
    Color statusColor = Colors.grey;
    if (policy.status == 'active') {
      statusColor = Colors.green;
    } else if (policy.status == 'pending') {
      statusColor = Colors.orange;
    } else if (policy.status == 'expired') {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Paket Polis Name (PROMINENTLY DISPLAYED)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield, color: Colors.indigo, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.tierName ?? 'Paket Polis',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          policy.policyNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    policy.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // ✅ POLICY BALANCE - Saldo per policy
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Policy',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${policy.policyBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Device Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perangkat',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${policy.deviceBrand} ${policy.deviceModel}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // IMEI
            Text(
              'IMEI: ${policy.imeiNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Tombol Ajukan Klaim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: policy.status == 'active'
                    ? () async {
                        // Navigate langsung ke form claim dengan policy ini
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClaimFormScreen(policy: policy),
                          ),
                        );
                        
                        // Refresh data jika claim berhasil disubmit
                        if (result == true) {
                          _loadData();
                        }
                      }
                    : null, // Disabled jika policy tidak active
                icon: Icon(
                  policy.status == 'active' 
                      ? Icons.assignment_outlined 
                      : Icons.block,
                  size: 20,
                ),
                label: Text(
                  policy.status == 'active' 
                      ? 'Ajukan Klaim' 
                      : policy.status == 'expired'
                          ? 'Policy Expired'
                          : 'Policy Tidak Aktif',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: policy.status == 'active' 
                      ? Colors.orange 
                      : Colors.grey.shade300,
                  foregroundColor: policy.status == 'active' 
                      ? Colors.white 
                      : Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: policy.status == 'active' ? 2 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}