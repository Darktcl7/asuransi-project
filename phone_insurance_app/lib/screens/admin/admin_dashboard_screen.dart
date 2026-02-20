// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _adminName = 'Super Admin';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final profile = await _apiService.getUserProfile();
      setState(() {
        _adminName = profile['full_name'] ?? 'Super Admin';
      });
      
      final stats = await _apiService.getAdminStats();
      final stores = await _apiService.getAdminStores();
      print('DEBUG DASHBOARD: stats keys=${stats.keys.toList()}');
      
      // API returns nested structure
      final overview = stats['overview'] ?? {};
      final policies = stats['policies'] ?? {};
      final claims = stats['claims'] ?? {};
      
      setState(() {
        _stats = {
          'total_stores': stores.length,
          'today_policies': overview['today_policies'] ?? 0,
          'today_claims': overview['today_claims'] ?? 0,
          'today_revenue': double.tryParse(overview['today_premium']?.toString() ?? '0') ?? 0.0,
        };
      });
    } catch (e) {
      print('DEBUG DASHBOARD ERROR: $e');
      SnackbarHelper.showError(context, 'Gagal memuat data admin');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        const Text('👑 ', style: TextStyle(fontSize: 16)),
        Text(
          'Halo, $_adminName',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          'Pusat Kontrol',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }


  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _buildStatCard('Total Toko', _stats?['total_stores']?.toString() ?? '0', Icons.store, Colors.blue),
        _buildStatCard('Polis Hari Ini', _stats?['today_policies']?.toString() ?? '0', Icons.security, Colors.green),
        _buildStatCard('Klaim Hari Ini', _stats?['today_claims']?.toString() ?? '0', Icons.warning_amber, Colors.orange),
        _buildStatCard('Omzet Hari Ini', 'Rp ${_stats?['today_revenue']?.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.') ?? '0'}', Icons.account_balance_wallet, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menus = [
      {'title': 'Manajemen Toko', 'icon': Icons.storefront, 'color': Colors.indigo, 'route': '/admin-stores'},
      {'title': 'Manajemen User', 'icon': Icons.group, 'color': Colors.blue, 'route': '/admin-users'},
      {'title': 'Daftar Polis', 'icon': Icons.security, 'color': Colors.cyan, 'route': '/admin-policies'},
      {'title': 'Manajemen Klaim', 'icon': Icons.assignment_turned_in, 'color': Colors.orange, 'route': '/admin-claims'},
      {'title': 'Data Perangkat', 'icon': Icons.devices, 'color': Colors.teal, 'route': '/admin-devices'},
      {'title': 'Tier Polis', 'icon': Icons.layers, 'color': Colors.purple, 'route': '/admin-tiers'},
      {'title': 'Log Aktivitas', 'icon': Icons.history_edu, 'color': Colors.blueGrey, 'route': '/admin-logs'},
      {'title': 'Analitik Data', 'icon': Icons.analytics, 'color': Colors.redAccent, 'route': '/admin-analytics'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2, // Custom ratio for horizontal cards
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return InkWell(
          onTap: () {
            if (menu['route'] == '/admin-stores') {
              Navigator.pushNamed(context, '/admin-stores');
            } else if (menu['route'] == '/admin-users') {
              Navigator.pushNamed(context, '/admin-users');
            } else if (menu['route'] == '/admin-policies') {
              Navigator.pushNamed(context, '/admin-policies');
            } else if (menu['route'] == '/admin-claims') {
              Navigator.pushNamed(context, '/admin-claims');
            } else if (menu['route'] == '/admin-devices') {
              Navigator.pushNamed(context, '/admin-devices');
            } else if (menu['route'] == '/admin-tiers') {
              Navigator.pushNamed(context, '/admin-tiers');
            } else if (menu['route'] == '/admin-analytics') {
              Navigator.pushNamed(context, '/admin-analytics');
            } else {
              SnackbarHelper.showInfo(context, 'Fitur ${menu['title']} akan segera hadir di Mobile');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: menu['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(menu['icon'], color: menu['color'], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    menu['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
