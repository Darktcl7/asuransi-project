import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _reports = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final data = await _apiService.getAdminReports(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() => _reports = data);
    } catch (e) {
      SnackbarHelper.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic val) {
    double amount = double.tryParse(val?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Laporan & Analitik'), elevation: 0),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('Tidak ada data laporan'))
                    : RefreshIndicator(
                        onRefresh: _loadReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) => _buildStoreCard(_reports[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Text(_startDate != null ? df.format(_startDate!) : 'Dari Tanggal', style: TextStyle(color: _startDate != null ? Colors.black : Colors.grey)),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('s/d')),
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Text(_endDate != null ? df.format(_endDate!) : 'Sampai Tanggal', style: TextStyle(color: _endDate != null ? Colors.black : Colors.grey)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _loadReports,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: const Text('Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    final sales = store['sales'] as Map<String, dynamic>? ?? {};
    final claims = store['claims'] as Map<String, dynamic>? ?? {};
    final double lossRatio = double.tryParse(store['loss_ratio']?.toString() ?? '0') ?? 0;

    Color lossColor = Colors.green;
    if (lossRatio > 70) lossColor = Colors.red;
    else if (lossRatio > 40) lossColor = Colors.orange;

    final bool isTotal = store['id'] == 'total';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTotal ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTotal ? const BorderSide(color: Colors.indigo, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['name'] ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTotal ? 16 : 15,
                          color: isTotal ? Colors.indigo : Colors.black87,
                        ),
                      ),
                      if (store['code'] != null && store['code'] != 'TOTAL')
                        Text(store['code'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                // Loss Ratio Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: lossColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Loss ${lossRatio.toStringAsFixed(1)}%',
                    style: TextStyle(color: lossColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (store['location'] != null) ...[
              const SizedBox(height: 4),
              Text('📍 ${store['location']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),  
            ],
            const Divider(height: 20),
            // Stats Grid
            Row(
              children: [
                _buildStat('Polis Terjual', '${sales['count'] ?? 0}', Colors.blue),
                _buildStat('Premi Masuk', _formatCurrency(sales['revenue']), Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStat('Total Klaim', '${claims['count'] ?? 0}', Colors.orange),
                _buildStat('Klaim Dibayar', _formatCurrency(claims['amount']), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
