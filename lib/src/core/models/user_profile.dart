class UserProfile {
  final String id;
  final String? handle;
  final int learnerCode;
  final String locale;
  final DateTime? studyGoalDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.handle,
    required this.learnerCode,
    required this.locale,
    required this.studyGoalDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to create from Supabase response
  factory UserProfile.fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      handle: data['handle'] as String?,
      learnerCode: data['learner_code'] as int,
      locale: data['locale'] as String,
      studyGoalDate: data['study_goal_date'] != null
          ? DateTime.parse(data['study_goal_date'] as String)
          : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Convert to Supabase insert/update format
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'handle': handle,
      'learner_code': learnerCode,
      'locale': locale,
      'study_goal_date': studyGoalDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for immutability
  UserProfile copyWith({
    String? id,
    String? handle,
    int? learnerCode,
    String? locale,
    DateTime? studyGoalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      handle: handle ?? this.handle,
      learnerCode: learnerCode ?? this.learnerCode,
      locale: locale ?? this.locale,
      studyGoalDate: studyGoalDate ?? this.studyGoalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, handle: $handle, learnerCode: $learnerCode, locale: $locale, studyGoalDate: $studyGoalDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}