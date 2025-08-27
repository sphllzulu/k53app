class Referral {
  final String id;
  final String referrerId;
  final String referredEmail;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? pointsAwarded;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredEmail,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.pointsAwarded,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'],
      referrerId: json['referrer_id'],
      referredEmail: json['referred_email'],
      status: ReferralStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReferralStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      pointsAwarded: json['points_awarded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_email': referredEmail,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'points_awarded': pointsAwarded,
    };
  }
}

enum ReferralStatus {
  pending,
  completed,
  expired,
  share_event,
}

class ShareContent {
  final String title;
  final String message;
  final String? imageUrl;
  final String? deepLink;

  ShareContent({
    required this.title,
    required this.message,
    this.imageUrl,
    this.deepLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (deepLink != null) 'deepLink': deepLink,
    };
  }

  ShareContent copyWith({
    String? title,
    String? message,
    String? imageUrl,
    String? deepLink,
  }) {
    return ShareContent(
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
    );
  }
}