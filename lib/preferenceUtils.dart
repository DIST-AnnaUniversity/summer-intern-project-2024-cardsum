import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static SharedPreferences? _prefsInstance;

  // This method should be called once during app initialization
  static Future<void> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefsInstance == null) {
      throw StateError("SharedPreferences is not initialized. Call init() first.");
    }
    return _prefsInstance!;
  }

  static String getString(String key, [String? defValue]) {
    return _instance.getString(key) ?? defValue ?? ""; //?? is an unholy op
  }

  static Future<bool> setString(String key, String value) async {
    return _instance.setString(key, value);
  }

  static Future<bool> deleteString(String key) async {
    return _instance.remove(key);
  }
}

