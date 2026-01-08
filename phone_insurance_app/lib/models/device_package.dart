// lib/models/device_package.dart

import 'package:intl/intl.dart';

class DevicePackage {
  final String id;
  final String deviceBrand;
  final String deviceModel;
  final String deviceVariant;
  final double deviceValue;
  final bool isActive;
  
  DevicePackage({
    required this.id,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deviceVariant,
    required this.deviceValue,
    required this.isActive,
  });
  
  factory DevicePackage.fromJson(Map<String, dynamic> json) {
    return DevicePackage(
      id: json['id'],
      deviceBrand: json['device_brand'],
      deviceModel: json['device_model'],
      deviceVariant: json['device_variant'],
      deviceValue: double.parse(json['device_value'].toString()),
      isActive: json['is_active'],
    );
  }
  
  String get fullName => '$deviceBrand $deviceModel $deviceVariant';
  
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(deviceValue);
  }
}
