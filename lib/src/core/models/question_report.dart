class QuestionReport {
  final String id;
  final String questionId;
  final String reporterUserId;
  final ReportReason reason;
  final String? comment;
  final String? sessionId;
  final DateTime createdAt;

  QuestionReport({
    required this.id,
    required this.questionId,
    required this.reporterUserId,
    required this.reason,
    this.comment,
    this.sessionId,
    required this.createdAt,
  });

  factory QuestionReport.fromJson(Map<String, dynamic> json) {
    return QuestionReport(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      reporterUserId: json['reporter_user_id'] as String,
      reason: ReportReason.fromString(json['reason'] as String),
      comment: json['comment'] as String?,
      sessionId: json['session_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'reporter_user_id': reporterUserId,
      'reason': reason.value,
      'comment': comment,
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum ReportReason {
  incorrectAnswer('incorrect_answer'),
  confusingQuestion('confusing_question'),
  multipleCorrect('multiple_correct'),
  outdatedInfo('outdated_info'),
  other('other');

  final String value;
  const ReportReason(this.value);

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportReason.other,
    );
  }

  String get displayText {
    switch (this) {
      case ReportReason.incorrectAnswer:
        return 'Answer seems incorrect';
      case ReportReason.confusingQuestion:
        return 'Question is confusing';
      case ReportReason.multipleCorrect:
        return 'Multiple answers seem correct';
      case ReportReason.outdatedInfo:
        return 'Information is outdated';
      case ReportReason.other:
        return 'Other';
    }
  }

  static List<ReportReason> get selectableReasons => [
        ReportReason.incorrectAnswer,
        ReportReason.confusingQuestion,
        ReportReason.multipleCorrect,
        ReportReason.outdatedInfo,
        ReportReason.other,
      ];
}