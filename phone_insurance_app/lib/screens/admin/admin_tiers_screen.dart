import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class AdminTiersScreen extends StatefulWidget {
  const AdminTiersScreen({super.key});

  @override
  State<AdminTiersScreen> createState() => _AdminTiersScreenState();
}

class _AdminTiersScreenState extends State<AdminTiersScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _tiers = [];
  
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _premiumController = TextEditingController();
  final _durationController = TextEditingController(text: '365');

  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  Future<void> _loadTiers() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final data = await _apiService.getAdminTiers();
      // Sort by min_price
      data.sort((a, b) {
        double pA = double.tryParse(a['min_price']?.toString() ?? '0') ?? 0;
        double pB = double.tryParse(b['min_price']?.toString() ?? '0') ?? 0;
        return pA.compareTo(pB);
      });
      setState(() => _tiers = data);
    } catch (e) {
      SnackbarHelper.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTier() async {
    if (!_formKey.currentState!.validate()) return;
    
    Navigator.pop(context);
    setState(() => _isLoading = true);
    
    try {
      final minPrice = double.tryParse(_minPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final maxPrice = double.tryParse(_maxPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final premium = double.tryParse(_premiumController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final duration = int.tryParse(_durationController.text) ?? 365;
      
      final data = {
        'tier_name': _nameController.text,
        'min_price': minPrice,
        'max_price': maxPrice,
        'policy_price': premium, // User calls it "Premium"
        'policy_duration_days': duration,
        'is_active': true,
      };
      
      await _apiService.createAdminTier(data);
      SnackbarHelper.showSuccess(context, 'Tier berhasil ditambahkan');
      
      _nameController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _premiumController.clear();
      _durationController.text = '365';
      
      _loadTiers();
    } catch (e) {
      setState(() => _isLoading = false);
      SnackbarHelper.showError(context, e.toString());
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tier Polis'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Tier (e.g. Smile 1)'),
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(labelText: 'Min Harga Perangkat (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(labelText: 'Max Harga Perangkat (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _premiumController,
                  decoration: const InputDecoration(labelText: 'Harga Premi (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Durasi (Hari)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: _createTier, child: const Text('Simpan')),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tier Polis')),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tiers.length,
              itemBuilder: (context, index) {
                final tier = _tiers[index];
                final double minPrice = double.tryParse(tier['min_price']?.toString() ?? '0') ?? 0;
                final double maxPrice = double.tryParse(tier['max_price']?.toString() ?? '0') ?? 0;
                final double premium = double.tryParse(tier['policy_price']?.toString() ?? '0') ?? 0;
                final int duration = int.tryParse(tier['policy_duration_days']?.toString() ?? '365') ?? 365;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tier['tier_name'] ?? 'Tier #${tier['id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
                            ),
                            Switch(
                              value: tier['is_active'] ?? true,
                              activeColor: Colors.purple,
                              onChanged: (val) {
                                 SnackbarHelper.showInfo(context, 'Edit status belum tersedia');
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.price_change, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatCurrency(minPrice)} - ${_formatCurrency(maxPrice)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Text('Harga Premi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(_formatCurrency(premium), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                ]
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                    const Text('Durasi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('$duration Hari', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ]
                            ),
                          ]
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
