// lib/models/wallet.dart

class Wallet {
  final String id;
  final double balance;
  final double totalTopup;
  final double totalSpent;
  
  Wallet({
    required this.id,
    required this.balance,
    required this.totalTopup,
    required this.totalSpent,
  });
  
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      balance: double.parse(json['balance'].toString()),
      totalTopup: double.parse(json['total_topup'].toString()),
      totalSpent: double.parse(json['total_spent'].toString()),
    );
  }
}