// import 'package:shared_preferences/shared_preferences.dart';

// class PreferenceHelper {
//   static const String _onboardingCompleted = 'onboarding_completed';

//   static Future<void> setOnboardingCompleted(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_onboardingCompleted, value);
//   }

//   static Future<bool> isOnboardingCompleted() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_onboardingCompleted) ?? false;
//   }

//   static Future<void> clearAll() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }