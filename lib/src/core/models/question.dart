class Question {
  final String id;
  final String category;
  final int learnerCode;
  final String questionText;
  final List<QuestionOption> options;
  final int correctIndex;
  final String explanation;
  final int version;
  final bool isActive;
  final int difficultyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.category,
    required this.learnerCode,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.version,
    required this.isActive,
    required this.difficultyLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to create from Supabase response
  factory Question.fromSupabase(Map<String, dynamic> data) {
    final optionsJson = data['options'] as List<dynamic>;
    final options = optionsJson.map((option) {
      if (option is Map<String, dynamic>) {
        return QuestionOption.fromJson(option);
      }
      return QuestionOption(text: option.toString());
    }).toList();

    return Question(
      id: data['id'] as String,
      category: data['category'] as String,
      learnerCode: data['learner_code'] as int,
      questionText: data['question_text'] as String,
      options: options,
      correctIndex: data['correct_index'] as int,
      explanation: data['explanation'] as String,
      version: data['version'] as int? ?? 1,
      isActive: data['is_active'] as bool? ?? true,
      difficultyLevel: data['difficulty_level'] as int? ?? 1,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Check if answer is correct
  bool isAnswerCorrect(int chosenIndex) {
    return chosenIndex == correctIndex;
  }

  // Get correct option
  QuestionOption get correctOption {
    return options[correctIndex];
  }

  @override
  String toString() {
    return 'Question(id: $id, category: $category, learnerCode: $learnerCode, questionText: $questionText)';
  }
}

class QuestionOption {
  final String text;
  final String? imageUrl;

  QuestionOption({
    required this.text,
    this.imageUrl,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return text;
  }
}