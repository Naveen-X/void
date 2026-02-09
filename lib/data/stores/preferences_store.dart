import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStore {
  static const String _keyOnboardingComplete = 'onboarding_complete';
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
  
  static Future<void> clear() async {
      await _prefs?.clear();
  }
}
