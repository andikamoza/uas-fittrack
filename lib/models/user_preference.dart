class UserPreference {
  final String fitnessGoal;
  final String activityLevel;
  final List<String> interests;

  UserPreference({
    required this.fitnessGoal,
    required this.activityLevel,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'interests': interests,
    };
  }

  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      fitnessGoal: map['fitnessGoal'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
