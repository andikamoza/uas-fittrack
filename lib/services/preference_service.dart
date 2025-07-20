class PreferenceService {
  static bool? getOnboardingSeen() {
    return false; // default
  }

  static bool? getLoginStatus() {
    return false; // default
  }

  static Future<void> setOnboardingSeen(bool seen) async {
    // dummy function
  }

  static Future<void> setLoginStatus(bool loggedIn) async {
    // dummy function
  }
}
