// lib/models/policy_tier.dart

class PolicyTier {
  final String id;
  final String tierName;
  final double minPrice;
  final double maxPrice;
  final double policyPrice;
  final double claimDeductionPercent;
  final int policyDurationDays;
  final int maxClaimsPerYear;
  final bool isActive;
  
  PolicyTier({
    required this.id,
    required this.tierName,
    required this.minPrice,
    required this.maxPrice,
    required this.policyPrice,
    required this.claimDeductionPercent,
    required this.policyDurationDays,
    required this.maxClaimsPerYear,
    required this.isActive,
  });
  
  factory PolicyTier.fromJson(Map<String, dynamic> json) {
    return PolicyTier(
      id: json['id'],
      tierName: json['tier_name'],
      minPrice: double.parse(json['min_price'].toString()),
      maxPrice: double.parse(json['max_price'].toString()),
      policyPrice: double.parse(json['policy_price'].toString()),
      claimDeductionPercent: double.parse(json['claim_deduction_percent'].toString()),
      policyDurationDays: json['policy_duration_days'],
      maxClaimsPerYear: json['max_claims_per_year'],
      isActive: json['is_active'],
    );
  }
  
  bool canCoverDevice(double devicePrice) {
    return devicePrice >= minPrice && devicePrice <= maxPrice;
  }
}
