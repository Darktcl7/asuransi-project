// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:developer'; // Untuk log debug
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Impor Model & Service yang dibutuhkan
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/user.dart';
import '../models/wallet.dart'; 
import '../models/policy.dart';
import '../models/claim.dart';
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

  // Helper formatting method
  String _formatCurrency(double amount) {
    if (amount == null) return 'Rp 0';
    String str = amount.toInt().toString();
    String result = "";
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = "." + result;
        count = 0;
      }
    }
    return 'Rp $result';
  }
  User? _user;
  Wallet? _wallet; 
  List<Policy> _policies = []; 
  List<Claim> _claims = [];
  bool _isLoading = true;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadData();
  }

  Future<void> _checkAdminAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role == 'super_admin') {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();

      log("Memuat User Profile...");
      final userJson = await _apiService.getUserProfile(); // /users/me/
      log("Data User dari API: Role=${userJson['role']}");
      
      // Sync Role to SharedPrefs
      final prefs = await SharedPreferences.getInstance();
      final role = userJson['role'] ?? 'customer';
      await prefs.setString('user_role', role);

      // REDIRECT IF ADMIN (SUPER ADMIN OR STORE ADMIN)
      final bool isAdmin = (role == 'super_admin' || role == 'store_admin');
      
      if (isAdmin) {
        log("DETEKSI ADMIN ($role): Melompat ke Admin Dashboard...");
        if (mounted) {
          // Tampilkan pesan debug agar USER bisa lihat role-nya apa di layar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terdeteksi Role: $role. Mengalihkan...'),
              backgroundColor: Colors.indigo,
              duration: const Duration(seconds: 2),
            ),
          );

          Future.microtask(() {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/admin-dashboard', 
                (route) => false
              );
            }
          });
          return;
        }
      } else {
        log("Role Customer terdeteksi. Tetap di dashboard ini.");
      }
      
      log("Memuat Wallet...");
      final walletJson = await _apiService.getWalletBalance(); // /wallet/
      
      log("Memuat Polis...");
      final policiesJson = await _apiService.getPolicies(); // /policies/
      
      log("Memuat Klaim...");
      final claimsJson = await _apiService.getClaims(); // /claims/
      
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
        _claims = claimsJson.map((json) {
          try { return Claim.fromJson(json); } catch (e) { return null; }
        }).whereType<Claim>().toList();
        _claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    
    return PopScope(
      canPop: false, // Menghalangi tombol back sistem (Android)
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Menghilangkan tombol back di AppBar
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('😊 ', style: TextStyle(fontSize: 18)),
                  Text('Hi, ${_user?.fullName ?? "Pengguna"}'),
                ],
              ),
              if (_user != null)
                Text(
                  '${_user?.email} (${_user?.role})',
                  style: TextStyle(fontSize: 9, color: Colors.white70),
                ),
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
            Text(
              'Polis Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // ====== RIWAYAT KLAIM ======
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Klaim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_claims.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: const [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada riwayat klaim', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ..._claims.map((claim) => _buildDashboardClaimCard(claim)).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
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
                _formatCurrency(_wallet?.balance ?? 0),
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
                        // ✅ STORE INFO - MOVED TO TOP FOR MAXIMUM VISIBILITY
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront, size: 10, color: Colors.orange.shade900),
                              const SizedBox(width: 4),
                              Text(
                                policy.storeName ?? 'Smile Center',
                                style: TextStyle(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
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
            
            // ✅ POLICY BALANCE - Color changed to ORANGE for visibility
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.orange.shade800],
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
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(policy.policyBalance),
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
            const SizedBox(height: 8),
            
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

  // ====== Widget Kartu Klaim di Dashboard ======
  Widget _buildDashboardClaimCard(Claim claim) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help;
    String statusLabel = claim.status;

    switch (claim.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusLabel = 'Pending';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusLabel = 'Disetujui';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusLabel = 'Ditolak';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        statusLabel = 'Selesai';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _showClaimDetail(claim),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.deviceFullName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      claim.damageType,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claim.formattedCreatedAt,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimDetail(Claim claim) {
    Color statusColor = Colors.grey;
    switch (claim.status.toLowerCase()) {
      case 'pending': statusColor = Colors.orange; break;
      case 'approved': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      case 'completed': statusColor = Colors.blue; break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Detail Klaim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              _buildDetailRow('Status', claim.status.toUpperCase(), statusColor),
              _buildDetailRow('Device', claim.deviceFullName),
              _buildDetailRow('Kerusakan', claim.damageType),
              _buildDetailRow('Tgl Kejadian', claim.formattedIncidentDate),
              _buildDetailRow('Tgl Pengajuan', claim.formattedCreatedAt),
              _buildDetailRow('Biaya Perbaikan', claim.formattedClaimAmount, Colors.blue.shade700),
              const SizedBox(height: 16),
              const Text('Deskripsi Kerusakan:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(claim.damageDescription, style: const TextStyle(fontSize: 14)),
              ),
              if (claim.adminNotes != null && claim.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Catatan Admin:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                  child: Text(claim.adminNotes!, style: TextStyle(fontSize: 14, color: Colors.orange.shade900)),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87))),
        ],
      ),
    );
  }
}