// lib/models/policy.dart

import 'package:flutter/material.dart';

class Policy {
  final String id;
  final String policyNumber;
  final String userName;
  final String deviceBrand;
  final String deviceModel;
  final String imeiNumber;
  final double purchasePrice;
  final double policyPrice;
  final double policyBalance; // ✅ Saldo per policy
  final DateTime activationDate;
  final DateTime expiryDate;
  final int claimsUsed;
  final String status;
  final String? tierName;
  final String? storeName; // ✅ Store association
  final int maxClaimsPerYear; // Updated to match backend
  
  Policy({
    required this.id,
    required this.policyNumber,
    required this.userName,
    required this.deviceBrand,
    required this.deviceModel,
    required this.imeiNumber,
    required this.purchasePrice,
    required this.policyPrice,
    required this.policyBalance, // ✅ Saldo per policy
    required this.activationDate,
    required this.expiryDate,
    required this.claimsUsed,
    required this.status,
    this.tierName,
    this.storeName,
    required this.maxClaimsPerYear,
  });
  
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'],
      policyNumber: json['policy_number'],
      userName: json['user_name'],
      deviceBrand: json['device_details']['device_brand'],
      deviceModel: json['device_details']['device_model'],
      imeiNumber: json['imei_number'],
      purchasePrice: double.parse(json['purchase_price'].toString()),
      policyPrice: double.parse(json['policy_price'].toString()),
      policyBalance: double.parse(json['policy_balance'].toString()), // ✅ Parse policy balance
      activationDate: DateTime.parse(json['activation_date']),
      expiryDate: DateTime.parse(json['expiry_date']),
      claimsUsed: json['claims_used'],
      status: json['status'],
      tierName: json['tier_name'] ?? json['tier_details']?['tier_name'],
      storeName: json['store_name'] ?? json['store_details']?['name'] ?? json['store']?['name'],
      maxClaimsPerYear: json['max_claims_per_year'] ?? json['claims_limit'] ?? 5,
    );
  }
}