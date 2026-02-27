import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStore {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyName = 'user_name';
  static const String _keyProfilePicture = 'user_profile_picture';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isOnboardingComplete {
    return _prefs?.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> completeOnboarding() async {
    await _prefs?.setBool(_keyOnboardingComplete, true);
  }

  static String get userName {
    return _prefs?.getString(_keyName) ?? 'XD';
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyName, name);
  }

  static String? get userProfilePicture {
    return _prefs?.getString(_keyProfilePicture);
  }

  static Future<void> setUserProfilePicture(String path) async {
    await _prefs?.setString(_keyProfilePicture, path);
  }
  
  static Future<void> clear() async {
      await _prefs?.clear();
  }
}
