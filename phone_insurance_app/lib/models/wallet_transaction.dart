// lib/models/wallet_transaction.dart

class WalletTransaction {
  final String id;
  final String walletId;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;
  
  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });
  
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    try {
      // Parse double safely
      double parseDouble(dynamic value, double fallback) {
        try {
          if (value == null) return fallback;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          return double.tryParse(value.toString()) ?? fallback;
        } catch (e) {
          print('Double parse error: $e');
          return fallback;
        }
      }
      
      // Parse date safely
      DateTime parseDate(dynamic value) {
        try {
          if (value == null) return DateTime.now();
          if (value is DateTime) return value;
          return DateTime.parse(value.toString());
        } catch (e) {
          print('Date parse error: $e');
          return DateTime.now();
        }
      }
      
      return WalletTransaction(
        id: json['id']?.toString() ?? 'unknown',
        walletId: json['wallet']?.toString() ?? 'unknown',
        transactionType: json['transaction_type']?.toString() ?? 'unknown',
        amount: parseDouble(json['amount'], 0.0),
        balanceBefore: parseDouble(json['balance_before'], 0.0),
        balanceAfter: parseDouble(json['balance_after'], 0.0),
        description: json['description']?.toString() ?? 'No description',
        referenceId: json['reference_id']?.toString(),
        referenceType: json['reference_type']?.toString(),
        createdAt: parseDate(json['created_at']),
      );
    } catch (e, stackTrace) {
      print('ERROR parsing WalletTransaction: $e');
      print('JSON: $json');
      print('StackTrace: $stackTrace');
      
      // Safe fallback
      return WalletTransaction(
        id: 'error',
        walletId: 'error',
        transactionType: 'error',
        amount: 0,
        balanceBefore: 0,
        balanceAfter: 0,
        description: 'Parse error',
        referenceId: null,
        referenceType: null,
        createdAt: DateTime.now(),
      );
    }
  }
  
  String get formattedAmount {
    try {
      final value = amount.abs();
      return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  String get formattedBalanceBefore {
    try {
      return 'Rp ${balanceBefore.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  String get formattedBalanceAfter {
    try {
      return 'Rp ${balanceAfter.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  String get formattedDate {
    // Simple pattern without locale
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  String get formattedDateShort {
    // Simple pattern without locale
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}';
  }
  
  bool get isCredit {
    return amount > 0;
  }
  
  bool get isDebit {
    return amount < 0;
  }
  
  String get typeLabel {
    switch (transactionType.toLowerCase()) {
      case 'topup':
        return 'Top Up';
      case 'deduction':
        return 'Potongan';
      case 'policy_purchase':
        return 'Beli Polis';
      case 'refund':
        return 'Refund';
      case 'adjustment':
        return 'Penyesuaian';
      default:
        return transactionType;
    }
  }
}
