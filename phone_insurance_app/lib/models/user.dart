// lib/models/user.dart

class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? ktpNumber;
  final double walletBalance; // Menggunakan double untuk saldo
  final bool isVerified; // Status verifikasi KTP
  final String role; // customer, store_admin, super_admin
  final String? storeCode; // Kode toko terdaftar
  final String? storeName; // Nama toko terdaftar

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.ktpNumber,
    required this.walletBalance,
    required this.isVerified,
    this.storeCode,
    this.storeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Extract store info if available
    final storeData = json['store'];
    String? sCode;
    String? sName;
    
    if (storeData is Map) {
      sCode = storeData['code'];
      sName = storeData['name'];
    }

    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      ktpNumber: json['ktp_number'],
      role: json['role'] ?? 'customer',
      // Pastikan konversi dari String/Decimal Django ke double Dart
      walletBalance: double.parse(json['wallet_balance'].toString()),
      isVerified: json['is_verified'] ?? false,
      storeCode: sCode,
      storeName: sName,
    );
  }
}
