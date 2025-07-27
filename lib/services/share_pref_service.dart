import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preference.dart';

class SharedPrefService {
  static const _fitnessGoalKey = 'fitnessGoal';
  static const _activityLevelKey = 'activityLevel';
  static const _interestsKey = 'interests';

  Future<void> saveUserPreference(UserPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fitnessGoalKey, preference.fitnessGoal);
    await prefs.setString(_activityLevelKey, preference.activityLevel);
    await prefs.setStringList(_interestsKey, preference.interests);
  }

  Future<UserPreference?> getUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final fitnessGoal = prefs.getString(_fitnessGoalKey);
    final activityLevel = prefs.getString(_activityLevelKey);
    final interests = prefs.getStringList(_interestsKey);

    if (fitnessGoal != null && activityLevel != null && interests != null) {
      return UserPreference(
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
        interests: interests,
      );
    }
    return null;
  }

  Future<void> clearPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fitnessGoalKey);
    await prefs.remove(_activityLevelKey);
    await prefs.remove(_interestsKey);
  }
}
