import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../services/image_picker_service.dart';
import '../../models/policy.dart';
import '../../utils/snackbar_helper.dart';

class ClaimFormScreen extends StatefulWidget {
  final Policy policy;

  const ClaimFormScreen({super.key, required this.policy});

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  final _descriptionController = TextEditingController();
  
  String? _selectedDamageType;
  DateTime _incidentDate = DateTime.now();
  bool _isLoading = false;
  File? _damagePhoto;

  final List<Map<String, dynamic>> _damageTypes = [
    {'value': 'Layar Pecah', 'icon': Icons.phone_android, 'color': Colors.red},
    {'value': 'LCD Rusak', 'icon': Icons.tv_off, 'color': Colors.orange},
    {'value': 'Kerusakan Air', 'icon': Icons.water_damage, 'color': Colors.blue},
    {'value': 'Baterai Rusak', 'icon': Icons.battery_alert, 'color': Colors.amber},
    {'value': 'Kamera Rusak', 'icon': Icons.camera_alt, 'color': Colors.purple},
    {'value': 'Port Charging Rusak', 'icon': Icons.power_off, 'color': Colors.green},
    {'value': 'Kehilangan', 'icon': Icons.find_in_page, 'color': Colors.deepOrange},
    {'value': 'Lainnya', 'icon': Icons.build, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _getDeductionInfo() {
    if (widget.policy.tierName?.toLowerCase() == 'standar') {
      return 'Potongan 10% dari jumlah klaim yang disetujui admin';
    } else if (widget.policy.tierName?.toLowerCase() == 'gold') {
      return 'Potongan 5% dari jumlah klaim yang disetujui admin';
    } else if (widget.policy.tierName?.toLowerCase() == 'premium') {
      return 'GRATIS! Tanpa potongan (0%)';
    }
    return 'Potongan sesuai tier';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    
    if (picked != null && picked != _incidentDate) {
      setState(() {
        _incidentDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePickerService.pickImageWithDialog(context);
    
    if (image != null) {
      // Check file size (max 5MB)
      final isValid = await _imagePickerService.isFileSizeValid(image, maxSizeMB: 5.0);
      
      if (isValid) {
        setState(() => _damagePhoto = image);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Foto berhasil dipilih');
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, 'Ukuran foto maksimal 5MB');
        }
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDamageType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis kerusakan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Klaim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${widget.policy.deviceBrand} ${widget.policy.deviceModel}'),
            Text('Jenis Kerusakan: $_selectedDamageType'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Klaim akan direview oleh admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin akan menentukan jumlah klaim berdasarkan kerusakan yang Anda laporkan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDeductionInfo(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
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
            child: const Text('Ajukan Klaim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.init();
      
      // Format to yyyy-MM-dd for backend
      final incidentDateStr = '${_incidentDate.year}-${_incidentDate.month.toString().padLeft(2, '0')}-${_incidentDate.day.toString().padLeft(2, '0')}';
      
      await _apiService.createClaim(
        policyId: widget.policy.id,
        damageType: _selectedDamageType!,
        damageDescription: _descriptionController.text.trim(),
        incidentDate: incidentDateStr,
        claimAmount: 0, // Admin will set the amount
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Klaim berhasil diajukan! Menunggu persetujuan admin.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pop(context, true); // Return to select policy screen
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Klaim Kerusakan'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Policy Info Card
              _buildPolicyInfoCard(),
              const SizedBox(height: 24),

              // Damage Type Dropdown
              const Text(
                'Jenis Kerusakan *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDamageType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pilih jenis kerusakan',
                  prefixIcon: Icon(Icons.report_problem),
                ),
                items: _damageTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Row(
                      children: [
                        Text(type['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(type['value']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDamageType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih jenis kerusakan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description TextArea
              const Text(
                'Deskripsi Kerusakan *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Jelaskan detail kerusakan (minimal 20 karakter)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  if (value.length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Incident Date Picker
              const Text(
                'Tanggal Kejadian *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_incidentDate.day.toString().padLeft(2, '0')}-${_incidentDate.month.toString().padLeft(2, '0')}-${_incidentDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Image Upload Section
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Info Card
              _buildInfoCard(),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'AJUKAN KLAIM',
                          style: TextStyle(
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Kerusakan (Opsional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_damagePhoto != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _damagePhoto!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => _damagePhoto = null),
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          iconSize: 20,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(_damagePhoto == null ? 'Ambil Foto' : 'Ganti Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
              
              if (_damagePhoto == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Foto kerusakan membantu proses verifikasi',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: _getTierColor(widget.policy.tierName)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Polis yang Dipilih',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTierColor(widget.policy.tierName).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getTierColor(widget.policy.tierName)),
                  ),
                  child: Text(
                    widget.policy.tierName ?? 'N/A',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getTierColor(widget.policy.tierName),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.policy.deviceBrand} ${widget.policy.deviceModel}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'IMEI: ${widget.policy.imeiNumber}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sisa Kuota Klaim: ${widget.policy.maxClaimsPerYear - widget.policy.claimsUsed}/${widget.policy.maxClaimsPerYear}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final isGoldOrStandar = widget.policy.tierName?.toLowerCase() == 'gold' || 
                            widget.policy.tierName?.toLowerCase() == 'standar';
    
    return Card(
      color: isGoldOrStandar ? Colors.orange.shade50 : Colors.green.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGoldOrStandar ? Icons.info_outline : Icons.check_circle_outline,
                  color: isGoldOrStandar ? Colors.orange.shade700 : Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informasi Penting',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isGoldOrStandar ? Colors.orange.shade900 : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Admin akan menentukan jumlah klaim berdasarkan kerusakan yang Anda laporkan',
              style: TextStyle(
                fontSize: 13,
                color: isGoldOrStandar ? Colors.orange.shade800 : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${_getDeductionInfo()}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isGoldOrStandar ? Colors.orange.shade900 : Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Status klaim dapat dilihat di menu Riwayat Klaim',
              style: TextStyle(
                fontSize: 13,
                color: isGoldOrStandar ? Colors.orange.shade800 : Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
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
}
