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

class _ClaimFormScreenState extends State<ClaimFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  final _descriptionController = TextEditingController();
  
  String? _selectedDamageType;
  DateTime _incidentDate = DateTime.now();
  bool _isLoading = false;
  List<File> _damagePhotos = []; // Multiple photos
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _damageTypes = [
    {'value': 'Layar Pecah', 'icon': Icons.phone_android, 'color': Colors.red},
    {'value': 'LCD Rusak', 'icon': Icons.tv_off, 'color': Colors.orange},
    {'value': 'Kerusakan Air', 'icon': Icons.water_damage, 'color': Colors.blue},
    {'value': 'Baterai Rusak', 'icon': Icons.battery_alert, 'color': Colors.amber},
    {'value': 'Kamera Rusak', 'icon': Icons.camera_alt, 'color': Colors.purple},
    {'value': 'Port Charging', 'icon': Icons.power_off, 'color': Colors.green},
    {'value': 'Kehilangan', 'icon': Icons.find_in_page, 'color': Colors.deepOrange},
    {'value': 'Lainnya', 'icon': Icons.build, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getClaimInfo() {
    return 'Admin akan menentukan biaya perbaikan dan memotong dari saldo policy Anda.';
  }

  Color _getTierColor() {
    // Smile primary color - Orange (matching dashboard)
    return Colors.orange.shade600;
  }
  
  Color _getSmilePrimary() {
    return Colors.orange.shade600;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getTierColor(),
            ),
          ),
          child: child!,
        );
      },
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
      // Check file size (max 10MB)
      final isValid = await _imagePickerService.isFileSizeValid(image, maxSizeMB: 10.0);
      
      if (isValid) {
        setState(() => _damagePhotos.add(image));
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Foto berhasil ditambahkan (${_damagePhotos.length} foto)');
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, 'Ukuran foto maksimal 10MB');
        }
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _damagePhotos.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDamageType == null) {
      SnackbarHelper.showError(context, 'Pilih jenis kerusakan terlebih dahulu');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _getTierColor()),
            const SizedBox(width: 8),
            const Text('Konfirmasi Klaim'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${widget.policy.deviceBrand} ${widget.policy.deviceModel}'),
            const SizedBox(height: 4),
            Text('Jenis Kerusakan: $_selectedDamageType'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Klaim akan direview oleh admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getClaimInfo(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTierColor(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ajukan', style: TextStyle(color: Colors.white)),
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
      
      // DEBUG: Log photo info
      print('[DEBUG ClaimForm] Number of photos: ${_damagePhotos.length}');
      for (int i = 0; i < _damagePhotos.length; i++) {
        final file = _damagePhotos[i];
        final size = await file.length();
        print('[DEBUG ClaimForm] Photo $i: ${file.path}, size: ${size} bytes');
      }
      
      await _apiService.createClaim(
        policyId: widget.policy.id,
        damageType: _selectedDamageType!,
        damageDescription: _descriptionController.text.trim(),
        incidentDate: incidentDateStr,
        claimAmount: 0, // Admin will set the amount
        photos: _damagePhotos.isNotEmpty ? _damagePhotos : null,
      );

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Klaim berhasil diajukan! Menunggu persetujuan admin.');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Ajukan Klaim', style: TextStyle(color: Colors.white)),
        backgroundColor: _getTierColor(),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Policy Info Card - Compact
              _buildPolicyInfoCard(),
              const SizedBox(height: 20),

              // Damage Type Selection - Grid Cards
              _buildDamageTypeSection(),
              const SizedBox(height: 20),

              // Description TextArea - Compact
              _buildDescriptionSection(),
              const SizedBox(height: 20),

              // Incident Date Picker - Compact
              _buildDateSection(),
              const SizedBox(height: 20),

              // Image Upload Section - Better Preview
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Info Card - Compact
              _buildInfoCard(),
              const SizedBox(height: 24),

              // Submit Button - More Compact
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTierColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.phone_iphone, color: _getTierColor(), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.policy.deviceBrand} ${widget.policy.deviceModel}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.policy.policyNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getTierColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getTierColor(), width: 1.5),
                ),
                child: Text(
                  widget.policy.tierName ?? 'N/A',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getTierColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDamageTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kerusakan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _damageTypes.length,
          itemBuilder: (context, index) {
            final type = _damageTypes[index];
            final isSelected = _selectedDamageType == type['value'];
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDamageType = type['value'];
                });
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? type['color'].withOpacity(0.15) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? type['color'] 
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: type['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      color: isSelected ? type['color'] : Colors.grey.shade600,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type['value'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? type['color'] : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Kerusakan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Jelaskan detail kerusakan',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _getTierColor(), width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
          maxLines: 4,
          maxLength: 500,
          style: const TextStyle(fontSize: 14),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Kejadian',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: _getTierColor(), size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_incidentDate.day.toString().padLeft(2, '0')}-${_incidentDate.month.toString().padLeft(2, '0')}-${_incidentDate.year}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto Kerusakan (Opsional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_damagePhotos.isNotEmpty)
              Text(
                '${_damagePhotos.length} foto',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Photo Grid
        if (_damagePhotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _damagePhotos.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              // Last item is the add button
              if (index == _damagePhotos.length) {
                return InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 32, color: _getTierColor()),
                        const SizedBox(height: 4),
                        Text(
                          'Tambah',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Photo item
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _damagePhotos[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: _getTierColor()),
                  const SizedBox(height: 8),
                  Text(
                    'Tap untuk upload foto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max 10MB per foto',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Penting',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin akan review klaim Anda, menentukan biaya perbaikan, dan memotong saldo policy sesuai biaya yang diperlukan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTierColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isLoading ? 0 : 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Ajukan Klaim',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
