// lib/models/notification.dart

class AppNotification {
  final String id;
  final String notificationType;
  final String title;
  final String message;
  final String? relatedClaimId;
  final String? relatedPolicyId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.relatedClaimId,
    this.relatedPolicyId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      notificationType: json['notification_type'],
      title: json['title'],
      message: json['message'],
      relatedClaimId: json['related_claim_id'],
      relatedPolicyId: json['related_policy_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  // Get icon based on notification type
  String getIcon() {
    switch (notificationType) {
      case 'claim_submitted':
        return '📝';
      case 'claim_approved':
        return '✅';
      case 'claim_rejected':
        return '❌';
      case 'claim_in_progress':
        return '🔧';
      case 'claim_completed':
        return '🎉';
      case 'policy_expiring':
        return '⚠️';
      case 'wallet_topup':
        return '💰';
      default:
        return '🔔';
    }
  }
}
