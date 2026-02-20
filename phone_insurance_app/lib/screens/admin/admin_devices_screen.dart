import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class AdminDevicesScreen extends StatefulWidget {
  const AdminDevicesScreen({super.key});

  @override
  State<AdminDevicesScreen> createState() => _AdminDevicesScreenState();
}

class _AdminDevicesScreenState extends State<AdminDevicesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _devices = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Create Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'handphone';

  final List<String> _categories = [
    'handphone', 'elektronik', 'laptop', 'printer', 'sepeda_listrik', 'lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final data = await _apiService.getAdminDevices(search: _searchQuery);
      setState(() => _devices = data);
    } catch (e) {
      SnackbarHelper.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDevice() async {
    if (!_formKey.currentState!.validate()) return;
    
    Navigator.pop(context); // Close dialog first
    setState(() => _isLoading = true);

    try {
      final double price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      final data = {
        'device_category': _selectedCategory,
        'device_brand': _brandController.text,
        'device_model': _modelController.text,
        'device_variant': _variantController.text.isEmpty ? null : _variantController.text,
        'device_color': _colorController.text.isEmpty ? null : _colorController.text,
        'device_value': price, // Model expects decimal
        'is_active': true,
      };

      await _apiService.createAdminDevice(data);
      SnackbarHelper.showSuccess(context, 'Perangkat berhasil ditambahkan');
      
      // Clear form
      _brandController.clear();
      _modelController.clear();
      _variantController.clear();
      _colorController.clear();
      _priceController.clear();
      _selectedCategory = 'handphone';
      
      _loadDevices(); // Refresh list
    } catch (e) {
      setState(() => _isLoading = false);
      SnackbarHelper.showError(context, e.toString());
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Perangkat Baru'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Brand (Merk)'),
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _variantController,
                  decoration: const InputDecoration(labelText: 'Variant (Optional, e.g. 8/256)'),
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Warna (Optional)'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga Pasaran (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: _createDevice, child: const Text('Simpan')),
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Data Perangkat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _devices.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDevices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return _buildDeviceCard(device);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Merk atau Model...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadDevices();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onSubmitted: (value) {
          setState(() => _searchQuery = value);
          _loadDevices();
        },
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    // Mapping keys from API (Model Serializer uses snake_case)
    final category = device['device_category'] ?? '-';
    final brand = device['device_brand'] ?? '-';
    final model = device['device_model'] ?? '-';
    final variant = device['device_variant'];
    final color = device['device_color'];
    
    double price = 0;
    if (device['device_value'] != null) price = double.tryParse(device['device_value'].toString()) ?? 0;
    else if (device['market_price'] != null) price = double.tryParse(device['market_price'].toString()) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(category.toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
                Text(_formatCurrency(price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            
            // Brand & Model
            Row(
              children: [
                const Icon(Icons.phone_android, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$brand $model',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            // Variant & Color
            if (variant != null || color != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (variant != null) ...[
                    Icon(Icons.memory, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(variant, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(width: 16),
                  ],
                  if (color != null) ...[
                    Icon(Icons.palette_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(color, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Tidak ada data perangkat', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
