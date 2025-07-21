import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static Future<void> savePreferenceData(Map<String, String?> data) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in data.keys) {
      if (data[key] != null) {
        await prefs.setString(key, data[key]!);
      }
    }
  }

  static Future<Map<String, String>> getPreferenceData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'goal': prefs.getString('goal') ?? '',
      'activityLevel': prefs.getString('activityLevel') ?? '',
      'workoutTime': prefs.getString('workoutTime') ?? '',
    };
  }

  static Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', seen);
  }

  static Future<bool?> getOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingSeen');
  }

  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool?> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn');
  }
}
