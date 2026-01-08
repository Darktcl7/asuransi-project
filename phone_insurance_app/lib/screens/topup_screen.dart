import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final _amountController = TextEditingController();
  String? _selectedMethod;
  bool _isLoading = false;

  Future<void> _handleTopUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Initialize API service to load token
      await _apiService.init();
      
      final amount = double.parse(_amountController.text);
      await _apiService.topUp(
        amount: amount,
        paymentMethod: _selectedMethod!,
      );

      // Jika sukses, kembali ke Dashboard dan refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Top Up berhasil dibuat! Menunggu verifikasi admin.')),
        );
        Navigator.pop(context, true); // Kirim sinyal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Top Up: ${e.toString()}')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Saldo'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah Top Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Min. Rp 100.000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (double.parse(value) < 100000) {
                    return 'Minimal top up Rp 100.000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Metode',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMethod,
                items: const [
                  DropdownMenuItem(value: 'transfer_bank', child: Text('Transfer Bank')),
                  DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet (Dana/Gopay)')),
                ],
                onChanged: (value) {
                  setState(() => _selectedMethod = value);
                },
                validator: (value) => (value == null) ? 'Pilih metode pembayaran' : null,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Ajukan Top Up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}