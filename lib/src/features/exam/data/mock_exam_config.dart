class MockExamConfig {
  final String id;
  final String title;
  final String? category;
  final int? learnerCode;
  final int questionCount;
  final int timeLimitMinutes;
  final int level; // 1 for easy, 2 for medium, 3 for hard

  const MockExamConfig({
    required this.id,
    required this.title,
    this.category,
    this.learnerCode,
    required this.questionCount,
    required this.timeLimitMinutes,
    required this.level,
  });

  // Level 1 Mock Exams (Easy Difficulty)
  static final List<MockExamConfig> level1Configs = [
    // All Categories - Code 1 (Motorcycles)
    MockExamConfig(
      id: 'level1_all_code1',
      title: 'Level 1 - All Categories (Code 1)',
      learnerCode: 1,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
    // All Categories - Code 2 (Light Vehicles)
    MockExamConfig(
      id: 'level1_all_code2',
      title: 'Level 1 - All Categories (Code 2)',
      learnerCode: 2,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
    // All Categories - Code 3 (Heavy Vehicles)
    MockExamConfig(
      id: 'level1_all_code3',
      title: 'Level 1 - All Categories (Code 3)',
      learnerCode: 3,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
    // Rules of the Road - All Codes
    MockExamConfig(
      id: 'level1_rules_all',
      title: 'Level 1 - Rules of the Road',
      category: 'rules_of_road',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
    // Road Signs - All Codes
    MockExamConfig(
      id: 'level1_signs_all',
      title: 'Level 1 - Road Signs',
      category: 'road_signs',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
    // Vehicle Controls - All Codes
    MockExamConfig(
      id: 'level1_controls_all',
      title: 'Level 1 - Vehicle Controls',
      category: 'vehicle_controls',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 1,
    ),
  ];

  // Level 2 Mock Exams (Medium Difficulty)
  static final List<MockExamConfig> level2Configs = [
    // All Categories - Code 1 (Motorcycles)
    MockExamConfig(
      id: 'level2_all_code1',
      title: 'Level 2 - All Categories (Code 1)',
      learnerCode: 1,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
    // All Categories - Code 2 (Light Vehicles)
    MockExamConfig(
      id: 'level2_all_code2',
      title: 'Level 2 - All Categories (Code 2)',
      learnerCode: 2,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
    // All Categories - Code 3 (Heavy Vehicles)
    MockExamConfig(
      id: 'level2_all_code3',
      title: 'Level 2 - All Categories (Code 3)',
      learnerCode: 3,
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
    // Rules of the Road - All Codes
    MockExamConfig(
      id: 'level2_rules_all',
      title: 'Level 2 - Rules of the Road',
      category: 'rules_of_road',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
    // Road Signs - All Codes
    MockExamConfig(
      id: 'level2_signs_all',
      title: 'Level 2 - Road Signs',
      category: 'road_signs',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
    // Vehicle Controls - All Codes
    MockExamConfig(
      id: 'level2_controls_all',
      title: 'Level 2 - Vehicle Controls',
      category: 'vehicle_controls',
      questionCount: 30,
      timeLimitMinutes: 45,
      level: 2,
    ),
  ];

  // Combined list of all mock exam configurations
  static List<MockExamConfig> get allConfigs => [...level1Configs, ...level2Configs];

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

  // Helper method to get configs by level
  static List<MockExamConfig> getConfigsByLevel(int level) {
    return allConfigs.where((config) => config.level == level).toList();
  }

  // Helper method to get configs accessible to user based on their level
  static List<MockExamConfig> getConfigsForUserLevel(int userLevel) {
    return allConfigs.where((config) => config.level <= userLevel).toList();
  }

  @override
  String toString() {
    return 'MockExamConfig(id: $id, title: $title, category: $category, learnerCode: $learnerCode, questionCount: $questionCount, timeLimitMinutes: $timeLimitMinutes, level: $level)';
  }
}