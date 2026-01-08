// lib/models/user.dart

class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? ktpNumber;
  final double walletBalance; // Menggunakan double untuk saldo

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.ktpNumber,
    required this.walletBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      ktpNumber: json['ktp_number'],
      // Pastikan konversi dari String/Decimal Django ke double Dart
      walletBalance: double.parse(json['wallet_balance'].toString()), 
    );
  }
}