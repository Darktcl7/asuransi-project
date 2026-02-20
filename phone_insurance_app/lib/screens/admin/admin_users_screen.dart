// lib/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final users = await _apiService.getAdminUsers(search: _searchQuery);
      setState(() {
        _users = users;
      });
    } catch (e) {
      SnackbarHelper.showError(context, 'Gagal memuat daftar user');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manajemen User', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeaderSearch(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildEnhancedUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _fetchUsers();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau HP...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          fillColor: Colors.white.withOpacity(0.2),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedUserCard(Map<String, dynamic> user) {
    final String role = user['role'] ?? 'customer';
    Color roleColor = Colors.grey;
    IconData roleIcon = Icons.person_outline;
    
    if (role == 'super_admin') {
      roleColor = Colors.purple;
      roleIcon = Icons.admin_panel_settings;
    } else if (role == 'store_admin') {
      roleColor = Colors.indigo;
      roleIcon = Icons.supervisor_account;
    } else if (role == 'store_staff') {
      roleColor = Colors.blue;
      roleIcon = Icons.badge_outlined;
    } else {
      roleColor = Colors.teal;
      roleIcon = Icons.people_outline;
    }

    final stats = user['stats'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => _showUserActions(user),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user['full_name'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user['full_name'] ?? 'User Tanpa Nama',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.more_vert, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user['email'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  
                  const SizedBox(height: 8),
                  
                  // Device & Tier Info
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone_android, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user['device_info'] ?? '-',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user['tier_info'] != null && user['tier_info'] != '-') ...[
                          Container(width: 1, height: 12, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                          Icon(Icons.workspace_premium, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            user['tier_info'],
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stats & Role
                  Row(
                    children: [
                      _buildStatBadge('Polis', '${stats?['total_policies'] ?? 0}', Colors.indigo),
                      const SizedBox(width: 6),
                      _buildStatBadge('Klaim', '${stats?['total_claims'] ?? 0}', Colors.orange),
                      const Spacer(),
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(roleIcon, size: 10, color: roleColor),
                            const SizedBox(width: 4),
                            Text(
                              role.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Text(
                user['full_name'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(user['email'] ?? '-', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 24),
              _buildActionTile(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                title: 'Ubah Role / Toko',
                onTap: () {
                  Navigator.pop(context);
                  SnackbarHelper.showInfo(context, 'Fitur edit segera hadir');
                },
              ),
              _buildActionTile(
                icon: Icons.lock_reset_outlined,
                color: Colors.orange,
                title: 'Reset Password',
                onTap: () {
                  Navigator.pop(context);
                  SnackbarHelper.showInfo(context, 'Reset password dikirim ke email');
                },
              ),
              const Divider(indent: 20, endIndent: 20),
              _buildActionTile(
                icon: Icons.delete_forever_outlined,
                color: Colors.red,
                title: 'Hapus Akun Selamanya',
                onTap: () {
                  Navigator.pop(context);
                  SnackbarHelper.showError(context, 'Fitur hapus akun dibatasi');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color == Colors.red ? Colors.red : Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('User tidak ditemukan', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }
}
