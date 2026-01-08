// lib/utils/validators.dart

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '📧 Email tidak boleh kosong';
    }
    
    // Basic email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '📧 Format email tidak valid';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '🔒 Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return '🔒 Password minimal 6 karakter';
    }
    
    return null;
  }

  // Password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '🔒 Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return '🔒 Password tidak cocok';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '📱 Nomor HP tidak boleh kosong';
    }
    
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanValue.length < 10) {
      return '📱 Nomor HP minimal 10 digit';
    }
    
    if (cleanValue.length > 15) {
      return '📱 Nomor HP maksimal 15 digit';
    }
    
    // Check if it's all numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return '📱 Nomor HP hanya boleh angka';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '👤 Nama tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return '👤 Nama minimal 3 karakter';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return '🏠 Alamat tidak boleh kosong';
    }
    
    if (value.length < 10) {
      return '🏠 Alamat terlalu pendek (minimal 10 karakter)';
    }
    
    return null;
  }

  // IMEI validation (15 digits)
  static String? validateIMEI(String? value) {
    if (value == null || value.isEmpty) {
      return '📱 IMEI tidak boleh kosong';
    }
    
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanValue.length != 15) {
      return '📱 IMEI harus 15 digit';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return '📱 IMEI hanya boleh angka';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {double? minAmount}) {
    if (value == null || value.isEmpty) {
      return '💰 Jumlah tidak boleh kosong';
    }
    
    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
    
    if (amount == null) {
      return '💰 Format jumlah tidak valid';
    }
    
    if (amount <= 0) {
      return '💰 Jumlah harus lebih dari 0';
    }
    
    if (minAmount != null && amount < minAmount) {
      return '💰 Jumlah minimal Rp ${_formatCurrency(minAmount)}';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {int minLength = 20, int maxLength = 500}) {
    if (value == null || value.isEmpty) {
      return '📝 Deskripsi tidak boleh kosong';
    }
    
    if (value.length < minLength) {
      return '📝 Deskripsi minimal $minLength karakter (${value.length}/$minLength)';
    }
    
    if (value.length > maxLength) {
      return '📝 Deskripsi maksimal $maxLength karakter';
    }
    
    return null;
  }

  // Helper method to format currency
  static String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
