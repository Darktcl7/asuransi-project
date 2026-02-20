// lib/screens/admin/admin_claims_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminClaimsScreen extends StatefulWidget {
  const AdminClaimsScreen({super.key});

  @override
  State<AdminClaimsScreen> createState() => _AdminClaimsScreenState();
}

class _AdminClaimsScreenState extends State<AdminClaimsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _claims = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchClaims();
  }

  Future<void> _fetchClaims() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final claims = await _apiService.getAdminClaims(search: _searchQuery);
      setState(() {
        _claims = claims;
      });
    } catch (e) {
      SnackbarHelper.showError(context, 'Gagal memuat daftar klaim');
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
        title: const Text('Manajemen Klaim', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeaderSearch(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _claims.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchClaims,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _claims.length,
                          itemBuilder: (context, index) {
                            final claim = _claims[index];
                            return _buildEnhancedClaimCard(claim);
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
          _fetchClaims();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari No. Klaim atau Perangkat...',
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

  Widget _buildEnhancedClaimCard(Map<String, dynamic> claim) {
    final status = (claim['status'] ?? 'pending').toString().toLowerCase();
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    
    if (status == 'approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_actions;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'completed') {
      statusColor = Colors.blue;
      statusIcon = Icons.task_alt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showClaimActions(claim),
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
                        '#${claim['claim_number'] ?? '-'}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700, fontSize: 13),
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
                  const SizedBox(height: 12),
                  Text(
                    claim['device_full_name'] ?? '-',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCompactRow(Icons.report_problem_outlined, 'Kerusakan', claim['damage_type'] ?? '-'),
                  _buildCompactRow(Icons.person_outline, 'Pengaju', claim['user_full_name'] ?? '-'),
                  _buildCompactRow(Icons.storefront_outlined, 'Toko', claim['store_name'] ?? '-'),
                  _buildCompactRow(Icons.payments_outlined, 'Estimasi', _formatCurrency(double.tryParse(claim['claim_amount']?.toString() ?? '0') ?? 0)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Update: ${claim['updated_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(claim['updated_at'])) : '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  const Text('Detail >', style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showClaimActions(Map<String, dynamic> claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detail Klaim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLargeDetailRow('Nomor Klaim', claim['claim_number']),
              _buildLargeDetailRow('Nama User', claim['user_full_name']),
              _buildLargeDetailRow('Perangkat', claim['device_full_name']),
              _buildLargeDetailRow('Toko', claim['store_name']),
              _buildLargeDetailRow('Tipe Kerusakan', claim['damage_type']),
              const SizedBox(height: 8),
              const Text('Deskripsi Kerusakan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Text(claim['damage_description'] ?? 'Tidak ada deskripsi', style: const TextStyle(fontSize: 14, height: 1.5)),
              ),
              const SizedBox(height: 24),
              // Buttons removed as requested (Super Admin read-only view)
              const SizedBox(height: 24),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final photos = claim['photos'] as List?;
                    if (photos == null || photos.isEmpty) {
                      SnackbarHelper.showError(context, 'Tidak ada dokumen foto dilampirkan');
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 500,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dokumentasi (${photos.length} Foto)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: PageView.builder(
                                  itemCount: photos.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              photos[index]['photo_url'] ?? '',
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey.shade300)),
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(child: CircularProgressIndicator());
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Foto ${index + 1} dari ${photos.length}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Lihat Dokumentasi Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLargeDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('Belum ada data klaim', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }
}
