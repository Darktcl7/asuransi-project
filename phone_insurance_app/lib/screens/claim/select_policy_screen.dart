import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/policy.dart';
import 'claim_form_screen.dart';

class SelectPolicyScreen extends StatefulWidget {
  const SelectPolicyScreen({super.key});

  @override
  State<SelectPolicyScreen> createState() => _SelectPolicyScreenState();
}

class _SelectPolicyScreenState extends State<SelectPolicyScreen> {
  final ApiService _apiService = ApiService();
  List<Policy> _policies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final policiesJson = await _apiService.getPolicies();
      
      setState(() {
        _policies = policiesJson
            .map((json) => Policy.fromJson(json))
            .where((policy) => policy.status.toLowerCase() == 'active')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool _canClaim(Policy policy) {
    // Check if policy can be claimed - now only check if active (no limit)
    return policy.status.toLowerCase() == 'active';
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    // Simple pattern without locale
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Color _getTierColor(String? tierName) {
    if (tierName == null) return Colors.indigo;
    switch (tierName.toLowerCase()) {
      case 'standar':
        return Colors.blue;
      case 'gold':
        return Colors.amber.shade700;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('😊 ', style: TextStyle(fontSize: 18)),
            const Text('Pilih Polis'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
      ),
      body: _policies.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _policies.length,
              itemBuilder: (context, index) {
                final policy = _policies[index];
                return _buildPolicyCard(policy);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Polis Aktif',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda perlu memiliki polis aktif terlebih dahulu\nsebelum mengajukan klaim.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Pembuatan polis dikelola oleh admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Silakan hubungi admin untuk dibuatkan polis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(Policy policy) {
    final canClaim = _canClaim(policy);
    final tierColor = _getTierColor(policy.tierName);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: canClaim 
            ? BorderSide(color: tierColor.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: canClaim 
            ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClaimFormScreen(policy: policy),
                  ),
                );
                // If claim was created, go back to dashboard
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Device & Tier Badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${policy.deviceBrand} ${policy.deviceModel}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IMEI: ${policy.imeiNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tier Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tierColor),
                    ),
                    child: Text(
                      policy.tierName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Policy Details
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Berlaku Hingga',
                value: _formatDate(policy.expiryDate),
                color: Colors.blue,
              ),

              const SizedBox(height: 16),

              // Action Button or Status
              if (!canClaim)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Polis tidak aktif',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClaimFormScreen(policy: policy),
                        ),
                      );
                      if (result == true && mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Ajukan Klaim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tierColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
