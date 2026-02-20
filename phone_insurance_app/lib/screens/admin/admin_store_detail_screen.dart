// lib/screens/admin/admin_store_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminStoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  const AdminStoreDetailScreen({super.key, required this.store});

  @override
  State<AdminStoreDetailScreen> createState() => _AdminStoreDetailScreenState();
}

class _AdminStoreDetailScreenState extends State<AdminStoreDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _lastError = '';

  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _pickDateRange() async {
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo,
            colorScheme: ColorScheme.light(primary: Colors.indigo),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
      });
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final storeId = widget.store['id'];
      final stats = await _apiService.getStoreStats(
        storeId,
        startDate: _selectedDateRange.start,
        endDate: _selectedDateRange.end,
      );
      print('DEBUG STORE DETAIL: Stats loaded OK: ${stats.keys.toList()}');
      setState(() {
        _stats = stats;
        _lastError = '';
      });
    } catch (e) {
      print('DEBUG STORE DETAIL ERROR: $e');
      setState(() {
        _lastError = e.toString();
      });
      if (mounted) {
        SnackbarHelper.showError(context, 'Gagal memuat statistik toko');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.store['name'] ?? 'Detail Toko'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDateRange),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      const Text('Gagal memuat statistik toko', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_lastError, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadStats,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('📊 Ringkasan Performa'),
                        const SizedBox(height: 12),
                        _buildStatsGrid(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('📅 Rekap Harian'),
                        const SizedBox(height: 12),
                        _buildDailyRecap(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('📱 Tipe Barang Terjual'),
                        const SizedBox(height: 12),
                        _buildDeviceDistribution(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('📋 Status Klaim'),
                        const SizedBox(height: 12),
                        _buildClaimStats(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
        ),
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18, // Reduced icon size
            backgroundColor: Colors.white24,
            child: Icon(Icons.store, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store['name'] ?? '-',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // Reduced font
                ),
                Text(
                  'Kode: ${widget.store['code'] ?? '-'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11), // Reduced font
                ),
                Text(
                  '${widget.store['city'] ?? ''} • ${widget.store['address'] ?? ''}',
                  style: const TextStyle(color: Colors.white60, fontSize: 10), // Reduced font
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    // API returns 'summary' object with filtered stats
    final summary = _stats?['summary'] ?? {};
    
    // Format tanggal untuk label
    final dateFormat = DateFormat('dd MMM');
    final dateLabel = _selectedDateRange.start.year == _selectedDateRange.end.year && 
                      _selectedDateRange.start.month == _selectedDateRange.end.month && 
                      _selectedDateRange.start.day == _selectedDateRange.end.day
        ? 'Hari Ini'
        : '${dateFormat.format(_selectedDateRange.start)} - ${dateFormat.format(_selectedDateRange.end)}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Text(
            'Menampilkan Data: $dateLabel',
            style: TextStyle(color: Colors.indigo.shade800, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.0,
          children: [
            _buildStatBox('Total Polis', summary['total_policies']?.toString() ?? '0', Icons.shield, Colors.blue),
            _buildStatBox('Omzet Toko', _formatCurrency(double.tryParse(summary['total_revenue']?.toString() ?? '0') ?? 0), Icons.payments, Colors.green),
            _buildStatBox('Klaim Baru/Pending', summary['claim_pending']?.toString() ?? '0', Icons.warning_amber, Colors.orange),
            _buildStatBox('Customer Baru', summary['new_customers']?.toString() ?? '0', Icons.person_add, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(title, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REKAP HARIAN ====================
  Widget _buildDailyRecap() {
    final List<dynamic> recap = _stats?['recap'] ?? [];
    if (recap.isEmpty) {
      return _buildEmptyCard('Belum ada rekap untuk periode ini.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo.shade700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Polis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo.shade700), textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Pendapatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo.shade700), textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          // Data rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recap.length > 14 ? 14 : recap.length, // Show max 14 days
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              // Show most recent first
              final item = recap[recap.length - 1 - (index < recap.length ? index : 0)];
              final count = item['count'] ?? 0;
              final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
              final dateStr = _formatDate(item['bucket']?.toString());

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(dateStr, style: const TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: count > 0 ? Colors.blue.shade50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: count > 0 ? Colors.blue.shade700 : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatCurrency(revenue),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: revenue > 0 ? Colors.green.shade700 : Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Total row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${_stats?['range_summary']?['policy_count'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatCurrency(double.tryParse(_stats?['range_summary']?['policy_revenue']?.toString() ?? '0') ?? 0),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade700),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TIPE BARANG TERJUAL ====================
  Widget _buildDeviceDistribution() {
    final List<dynamic> devices = _stats?['phone_distribution'] ?? [];
    if (devices.isEmpty) {
      return _buildEmptyCard('Belum ada data tipe barang.');
    }

    // Calculate total for percentage
    int totalDevices = 0;
    for (var d in devices) {
      totalDevices += (d['count'] as int? ?? 0);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final device = devices[index];
          final brand = device['device_package__device_brand'] ?? 'Unknown';
          final model = device['device_package__device_model'] ?? '';
          final count = device['count'] ?? 0;
          final percentage = totalDevices > 0 ? (count / totalDevices * 100) : 0;

          final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
          final barColor = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.phone_android, size: 16, color: barColor),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '$brand $model',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$count unit (${percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: barColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: barColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== STATUS KLAIM ====================
  Widget _buildClaimStats() {
    final claimStats = _stats?['claims'] ?? {};
    final total = claimStats['filtered_total'] ?? 0;
    final pending = claimStats['filtered_pending'] ?? 0;
    final approved = claimStats['filtered_approved'] ?? 0;
    final inProgress = claimStats['filtered_in_progress'] ?? 0;
    final completed = claimStats['filtered_completed'] ?? 0;
    final rejected = claimStats['filtered_rejected'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Klaim', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 1: Pending, Approved, Progress
          Row(
            children: [
              Expanded(child: _buildClaimChip('Pending', pending, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildClaimChip('Approved', approved, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildClaimChip('Progress', inProgress, Colors.cyan)),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Selesai, Ditolak
          Row(
            children: [
              Expanded(child: _buildClaimChip('Selesai', completed, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildClaimChip('Ditolak', rejected, Colors.red)),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()), // Spacer to align with 3-column grid
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaimChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Smaller padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)), // Smaller font
          Text(label, style: TextStyle(fontSize: 9, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis), // Smaller font
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
    );
  }
}
