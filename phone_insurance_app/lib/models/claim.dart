// lib/models/claim.dart

class Claim {
  final String id;
  final String policyId;
  final String deviceBrand;
  final String deviceModel;
  final String damageType;
  final String damageDescription;
  final DateTime incidentDate;
  final double claimAmount;
  final double? walletDeducted;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? processedAt;
  
  Claim({
    required this.id,
    required this.policyId,
    required this.deviceBrand,
    required this.deviceModel,
    required this.damageType,
    required this.damageDescription,
    required this.incidentDate,
    required this.claimAmount,
    this.walletDeducted,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
  });
  
  factory Claim.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates safely
      DateTime parseDate(dynamic value, DateTime fallback) {
        try {
          if (value == null) return fallback;
          if (value is DateTime) return value;
          return DateTime.parse(value.toString());
        } catch (e) {
          print('Date parse error: $e, value: $value');
          return fallback;
        }
      }
      
      // Parse double safely
      double parseDouble(dynamic value, double fallback) {
        try {
          if (value == null) return fallback;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          return double.tryParse(value.toString()) ?? fallback;
        } catch (e) {
          print('Double parse error: $e, value: $value');
          return fallback;
        }
      }
      
      return Claim(
        id: json['id']?.toString() ?? 'unknown',
        policyId: json['policy']?.toString() ?? 'unknown',
        deviceBrand: json['device_brand']?.toString() ?? 'Unknown',
        deviceModel: json['device_model']?.toString() ?? 'Unknown',
        damageType: json['damage_type']?.toString() ?? 'Unknown',
        damageDescription: json['damage_description']?.toString() ?? 'No description',
        incidentDate: parseDate(json['incident_date'], DateTime.now()),
        claimAmount: parseDouble(json['claim_amount'], 0.0),
        walletDeducted: json['wallet_deducted'] != null 
            ? parseDouble(json['wallet_deducted'], 0.0)
            : null,
        status: json['status']?.toString() ?? 'pending',
        adminNotes: json['admin_notes']?.toString(),
        createdAt: parseDate(json['created_at'], DateTime.now()),
        processedAt: json['processed_at'] != null 
            ? parseDate(json['processed_at'], DateTime.now())
            : null,
      );
    } catch (e, stackTrace) {
      print('ERROR parsing Claim: $e');
      print('JSON: $json');
      print('StackTrace: $stackTrace');
      
      // Return safe fallback
      return Claim(
        id: json['id']?.toString() ?? 'error',
        policyId: 'error',
        deviceBrand: 'Error',
        deviceModel: 'Error',
        damageType: 'Error',
        damageDescription: 'Parse error',
        incidentDate: DateTime.now(),
        claimAmount: 0,
        walletDeducted: null,
        status: 'pending',
        adminNotes: null,
        createdAt: DateTime.now(),
        processedAt: null,
      );
    }
  }
  
  String get formattedClaimAmount {
    try {
      String str = claimAmount.toInt().toString();
      String result = "";
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        result = str[i] + result;
        count++;
        if (count == 3 && i > 0) {
          result = "." + result;
          count = 0;
        }
      }
      return 'Rp $result';
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  String get formattedWalletDeducted {
    try {
      if (walletDeducted == null || walletDeducted == 0) {
        return 'Rp 0';
      }
      return 'Rp ${walletDeducted!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  String get formattedIncidentDate {
    // Simple pattern without locale
    return '${incidentDate.day.toString().padLeft(2, '0')}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.year}';
  }
  
  String get formattedCreatedAt {
    // Simple pattern without locale
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
  
  String get deviceFullName => '$deviceBrand $deviceModel';
}
