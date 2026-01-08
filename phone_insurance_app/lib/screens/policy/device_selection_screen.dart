import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/device_package.dart';
import 'policy_purchase_screen.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  final ApiService _apiService = ApiService();
  List<DevicePackage> _devices = [];
  List<DevicePackage> _filteredDevices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final devicesJson = await _apiService.getDevicePackages();
      
      setState(() {
        _devices = devicesJson
            .map((json) => DevicePackage.fromJson(json))
            .where((device) => device.isActive)
            .toList();
        _filteredDevices = _devices;
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

  void _filterDevices(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDevices = _devices;
      } else {
        _filteredDevices = _devices.where((device) {
          return device.fullName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  IconData _getBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'apple':
        return Icons.apple;
      case 'samsung':
        return Icons.smartphone;
      case 'xiaomi':
        return Icons.phone_android;
      case 'oppo':
        return Icons.phone_iphone;
      case 'vivo':
        return Icons.phone_android;
      default:
        return Icons.phone_android;
    }
  }

  Color _getBrandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'apple':
        return Colors.grey.shade800;
      case 'samsung':
        return Colors.blue.shade700;
      case 'xiaomi':
        return Colors.orange.shade700;
      case 'oppo':
        return Colors.green.shade700;
      case 'vivo':
        return Colors.purple.shade700;
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
        title: const Text('Pilih Device Anda'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterDevices,
              decoration: InputDecoration(
                hintText: 'Cari device...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Device Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_filteredDevices.length} device tersedia',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Device List
          Expanded(
            child: _filteredDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Device tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _filteredDevices[index];
                      return _buildDeviceCard(device);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DevicePackage device) {
    final brandColor = _getBrandColor(device.deviceBrand);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PolicyPurchaseScreen(device: device),
            ),
          );
          // If policy was purchased, go back to dashboard with refresh signal
          if (result == true && mounted) {
            print('Policy purchased, popping back to dashboard with result=true');
            Navigator.of(context).pop(true);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBrandIcon(device.deviceBrand),
                  size: 32,
                  color: brandColor,
                ),
              ),

              const SizedBox(width: 16),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      device.deviceBrand,
                      style: TextStyle(
                        fontSize: 12,
                        color: brandColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Model & Variant
                    Text(
                      '${device.deviceModel} ${device.deviceVariant}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Price
                    Text(
                      _formatCurrency(device.deviceValue),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
