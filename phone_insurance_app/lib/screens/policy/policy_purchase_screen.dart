import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/device_package.dart';
import '../../models/policy_tier.dart';

class PolicyPurchaseScreen extends StatefulWidget {
  final DevicePackage device;

  const PolicyPurchaseScreen({super.key, required this.device});

  @override
  State<PolicyPurchaseScreen> createState() => _PolicyPurchaseScreenState();
}

class _PolicyPurchaseScreenState extends State<PolicyPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _imeiController = TextEditingController();
  final _priceController = TextEditingController();
  
  List<PolicyTier> _tiers = [];
  PolicyTier? _selectedTier;
  Map<String, dynamic>? _walletData;
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill price with device value
    _priceController.text = widget.device.deviceValue.toStringAsFixed(0);
    _loadData();
  }

  @override
  void dispose() {
    _imeiController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      await _apiService.init();
      
      // Load tiers and wallet in parallel
      final results = await Future.wait([
        _apiService.getPolicyTiers(),
        _apiService.getWalletBalance(),
      ]);
      
      final tiersJson = results[0] as List<dynamic>;
      final walletJson = results[1] as Map<String, dynamic>?;
      
      setState(() {
        _tiers = tiersJson.map((json) => PolicyTier.fromJson(json)).toList();
        _walletData = walletJson;
        _isLoadingData = false;
        _detectTier(); // Auto-detect tier based on price
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _detectTier() {
    if (_priceController.text.isEmpty) return;
    
    final price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (price == null) return;
    
    setState(() {
      _selectedTier = _tiers.firstWhere(
        (tier) => tier.canCoverDevice(price),
        orElse: () => _tiers.last,
      );
    });
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  double get _currentBalance {
    if (_walletData == null) return 0;
    return double.parse(_walletData!['balance'].toString());
  }

  double get _balanceAfterPurchase {
    if (_selectedTier == null) return _currentBalance;
    return _currentBalance - _selectedTier!.policyPrice;
  }

  bool get _hasEnoughBalance {
    if (_selectedTier == null) return false;
    return _currentBalance >= _selectedTier!.policyPrice;
  }

  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasEnoughBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak cukup! Silakan top-up terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembelian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${widget.device.fullName}'),
            Text('Tier: ${_selectedTier?.tierName}'),
            Text('Harga Polis: ${_formatCurrency(_selectedTier?.policyPrice ?? 0)}'),
            const SizedBox(height: 12),
            Text(
              'Saldo akan berkurang dari ${_formatCurrency(_currentBalance)} menjadi ${_formatCurrency(_balanceAfterPurchase)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Beli Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      
      await _apiService.createPolicy(
        devicePackageId: widget.device.id,
        imeiNumber: _imeiController.text.trim(),
        purchasePrice: price,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Polis berhasil dibeli! Wallet Anda telah di-deduct.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a bit for message to show, then navigate back
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Pop back to device selection with success result
        if (mounted) {
          print('Policy created successfully, popping with result=true');
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beli Polis Asuransi'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Device Info Card
              _buildDeviceInfoCard(),
              const SizedBox(height: 24),

              // IMEI Input
              TextFormField(
                controller: _imeiController,
                decoration: const InputDecoration(
                  labelText: 'Nomor IMEI *',
                  hintText: '15 digit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phonelink_lock),
                ),
                keyboardType: TextInputType.number,
                maxLength: 15,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IMEI wajib diisi';
                  }
                  if (value.length != 15) {
                    return 'IMEI harus 15 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Purchase Price Input
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Pembelian *',
                  hintText: 'Rp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _detectTier(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga pembelian wajib diisi';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tier Info Card
              if (_selectedTier != null) _buildTierInfoCard(),
              const SizedBox(height: 24),

              // Wallet Balance Card
              _buildWalletCard(),
              const SizedBox(height: 32),

              // Purchase Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasEnoughBalance ? Colors.indigo : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _hasEnoughBalance
                              ? 'BELI POLIS SEKARANG'
                              : 'SALDO TIDAK CUKUP - TOP UP DULU',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildDeviceInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device yang Diasuransikan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.device.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nilai Device: ${_formatCurrency(widget.device.deviceValue)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierInfoCard() {
    return Card(
      color: Colors.indigo.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  'Tier: ${_selectedTier!.tierName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildTierDetail('💰 Harga Polis', _formatCurrency(_selectedTier!.policyPrice)),
            _buildTierDetail('🎯 Potongan Klaim', '${_selectedTier!.claimDeductionPercent.toStringAsFixed(0)}%'),
            _buildTierDetail('📅 Durasi', '${_selectedTier!.policyDurationDays} hari'),
            _buildTierDetail('🔄 Max Klaim/Tahun', '${_selectedTier!.maxClaimsPerYear}x'),
          ],
        ),
      ),
    );
  }

  Widget _buildTierDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Card(
      color: _hasEnoughBalance ? Colors.green.shade50 : Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Saldo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo Sekarang:'),
                Text(
                  _formatCurrency(_currentBalance),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo Setelah:'),
                Text(
                  _formatCurrency(_balanceAfterPurchase),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _hasEnoughBalance ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            if (!_hasEnoughBalance) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saldo tidak cukup! Kurang ${_formatCurrency(_selectedTier!.policyPrice - _currentBalance)}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
