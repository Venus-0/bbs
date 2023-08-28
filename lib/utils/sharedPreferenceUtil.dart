import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static const String COOKIE = 'cookie';

  static Future<String> getCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _cookie = await prefs.getString(COOKIE);
    return _cookie ?? '';
  }

  static Future<bool> setCookie(String cookie) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(COOKIE, cookie);
  }

  static Future<bool> set(String key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is String) {
      return prefs.setString(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else {
      return false;
    }
  }

  static Future<dynamic> get(String key, {defaultValue}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static Future<bool> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
