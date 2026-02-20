// lib/screens/admin/admin_policies_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminPoliciesScreen extends StatefulWidget {
  const AdminPoliciesScreen({super.key});

  @override
  State<AdminPoliciesScreen> createState() => _AdminPoliciesScreenState();
}

class _AdminPoliciesScreenState extends State<AdminPoliciesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _policies = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
  }

  Future<void> _fetchPolicies() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final policies = await _apiService.getAdminPolicies(search: _searchQuery);
      setState(() {
        _policies = policies;
      });
    } catch (e) {
      SnackbarHelper.showError(context, 'Gagal memuat daftar polis');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manajemen Polis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeaderSearch(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _policies.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchPolicies,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _policies.length,
                          itemBuilder: (context, index) {
                            final policy = _policies[index];
                            return _buildEnhancedPolicyCard(policy);
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
          _fetchPolicies();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari No. Polis atau Nama User...',
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

  Widget _buildEnhancedPolicyCard(Map<String, dynamic> policy) {
    final status = (policy['status'] ?? 'pending').toString().toLowerCase();
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.shield_outlined;
    
    if (status == 'active') {
      statusColor = Colors.green;
      statusIcon = Icons.verified_user_outlined;
    } else if (status == 'pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else if (status == 'expired') {
      statusColor = Colors.red;
      statusIcon = Icons.event_busy_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      policy['policy_number'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildCompactRow(Icons.person_outline, 'Pemilik', policy['user_full_name'] ?? '-'),
                _buildCompactRow(Icons.devices_other_outlined, 'Perangkat', '${policy['device_brand'] ?? ''} ${policy['device_model'] ?? ''}'),
                _buildCompactRow(Icons.storefront_outlined, 'Toko', policy['store_name'] ?? '-'),
                _buildCompactRow(Icons.workspace_premium, 'Tier', policy['tier_name'] ?? '-'),
                _buildCompactRow(Icons.account_balance_wallet_outlined, 'Sisa Saldo', _formatCurrency(double.tryParse(policy['policy_balance']?.toString() ?? '0') ?? 0)),
              ],
            ),
          ),
          
          // Expandable Detail Barang
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Material(
              color: Colors.grey.shade50,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  backgroundColor: Colors.grey.shade50,
                  collapsedBackgroundColor: Colors.grey.shade50,
                  title: Row(
                    children: [
                      Icon(Icons.event_note_outlined, size: 14, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Masa Berlaku: ${policy['expiry_date'] ?? '-'}',
                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Detail Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Perangkat', '${policy['device_brand'] ?? ''} ${policy['device_model'] ?? ''}'),
                    _buildDetailRow('Tier', policy['tier_name'] ?? '-'),
                    _buildDetailRow('IMEI', policy['imei_number'] ?? '-'),
                    _buildDetailRow('Tgl Aktivasi', policy['activation_date'] ?? '-'),
                    _buildDetailRow('Harga Polis', _formatCurrency(double.tryParse(policy['policy_price']?.toString() ?? '0') ?? 0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.indigo.withOpacity(0.5)),
          const SizedBox(width: 10),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('Data polis tidak ditemukan', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }
}
