/// 安全存储 Web 实现 - 使用 shared_preferences
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> read({required String key}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> write({required String key, required String value}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> delete({required String key}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
