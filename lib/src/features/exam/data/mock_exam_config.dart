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
    // All Categories - Code 1 (Motorcycles)
    MockExamConfig(
      id: 'all_code1',
      title: 'All Categories (Code 1)',
      learnerCode: 1,
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // All Categories - Code 2 (Light Vehicles)
    MockExamConfig(
      id: 'all_code2',
      title: 'All Categories (Code 2)',
      learnerCode: 2,
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // All Categories - Code 3 (Heavy Vehicles)
    MockExamConfig(
      id: 'all_code3',
      title: 'All Categories (Code 3)',
      learnerCode: 3,
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Rules of the Road - All Codes
    MockExamConfig(
      id: 'rules_all',
      title: 'Rules of the Road',
      category: 'rules_of_road',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Road Signs - All Codes
    MockExamConfig(
      id: 'signs_all',
      title: 'Road Signs',
      category: 'road_signs',
      questionCount: 30,
      timeLimitMinutes: 45,
    ),
    // Vehicle Controls - All Codes
    MockExamConfig(
      id: 'controls_all',
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