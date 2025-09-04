class MockExamConfig {
  final String id;
  final String title;
  final String? category;
  final int? learnerCode;
  final int questionCount;
  final int timeLimitMinutes;

  const MockExamConfig({
    required this.id,
    required this.title,
    this.category,
    this.learnerCode,
    required this.questionCount,
    required this.timeLimitMinutes,
  });

  // All Mock Exams
  static final List<MockExamConfig> allConfigs = [
    // All Categories - Combined from all learner codes
    MockExamConfig(
      id: 'all_codes_combined',
      title: 'All Categories (Combined Codes)',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Rules of the Road - Combined from all learner codes
    MockExamConfig(
      id: 'rules_combined',
      title: 'Rules of the Road',
      category: 'rules_of_road',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Road Signs - Combined from all learner codes
    MockExamConfig(
      id: 'signs_combined',
      title: 'Road Signs',
      category: 'road_signs',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Vehicle Controls - Combined from all learner codes
    MockExamConfig(
      id: 'controls_combined',
      title: 'Vehicle Controls',
      category: 'vehicle_controls',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
  ];

  // Helper method to get config by ID
  static MockExamConfig? getConfigById(String id) {
    try {
      return allConfigs.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get configs by category
  static List<MockExamConfig> getConfigsByCategory(String category) {
    return allConfigs.where((config) => config.category == category).toList();
  }

  // Helper method to get configs by learner code
  static List<MockExamConfig> getConfigsByLearnerCode(int learnerCode) {
    return allConfigs.where((config) => config.learnerCode == learnerCode).toList();
  }

  @override
  String toString() {
    return 'MockExamConfig(id: $id, title: $title, category: $category, learnerCode: $learnerCode, questionCount: $questionCount, timeLimitMinutes: $timeLimitMinutes)';
  }
}